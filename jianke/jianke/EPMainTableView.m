//
//  EPMainTableView.m
//  jianke
//
//  Created by xiaomk on 15/11/19.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "EPMainTableView.h"
#import "JobModel.h"
#import "InvitingForJobCell.h"
#import "CompleteForJobCell.h"
#import "JobDetail_VC.h"
#import "ShareHelper.h"
#import "QrCodeViewController.h"
#import "RefreshLeftCountModel.h"
#import "LookupApplyJKListController.h"
#import "ShareToGroupController.h"
#import "CityTool.h"
#import "ScrollNewsView.h"
#import "JKNewsModel.h"
#import "NewsBtn.h"
#import "WebView_VC.h"
#import "JKHomeModel.h"
#import "XSJRequestHelper.h"
#import "UIView+MKException.h"
#import "ApplyJKController.h"
#import "JiankeCollection_VC.h"
#import "JianKeAppreciation_VC.h"

@interface EPMainTableView()<UITableViewDelegate, UITableViewDataSource, InvitingForJobDelegate, ScrollNewsViewDelegate>{
    
    BOOL _isGetLast;
    BOOL _isGetHistory;
    NSMutableArray  *_arrayDataInvite;
    NSMutableArray  *_allDataArray;

    QueryParamModel *_queryParam;
    NSNumber *_jobHistoryNum;
    BOOL _isHirtory;
}

@property (nonatomic, strong) UIView *viewWithNoData;
@property (nonatomic, strong) UIView *viewWithNoNetwork;

@end

@implementation EPMainTableView


- (instancetype)init{
    if (self = [super init]) {
        _isGetLast = YES;
        _arrayDataInvite = [[NSMutableArray alloc] init];
        _allDataArray = [[NSMutableArray alloc] init];
        _jobHistoryNum = @(0);
    }
    return self;
}

- (void)setTableView:(UITableView *)tableView{
    _tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.estimatedRowHeight = 150;
    _tableView.tableFooterView = [UIView new];
//    _tableView.contentInset = UIEdgeInsetsMake(-35, 0, 0, 0);

    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getLastDataList)];
//    self.tableView.header.ignoredScrollViewContentInsetTop = -35;
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreDataList)];

    [self initWithNoDataViewWithStr:@"请点击右上角 “+” 开始发布" onView:self.tableView];

    // 设置雇主头条
    [self setupEPNewsView];
}

- (void)setupEPNewsView{
    WEAKSELF
    [[XSJRequestHelper sharedInstance] getClientGlobalInfoWithBlock:^(ClientGlobalInfoRM* result) {
        if (result && result.ent_head_line_ad_list && result.ent_head_line_ad_list.count > 0) {
            NSArray *newsModelArray = [AdModel objectArrayWithKeyValuesArray:result.ent_head_line_ad_list];
            if (newsModelArray.count) {
                AdModel *model = newsModelArray.firstObject;
                if ([[UserData sharedInstance] getEpHideNewsViewStateWithAdId:model.ad_id]) { // 不显示
                    return;
                }
                ScrollNewsView *newsView = [[ScrollNewsView alloc] initWithNewsModelArray:newsModelArray size:CGSizeMake(SCREEN_WIDTH, 50)];
                newsView.delegate = weakSelf;
                weakSelf.tableView.tableHeaderView = newsView;
            }
        }
    }];
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
    //    [self initWithNoDataViewWithStr:@"请点击右上角 “+” 开始发布" labColor:nil imgName:@"v3_home_ep_nodata" onView:self.tableView];
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
//    [self.tableView.header beginRefreshing];
    [self getLastDataList];
}

/** 加载历史数据 */
- (void)historyClick{
    [self.tableView.footer beginRefreshing];
}

//下拉 刷新
- (void)getLastDataList{
    if ([[UserData sharedInstance] isLogin]) {
        _isGetLast = YES;
        [self getJobListForEP];

    }else{
        [self.tableView.header endRefreshing];
    }
}

//上拉刷新
- (void)getMoreDataList{
//    _isGetLast = NO;
//    [self getJobListForEP];
    [self getJobListForEPHistory];
}

