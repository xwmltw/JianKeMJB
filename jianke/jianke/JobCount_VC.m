//
//  JobCount_VC.m
//  jianke
//
//  Created by 时现 on 15/11/5.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "JobCount_VC.h"
#import "JobCountCell.h"
#import "MJRefresh.h"
#import "UserData.h"
#import "UIHelper.h"
#import "JobModel.h"
#import "JobDetail_VC.h"

@interface JobCount_VC ()<UITableViewDelegate,UITableViewDataSource>
{
    JobModel *_model;
}

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) QueryParamModel *queryParam;
@property (nonatomic, strong) NSMutableArray *jobCountArray;

@end

@implementation JobCount_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"正在招人";
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 74;
    self.tableView = tableView;
    [self.tableView registerNib:[UINib nibWithNibName:@"JobCountCell" bundle:nil] forCellReuseIdentifier:@"JobCountCell"];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];

    [self setupUI];
    [self.tableView.header beginRefreshing];

}
- (void)setupUI{
    
    [self initWithNoDataViewWithStr:@"您当前还没有岗位" onView:self.tableView];
    
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
    
    NSString *content = [NSString stringWithFormat:@"\"ent_id\":%@,\"query_type\":%d, %@",self.enterprise_id,1, [self.queryParam getContent]];
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_getEnterpriseSelfJobList_v2" andContent:content];
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (response && response.success) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            weakSelf.viewWithNoData.hidden = YES;
            
            weakSelf.jobCountArray = [NSMutableArray arrayWithArray:[JobModel objectArrayWithKeyValuesArray:response.content[@"job_list"]]];
            if (weakSelf.jobCountArray && weakSelf.jobCountArray.count) {
                NSMutableArray *array = [NSMutableArray arrayWithArray:self.jobCountArray];
                for (JobModel *model in weakSelf.jobCountArray) {
                    if (model.status.intValue != 2) {
                        [array removeObject:model];
                        
                    }
                }
                weakSelf.jobCountArray = array;
            }

            if (!weakSelf.jobCountArray.count || weakSelf.jobCountArray.count == 0) {
                weakSelf.viewWithNoData.hidden = NO;
            }
            [weakSelf.tableView reloadData];
        }else{
            weakSelf.jobCountArray = nil;
            weakSelf.viewWithNoNetwork.hidden = NO;
            weakSelf.viewWithNoData.hidden = YES;
            [weakSelf.tableView reloadData];
        }
        [weakSelf.tableView.header endRefreshing];
        
    }];
}

- (void)getMore{
    self.queryParam.page_num = @(self.queryParam.page_num.integerValue + 1);
    self.queryParam.timestamp = @([[NSDate date]timeIntervalSince1970] * 1000);
    
    NSString *content = [NSString stringWithFormat:@"\"ent_id\":%@,\"query_type\":%d, %@",self.enterprise_id,1, [self.queryParam getContent]];
    
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_getEnterpriseSelfJobList_v2" andContent:content];
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (!response) {
            weakSelf.jobCountArray = nil;
            weakSelf.viewWithNoNetwork.hidden = NO;
            weakSelf.viewWithNoData.hidden = YES;
        }
        
        if (response && response.success) {
            weakSelf.viewWithNoData.hidden = YES;
            weakSelf.viewWithNoNetwork.hidden = YES;
            
            NSArray *newArray = [JobModel objectArrayWithKeyValuesArray:response.content[@"job_list"]];
            if (!newArray || newArray.count == 0) {
                [weakSelf.tableView.footer endRefreshing];
                return ;
            }
            [weakSelf.jobCountArray addObjectsFromArray:newArray];
            weakSelf.jobCountArray = [NSMutableArray arrayWithArray:[JobModel objectArrayWithKeyValuesArray:response.content[@"job_list"]]];
            weakSelf.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.header endRefreshing];
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -  table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.jobCountArray) {
        return self.jobCountArray.count;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JobCountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JobCountCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    _model = self.jobCountArray[indexPath.row];
    [cell refreshWithData:_model];
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}
- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([[UserData sharedInstance]getLoginType].integerValue == WDLoginType_JianKe) {
        JobDetail_VC* vc = [[JobDetail_VC alloc] init];
        JobModel *modelSelect;
        modelSelect = self.jobCountArray[indexPath.row];
        vc.jobId = [NSString stringWithFormat:@"%@",modelSelect.job_id];
        vc.userType = WDLoginType_JianKe;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if ([[UserData sharedInstance]getLoginType].integerValue == WDLoginType_Employer) {
        JobDetail_VC* vc = [[JobDetail_VC alloc] init];
        JobModel *modelSelect;
        modelSelect = self.jobCountArray[indexPath.row];
        vc.jobId = [NSString stringWithFormat:@"%@",modelSelect.job_id];
        vc.userType = WDLoginType_Employer;
        [self.navigationController pushViewController:vc animated:YES];
    }
 
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
