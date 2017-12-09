//
//  JiankeCollection_VC.m
//  jianke
//
//  Created by fire on 16/9/6.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JiankeCollection_VC.h"
#import "JKMangeCollectionCell.h"
#import "ApplyJKController.h"
#import "ManualAddPerson_VC.h"
#import "LinkAddPerson_VC.h"
#import "JiankeManage_VC.h"
#import "JobModel.h"
#import "GroupMessageController.h"
#import "ClockRecordManager_VC.h"
#import "PayExactWageManager_VC.h"
#import "PayWage_VC.h"
#import "MakeCheck_VC.h"
#import "SalaryRecord_VC.h"
#import "JKMangeHeadView.h"
#import "JobDetail_VC.h"
#import "JKCallList_VC.h"
#import "EmployExaManager_VC.h"
#import "EmployList_TV.h"
#import "MJRefreshNormalHeader.h"
#import "MKMessageComposeHelper.h"
#import "JobVasOrder_VC.h"

@interface JiankeCollection_VC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, JKMangeHeaderViewDalegate>{
    JobDetailModel *_JobDetailModel;
}

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, copy) NSArray *dataSource;
@property (nonatomic, copy) NSArray *jkModelArray;
@property (nonatomic, weak) UITextField *emailTextField;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, strong) id model;
@property (nonatomic, strong) MKBlurView *blurView;

@end

@implementation JiankeCollection_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"兼职管理";
    self.dataSource = @[@(JKBannerType_JianLi), @(JKBannerType_Add), @(JKBannerType_Manage), @(JKBannerType_IM), @(JKBannerType_Record), @(JKBannerType_Salary), @(JKBannerType_NotifRecord), @(JKBannerType_OutPut), @(JKBannerType_jobVas)];
    [self initUI];
}

- (void)getData{
    [self getLastestData:NO];
}