- (void)getJobListForEPHistory{
    NSString* content;
    GetEnterpriscJobModel *reqModel = [[GetEnterpriscJobModel alloc] init];
    reqModel.query_type = @(5);
    reqModel.in_history = @(1);
    if (!_queryParam) {
        _queryParam = [[QueryParamModel alloc] init];
    }
    reqModel.query_param = _queryParam;
    content = [reqModel getContent];
    
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_getEnterpriseSelfJobList_v2" andContent:content];
    [self getJobListWithRequest2:request];
}

- (void)getJobListForEP{
    NSString* content;
    GetEnterpriscJobModel *reqModel = [[GetEnterpriscJobModel alloc] init];
    reqModel.query_type = @(5);
    
    if (_isGetLast) {
        _queryParam = nil;
        reqModel.in_history = @(0);
        content = [reqModel getContent];
    }

    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_getEnterpriseSelfJobList_v2" andContent:content];
    [self getJobListWithRequest:request];
}


- (void)getJobListWithRequest:(RequestInfo *)request{
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        [weakSelf.tableView.header endRefreshing];
        
        if (response && [response success]) {
            weakSelf.viewWithNoData.hidden = YES;
            weakSelf.viewWithNoNetwork.hidden = YES;
            
            if (![[UserData sharedInstance] isLogin]) {
                weakSelf.tableView.footer.hidden = YES;
                weakSelf.viewWithNoData.hidden = NO;
                [_arrayDataInvite removeAllObjects];
                [_allDataArray removeAllObjects];
                [weakSelf setNoDataViewText:@"您还没有登录唷"];
                [weakSelf.tableView reloadData];
                return ;
            }else{
                _jobHistoryNum = response.content[@"history_job_list_count"];
                
                NSArray *dataList = [JobModel objectArrayWithKeyValuesArray:response.content[@"job_list"]];

                    [_allDataArray removeObjectsInArray:_arrayDataInvite];
                    [_arrayDataInvite removeAllObjects];
                    _queryParam = nil;
                
                
                if (dataList && dataList.count > 0) {   //有数据
                    [_allDataArray removeAllObjects];
                    [_arrayDataInvite addObjectsFromArray:dataList];
                    [_allDataArray addObjectsFromArray:dataList];
                    [weakSelf.tableView reloadData];
                }else{                                  //无数据
                    [weakSelf.tableView reloadData];
                    [weakSelf.tableView.footer endRefreshing];
                    [weakSelf getMoreDataList];
                    return ;
                }
                
            }
        }else{
            weakSelf.viewWithNoNetwork.hidden = YES;
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.footer endRefreshing];
    }];
}


- (void)getJobListWithRequest2:(RequestInfo *)request{
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        [weakSelf.tableView.header endRefreshing];
        
        if (response && [response success]) {
            weakSelf.viewWithNoData.hidden = YES;
            weakSelf.viewWithNoNetwork.hidden = YES;
            
            if (![[UserData sharedInstance] isLogin]) {
                weakSelf.tableView.footer.hidden = YES;
                weakSelf.viewWithNoData.hidden = NO;
                [_arrayDataInvite removeAllObjects];
                [_allDataArray removeAllObjects];
                [weakSelf setNoDataViewText:@"您还没有登录唷"];
                [weakSelf.tableView reloadData];
                return ;
            }else{
                _jobHistoryNum = response.content[@"history_job_list_count"];
                
                NSArray *dataList = [JobModel objectArrayWithKeyValuesArray:response.content[@"job_list"]];
                _queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
                if (dataList && dataList.count > 0) {   //有数据
                    if (_allDataArray.count > _arrayDataInvite.count && _queryParam.page_num.integerValue == 1) {
                        [_arrayDataInvite removeAllObjects];
                        [_allDataArray removeAllObjects];
                    }
                        _queryParam.page_num = @(_queryParam.page_num.integerValue+1);
                        [_allDataArray addObjectsFromArray:dataList];
                }else{                                  //无数据

                    _queryParam.page_num = @(_queryParam.page_num.integerValue-1);
                        
                    weakSelf.tableView.footer.state = MJRefreshStateNoMoreData;
                    if (_allDataArray.count == 0) {
                        weakSelf.viewWithNoData.hidden = NO;
                        [weakSelf setNoDataViewText:@"请点击右上角 “+” 开始发布"];
                        return;
                    }
                }
                
            }
        }else{
            weakSelf.viewWithNoNetwork.hidden = YES;
        }
        [weakSelf.tableView reloadData];
        [weakSelf.tableView.footer endRefreshing];
    }];
}

