//
//  EmployList_TV.m
//  jianke
//
//  Created by xiaomk on 15/11/24.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "EmployList_TV.h"
#import "WDConst.h"
#import "EmployListCell.h"
#import "PayWage_VC.h"
#import "DateTools.h"
#import "LookupResume_VC.h"
#import "ApplyCell.h"
#import "GroupMessageController.h"
#import "BuyInsurance_VC.h"
#import "MakeCheck_VC.h"
#import "ApplyJobModel.h"
#import "MKMessageComposeHelper.h"
#import "ClockRecordManager_VC.h"
#import "PayExactWageManager_VC.h"
#import "JobModel.h"


@interface EmployList_TV() <UITableViewDataSource, UITableViewDelegate, EmployListCellDelegate>{

    NSArray* _botBtnArray;  /*!< 底部按钮列表 */
    
    NSArray* _nameFirstLetterArray;
    NSArray* _allSortJK;
    
    BOOL _isRefreshWhenShow;
}

@property (nonatomic, strong) UIView *botView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *jkModelArray;
@property (nonatomic, strong) ApplyJobModel *ajModel;

@property (nonatomic, copy) NSString *accountStr;
@end

@implementation EmployList_TV

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"兼客管理";
    [WDNotificationCenter addObserver:self selector:@selector(getLastData) name:ApplyCellReflushNotification object:nil];

    _jkModelArray = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor XSJColor_grayTinge];
    self.tableView.tableFooterView = [UIView new];
    //    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    [self.view addSubview:self.tableView];
    
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getLastData)];
    
    self.botView = [[UIView alloc] initWithFrame:CGRectZero];
    self.botView.backgroundColor = MKCOLOR_RGB(250, 250, 250);
    [self.view addSubview:self.botView];

    [self.botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(self.botView.mas_top);
    }];
    
    [self initWithNoDataViewWithStr:@"没有已录用的兼客" onView:self.tableView];
    [self setupBottomToolBar];
//    [self getLastData];
    _isRefreshWhenShow = YES;
    [self getDataWhenShow];

}

- (void)setNeedRefresh{
    _isRefreshWhenShow = YES;
}

- (void)getDataWhenShow{
    if (_isRefreshWhenShow) {
        _isRefreshWhenShow = NO;
        [self.tableView.header beginRefreshing];
    }
}

#pragma mark - ***** 设置底部按钮 ******
- (void)setupBottomToolBar{
    UIButton *btnSendMsg = [self setupBottomBtnWithImg:@"v3_jkgl_qftz"];
    btnSendMsg.tag = 101;
    UIButton *btnCheckInMgr = [self setupBottomBtnWithImg:@"v3_mgr_qdgl"];
    btnCheckInMgr.tag = 102;
    UIButton *btnPay = [self setupBottomBtnWithImg:@"v3_mgr_plzf"];
    btnPay.tag = 103;
     _botBtnArray = @[btnSendMsg, btnCheckInMgr, btnPay];
    
    [self layoutBottomBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    lineView.backgroundColor  = [UIColor XSJColor_grayLine];
    [self.botView addSubview:lineView];
}

- (UIButton *)setupBottomBtnWithImg:(NSString *)imgName{
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnBottomOnclick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)layoutBottomBtn{
    NSInteger count = _botBtnArray.count;
    
    CGFloat BtnW = SCREEN_WIDTH / count;
    for (NSInteger i = 0; i < count; i++) {
        UIButton *btn = _botBtnArray[i];
        [self.botView addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.botView);
            make.width.mas_equalTo(BtnW);
            make.left.mas_equalTo(BtnW * i);
        }];
    }
}

#pragma mark - ***** 获取数据 ******
- (void)getLastData{

    WEAKSELF
    [[UserData sharedInstance] entQueryApplyJobListWithJobId:self.jobId listType:@(2) queryParam:nil block:^(ResponseInfo* response) {
        [weakSelf.tableView.header endRefreshing];

        if (response && response.success) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            weakSelf.ajModel = [ApplyJobModel objectWithKeyValues:response.content];

            NSArray *dataArray = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];
            
            [_jkModelArray removeAllObjects];
            _jkModelArray = [NSMutableArray arrayWithArray:dataArray];
      
            if (_jkModelArray.count <= 0 ) {
                weakSelf.viewWithNoData.hidden = NO;
            }else{
                weakSelf.viewWithNoData.hidden = YES;
            }
            [weakSelf initTableViewData];
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
    }];
}

