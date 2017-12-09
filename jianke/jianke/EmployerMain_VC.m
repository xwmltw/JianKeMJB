//
//  EmployerMain_VC.m
//  jianke
//
//  Created by xiaomk on 15/9/15.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "EmployerMain_VC.h"
#import "MoneyBag_VC.h"
#import "CitySelectController.h"
#import "IMHome_VC.h"
#import "ImDataManager.h"
#import "EPMainTableView.h"
#import "ScrollNewsView.h"
#import "ChoosePostJobType_VC.h"
#import "PostJob_VC.h"
#import "XSJRequestHelper.h"
#import "AccountMoneyModel.h"
#import "WebView_VC.h"
#import "GuideUIManager.h"
#import "JKHomeModel.h"
#import "JobDetail_VC.h"
#import "ForceSwitchView.h"

@interface EmployerMain_VC ()<UIScrollViewDelegate, UIAlertViewDelegate>{
    EPMainTableView* _epMainTableView;
    EPModel* _epInfo;
}

@property (nonatomic, weak) UITableView* tableView;
@property (nonatomic, strong) UIAlertView *trueNameAlertView;

@property (nonatomic, strong) UIBarButtonItem *leftItem;
//@property (nonatomic, strong) UIButton *localBtn;

@end


@implementation EmployerMain_VC

#pragma mark - UI init =============
- (void)addNotification{
    ELog(@"====ep addNotification");
    [WDNotificationCenter removeObserver:self];
    [WDNotificationCenter addObserver:self selector:@selector(loginSuccessNotifi) name:WDNotifi_LoginSuccess object:nil];
    [WDNotificationCenter addObserver:self selector:@selector(updateMsgNum:) name:WDNotification_EP_homeUpdateMsgNum object:nil];
    [WDNotificationCenter addObserver:self selector:@selector(updateMainTV) name:IMNotification_EPMainUpdate object:nil];
    [WDNotificationCenter addObserver:self selector:@selector(walletNotify) name:IMPushWalletNotification object:nil];
    //收到包招账单
    [WDNotificationCenter addObserver:self selector:@selector(showBaozhaoCheckRedPoint) name:IMNotification_BDSendBillForPayToEP object:nil];
    //    [WDNotificationCenter addObserver:self selector:@selector(updateHeadImage) name:WDNotifi_updateEPResume object:nil];
    //    [WDNotificationCenter addObserver:self selector:@selector(updateUIWithLoginOut) name:WDNotifi_setLoginOut object:nil];

}

- (void)initNavigationButton{
    
//    self.localBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.localBtn.frame = CGRectMake(0, 0, 120, 44);
//    self.localBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    [self.localBtn setImage:[UIImage imageNamed:@"v3_home_location"] forState:UIControlStateNormal];
//    [self.localBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 12, 0, 0)];
//    self.localBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [self.localBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.localBtn addTarget:self action:@selector(localBtnOnclick) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:self.localBtn];
//    self.navigationItem.leftBarButtonItem = leftItem;
//    [self updateLocalBtnTitle];
    
    
    
    self.leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"v3_home_ep_partner"] style:UIBarButtonItemStylePlain target:self action:@selector(btnPartnerOnclick)];
//    [self.leftItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName, nil] forState:UIControlStateNormal];
    [self setTopLeftItem];
    
    //发布岗位按钮
    UIButton* issueJobBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [issueJobBtn setImage:[UIImage imageNamed:@"v3_home_ep_create_jobs"] forState:UIControlStateNormal];
    issueJobBtn.frame = CGRectMake(0, 0, 44, 44);
    [issueJobBtn addTarget:self action:@selector(issueJobBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:issueJobBtn];

    UIBarButtonItem *nevgativeSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    nevgativeSpaceRight.width = -12;
    
    self.navigationItem.rightBarButtonItems =  @[nevgativeSpaceRight,rightItem];
}