- (void)getLastestData:(BOOL)isShowLoding{
    WEAKSELF
    [[UserData sharedInstance] getJobDetailWithJobId:self.jobId andIsFromSAB:NO isShowLoding:isShowLoding Block:^(JobDetailModel *model) {
        [weakSelf.collectionView.header endRefreshing];
        if (model) {
            if (model.parttime_job.source.integerValue == 1) {
                [weakSelf.collectionView addSubview:self.blurView];
            }
            _JobDetailModel = model;
            [weakSelf.collectionView reloadData];
        }
    }];
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
////    [self.collectionView.header beginRefreshing];
//    [self getLastestData:YES];
//}

- (void)initUI{
    
    //collectionview
    self.layout = [[UICollectionViewFlowLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView setScrollEnabled:YES];
    self.collectionView = collectionView;
    [self.view addSubview:collectionView];
    
    self.layout.itemSize = CGSizeMake(SCREEN_WIDTH / 3, 126);
    self.layout.minimumInteritemSpacing = 0;
    self.layout.minimumLineSpacing = 0;
    self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    [self.collectionView registerNib:nib(@"JKMangeCollectionCell") forCellWithReuseIdentifier:@"JKMangeCollectionCell"];
    [self.collectionView registerNib:nib(@"JKMangeHeadView") forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JKMangeHeadView"];
    WEAKSELF
    self.collectionView.header =[MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    if (self.jobModel.source.integerValue == 1) {
        [self.collectionView addSubview:self.blurView];
    }
    [self.collectionView.header beginRefreshing];
}

- (MKBlurView *)blurView{
    if (!_blurView) {
        _blurView = [[MKBlurView alloc] initWithFrame:SCREEN_BOUNDS];
        _blurView.y = 210;
        [self initWithNoDataViewWithStr:@"当前岗位为采集岗位,只有平台内发布的岗位才能进行管理哦~" labColor:[UIColor XSJColor_blackBase] imgName:@"v3_public_sorry" button:@" 查看咨询的兼客 > " onView:_blurView];
        self.viewWithNoData.backgroundColor = [UIColor clearColor];
        self.viewWithNoData.y = 64.0f;
        self.viewWithNoData.hidden = NO;
        [self.btnWithNoData setBackgroundColor:[UIColor clearColor]];
        [self.btnWithNoData setTitleColor:[UIColor XSJColor_tBlue] forState:UIControlStateNormal];
    }
    return _blurView;
}

#pragma mark - uicollectionview delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataSource ? self.dataSource.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    JKMangeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JKMangeCollectionCell" forIndexPath:indexPath];
    cell.redPoint.hidden = YES;
    cell.feturePoint.hidden = YES;
    JKBannerType type = [[self.dataSource objectAtIndex:indexPath.item] integerValue];
    switch (type) {
        case JKBannerType_JianLi:{
            cell.titleLab.text = @"简历处理";
            cell.img.image = [UIImage imageNamed:@"v3_epgl_icon_jlcl"];
            cell.redPoint.text = _JobDetailModel.parttime_job.undeal_apply_num.description;
            cell.redPoint.hidden = !(_JobDetailModel.parttime_job.undeal_apply_num.integerValue > 0);
        }
            
            break;
        case JKBannerType_Add:{
            cell.titleLab.text = @"人员补录";
            cell.img.image = [UIImage imageNamed:@"v3_epgl_icon_rybl"];
        }
            
            break;
        case JKBannerType_Manage:{
            cell.titleLab.text = @"兼客管理";
            cell.img.image = [UIImage imageNamed:@"v3_epgl_icon_gkgl"];
        }
            
            break;
        case JKBannerType_IM:{
            cell.titleLab.text = @"群发通知";
            cell.img.image = [UIImage imageNamed:@"v3_epgl_icon_qfxx"];
        }
            
            break;
        case JKBannerType_Record:{
            cell.titleLab.text = @"签到管理";
            cell.img.image = [UIImage imageNamed:@"v3_epgl_icon_qdgl"];
        }
            
            break;
        case JKBannerType_Salary:{
            cell.titleLab.text = @"发放工资";
            cell.img.image = [UIImage imageNamed:@"v3_epgl_icon_ffgz"];
        }
            
            break;
        case JKBannerType_NotifRecord:{
            cell.titleLab.text = @"发放记录";
            cell.img.image = [UIImage imageNamed:@"v3_epgl_icon_ffjl"];
        }
            
            break;
        case JKBannerType_OutPut:{
            cell.titleLab.text = @"名单导出";
            cell.img.image = [UIImage imageNamed:@"v3_epgl_icon_mddc"];
        }
            break;
        case JKBannerType_jobVas:{
            cell.titleLab.text = @"付费推广";
            cell.feturePoint.hidden = [WDUserDefaults boolForKey:NewFeatureAboutApprecite];
            cell.img.image = [UIImage imageNamed:@"v3_epgl_icon_fftg"];
        }
            
            break;
        default:
            break;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    JKMangeHeadView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JKMangeHeadView" forIndexPath:indexPath];
    view.delegate = self;
    [view setData:_JobDetailModel];
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 210.0f);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    JKBannerType type = [[self.dataSource objectAtIndex:indexPath.item] integerValue];
    switch (type) {
        case JKBannerType_JianLi:
            [self pushApplyVC];
            break;
        case JKBannerType_Add:
            [self showHireSheet];
            break;
        case JKBannerType_Manage:
            [self pushJKmange];
            break;
        case JKBannerType_IM:
            [self getDatasList];
            break;
        case JKBannerType_Record:
            [self pushClockVC];
            break;
        case JKBannerType_Salary:
            [self pushPaywage];
            break;
        case JKBannerType_NotifRecord:
            [self pushSalaryRec];
            break;
        case JKBannerType_OutPut:
            [self exportJiankeList];
            break;
        case JKBannerType_jobVas:{
            [WDUserDefaults setBool:YES forKey:NewFeatureAboutApprecite];
            [WDUserDefaults synchronize];
            JKMangeCollectionCell *cell = (JKMangeCollectionCell*)[collectionView cellForItemAtIndexPath:indexPath];
            cell.feturePoint.hidden = YES;
            [self payJobVasOrder];
        }
            break;
        default:
            break;
    }
}

#pragma mark - JKMangeHeadViewDelegate

- (void)jkHeadView:(JKMangeHeadView *)headView btnOnClick:(UIButton *)sender{
    JobDetail_VC *viewCtrl = [[JobDetail_VC alloc] init];
    viewCtrl.jobId = self.jobModel.job_id.description;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - 重写方法

- (void)noDataButtonAction:(UIButton *)sender{
    ELog(@"查看咨询的兼客");
    JKCallList_VC *viewCtrl = [[JKCallList_VC alloc] init];
    viewCtrl.jobId = self.jobId;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - item按钮响应

/** 简历处理 */
- (void)pushApplyVC{
    ApplyJKController *applyVC = [[ApplyJKController alloc] init];
    applyVC.jobId = self.jobId;
    applyVC.isAccurateJob = self.isAccurateJob;
    applyVC.managerType = self.managerType;
    applyVC.blockBack = ^(BOOL isRefresh){
        [self getLastestData:YES];
    };
    [self.navigationController pushViewController:applyVC animated:YES];
}

- (void)showHireSheet{
    WEAKSELF
    [MKActionSheet sheetWithTitle:nil buttonTitleArray:@[@"手动补录",@"链接补录"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {         //手动
            ManualAddPerson_VC *vc = [[ManualAddPerson_VC alloc] init];
            vc.title = @"手动补录";
            vc.job_id = _jobId;
            vc.block = ^(NSArray *addArray){
                if (addArray && addArray.count > 0) {
                    [weakSelf getLastestData:YES];
                }
            };
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }else if (buttonIndex == 1){    //链接
            [weakSelf addJiankeWithJobId:_jobId];
        }
    }];
}
             
//* 二维码补录
- (void)addJiankeWithJobId:(NSString *)jobId{
     LinkAddPerson_VC *vc = [[LinkAddPerson_VC alloc] init];
     vc.jobId = jobId;
     [self.navigationController pushViewController:vc animated:YES];
 
}

/** 签到管理 */
- (void)pushClockVC{
    ClockRecordManager_VC *viewCtrl = [[ClockRecordManager_VC alloc] init];
    viewCtrl.jobId = self.jobId;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (void)pushJKmange{
    
    if (self.isAccurateJob.integerValue == 1) {     //精确岗位
        EmployExaManager_VC *emVC = [[EmployExaManager_VC alloc] init];
        emVC.jobId = self.jobId;
        emVC.managerType = self.managerType;
        emVC.isAccurateJob = self.isAccurateJob;
        emVC.jobModel = self.jobModel;
        [self.navigationController pushViewController:emVC animated:YES];
    }else{      //松散岗位
        EmployList_TV *elVC = [[EmployList_TV alloc] init];
        elVC.jobId = self.jobId;
        elVC.managerType = self.managerType;
        elVC.isAccurateJob = self.isAccurateJob;
        elVC.jobModel = self.jobModel;
        [self.navigationController pushViewController:elVC animated:YES];
    }
    
}

/** 消息群发 */
- (void)sendGroupMsg{
    if (_jkModelArray.count) {
        WEAKSELF
        [MKActionSheet sheetWithTitle:nil buttonTitleArray:@[@"消息铃铛群发",@"手机短信群发"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                __block NSString *accountStr = nil;
                NSMutableArray *accountIDarray = [NSMutableArray array];
                [_jkModelArray enumerateObjectsUsingBlock:^(JKModel *jkModel, NSUInteger idx, BOOL *stop) {
                    [accountIDarray addObject:jkModel.account_id.description];
                    accountStr = [accountIDarray componentsJoinedByString:@","];
                }];
                
                GroupMessageController *vc = [[GroupMessageController alloc] init];
                vc.jobId = self.jobId;
                vc.account_id = accountStr;
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

- (void)getDatasList{
    WEAKSELF
    [[UserData sharedInstance] entQueryApplyJobListWithJobId:self.jobId listType:@(2) boardDate:nil queryParam:nil isShowLoading:YES block:^(ResponseInfo *response) {
        if (response && response.success) {
            //            weakSelf.ajModel = [ApplyJobModel objectWithKeyValues:response.content];
            NSArray* array = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];
            weakSelf.jkModelArray = array;
            [weakSelf sendGroupMsg];
        }
    }];
}

- (void)pushJKDebug{
    JiankeManage_VC *vc = [[JiankeManage_VC alloc] init];
    vc.jobId = self.jobId;
    vc.isAccurateJob = self.jobModel.is_accurate_job;
    vc.managerType = self.managerType;
    vc.jobModel = self.jobModel;
    vc.isClose = self.jobModel.status.integerValue == 3;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)pushPaywage{
    if (self.managerType == ManagerTypeEP) {
        if (self.isAccurateJob.integerValue == 1) {
            PayExactWageManager_VC *payVc = [[PayExactWageManager_VC alloc] init];
            payVc.jobId = self.jobId;
            payVc.isAccurateJob = self.isAccurateJob;
            payVc.jobModel = self.jobModel;
            payVc.popToVC = self;
            [self.navigationController pushViewController:payVc animated:YES];
        }else{
            PayWage_VC *payVc = [[PayWage_VC alloc] init];
            payVc.jobId = self.jobId;
            payVc.popToVC = self;
            [self.navigationController pushViewController:payVc animated:YES];
        }
    }else{
        MakeCheck_VC *mcVc = [[MakeCheck_VC alloc] init];
        mcVc.jobId = self.jobId;
        mcVc.jobModel =  self.jobModel;
        [self.navigationController pushViewController:mcVc animated:YES];
    }
}

- (void)pushSalaryRec{
    SalaryRecord_VC *viewCtrl = [[SalaryRecord_VC alloc] init];
    viewCtrl.jobId = self.jobId;
    [self.navigationController pushViewController:viewCtrl animated:YES];
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

- (void)payJobVasOrder{
    JobVasOrder_VC *viewCtrl = [[JobVasOrder_VC alloc] init];
    viewCtrl.jobId = self.jobId;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

/** 岗位详情 */
- (void)pushJobDetail:(UIButton *)sender{
    ELog(@"岗位详情");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    ELog(@"%@----dealloc", [self class]);
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