#pragma mark - tableView delegate
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allDataArray.count ? _allDataArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_arrayDataInvite.count > 0 && indexPath.section < _arrayDataInvite.count) {
        return 176;
    }else if (indexPath.section >= _arrayDataInvite.count) {
        return 130;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    
    if ( _allDataArray.count > _arrayDataInvite.count && section == _arrayDataInvite.count) {
        return 44;
    }
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_arrayDataInvite.count > 0 && _arrayDataInvite.count == _allDataArray.count && section == _arrayDataInvite.count-1) {
        return 44;
    }
    return 0.1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if ( _allDataArray.count > _arrayDataInvite.count && section == _arrayDataInvite.count) {
        UIView *sectionHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        sectionHeadView.backgroundColor = [UIColor XSJColor_grayTinge];
        
        NSString *historyBtnTitle = [NSString stringWithFormat:@"历史记录(%@)",_jobHistoryNum];
        
        UIButton *headBtn = [[UIButton alloc] init];
        headBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [headBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [headBtn setTitle:historyBtnTitle forState:UIControlStateNormal];
        [headBtn setTitleColor:[UIColor XSJColor_tGrayTinge] forState:UIControlStateNormal];
        [headBtn setImage:[UIImage imageNamed:@"v3_public_history"] forState:UIControlStateNormal];
        headBtn.userInteractionEnabled = NO;
        [sectionHeadView addSubview:headBtn];
        headBtn.backgroundColor = [UIColor clearColor];
        
        [headBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(sectionHeadView);
            make.width.mas_equalTo(140);
        }];
       
        return sectionHeadView;
    }else{
        UIView *sectionHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 12)];
        sectionHeadView.backgroundColor = [UIColor XSJColor_grayTinge];
        return sectionHeadView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_arrayDataInvite.count > 0 && _arrayDataInvite.count == _allDataArray.count && section == _arrayDataInvite.count-1) {
        
        UIView *sectionHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        sectionHeadView.backgroundColor = [UIColor XSJColor_grayTinge];
        
        NSString *historyBtnTitle = [NSString stringWithFormat:@"历史记录(%@)",_jobHistoryNum];

        UIButton *headBtn = [[UIButton alloc] init];
        headBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [headBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [headBtn setBackgroundImage:[UIImage imageNamed:@"info_rectbg"] forState:UIControlStateNormal];
        [headBtn setImage:[UIImage imageNamed:@"v3_public_history_white"] forState:UIControlStateNormal];
        [headBtn setImage:[UIImage imageNamed:@"v3_public_history_white"] forState:UIControlStateHighlighted];
        [headBtn setTitle:historyBtnTitle forState:UIControlStateNormal];
        [headBtn addTarget:self action:@selector(historyClick) forControlEvents:UIControlEventTouchUpInside];
        headBtn.userInteractionEnabled = YES;
        [sectionHeadView addSubview:headBtn];
        headBtn.backgroundColor = [UIColor clearColor];

        [headBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(sectionHeadView);
            make.width.mas_equalTo(140);
        }];
       
        return sectionHeadView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ELog(@"=========didSelectRowAtIndexPath:%ld",(long)indexPath.row);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    JobModel* model = _allDataArray[indexPath.section];
    if (model.status.intValue == 1 || model.job_close_reason.integerValue == 3 || model.job_close_reason.integerValue == 4) {
        JobDetail_VC* vc = [[JobDetail_VC alloc] init];
        vc.jobId = model.job_id.description;
        vc.hidesBottomBarWhenPushed = YES;
        [self.owner.navigationController pushViewController:vc animated:YES];
    } else {
        ELog(@"跳转到兼客管理");
        
        JiankeCollection_VC *vc = [[JiankeCollection_VC alloc] init];
        vc.jobId = model.job_id.stringValue;
        vc.isAccurateJob = model.is_accurate_job;
        vc.managerType = self.managerType;
        vc.jobModel = model;
        vc.isClose = model.status.integerValue == 3;
        vc.hidesBottomBarWhenPushed = YES;
        [self.owner.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - 正在招人  业务逻辑
//选择cell 跳转到岗位详情
//- (void)cell_didSelectRowAtIndex:(JobModel*)model{
//    ELog(@"1======index:%@",model.job_title);
//    ELog(@"跳转到岗位详情");
//    JobDetail_VC* vc = [[JobDetail_VC alloc] init];
//    vc.jobId = model.job_id.description;
//    vc.isAccurateJob = model.is_accurate_job;
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.owner.navigationController pushViewController:vc animated:YES];
//}

- (void)cell_btnBotOnClick:(JobModel *)model{
//    [MKActionSheet sheetWithTitle:nil buttonTitleArray:@[@"分享", @"刷新", @"推送人才库", @"结束招聘"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
//        switch (buttonIndex) {
//            case 0:{    //分享
//                [self share:model];
//            }
//                break;
//            case 1:{    //刷新岗位
//                [self refreshJob:model];
//            }
//                break;
//            case 2:{    //人才库
//                [[UserData sharedInstance] entShareJobToTalentPoolWithJobId:model.job_id.stringValue];
//            }
//                break;
//            case 3:{    //结束招聘
//                [self closeJob:model];
//            }
//                break;
//            default:
//                break;
//        }
//    }];
    
    
    [MKActionSheet sheetWithTitle:nil buttonTitleArray:@[@"分享", @"置顶", @"刷新", @"推送", @"结束招聘"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0:{    //分享
                [self share:model];
            }
                break;
            case 1:{    //置顶
                ELog(@"进入置顶");
                if (model.stick.integerValue == 0) {
                    [self pushAppreciteVC:Appreciation_stick_Type jobId:model.job_id];
                }else{
                    [UIHelper toast:@"岗位已处于置顶状态"];
                }
                
            }
                break;
            case 2:{    //刷新岗位
                ELog(@"进入刷新");
                [self pushAppreciteVC:Appreciation_Refresh_Type jobId:model.job_id];
            }
                break;
            case 3:{    //人才库
                ELog(@"推送");
                [self pushAppreciteVC:Appreciation_push_Type jobId:model.job_id];
            }
                break;
            case 4:{    //结束招聘
                [self closeJob:model];
            }
                break;
            default:
                break;
        }
    }];
}


#pragma mark - ScrollNewsViewDelegate
- (void)scrollNewsViewCloseBtnClick:(ScrollNewsView *)aScrollNewsView{
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
}

- (void)scrollNewsView:(ScrollNewsView *)aScrollNewsView btnClickWithAdModel:(AdModel *)model{
    DLog(@"NewsViewDelegate - 雇主头条新闻点击");
    DLog(@"%@", model.ad_name);
    [[XSJRequestHelper sharedInstance] queryAdClickLogRecordWithADId:model.ad_id];

    switch (model.ad_type.integerValue) {
        case 1: // 应用内打开
        {
            if (!model.ad_detail_url || model.ad_detail_url.length < 5) {
                return;
            }
            NSString *url = [model.ad_detail_url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            WebView_VC* vc = [[WebView_VC alloc] init];
            vc.url = url;
            vc.hidesBottomBarWhenPushed = YES;
            [self.owner.navigationController pushViewController:vc animated:YES];
            
        }
            break;
            
        case 2: // 岗位广告
        {
            if (model.ad_detail_id == nil || model.ad_detail_id.intValue == 0) {
                return;
            }
            //进入岗位详情
            JobDetail_VC* vc = [[JobDetail_VC alloc] init];
            vc.jobId = [NSString stringWithFormat:@"%@",model.ad_detail_id];
            vc.hidesBottomBarWhenPushed = YES;
            [self.owner.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case 3: // 浏览器打开链接
        {
            if (model.ad_detail_url == nil || model.ad_detail_url.length < 5) {
                return;
            }
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.ad_detail_url]];
        }
            break;
        default:
            break;
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    CGFloat offsetY = scrollView.contentOffset.y;
//    ELog(@"===y:%f",offsetY);

}

#pragma mark - 底部弹窗按钮操作

/** 置顶/刷新/推送 */
- (void)pushAppreciteVC:(AppreciationType)type jobId:(NSNumber *)jobId{
    JianKeAppreciation_VC *viewCtrl = [[JianKeAppreciation_VC alloc] init];
    viewCtrl.serviceType = type;
    viewCtrl.jobId = jobId.stringValue;
    viewCtrl.popToVC = self.owner;
    viewCtrl.hidesBottomBarWhenPushed = YES;
    [self.owner.navigationController pushViewController:viewCtrl animated:YES];
}

/** 刷新 */
- (void)refreshJob:(JobModel *)model{
    [self getJobRefreshLeftCount:^(RefreshLeftCountModel* select) {
        if (select.busi_power_gift_limit.intValue + select.busi_power_limit.intValue > 0) {
            NSInteger leftCount = select.busi_power_gift_limit.intValue + select.busi_power_limit.intValue;
            NSString* leftCountStr = [NSString stringWithFormat:@"今天还剩%ld次刷新岗位机会，是否确定刷新", (long)leftCount];
            
            [UIHelper showConfirmMsg:leftCountStr completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    return;
                }else{
                    [self updateParttimeJobRanking:model.job_id];
                }
            }];
        }else{
            [UIHelper showConfirmMsg:@"您今天已用完该权限...明天再来试试吧" title:@"提示" cancelButton:@"取消" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
            }];
        }
    }];
}