- (void)setTopLeftItem{
    if ([[UserData sharedInstance] isLogin] && _epInfo.identity_mark.integerValue == 2) {
        UIBarButtonItem *nevgativeSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        nevgativeSpaceLeft.width = -8;
        self.navigationItem.leftBarButtonItems = @[nevgativeSpaceLeft,self.leftItem];
    }else{
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)initTableView{
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor XSJColor_grayTinge];

    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _epMainTableView = [[EPMainTableView alloc] init];
    _epMainTableView.tableView = self.tableView;
    _epMainTableView.owner = self;
    _epMainTableView.managerType = ManagerTypeEP;
    _epMainTableView.isFromHome = YES;
    
    [self initWithNoDataViewWithStr:@"请点击右上角 “+” 开始发布" labColor:nil imgName:@"v3_home_ep_nodata" onView:self.tableView];
}

#pragma mark - ***** viewDidLoad ******
- (void)viewDidLoad {
    self.isRootVC = YES;
    [super viewDidLoad];
    
    self.title = @"首页";
    [TalkingData trackEvent:@"雇主首页"];
    self.view.backgroundColor = [UIColor whiteColor];

    [self addNotification];
    
    [self initNavigationButton];
    
    //   所在城市信息
    CityModel* cityModel = [[UserData sharedInstance] city];
    if (cityModel) {
        [self initUI];
    }else{
        CitySelectController* cityVC =[[CitySelectController alloc] init];
        cityVC.showSubArea = NO;
        WEAKSELF
        cityVC.didSelectCompleteBlock = ^(CityModel *area){
            if ([area isKindOfClass:[CityModel class]]) {
                CityModel* model = area;
                [[UserData sharedInstance] setCity:model];
            }
            [weakSelf initUI];
        };
        MainNavigation_VC* nav = [[MainNavigation_VC alloc] initWithRootViewController:cityVC];
        [weakSelf presentViewController:nav animated:YES completion:nil];
    }
//    [XSJUserInfoData checkVersion];
    ForceSwitchView *forceView = [[ForceSwitchView alloc] initWithFrame:SCREEN_BOUNDS];
//    forceView.backgroundColor = [UIColor grayColor];
    
    [self postInfoToThirdPlat];
}

- (void)postInfoToThirdPlat{
    if ([UserData sharedInstance].registrationID) {
        WEAKSELF
        [[XSJRequestHelper sharedInstance] postThirdPushPlatInfo:[UserData sharedInstance].registrationID block:^(id result) {
            
        }];
    }
}


- (void)initUI{
    [GuideUIManager showGuideWithType:GuideUIType_EPHomeScrollAd block:^(GuideView *guideView, AdModel *model) {
        if (guideView && model) {
            if (model.ad_detail_url || model.ad_detail_url.length > 4) {
                [[XSJRequestHelper sharedInstance] queryAdClickLogRecordWithADId:model.ad_id];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.ad_detail_url]];
            }
            
//            // 1:应用内打开链接 2:岗位广告  3:浏览器打开链接 4:专题类型
//            switch (model.ad_type.intValue) {
//                case 1:{
//                    if (model.ad_detail_url == nil || model.ad_detail_url.length < 5) {
//                        return;
//                    }
//                    model.ad_detail_url = [model.ad_detail_url stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//                    WebView_VC* vc = [[WebView_VC alloc] init];
//                    vc.url = model.ad_detail_url;
//                    vc.title = model.ad_name;
//                    vc.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:vc animated:YES];
//                }
//                    break;
//                case 3:{
//                    if (model.ad_detail_url == nil || model.ad_detail_url.length < 5) {
//                        return;
//                    }
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.ad_detail_url]];
//                }
//                    break;
//                default:
//                    break;
//            }
        }
    }];
    
    WEAKSELF
    [[XSJRequestHelper sharedInstance] activateAutoLoginWithBlock:^(id result) {
        [weakSelf initTableView];
        [weakSelf initUIWithData];
    }];
    
    [UserData delayTask:3 onTimeEnd:^{
        [[XSJUIHelper sharedInstance] showCommentAlertWithVC:self];
    }];
}


