//
//  ApplyJKController.m
//  jianke
//
//  Created by fire on 15/9/29.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "ApplyJKController.h"
#import "ApplyCell.h"
#import "MJRefresh.h"
#import "UIView+MKExtension.h"
#import "UserData.h"
#import "ParamModel.h"
#import "JKModel.h"
#import "Masonry.h"
#import "JobDetail_VC.h"
#import "JKModel.h"
#import "cellModel.h"
#import "LookupResume_VC.h"
#import "WDChatView_VC.h"
#import "XHPopMenu.h"
#import "DateTools.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ApplyJobModel.h"
#import "GroupMessageController.h"
#import "AddAchieveJK_VC.h"
#import "WorkPostDetail_VC.h"
#import "MKMessageComposeHelper.h"

@interface ApplyJKController () <UITableViewDelegate, UITableViewDataSource, ApplyCellDelegate>{
    NSString *_accountStr;
    JobDetailModel *_jobDetail;

}

@property (nonatomic, strong) ApplyJobModel* ajModel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) QueryParamModel *queryParam;
@property (nonatomic, strong) NSMutableArray *cellModelArray;
@property (nonatomic, strong) NSMutableArray *jkModelArray;
@property (nonatomic, strong) UILabel *jobTitleLabel;   //岗位名称条
@property (nonatomic, strong) NSArray *dateStrArray;

@property (nonatomic, strong) NSIndexPath *flushIndexPath; /*!< 返回后须要刷新的cell 自V3.0.7 弃用*/


//@property (nonatomic, strong) UIView *botView;

@end

@implementation ApplyJKController

//- (void)initTableViewHead{
//    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
//    headView.backgroundColor = [UIColor clearColor];
//    
//    UIButton *headBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
//    [headBtn setBackgroundImage:[UIImage imageNamed:@"ep_header"] forState:UIControlStateNormal];
//    [headBtn addTarget:self action:@selector(jobDetailClick) forControlEvents:UIControlEventTouchUpInside];
//    [headView addSubview:headBtn];
//    
//    UILabel *jobTitleLabel = [[UILabel alloc] init];
//    jobTitleLabel.textAlignment = NSTextAlignmentLeft;
//    jobTitleLabel.textColor = MKCOLOR_RGB(76, 133, 226);
//    self.jobTitleLabel = jobTitleLabel;
//    [headBtn addSubview:jobTitleLabel];
//    [jobTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.bottom.equalTo(headBtn).insets(UIEdgeInsetsMake(8, 20, 8, 70));
//    }];
//    self.tableView.tableHeaderView = headView;
//}

//- (void)initWithBotView{
//    UIButton* btnBot1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnBot1 setImage:[UIImage imageNamed:@"v3_mgr_sgqr"] forState:UIControlStateNormal];
//    [btnBot1 addTarget:self action:@selector(btnWorkCheckOnclick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton* btnBot2 = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnBot2 setImage:[UIImage imageNamed:@"v3_mgr_sxqf"] forState:UIControlStateNormal];
//    [btnBot2 addTarget:self action:@selector(btnSendMsgOnclick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton* btnBot3 = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btnBot3 setImage:[UIImage imageNamed:@"v3_mgr_qbly"] forState:UIControlStateNormal];
//    [btnBot3 addTarget:self action:@selector(btnAllApplyClickOnclick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.botView addSubview:btnBot1];
//    [self.botView addSubview:btnBot2];
//    [self.botView addSubview:btnBot3];
//    
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
//    lineView.backgroundColor = [UIColor XSJColor_grayLine];
//    [self.botView addSubview:lineView];
//    
//    WEAKSELF
//    [btnBot1 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.top.bottom.equalTo(weakSelf.botView);
//    }];
//    
//    [btnBot3 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.top.bottom.equalTo(weakSelf.botView);
//    }];
//    
//    [btnBot2 mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.bottom.equalTo(weakSelf.botView);
//        make.left.equalTo(btnBot1.mas_right);
//        make.right.equalTo(btnBot3.mas_left);
//        make.width.equalTo(btnBot1);
//        make.width.equalTo(btnBot3);
//    }];
//}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"简历处理";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"上岗确认"
                                                                             style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(btnWorkCheckOnclick)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor XSJColor_grayDeep];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"ApplyCell" bundle:nil] forCellReuseIdentifier:@"ApplyCell"];
    [self.view addSubview:self.tableView];
  
