//
//  ReportRecord_VC.m
//  jianke
//
//  Created by 时现 on 15/10/27.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "ReportRecord_VC.h"
#import "MJRefresh.h"
#import "UserData.h"
#import "UIHelper.h"
#import "ReportRecordCell.h"
#import "ReportRecordModel.h"
#import "CityTool.h"
#import "Masonry.h"

@interface ReportRecord_VC ()<UITableViewDataSource,UITableViewDelegate,ReportRecordModelDelegate>{
    NSInteger _nextPageNum;
}

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) QueryParamModel *queryParam;
@property (nonatomic, strong) NSMutableArray *ReportRecordArray;


@end

@implementation ReportRecord_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"签到记录";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 64;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView = tableView;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ReportRecordCell" bundle:nil] forCellReuseIdentifier:@"ReportRecordCell"];
    self.tableView.allowsSelection = NO;
    [self makeConstraint];
    
    [self setupUI];
    // 获取数据
    [self.tableView.header beginRefreshing];
}

-(void)setupUI{
    
    [self initWithNoDataViewWithStr:@"您当前还没有打卡信息" onView:self.tableView];
    
    //上下拉刷新
    [self.tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)]];
    [self.tableView setFooter:[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMore)]];
}

- (void)makeConstraint{
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}

#pragma mark - 服务器交互
//获取数据
-(void)getData{
    self.queryParam = [[QueryParamModel alloc] init];
    self.queryParam.timestamp = @((long)([[NSDate date] timeIntervalSince1970] * 1000));
   
    NSString *content = [NSString stringWithFormat:@"\"punch_the_clock_request_id\":%@, %@",self.punch_the_clock_request_id, [self.queryParam getContent]];
    WEAKSELF
    [[UserData sharedInstance] entQueryStuPunchTheClockRecord:content block:^(ResponseInfo *response) {
        if (response && response.success) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            weakSelf.viewWithNoData.hidden = YES;
            weakSelf.ReportRecordArray = [NSMutableArray arrayWithArray:[ReportRecordModel objectArrayWithKeyValuesArray:response.content[@"punch_the_clock_list"]]];
            if (weakSelf.ReportRecordArray && weakSelf.ReportRecordArray.count) {
                _nextPageNum = 2;
            }
        }else{
            weakSelf.ReportRecordArray = nil;
            weakSelf.viewWithNoNetwork.hidden = NO;
            weakSelf.viewWithNoData.hidden = YES;
        }
        [weakSelf.tableView reloadData];
        [self.tableView.header endRefreshing];
    }];

}
//获取更多数据
- (void)getMore{
    if (_nextPageNum <= 1) {
        [self.tableView.footer endRefreshing];
        return;
    }
    self.queryParam.page_num = @(_nextPageNum);
    self.queryParam.timestamp = @([[NSDate date]timeIntervalSince1970] * 1000);
    
    NSString *content = [NSString stringWithFormat:@"\"punch_the_clock_request_id\":%@, %@",self.punch_the_clock_request_id, [self.queryParam getContent]];
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_entQueryStuPunchTheClockRecord" andContent:content];
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        
        if (response && response.success) {
            NSArray *newArray = [ReportRecordModel objectArrayWithKeyValuesArray:response.content[@"punch_the_clock_list"]];
            if (newArray && newArray.count) {
                weakSelf.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
                _nextPageNum = weakSelf.queryParam.page_num.integerValue + 1;
                [weakSelf.ReportRecordArray addObjectsFromArray:newArray];
                [weakSelf.tableView reloadData];
            }
        }
        [weakSelf.tableView.footer endRefreshing];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.ReportRecordArray ? self.ReportRecordArray.count : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ReportRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportRecordCell"];
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    ReportRecordModel *reportRecordModel = self.ReportRecordArray[indexPath.row];
    cell.reportRecordModel = reportRecordModel;
    
    return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

#pragma mark - ReportRecordCell delegate

- (void)manualPunch:(ReportRecordModel *)reportRecordModel{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970]*1000;
    [UIHelper showLoading:YES withMessage:@"打卡中"];
    WEAKSELF
    [CityTool getLocalWithBlock:^(LocalModel *result) {
        [[UserData sharedInstance] stuPunchTheClockWithJobId:reportRecordModel.apply_job_id punchId:weakSelf.punch_the_clock_request_id punchTime:[NSString stringWithFormat:@"%f",interval] punchLat:result.latitude punchLng:result.longitude punchLocation:result.subAddress block:^(ResponseInfo *result1) {
            [UIHelper showLoading:NO withMessage:nil];
            if (result1.success) {
                [weakSelf getData];
            }
        }];
    }];
    
}

@end