- (void)initUIWithData{
    [self updateTableViewData];

    if ([[UserData sharedInstance] isLogin]) {
        WEAKSELF
        [[UserData sharedInstance] getEPModelWithBlock:^(EPModel* obj) {
            _epInfo = obj;
            [weakSelf loginIm];
            [weakSelf setWallet];
            [weakSelf baozhaoRedPoint];
            [weakSelf setTopLeftItem];
        }];
    }
}

- (void)updateTableViewData{
    ELog(@"======updateTableViewData");
    if ([[UserData sharedInstance] isLogin]) {
        [_epMainTableView getLastData];
        self.viewWithNoData.hidden = YES;
    }else{
        self.viewWithNoData.hidden = NO;
    }
    
}

/** 设置钱袋子小红点 */
- (void)setWallet{
    if ([[UserData sharedInstance] isLogin]) {
        WEAKSELF
        [[XSJRequestHelper sharedInstance] queryAccountMoneyWithBlock:^(ResponseInfo *response) {
            if (response && response.success) {
                AccountMoneyModel *account = [AccountMoneyModel objectWithKeyValues:response.content[@"account_money_info"]];
                if (account.money_bag_small_red_point.integerValue > 0) {
                    [XSJUserInfoData sharedInstance].isShowMoneyBadRedPoint = YES;
                    [weakSelf walletNotify];
                }else{
                    [XSJUserInfoData sharedInstance].isShowMoneyBadRedPoint = NO;
                }
            }
        }];
    }
}

- (void)baozhaoRedPoint{
    if (_epInfo.job_bill_small_red_point && _epInfo.job_bill_small_red_point.integerValue == 1) {
        [XSJUserInfoData sharedInstance].isShowEpBaozhaoCheckRedPoint = YES;
        [self showBaozhaoCheckRedPoint];
    }
}

- (void)updateMainTV{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateTableViewData];
    });
}

- (void)loginIm{
    if ([[UserData sharedInstance] isLogin]) {
        if (![[ImDataManager sharedInstance] isUserLogin]) {
            [[ImDataManager sharedInstance] tryLogin];
        }
    }
}