//    self.botView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.botView.backgroundColor = [UIColor XSJColor_grayTinge];
//    [self.view addSubview:self.botView];

//    [self.botView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.left.right.equalTo(self.view);
//        make.height.mas_equalTo(50);
//    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(self.view);
    }];
    
//    [self initTableViewHead];
//    [self initWithBotView];
    [self initWithNoDataViewWithStr:@"没有已报名的兼客" onView:self.tableView];

    [self.tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)]];
    [self.tableView setFooter:[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMore)]];
    self.tableView.footer.hidden = YES;
    
    // 注册通知
    [WDNotificationCenter addObserver:self selector:@selector(reflushCell:) name:ApplyCellReflushNotification object:nil];
    [WDNotificationCenter addObserver:self selector:@selector(chatWithJk:) name:ApplyChatWithJkNotification object:nil];
    
    [self.tableView.header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.flushIndexPath) {
        [self.tableView reloadRowsAtIndexPaths:@[self.flushIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        self.flushIndexPath = nil;
    }
}

#pragma mark - ***** tableView delegate ******
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ApplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ApplyCell"];
    cell.delegate = self;
    [self setupCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)setupCell:(ApplyCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.jobId = self.jobId;
    cell.isAccurateJob = self.isAccurateJob;
    cell.cellModel = self.cellModelArray[indexPath.section][indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [TalkingData trackEvent:@"已报名_兼客条目_兼客名片"];
    DLog(@"跳转到兼客简历");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JKModel *jkModel = [self.cellModelArray[indexPath.section][indexPath.row] jkModel];
    
    // 去掉小红点
    jkModel.ent_big_red_point_status = @(0);
    [[UserData sharedInstance] entReadApplyJobResumeWithApplyJobId:jkModel.apply_job_id.stringValue block:nil];
    
    ApplyCell *cell = (ApplyCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.redDot.hidden = YES;
    
    // 保存返回须要刷新的cell
    self.flushIndexPath = indexPath;
    
    // 跳转
    LookupResume_VC *vc = [[LookupResume_VC alloc]init];
    vc.resumeId = jkModel.resume_id;
    vc.jobId = [NSNumber numberWithInt:self.jobId.intValue];
    vc.isLookOther = YES;
    vc.otherJkModel = jkModel;
    vc.jobTitle = self.jobTitleLabel.text;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.cellModelArray.count ? self.cellModelArray.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cellModelArray[section] count] ? [self.cellModelArray[section] count] : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    WEAKSELF
    return [tableView fd_heightForCellWithIdentifier:@"ApplyCell" configuration:^(ApplyCell *cell) {
        [weakSelf setupCell:cell atIndexPath:indexPath];
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (!self.dateStrArray || !self.dateStrArray.count) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 28)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = MKCOLOR_RGB(212, 212, 212);
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"  %@  ", self.dateStrArray[section]];
    label.font = [UIFont systemFontOfSize:13];
    [label setCorner];
    [view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {       
        make.height.mas_equalTo(@(20));
        make.centerX.equalTo(view);
        make.centerY.equalTo(view).offset(4);
    }];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 28;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

#pragma mark - applycell delegate

- (void)applyCell:(ApplyCell *)cell cellModel:(CellModel *)cellModel actionType:(ActionType)actionType{
    if (cellModel) {
        NSUInteger section = -1;
        NSUInteger row = -1;
        
        NSUInteger sections = self.cellModelArray.count;
        for (NSUInteger i = 0; i < sections; i++) {
            row = [self.cellModelArray[i] indexOfObject:cellModel];
            if (NSNotFound != row) {
                section = i;
                break;
            }
        }
        if (section == -1 || row == -1) {
            [self.tableView.header beginRefreshing];
        } else {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            NSArray *array = @[indexPath];
            [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
            
            [[UserData sharedInstance] setIsUpdateWithEPHome:YES];
        }
    } else {
        [self.tableView.header beginRefreshing];
    }
}

#pragma mark - ***** 数据交互 ******
- (void)getData{
    
    QueryParamModel *queryParam = [[QueryParamModel alloc] init];
    queryParam.page_size = @(30);
    
    WEAKSELF
    [[UserData sharedInstance] entQueryApplyJobListWithJobId:self.jobId listType:@(8) queryParam:queryParam block:^(ResponseInfo *response) {
        [weakSelf.tableView.header endRefreshing];

        if (response && response.success) {
            weakSelf.ajModel = [ApplyJobModel objectWithKeyValues:response.content];
            weakSelf.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];

            NSArray *jkModelArray = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];
            weakSelf.jkModelArray = [NSMutableArray arrayWithArray:jkModelArray];
            weakSelf.cellModelArray = [CellModel cellModelArrayWithJkModel:jkModelArray];
            weakSelf.dateStrArray = [CellModel getSortDateStrArrayWithJkModelArray:jkModelArray];
            
            // 设置标题
//            self.title = [NSString stringWithFormat:@"已报名(%@)", response.content[@"apply_job_list_count"]];
//            weakSelf.jobTitleLabel.text = response.content[@"job_title"];
            weakSelf.jobTitleLabel.text = weakSelf.ajModel.job_title;
            
            // 设置已报名数
//            NSNumber *applyNum = weakSelf.ajModel.apply_job_list_count;
//            if ([weakSelf.owner respondsToSelector:@selector(setApplyCount:)] && applyNum) {
//                [weakSelf.owner performSelector:@selector(setApplyCount:) withObject:applyNum];
//            }
            
            weakSelf.tableView.footer.hidden = NO;
            [weakSelf.tableView reloadData];
            
            // 判断是否有数据
            if (weakSelf.cellModelArray && weakSelf.cellModelArray.count) {
                weakSelf.viewWithNoData.hidden = YES;
            } else {
//                weakSelf.navigationItem.rightBarButtonItem = nil;
                weakSelf.viewWithNoData.hidden = NO;
            }
        }
    }];
}

- (void)getMore{
    self.queryParam.page_num = @(self.queryParam.page_num.integerValue + 1);
    WEAKSELF
    [[UserData sharedInstance] entQueryApplyJobListWithJobId:self.jobId listType:@(8) queryParam:self.queryParam block:^(ResponseInfo *response) {
        if (response && response.success) {
            NSArray *moreJkModelArray = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];
            if (moreJkModelArray.count > 0 ) {
                [weakSelf.jkModelArray addObjectsFromArray:moreJkModelArray];
                weakSelf.cellModelArray = [CellModel cellModelArrayWithJkModel:weakSelf.jkModelArray];
                weakSelf.dateStrArray = [CellModel getSortDateStrArrayWithJkModelArray:weakSelf.jkModelArray];
                [weakSelf.tableView reloadData];
            } else {
                weakSelf.tableView.footer.hidden = YES;
            }
            weakSelf.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
        }
        [weakSelf.tableView.footer endRefreshing];
    }];
}

#pragma mark - ***** 按钮点击 ******
/** 全部录用 */
- (void)btnAllApplyClickOnclick:(UIButton*)sender{
    // 判读有没有未录用的兼客
    NSMutableArray *jobIdArray = [NSMutableArray array];
    [self.jkModelArray enumerateObjectsUsingBlock:^(JKModel *jkModel, NSUInteger idx, BOOL *stop) {
        if (jkModel.trade_loop_status.integerValue == 1) { // 已报名
            [jobIdArray addObject:jkModel.apply_job_id.description];
        }
    }];
    
    if (jobIdArray.count > 0) {
        [TalkingData trackEvent:@"已报名_全部录用"];
        WEAKSELF
        [UIHelper showConfirmMsg:@"你确定”全部录用“的操作吗？" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[UserData sharedInstance] entEmployApplyJobWithWithJobId:weakSelf.jobId employStatus:@(1) employMemo:nil block:^(ResponseInfo *response) {
                    if (response && response.success) {
                        [weakSelf.tableView.header beginRefreshing];
                    }
                }];
            }
        }];
    } else {
        [UserData delayTask:0.3 onTimeEnd:^{
            [UIHelper toast:@"当前没有未录用的兼客"];
        }];
    }
}

