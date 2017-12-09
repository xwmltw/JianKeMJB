//
//  JobComplaint_VC.m
//  jianke
//
//  Created by 时现 on 15/11/6.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "JobComplaint_VC.h"
#import "JobComplaintCell.h"
#import "JobModel.h"
#import "UserData.h"
#import "MJRefresh.h"


@interface JobComplaint_VC ()<UITableViewDataSource,UITableViewDelegate>
{
    JobModel *_model;
}
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, strong) QueryParamModel *queryParam;
@property (nonatomic, strong) NSMutableArray *jobComplaintArray;

@end

@implementation JobComplaint_VC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.title = @"被投诉岗位";
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [self.tableView registerNib:[UINib nibWithNibName:@"JobComplaintCell" bundle:nil] forCellReuseIdentifier:@"JobComplaintCell"];
    [self setupUI];
    [self.tableView.header beginRefreshing];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];


}
- (void)setupUI{
    
    [self initWithNoDataViewWithStr:@"您当前没有被投诉岗位" onView:self.tableView];
    
    //上下拉刷新
    [self.tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)]];
    [self.tableView setFooter:[MJRefreshBackFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMore)]];
    self.tableView.footer.hidden = YES;
    //    self.tableView.header.hidden = YES;
    
    
}
- (void)getData{
    self.queryParam = [[QueryParamModel alloc] init];
    self.queryParam.page_num = @(1);
    self.queryParam.page_size = @(30);
    self.queryParam.timestamp = @((long)([[NSDate date] timeIntervalSince1970] * 1000));
    
//    NSString *content = [NSString stringWithFormat:@"\"query_type\":%d, %@",3, [self.queryParam getContent]];

    NSString *content = [NSString stringWithFormat:@"\"ent_id\":%@,\"query_type\":%d, %@",self.entID,3, [self.queryParam getContent]];
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_getEnterpriseSelfJobList_v2" andContent:content];
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (response) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            weakSelf.jobComplaintArray = [NSMutableArray arrayWithArray:[JobModel objectArrayWithKeyValuesArray:response.content[@"job_list"]]];
            
            if (weakSelf.jobComplaintArray.count < 1) {
                weakSelf.viewWithNoData.hidden = NO;
            }
            [weakSelf.tableView reloadData];
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
            weakSelf.viewWithNoData.hidden = YES;
            weakSelf.jobComplaintArray = nil;
            [weakSelf.tableView reloadData];
        }
        [weakSelf.tableView.header endRefreshing];
    }];

}
- (void)getMore{
    self.queryParam.page_num = @(self.queryParam.page_num.integerValue + 1);
    self.queryParam.timestamp = @([[NSDate date]timeIntervalSince1970] * 1000);
    NSString *content = [NSString stringWithFormat:@"\"ent_id\":%@,\"query_type\":%d, %@",self.entID,3, [self.queryParam getContent]];
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_getEnterpriseSelfJobList_v2" andContent:content];
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        
        if (response) {
            weakSelf.viewWithNoData.hidden = YES;
            weakSelf.viewWithNoNetwork.hidden = YES;
            
            NSArray *newArray = [JobModel objectArrayWithKeyValuesArray:response.content[@"job_list"]];
            if (!newArray || newArray.count == 0) {
                [weakSelf.tableView.footer endRefreshing];
                return;
            }
            [weakSelf.jobComplaintArray addObjectsFromArray:newArray];
            weakSelf.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
            
            [weakSelf.tableView reloadData];
        }else{
            weakSelf.jobComplaintArray = nil;
            weakSelf.viewWithNoNetwork.hidden = NO;
            weakSelf.viewWithNoData.hidden = YES;
            [weakSelf.tableView reloadData];
        }
        [weakSelf.tableView.header endRefreshing];
        
    }];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.jobComplaintArray) {
        return self.jobComplaintArray.count;
    }
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JobComplaintCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JobComplaintCell"];
    _model = self.jobComplaintArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell refreshWithData:_model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
