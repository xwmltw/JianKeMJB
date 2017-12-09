//
//  BDManagerTableView.m
//  jianke
//
//  Created by xiaomk on 16/6/27.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "BDManagerTableView.h"
#import "XSJConst.h"
#import "JobModel.h"
#import "InvitingForJobCell.h"
#import "JobDetail_VC.h"
#import "JiankeManage_VC.h"
#import "ApplyJKController.h"

@interface BDManagerTableView ()<UITableViewDelegate, UITableViewDataSource,InvitingForJobDelegate>{
    BOOL _isGetLast;
    NSMutableArray  *_arrayDataInvite;
    NSMutableArray  *_arrayDataHistory;
    NSMutableArray *_allDataArray;
    
    QueryParamModel *_queryParam;
    NSNumber *_jobHistoryNum;

}

@property (nonatomic, strong) UIView *viewWithNoData;
@property (nonatomic, strong) UIView *viewWithNoNetwork;

@end

@implementation BDManagerTableView

- (instancetype)init{
    self = [super init];
    if (self) {
        _isGetLast = YES;
        _arrayDataInvite = [[NSMutableArray alloc] init];
        _arrayDataHistory = [[NSMutableArray alloc] init];
        _allDataArray = [[NSMutableArray alloc] init];
        _jobHistoryNum = @(0);

    }
    return self;
}

- (void)setTableView:(UITableView *)tableView{
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getLastDataList)];
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreDataList)];
    [self initWithNoDataViewWithStr:@"您还没有任何包招岗位" onView:self.tableView];

}

- (void)initWithNoDataViewWithStr:(NSString*)str onView:(UIView*)view{
    NSString* labStr;
    if (![[UserData sharedInstance] isLogin]) {
        labStr = @"您还没有登录唷";
    }else{
        if (str) {
            labStr = str;
        }
    }

    self.viewWithNoData = [UIHelper noDataViewWithTitle:labStr titleColor:nil image:@"v3_home_ep_nodata"];
    [view addSubview:self.viewWithNoData];
    self.viewWithNoData.frame = CGRectMake(0, 80, self.viewWithNoData.size.width, self.viewWithNoData.size.height);
    self.viewWithNoData.hidden = YES;
    
    //无信号
    self.viewWithNoNetwork = [UIHelper noDataViewWithTitle:@"啊噢,网络不见了" image:@"v3_public_nowifi"];
    [view addSubview:self.viewWithNoNetwork];
    self.viewWithNoNetwork.frame = CGRectMake(0, 80, self.viewWithNoNetwork.size.width, self.viewWithNoNetwork.size.height);
    self.viewWithNoNetwork.hidden = YES;
}


- (void)setNoDataViewText:(NSString*)text{
    if (self.viewWithNoData) {
        UILabel* lab = (UILabel*)[self.viewWithNoData viewWithTag:666];
        lab.text = text;
    }
}

- (void)reloadTableView{
    [self.tableView reloadData];
}

#pragma mark - 获取岗位数据 业务逻辑
- (void)getLastData{
    [self.tableView.header beginRefreshing];
}

//下拉 刷新
- (void)getLastDataList{
    if ([[UserData sharedInstance] isLogin]) {
        _isGetLast = YES;
        [self getJobListForBD];
    }else{
        [self.tableView.header endRefreshing];
    }
}

//上拉刷新
- (void)getMoreDataList{
    _isGetLast = NO;
    [self getJobListForBD];
}

- (void)getJobListForBD{
    NSString* content;
    GetEnterpriscJobModel *reqModel = [[GetEnterpriscJobModel alloc] init];
    reqModel.query_type = @(1);
    
    if (_isGetLast) {
        _queryParam = nil;
        content = [reqModel getContent];
    }else{
        if (_queryParam) {
            _queryParam.page_num = @(_queryParam.page_num.integerValue + 1);
            reqModel.query_param = _queryParam;
        }
        content = [reqModel getContent];
    }
    
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_bdQueryJobList" andContent:content];
    [self getJobListWithRequest:request];
}

