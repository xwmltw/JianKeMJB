//
//  PersonnelManager_VC.m
//  jianke
//
//  Created by xiaomk on 16/7/3.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "PersonnelManager_VC.h"
#import "XSJConst.h"
#import "PersonnelManagerCell.h"
#import "ApplyJobModel.h"
#import "ApplyJKController.h"
#import "MKActionSheet.h"
#import "LinkAddPerson_VC.h"
#import "EPMainTableView.h"
#import "QrCodeViewController.h"
#import "ParamModel.h"
#import "MJExtension.h"
#import "ManualAddPerson_VC.h"
#import "LookupResume_VC.h"
#import "GroupMessageController.h"
#import "MKMessageComposeHelper.h"


@interface PersonnelManager_VC ()<UITableViewDelegate, UITableViewDataSource>{
    NSArray* _botBtnArray;  /*!< 底部按钮列表 */

    NSArray *_nameFirstLetterArray;
    NSArray *_allSortJK;

}
@property (nonatomic, strong) UIView *botView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *jkModelArray;
@property (nonatomic, strong) ApplyJobModel *ajModel;

@property (nonatomic, copy) NSString *accountStr;  /*!< 群发消息 */

@property (nonatomic, weak) UITextField *emailTextField;

@end

@implementation PersonnelManager_VC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _jkModelArray = [[NSMutableArray alloc] init];

    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    [self.view addSubview:self.tableView];
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getDatasList)];

    self.botView = [[UIView alloc] init];
    self.botView.backgroundColor = MKCOLOR_RGBA(250, 250, 250, 1);
    [self.view addSubview:self.botView];
    
    [self.botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.botView.mas_top);
    }];

    [self initWithNoDataViewWithStr:@"没有已录用的兼客" onView:self.tableView];
    [self setupBottomToolBar];
    
    [self getData];

}

- (void)getData{
    [self.tableView.header beginRefreshing];
}