/** 获取刷新次数 */
- (void)getJobRefreshLeftCount:(WdBlock_Id)block{
    NSString* content = @"";
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_getJobRefreshLeftCount" andContent:content];
    request.isShowLoading = NO;
    request.loadingMessage = @"数据加载中...";
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            if (block) {
                RefreshLeftCountModel *model=[RefreshLeftCountModel objectWithKeyValues:response.content];
                block(model);
            }
        }
    }];
}

/** 刷新岗位 */
- (void)updateParttimeJobRanking:(NSNumber *)jobId{
    NSString* content = [NSString stringWithFormat:@"job_id:%@", jobId];
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_updateParttimeJobRanking" andContent:content];
    request.isShowLoading = YES;
    request.loadingMessage = @"刷新中...";
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            ELog(@"刷新成功");
            [UserData delayTask:0.3 onTimeEnd:^{
                [UIHelper toast:@"刷新成功"];
            }];
        }
    }];
}

/** 雇主分享岗位 */

- (void)share:(JobModel *)jobModel{
    WEAKSELF
    if ( jobModel.is_social_activist_job.integerValue == 1 ){  //人脉王岗位
        [[UserData sharedInstance] userIsLogin:^(id result) {
            [weakSelf shareJob:jobModel];
        }];
    }else{
        [self shareJob:jobModel];
    }
}

