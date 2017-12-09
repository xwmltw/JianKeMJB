//
//  EpSingleDay_VC.m
//  jianke
//
//  Created by xiaomk on 15/11/28.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "EpSingleDay_VC.h"
#import "WDConst.h"
#import "EpSingleDayCell.h"
#import "LookupResume_VC.h"
#import "NSDate+DateTools.h"
#import "GroupMessageController.h"
#import "ApplyJobModel.h"
#import "MakeCheck_VC.h"
#import "ClockRecordManager_VC.h"
#import "MKMessageComposeHelper.h"
#import "JiankeScheduling_VC.h"

@interface EpSingleDay_VC ()<UITableViewDataSource, UITableViewDelegate, EmployListCellDelegate,DLAVAlertViewDelegate>{
    
    NSArray* _botBtnArray;
    NSArray* _nameFirstLetterArray;
    NSArray* _allSortJK;

}
@property (nonatomic, strong) ApplyJobModel *ajModel;
@property (nonatomic, strong) NSMutableArray *jkModelArray;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, copy)NSString *accountStr;
@property (nonatomic, strong) NSDate *reportTime;
@property (nonatomic, strong) DLAVAlertView *exportAlertView;
@property (nonatomic, weak) UITextField *emailTextField;
@property (nonatomic, weak) UIView* botView;
@end

@implementation EpSingleDay_VC

- (void)viewDidLoad {
    [super viewDidLoad];

    _jkModelArray = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor XSJColor_grayTinge];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    [self.view addSubview:self.tableView];
    
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getLastDataList)];
    
    UIView* botView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:botView];
    botView.backgroundColor = MKCOLOR_RGB(250, 250, 250);
    self.botView = botView;
    
    [botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tableView.mas_left);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.bottom.equalTo(self.view.mas_bottom);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.width.mas_equalTo(SCREEN_WIDTH);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(botView.mas_top);
    }];
    
    [self initWithNoDataViewWithStr:@"没有已录用的兼客" onView:self.tableView];
    
    [self setupBottomToolBar];
}


- (void)setupBottomToolBar{
    UIButton *btnSendMsg = [self setupBottomBtnWithImg:@"v3_jkgl_qftz"];
    btnSendMsg.tag = 101;
    UIButton *btnMgrWork = [self setupBottomBtnWithImg:@"v3_mgr_rypb"];
    btnMgrWork.tag = 102;
    UIButton *btnMgrCheckIn = [self setupBottomBtnWithImg:@"v3_mgr_qdgl"];
    btnMgrCheckIn.tag = 103;
    UIButton *btnPay = [self setupBottomBtnWithImg:@"v3_mgr_plzf"];
    btnPay.tag = 104;
    _botBtnArray = @[btnSendMsg, btnMgrWork, btnMgrCheckIn, btnPay];

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

- (void)getDatas{
    [self.tableView.header beginRefreshing];
}

- (void)getLastDataList{
    WEAKSELF
    [[UserData sharedInstance] entQueryApplyJobListWithJobId:self.jobId listType:@(2) boardDate:self.boardDate queryParam:nil block:^(ResponseInfo* response) {
        [weakSelf.tableView.header endRefreshing];
        
        if (response && response.success) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            
            weakSelf.ajModel = [ApplyJobModel objectWithKeyValues:response.content];
            NSArray* dataArray = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];
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

#pragma mark - UITableView delegate
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    EpSingleDayCell *cell = [EpSingleDayCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.boardDate = self.boardDate;
    
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
    LookupResume_VC *vc = [[LookupResume_VC alloc] init];
    vc.resumeId = jkModel.resume_id;
    vc.jobId = [NSNumber numberWithInt:self.jobId.intValue];
    vc.isLookOther = YES;
    vc.otherJkModel = jkModel;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 112;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_allSortJK[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allSortJK.count > 0 ? _allSortJK.count : 0;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView{
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
    [self.tableView reloadData];
}

#pragma mark - ***** 底部按钮事件 ******
- (void)btnBottomOnclick:(UIButton *)sender{
    if (sender.tag == 101) {        //群发消息
        [self sendGroupMsg];
    }else if (sender.tag == 102){   //人员排班
        JiankeScheduling_VC *vc = [[JiankeScheduling_VC alloc] init];
        vc.jobId = self.jobId;
        vc.on_board_date = self.boardDate;
        WEAKSELF
        vc.block = ^(NSArray *array){
            if (array.count > 0) {
                [weakSelf getDatas];
            }
        };
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 103){   //签到管理
        ClockRecordManager_VC *viewCtrl = [[ClockRecordManager_VC alloc] init];
        viewCtrl.jobId = _jobId;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }else if (sender.tag == 104){   //批量支付
        if ([self.delegate respondsToSelector:@selector(elm_changeToPayVC)]) {
            [self.delegate elm_changeToPayVC];
        }
    }
}



/** 群发消息按钮点击 */
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
                vc.jobId = self.jobId;
                vc.account_id = _accountStr;
                vc.receiveDate = self.boardDate;
                [self.navigationController pushViewController:vc animated:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