/** 发布岗位 */
- (void)issueJobBtnOnClick:(UIButton *)sender{
    [TalkingData trackEvent:@"雇主首页_发布岗位"];

// 0.判断是否登录
    WEAKSELF
    [[UserData sharedInstance] userIsLogin:^(id obj) {
        if (obj) {
            // 1.判断是否完善姓名
            NSString *trueName = [[UserData sharedInstance] getUserTureName];
            if (!trueName || trueName.length < 1) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"完善姓名" message:@"请填写真实姓名" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *nameTextField = [alertView textFieldAtIndex:0];
                nameTextField.placeholder = @"真实姓名";
                weakSelf.trueNameAlertView = alertView;
                [alertView show];
            } else {
                CityModel* cityModel = [[UserData sharedInstance] city];
                
                if (_epInfo.identity_mark.integerValue == 2) {
                    PostJob_VC* vc = [[PostJob_VC alloc] init];
                    vc.postJobType = PostJobType_fast;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }else if(cityModel.enableRecruitmentService.integerValue == 0){
                    PostJob_VC* vc = [[PostJob_VC alloc] init];
                    vc.postJobType = PostJobType_common;
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }else{
                    ChoosePostJobType_VC* vc = [[ChoosePostJobType_VC alloc] init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
    }];
}

#pragma mark - ***** 按钮事件 ******
//合伙人说明
- (void)btnPartnerOnclick{
    WebView_VC *vc = [[WebView_VC alloc] init];
    vc.url = [NSString stringWithFormat:@"%@%@", URL_HttpServer,kUrl_partnerIntroPage];;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
//- (void)localBtnOnclick{
//    //    //小红点测试
//    //    [XSJUserInfoData sharedInstance].isShowMoneyBadRedPoint = YES;
//    //    [XSJUserInfoData sharedInstance].isShowEpBaozhaoCheckRedPoint = YES;
//    //    [self.tabBarController.tabBar showSmallBadgeOnItemIndex:2];
//    //    return;
//    
//    
//    CitySelectController* cityVC = [[CitySelectController alloc] init];
//    cityVC.showSubArea = NO;
//    cityVC.hidesBottomBarWhenPushed = YES;
//    WEAKSELF
//    cityVC.didSelectCompleteBlock = ^(CityModel *area){
//        if (area && [area isKindOfClass:[CityModel class]]) {
//            [[UserData sharedInstance] setCity:area];
//            [weakSelf updateLocalBtnTitle];
//
//        }
//    };
//    MainNavigation_VC *nav = [[MainNavigation_VC alloc] initWithRootViewController:cityVC];
//    [self presentViewController:nav animated:YES completion:nil];
//}

//- (void)updateLocalBtnTitle{
//    CityModel *ctModel = [[UserData sharedInstance] city];
//    if (ctModel) {
//        [self.localBtn setTitle:ctModel.name forState:UIControlStateNormal];
//    }
//}


#pragma mark - ***** 通知 ******
- (void)loginSuccessNotifi{
    ELog(@"===ep loginSuccessNotifi");
    [self initUIWithData];
    [self loginIm];
}

- (void)updateMsgNum:(NSNotification *)notification{
    NSNumber* msgCount = notification.userInfo[@"msgCount"];
    ELog(@"EP====msgCount:%@",msgCount);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:1];
        if (msgCount.intValue <= 0) {
            item.badgeValue = nil;
        }else{
            NSString* numStr;
            if (msgCount.integerValue > 99) {
                numStr = @"99+";
            }else{
                numStr = msgCount.stringValue;
            }
            item.badgeValue = numStr;
        }
    });
}

/** 钱袋子小红点通知 */
- (void)walletNotify{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[XSJUserInfoData sharedInstance] getIsShowMyInfoTabBarSmallRedPoint]) {
            [self.tabBarController.tabBar showSmallBadgeOnItemIndex:2];
        }
    });
}

- (void)showBaozhaoCheckRedPoint{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[XSJUserInfoData sharedInstance] getIsShowMyInfoTabBarSmallRedPoint]) {
            [self.tabBarController.tabBar showSmallBadgeOnItemIndex:2];
        }
    });
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        return;
    }
    
    if (buttonIndex == 1) {
        UITextField *nameTextField = [alertView textFieldAtIndex:0];
        if (!nameTextField.text || nameTextField.text.length < 2 || nameTextField.text.length > 5) {
            [UIHelper toast:@"请填写真实姓名"];
            [alertView show];
            return;
        }
        
        // 发送完善姓名的请求
        [[UserData sharedInstance] stuUpdateTrueName:nameTextField.text block:^(ResponseInfo *response) {
            if (response && response.success) {
                // 保存姓名
                [[UserData sharedInstance] setUserTureName:nameTextField.text];
                [UIHelper toast:@"提交成功"];
            }
        }];
    }
}


#pragma mark - viewAppear
#pragma mark - 刷新数据
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[UserData sharedInstance] isUpdateWithEPHome]) {
        [[UserData sharedInstance] setIsUpdateWithEPHome:NO];
        [self initUIWithData];
    }
    
    if (self.tableView.tableHeaderView) {
        if ([self.tableView.tableHeaderView respondsToSelector:@selector(playNews)]) {
            [self.tableView.tableHeaderView performSelector:@selector(playNews)];
        }
    }
}

- (void)dealloc{
    ELog(@"=====dealloc epmain");
    _epMainTableView = nil;
    _epInfo = nil;
    [WDNotificationCenter removeObserver:self];
}

@end