/** 群发消息 */
- (void)btnSendMsgOnclick:(UIButton*)sender{
    // 判读有没有未录用的兼客
    [TalkingData trackEvent:@"兼客管理_已录用_群发"];

    NSMutableArray *jobIdArray = [NSMutableArray array];
    [self.jkModelArray enumerateObjectsUsingBlock:^(JKModel *jkModel, NSUInteger idx, BOOL *stop) {
        if (jkModel.trade_loop_status.integerValue == 1) { // 已报名
            [jobIdArray addObject:jkModel.apply_job_id.description];
        }
    }];
    
    if (jobIdArray.count > 0) {
        if (_jkModelArray.count) {
            WEAKSELF
            [MKActionSheet sheetWithTitle:nil buttonTitleArray:@[@"消息铃铛群发",@"手机短信群发"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    NSMutableArray *accountIDarray = [NSMutableArray array];
                    [_jkModelArray enumerateObjectsUsingBlock:^(JKModel *jkModel, NSUInteger idx, BOOL *stop) {
                        [accountIDarray addObject:jkModel.account_id.description];
                        _accountStr = [accountIDarray componentsJoinedByString:@","];
                    }];
                    GroupMessageController *vc = [[GroupMessageController alloc] init];
                    vc.jobId = weakSelf.jobId;
                    vc.account_id = _accountStr;
                    vc.isSendApplyYet = YES;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }else if (buttonIndex == 1){
                    // 判断当前设备能否发送短信
                    [[MKMessageComposeHelper sharedInstance] showWithRecipientArray:[_jkModelArray valueForKeyPath:@"contact.phone_num"] onViewController:self block:nil];
                }
            }];
        } else {
            [UIHelper toast:@"当前没有需要发送消息的兼客"];
        }
    } else {
        [UserData delayTask:0.3 onTimeEnd:^{
            [UIHelper toast:@"当前没有未录用的兼客"];
        }];
    }
}