//** 拼音分组 */
- (void)initTableViewData{
    NSArray* array = [MKCommonHelper getNoRepeatSortLetterArray:_jkModelArray letterKey:@"name_first_letter"];
    _nameFirstLetterArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:array]];
    
    NSMutableArray *sortJk = [NSMutableArray array];
    for (NSString *letter in _nameFirstLetterArray) {
        NSArray* tempArray = [_jkModelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name_first_letter like[cd] %@", letter]];
        [sortJk addObject:tempArray];
    }
    _allSortJK = [[NSArray alloc] initWithArray:sortJk];
    [self.tableView reloadData];
}


#pragma mark - ***** UITableView delegate ******
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EmployListCell *cell = [EmployListCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.isAccurateJob = self.isAccurateJob;

    if (_allSortJK.count <= indexPath.section || [_allSortJK[indexPath.section] count] <= indexPath.row) {
        return cell;
    }
    
    JKModel *jkmodel = _allSortJK[indexPath.section][indexPath.row];
    [cell refreshWithData:jkmodel andIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JKModel* jkModel =_allSortJK[indexPath.section][indexPath.row];
    // 跳转
    LookupResume_VC *vc = [[LookupResume_VC alloc]init];
    vc.resumeId = jkModel.resume_id;
    vc.jobId = [NSNumber numberWithInt:self.jobId.intValue];
    vc.isLookOther = YES;
    vc.otherJkModel = jkModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    JKModel* jkmodel =_allSortJK[indexPath.section][indexPath.row];
    return jkmodel.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_allSortJK[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allSortJK.count > 0 ? _allSortJK.count : 0;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView{
//    NSMutableArray* array = [[NSMutableArray alloc] initWithArray:_nameFirstLetterArray];
//    [array addObject:@"#"];
    return _nameFirstLetterArray;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = [UIColor XSJColor_grayTinge];
    [view setBorderWidth:0.5 andColor:[UIColor XSJColor_grayLine]];

    UILabel* labTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 100, 20)];
    labTitle.textColor = MKCOLOR_RGB(128, 128, 128);
    labTitle.font = [UIFont systemFontOfSize:14];
    labTitle.text = _nameFirstLetterArray[section];
    [view addSubview:labTitle];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

#pragma mark - employList delegate
- (void)elCell_updateCellIndex:(NSIndexPath*)indexPath withModel:(JKModel *)model{
    //    [_jkModelArray replaceObjectAtIndex:indexPath.row withObject:model];
    [self.tableView reloadData];
    //    NSArray* array = @[indexPath];
    //    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - ***** 按钮事件 ******
- (void)btnBottomOnclick:(UIButton *)sender{
    if (sender.tag == 101) {        //群发消息
        [self sendGroupMsg];
    }else if (sender.tag == 102){   //签到管理
        ClockRecordManager_VC *viewCtrl = [[ClockRecordManager_VC alloc] init];
        viewCtrl.jobId = _jobId;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }else if (sender.tag == 103){   //批量支付
        if (self.managerType == ManagerTypeEP) {
            if (self.isAccurateJob.integerValue == 1) {
                PayExactWageManager_VC *payVc = [[PayExactWageManager_VC alloc] init];
                payVc.jobId = self.jobId;
                payVc.isAccurateJob = self.isAccurateJob;
                payVc.jobModel = self.jobModel;
                [self.navigationController pushViewController:payVc animated:YES];
            }else{
                PayWage_VC *payVc = [[PayWage_VC alloc] init];
                payVc.jobId = self.jobId;
                [self.navigationController pushViewController:payVc animated:YES];
            }
        }else{
            MakeCheck_VC *mcVc = [[MakeCheck_VC alloc] init];
            mcVc.jobId = self.jobId;
            mcVc.jobModel =  self.jobModel;
            [self.navigationController pushViewController:mcVc animated:YES];
        }
    }
}

/** 消息群发 */
- (void)sendGroupMsg{
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
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if (buttonIndex == 1){
                [weakSelf sendPhoneMessage];
            }
        }];
    } else {
        [UIHelper toast:@"当前没有需要发送消息的兼客"];
    }
}

- (void)sendPhoneMessage{
    [[MKMessageComposeHelper sharedInstance] showWithRecipientArray:[_jkModelArray valueForKeyPath:@"contact.phone_num"] onViewController:self block:nil];
}

- (void)dealloc{
    DLog(@"EmployList dealloc");
}

@end