- (void)shareJob:(JobModel *)jobDetailModel{
    WEAKSELF
    [ShareHelper platFormShareWithVc:weakSelf.owner info:jobDetailModel.share_info_not_sms block:^(NSNumber *obj) {
        switch (obj.integerValue) {
            case ShareTypeInvitePerson: // 分享到人才库
            {
                [[UserData sharedInstance] entShareJobToTalentPoolWithJobId:jobDetailModel.job_id.stringValue];
            }
                break;
            case ShareTypeIMGroup: // 分享到IM群组
            {
                ShareToGroupController *vc = [[ShareToGroupController alloc] init];
                vc.jobModel = jobDetailModel;
                [weakSelf.owner.navigationController pushViewController:vc animated:YES];
            }
                break;
            default:
                break;
        }
        if (jobDetailModel.is_social_activist_job.integerValue == 1 ){  //人脉王岗位
            NSString *content = [NSString stringWithFormat:@"job_id:%@",jobDetailModel.job_id];
            RequestInfo *request = [[RequestInfo alloc] initWithService:@"shijianke_shareSocialActivistJob" andContent:content];
            [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
                ELog(@"分享请求成功");
            }];
        }
    }];
    
}

/** 结束招聘 */

- (void)closeJob:(JobModel *)jobModel{
    if (jobModel.status.integerValue == 1 || jobModel.status.integerValue == 3) { // 待审核 || 已结束
        return;
    }
    [UIHelper showConfirmMsg:@"确定结束?" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            return;
        } else {
            NSString* content = [NSString stringWithFormat:@"job_id:%@", jobModel.job_id];
            RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_closeJob" andContent:content];
            request.isShowLoading = NO;
            request.loadingMessage = @"数据加载中...";
            WEAKSELF
            [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
                if (response && [response success]) {
                    if (response.errCode.intValue==0) {
                        [UIHelper toast:@"关闭成功"];
                        [weakSelf getLastData];
                    }
                }
            }];
        }
    }];

}

@end