/** 确认上岗 */
- (void)btnWorkCheckOnclick{
    [TalkingData trackEvent:@"已报名_上岗确认"];
    NSString *content = [NSString stringWithFormat:@"job_id:%@", self.jobId];
    RequestInfo *request = [[RequestInfo alloc] initWithService:@"shijianke_getJobDetail" andContent:content];
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && response.success) {
            _jobDetail = [JobDetailModel objectWithKeyValues:response.content];
            if (_jobDetail.parttime_job.click_confirm_work_status.integerValue == 1) {
                WorkPostDetail_VC *vc = [[WorkPostDetail_VC alloc] init];
                vc.jobId = weakSelf.jobId;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else{
                AddAchieveJK_VC *vc = [[AddAchieveJK_VC alloc] init];
                vc.job_id = weakSelf.jobId;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        }
    }];
}

/** 调转岗位详情 */
- (void)jobDetailClick{
    DLog(@"跳转到岗位详情");
    JobDetail_VC* vc = [[JobDetail_VC alloc] init];
    vc.jobId = self.jobId;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 通知
- (void)reflushCell:(NSNotification *)notification{
    CellModel *cellModel = notification.userInfo[ApplyCellReflushInfo];
    if (cellModel) {
        NSUInteger section = -1;
        NSUInteger row = -1;
        
        NSUInteger sections = self.cellModelArray.count;
        for (NSUInteger i = 0; i < sections; i++) {
            row = [self.cellModelArray[i] indexOfObject:cellModel];
            if (NSNotFound != row) {
                section = i;
                break;
            }
        }
        if (section == -1 || row == -1) {
             [self.tableView.header beginRefreshing];
        } else {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            NSArray *array = @[indexPath];
            [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
        }
    } else {
        [self.tableView.header beginRefreshing];
    }
}


- (void)chatWithJk:(NSNotification *)notification{
    JKModel *jkModel = notification.userInfo[ApplyChatWithJkInfo];
    NSString *jobTitle = self.jobTitleLabel.text;
    if (jkModel.account_im_open_status) { // 有开通IM
        
        NSString* content = [NSString stringWithFormat:@"\"accountId\":\"%@\"", jkModel.account_id];
        RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_im_getUserPublicInfo" andContent:content];
        request.isShowLoading = NO;
        [request sendRequestToImServer:^(ResponseInfo* response) {
            if (response && [response success]) {
                [WDChatView_VC openPrivateChatOn:self accountId:jkModel.account_id.description withType:WDImUserType_Jianke jobTitle:jobTitle jobId:self.jobId];
            }
        }];
    } else {
        [UIHelper toast:@"对不起,该用户未开通IM功能"];
    }
}




- (void)backToLastView{
    MKBlockExec(self.blockBack, YES);
    [super backToLastView];
}

- (void)dealloc{
    DLog(@"applyController dealloc");
}
@end