- (void)getJobListWithRequest:(RequestInfo *)request{
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        
        if (response && [response success]) {
            weakSelf.viewWithNoData.hidden = YES;
            weakSelf.viewWithNoNetwork.hidden = YES;
            
            if (![[UserData sharedInstance] isLogin]) {
                weakSelf.tableView.footer.hidden = YES;
                weakSelf.viewWithNoData.hidden = NO;
                [_arrayDataInvite removeAllObjects];
                [_arrayDataHistory removeAllObjects];
                [_allDataArray removeAllObjects];
                _queryParam = nil;
                [weakSelf setNoDataViewText:@"您还没有登录唷"];
            }else{
                _jobHistoryNum = response.content[@"history_job_list_count"];

                NSArray *dataList = [JobModel objectArrayWithKeyValuesArray:response.content[@"job_list"]];

                if (_isGetLast) {
                    [_arrayDataInvite removeAllObjects];
                    [_arrayDataHistory removeAllObjects];
                    [_allDataArray removeAllObjects];
                    _queryParam = nil;
                }
                
                if (dataList && dataList.count > 0) {
                    _queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];

                    for (JobModel* model in dataList) {
                        if (model.status.intValue == 1 || model.status.intValue == 2) {
                            [_arrayDataInvite addObject:model];
                        }else if (model.status.intValue == 3){
                            [_arrayDataHistory addObject:model];
                        }
                    }
                }else{  //无数据
                    if (_isGetLast) {
                        [weakSelf.tableView.footer endRefreshing];
                        [weakSelf.tableView.header endRefreshing];
                        return ;
                    }else{
                        _queryParam.page_num = @(_queryParam.page_num.integerValue-1);
                        weakSelf.tableView.footer.state = MJRefreshStateNoMoreData;
                        return;
                    }
                }
                
                [_allDataArray removeAllObjects];
                [_allDataArray addObjectsFromArray:_arrayDataInvite];
                [_allDataArray addObjectsFromArray:_arrayDataHistory];
                if (_allDataArray.count == 0) {
                    weakSelf.viewWithNoData.hidden = NO;
                    [weakSelf setNoDataViewText:@"您还没有任何包招岗位"];
                }
            }
        }else{
            weakSelf.viewWithNoNetwork.hidden = YES;
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.footer endRefreshing];
        [weakSelf.tableView.header endRefreshing];
    }];
}

#pragma mark - ***** tableView delegate ******
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InvitingForJobCell* cell = [InvitingForJobCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.managerType = self.managerType;
    
    if (_allDataArray.count <= indexPath.section) {
        return cell;
    }
    JobModel* model = _allDataArray[indexPath.section];
    [cell refreshWithData:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ELog(@"=========didSelectRowAtIndexPath:%ld",(long)indexPath.section);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JobModel* model = _allDataArray[indexPath.section];
    
    if (model.status.intValue == 1 || model.job_close_reason.integerValue == 3 || model.job_close_reason.integerValue == 4) {
        DLog(@"跳转到岗位详情");
        JobDetail_VC* vc = [[JobDetail_VC alloc] init];
        vc.jobId = model.job_id.description;
        [self.owner.navigationController pushViewController:vc animated:YES];
    } else {
        ELog(@"跳转到兼客管理");
        
        JiankeManage_VC *vc = [[JiankeManage_VC alloc] init];
        vc.jobId = model.job_id.stringValue;
        vc.isAccurateJob = model.is_accurate_job;
        vc.managerType = self.managerType;
        vc.jobModel = model;
        vc.hidesBottomBarWhenPushed = YES;
        [self.owner.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allDataArray.count ? _allDataArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_arrayDataInvite.count > 0 && indexPath.section < _arrayDataInvite.count) {
        return 150;
    }else if (indexPath.section >= _arrayDataInvite.count) {
        return 104;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_arrayDataHistory && _arrayDataHistory.count > 0 && section == _arrayDataInvite.count) {
        return 44;
    }
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_arrayDataHistory && _arrayDataHistory.count > 0 && section == _arrayDataInvite.count) {
        NSString *historyBtnTitle = [NSString stringWithFormat:@"历史记录(%@)",_jobHistoryNum];
        
        UIButton *headBtn = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120) * 0.5, 6, 120, 32)];
        headBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [headBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [headBtn setTitle:historyBtnTitle forState:UIControlStateNormal];
        [headBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [headBtn setImage:[UIImage imageNamed:@"v3_public_history"] forState:UIControlStateNormal];
        headBtn.userInteractionEnabled = NO;
        
        UIView *sectionHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        sectionHeadView.backgroundColor = [UIColor clearColor];
        [sectionHeadView addSubview:headBtn];
        return sectionHeadView;
    }
    return nil;
}

//选择cell 跳转到岗位详情
- (void)cell_didSelectRowAtIndex:(JobModel*)model{
    ELog(@"1======index:%@",model.job_title);
    ELog(@"跳转到岗位详情");
    JobDetail_VC* vc = [[JobDetail_VC alloc] init];
    vc.jobId = model.job_id.description;
    vc.isAccurateJob = model.is_accurate_job;
    [self.owner.navigationController pushViewController:vc animated:YES];
}

- (void)cell_btnBotOnClick:(JobModel *)model{
    ApplyJKController *applyVC = [[ApplyJKController alloc] init];
    applyVC.jobId = model.job_id.stringValue;
    applyVC.isAccurateJob = model.is_accurate_job;
    applyVC.managerType = self.managerType;
    [self.owner.navigationController pushViewController:applyVC animated:YES];
}


@end