- (void)setupBottomToolBar{
    //简历处理
    UIButton *btn1 = [self setupBottomBtnWithImg:@"v3_mgr_resume"];
    btn1.tag = 101;
    //人员补录
    UIButton *btn2 = [self setupBottomBtnWithImg:@"v3_mgr_rybl"];
    btn2.tag = 102;
    //消息群发
    UIButton *btn3 = [self setupBottomBtnWithImg:@"v3_jkgl_qftz"];
    btn3.tag = 103;
    //名单导入
    UIButton *btn4 = [self setupBottomBtnWithImg:@"v3_mgr_dczd"];
    btn4.tag = 104;
    
    _botBtnArray = @[btn1, btn2, btn3, btn4];


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
- (void)getDatasList{
    WEAKSELF
    [[UserData sharedInstance] entQueryApplyJobListWithJobId:self.jobId listType:@(2) queryParam:nil block:^(ResponseInfo* response) {
        [weakSelf.tableView.header endRefreshing];
        
        if (response && response.success) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            
            weakSelf.ajModel = [ApplyJobModel objectWithKeyValues:response.content];
            NSArray* array = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];
            [_jkModelArray removeAllObjects];
            [_jkModelArray addObjectsFromArray:array];
        
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

/* 拼音分组 */
- (void)initTableViewData{
    NSArray* array = [MKCommonHelper getNoRepeatSortLetterArray:_jkModelArray letterKey:@"name_first_letter"];
    _nameFirstLetterArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:array]];
    
    NSMutableArray *sortJk = [NSMutableArray array];
    for (NSString* letter in _nameFirstLetterArray) {
        NSArray* tempArray = [_jkModelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name_first_letter like[cd] %@", letter]];
        [sortJk addObject:tempArray];
    }
    
    if ([self.delegate respondsToSelector:@selector(pmd_setTitle:withIndex:)]) {
        [self.delegate pmd_setTitle:[NSString stringWithFormat:@"人员管理(%lu)",(unsigned long)_jkModelArray.count] withIndex:0];
    }
    
    _allSortJK = [[NSArray alloc] initWithArray:sortJk];
    [self.tableView reloadData];
}

#pragma mark - ***** UITableView delegate ******
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PersonnelManagerCell *cell = [PersonnelManagerCell cellWithTableView:tableView];
    if (indexPath.section >= _allSortJK.count || indexPath.row >= [_allSortJK[indexPath.section] count]) {
        return cell;
    }
    JKModel* jkmodel =_allSortJK[indexPath.section][indexPath.row];
    [cell refreshWithData:jkmodel];
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
    JKModel* jkmodel =_allSortJK[indexPath.section][indexPath.row];
    return jkmodel.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_allSortJK[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allSortJK.count > 0 ? _allSortJK.count : 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView*)tableView{
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

#pragma mark - ***** 按钮事件 ******
- (void)btnBottomOnclick:(UIButton *)sender{
    if (sender.tag == 101) {  //简历处理      跳到已报名界面
        ApplyJKController *applyVC = [[ApplyJKController alloc] init];
        applyVC.jobId = self.jobId;
        applyVC.isAccurateJob = self.isAccurateJob;
        applyVC.managerType = self.managerType;
        applyVC.blockBack = ^(BOOL bRet){
            if (bRet) {
                [self getDatasList];
            }
        };
        [self.navigationController pushViewController:applyVC animated:YES];
    }else if (sender.tag == 102){ //人员补录
        WEAKSELF
        [MKActionSheet sheetWithTitle:nil buttonTitleArray:@[@"手动补录",@"链接补录"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {         //手动
                ManualAddPerson_VC *vc = [[ManualAddPerson_VC alloc] init];
                vc.title = @"手动补录";
                vc.job_id = _jobId;
                vc.block = ^(NSArray *addArray){
                    if (addArray && addArray.count > 0) {
                        if ([weakSelf.delegate respondsToSelector:@selector(pmd_setOtherVcRefreshStatus)]) {   //设置刷新转态
                            [weakSelf.delegate performSelector:@selector(pmd_setOtherVcRefreshStatus) withObject:nil];
                        }
                        [weakSelf getDatasList];
                    }
                };
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if (buttonIndex == 1){    //链接
                [weakSelf addJiankeWithJobId:_jobId];
            }
        }];
        
    }else if (sender.tag == 103){   //消息群发
        [self sendGroupMsg];
    }else if (sender.tag == 104){   //名单导入
        [self exportJiankeList];
    }
}

//* 二维码补录
- (void)addJiankeWithJobId:(NSString *)jobId{
    LinkAddPerson_VC *vc = [[LinkAddPerson_VC alloc] init];
    vc.jobId = jobId;
    [self.navigationController pushViewController:vc animated:YES];
    
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

/** 名单导入 */
- (void)exportJiankeList{
    ELog(@"导出至邮箱点击");
    [TalkingData trackEvent:@"兼客管理_已录用_表格"];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 185)];
    
    UITextField *emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(25, 0, 220, 30)];
    self.emailTextField = emailTextField;
    emailTextField.placeholder = @"请指定要导出的邮箱";
    [contentView addSubview:emailTextField];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(25, 30, 220, 1)];
    lineView.backgroundColor = [UIColor XSJColor_base];
    [contentView addSubview:lineView];
    
    UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 35, 220, 30)];
    msgLabel.text = @"导出的表格里包含这些:";
    msgLabel.textColor = [UIColor lightGrayColor];
    msgLabel.font = [UIFont systemFontOfSize:12];
    [contentView addSubview:msgLabel];
    
    UIButton *btn1 = [[UIButton alloc] initWithFrame:CGRectMake(25, 65, 220, 30)];
    [btn1 setTitle:@"基本信息" forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"main_icon_check"] forState:UIControlStateNormal];
    [btn1 setTitleColor:MKCOLOR_RGB(92, 92, 92) forState:UIControlStateNormal];
    btn1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn1.titleLabel.font = [UIFont systemFontOfSize:14];
    btn1.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    btn1.userInteractionEnabled = NO;
    [contentView addSubview:btn1];
    
    EPModel *epModel = [[UserData sharedInstance] getEpModelFromHave];
    
    UIButton *btn2 = [[UIButton alloc] initWithFrame:CGRectMake(25, 95, 220, 30)];
    if (epModel.verifiy_status.integerValue == 3) {
        [btn2 setTitle:@"身份证号" forState:UIControlStateNormal];
        [btn2 setImage:[UIImage imageNamed:@"main_icon_check"] forState:UIControlStateNormal];
    } else {
        [btn2 setTitle:@"身份证号(需企业认证)" forState:UIControlStateNormal];
        [btn2 setImage:[UIImage imageNamed:@"v210_xx"] forState:UIControlStateNormal];
    }
    
    [btn2 setTitleColor:MKCOLOR_RGB(92, 92, 92) forState:UIControlStateNormal];
    btn2.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn2.titleLabel.font = [UIFont systemFontOfSize:14];
    btn2.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    btn2.userInteractionEnabled = NO;
    [contentView addSubview:btn2];
    
    UIButton *btn3 = [[UIButton alloc] initWithFrame:CGRectMake(25, 125, 220, 30)];
    [btn3 setTitle:@"签到记录" forState:UIControlStateNormal];
    [btn3 setImage:[UIImage imageNamed:@"main_icon_check"] forState:UIControlStateNormal];
    [btn3 setTitleColor:MKCOLOR_RGB(92, 92, 92) forState:UIControlStateNormal];
    btn3.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn3.titleLabel.font = [UIFont systemFontOfSize:14];
    btn3.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    btn3.userInteractionEnabled = NO;
    [contentView addSubview:btn3];
    
    UIButton *btn4 = [[UIButton alloc] initWithFrame:CGRectMake(25, 155, 220, 30)];
    [btn4 setTitle:@"工资记录" forState:UIControlStateNormal];
    [btn4 setImage:[UIImage imageNamed:@"main_icon_check"] forState:UIControlStateNormal];
    [btn4 setTitleColor:MKCOLOR_RGB(92, 92, 92) forState:UIControlStateNormal];
    btn4.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn4.titleLabel.font = [UIFont systemFontOfSize:14];
    btn4.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    btn4.userInteractionEnabled = NO;
    [contentView addSubview:btn4];
    
    WEAKSELF
    [XSJUIHelper showConfirmWithView:contentView msg:nil title:@"请指定邮箱" cancelBtnTitle:@"取消" okBtnTitle:@"确定" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            // 判读邮箱是否为空
            if (self.emailTextField.text && self.emailTextField.text.length == 0) {
                [UIHelper showConfirmMsg:@"要导出的邮箱地址不能为空" title:@"提示" cancelButton:@"确定" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
                    [weakSelf exportJiankeList];
                }];
                return;
            }
            
            // 判断邮箱格式是否正确
            BOOL result = [MKCommonHelper validateEmail:weakSelf.emailTextField.text];
            if (!result) {
                [UIHelper showConfirmMsg:@"您输入的邮箱格式错误,请出入正确的邮箱地址!" title:@"提示" cancelButton:@"确定" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
                    [weakSelf exportJiankeList];
                }];
                return;
            }
            // 发送请求
            [[UserData sharedInstance] entExportJobApplyDetailToEmailWithJobId:weakSelf.jobId email:weakSelf.emailTextField.text block:^(ResponseInfo *response) {
                if (response.success) {
                    [UIHelper toast:@"导出成功"];
                }
            }];
        }
    }];
}


- (void)dealloc{
    DLog(@"PersonnelManager_VC dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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
