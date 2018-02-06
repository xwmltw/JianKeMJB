//
//  MainTabBarCtlMgr.m
//  jianke
//
//  Created by xiaomk on 16/6/14.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MainTabBarCtlMgr.h"

#import "JKHome_VC.h"
#import "ZBHome_VC.h"
#import "IMHome_VC.h"
#import "MyInfo_VC.h"
#import "MyInfoCollect_VC.h"
#import "EmployerMain_VC.h"
#import "JKApplyJobListController.h"
#import "MyNewInfo_VC.h"
#import "ParttimeJobList_VC.h"

#import "WDConst.h"

@interface MainTabBarCtlMgr()<UITabBarControllerDelegate>{
    TabBarSwitchVC _nextVC;
}
@property (nonatomic, strong) UITabBarController *rootTabbarCtl;
@end

@implementation MainTabBarCtlMgr

Impl_SharedInstance(MainTabBarCtlMgr);

- (void)creatJKTabbar:(MKBlock)block{
    MKBlockExec(block, [self getJKTabbarCtrl]);
}

- (void)creatJKTabbar{
    [self getJKTabbarCtrl];
    UIViewController* current = [MKUIHelper getCurrentRootViewController];
    current.view.window.rootViewController = self.rootTabbarCtl;
}

- (UITabBarController *)getJKTabbarCtrl{
    JKHome_VC *vc1 = [[JKHome_VC  alloc] init];
    MainNavigation_VC *nav1 = [[MainNavigation_VC alloc] initWithRootViewController:vc1];
    nav1.tabBarItem.title = @"首页";
    nav1.tabBarItem.image = [UIImage imageNamed:@"home_tabbar_1_0"];
    nav1.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_tabbar_1_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [nav1.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor XSJColor_tGrayDeepTinge]} forState:UIControlStateSelected];
    
    
    NSArray *tabbarCtrls;
    
    ClientGlobalInfoRM *globalInfoRM = [[XSJRequestHelper sharedInstance] getClientGlobalModel];
    
    ParttimeJobList_VC *vc2 = [[ParttimeJobList_VC  alloc] init];
    MainNavigation_VC *nav2 = [[MainNavigation_VC alloc] initWithRootViewController:vc2];
    nav2.tabBarItem.title = @"岗位";
    nav2.tabBarItem.image = [UIImage imageNamed:@"TabBerPost"];
    nav2.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBerPost"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [nav2.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor XSJColor_tGrayDeepTinge]} forState:UIControlStateSelected];
    
    
        IMHome_VC *vc3 = [[IMHome_VC  alloc] init];
        MainNavigation_VC *nav3 = [[MainNavigation_VC alloc] initWithRootViewController:vc3];
        nav3.tabBarItem.title = @"消息";
        nav3.tabBarItem.image = [UIImage imageNamed:@"home_tabbar_3_0"];
        nav3.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_tabbar_3_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [nav3.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor XSJColor_tGrayDeepTinge]} forState:UIControlStateSelected];
    
    ZBHome_VC *vc5 = [[ZBHome_VC  alloc] init];
    MainNavigation_VC *nav5 = [[MainNavigation_VC alloc] initWithRootViewController:vc5];
    nav5.tabBarItem.title = @"任务";
    nav5.tabBarItem.image = [UIImage imageNamed:@"home_tabbar_ZB_2_1"];
    nav5.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_tabbar_ZB_2_0"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        MyNewInfo_VC *vc4 = [[MyNewInfo_VC  alloc] init];
        MainNavigation_VC *nav4 = [[MainNavigation_VC alloc] initWithRootViewController:vc4];
        nav4.tabBarItem.title = @"个人中心";
        nav4.tabBarItem.image = [UIImage imageNamed:@"home_tabbar_4_0"];
        nav4.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_tabbar_4_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        [nav4.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor XSJColor_tGrayDeepTinge]} forState:UIControlStateSelected];
    
    if (globalInfoRM.is_not_support_zhong_bao.integerValue != 1) {
        // 众包入口
        tabbarCtrls = @[nav1,nav2,nav5,nav3,nav4];
        
    }else{
        tabbarCtrls = @[nav1,nav2,nav3,nav4];
    }
    self.rootTabbarCtl.viewControllers = nil;
    if (self.rootTabbarCtl.presentedViewController) {
        [self.rootTabbarCtl dismissViewControllerAnimated:NO completion:nil];
    }
    [self.rootTabbarCtl.tabBar clearAllSmallBadge];
    
    self.rootTabbarCtl.viewControllers = tabbarCtrls;
//        [UIHelper setKeyWindowWithVC:self.rootTabbarCtl];
    return self.rootTabbarCtl;
}

- (void)creatEPTabbar{
    [self getEpTabbarCtrl];
    UIViewController* current = [MKUIHelper getCurrentRootViewController];
    current.view.window.rootViewController = self.rootTabbarCtl;
}

- (void)creatEPTabbar:(MKBlock)block{
    MKBlockExec(block, [self getEpTabbarCtrl]);
}

- (UITabBarController *)getEpTabbarCtrl{
    EmployerMain_VC *vc1 = [[EmployerMain_VC  alloc] init];
    MainNavigation_VC *nav1 = [[MainNavigation_VC alloc] initWithRootViewController:vc1];
    nav1.tabBarItem.title = @"首页";
    nav1.tabBarItem.image = [UIImage imageNamed:@"home_tabbar_1_0"];
    nav1.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_tabbar_1_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    IMHome_VC *vc2 = [[IMHome_VC  alloc] init];
//    MainNavigation_VC *nav2 = [[MainNavigation_VC alloc] initWithRootViewController:vc2];
//    nav2.tabBarItem.title = @"岗位";
//    nav2.tabBarItem.image = [UIImage imageNamed:@"home_tabbar_3_0"];
//    nav2.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_tabbar_3_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    IMHome_VC *vc3 = [[IMHome_VC  alloc] init];
    MainNavigation_VC *nav3 = [[MainNavigation_VC alloc] initWithRootViewController:vc3];
    nav3.tabBarItem.title = @"消息";
    nav3.tabBarItem.image = [UIImage imageNamed:@"home_tabbar_3_0"];
    nav3.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_tabbar_3_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    MyInfo_VC *vc4 = [[MyInfo_VC alloc] init];
    MainNavigation_VC *nav4 = [[MainNavigation_VC alloc] initWithRootViewController:vc4];
    nav4.tabBarItem.title = @"个人中心";
    nav4.tabBarItem.image = [UIImage imageNamed:@"home_tabbar_4_0"];
    nav4.tabBarItem.selectedImage = [[UIImage imageNamed:@"home_tabbar_4_1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.rootTabbarCtl.viewControllers = nil;
    [self.rootTabbarCtl.tabBar clearAllSmallBadge];
    self.rootTabbarCtl.viewControllers = @[nav1,nav3,nav4];
    self.rootTabbarCtl.selectedIndex = 0;
    
    return self.rootTabbarCtl;
}

- (UITabBarController *)rootTabbarCtl{
    if (!_rootTabbarCtl) {
        _rootTabbarCtl = [[UITabBarController alloc] init];
        _rootTabbarCtl.tabBar.tintColor = [UIColor XSJColor_base];
        _rootTabbarCtl.delegate = self;
        _rootTabbarCtl.tabBar.translucent = NO;
    }
    return _rootTabbarCtl;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[MainNavigation_VC class]]) {
        MainNavigation_VC *nav = (MainNavigation_VC *)viewController;
        if (nav.childViewControllers.count > 0) {
            if ([[nav.childViewControllers firstObject] isKindOfClass:[IMHome_VC class]]){
                if (![[UserData sharedInstance] isLogin]) {
                    if ([[UserData sharedInstance] getLoginType].integerValue == WDLoginType_Employer) {
                        _nextVC = TabBarSwitchVC_EPIM;
                    }else{
                        _nextVC = TabBarSwitchVC_JKIM;
                    }
                    [self showLoginViewWithShowGuide:YES];
                    return NO;
                }
            }
        }
    }
    return YES;
}

- (void)showLoginView{
//    WEAKSELF
//    [[UserData sharedInstance] userIsLogin:^(id result) {
//        if (result) {
//            [weakSelf showVC];
//        }else{
//            _nextVC = TabBarSwitchVC_None;
//        }
//    }];
    [self showLoginViewWithShowGuide:NO];
}

- (void)showLoginViewWithShowGuide:(BOOL)isShowGuide{
    WEAKSELF
    [[UserData sharedInstance] userIsLogin:isShowGuide block:^(id result) {
        if (result) {
            [weakSelf showVC];
        }else{
            _nextVC = TabBarSwitchVC_None;
        }
    }];
}

- (void)showVC{
    if (_nextVC < 0)  return;
    NSInteger index = -1;
    switch (_nextVC) {
        case TabBarSwitchVC_JKApplyJobListVC:
        case TabBarSwitchVC_EPIM:
            index = 1;
            break;
        case TabBarSwitchVC_JKIM:
            index = 2;
            break;
        default:
            break;
    }
    if (index >= 0 && index < self.rootTabbarCtl.viewControllers.count) {
        [self.rootTabbarCtl setSelectedIndex:index];
    }
}

- (void)setSelectWithIndex:(NSInteger)index{
    if (self.rootTabbarCtl.viewControllers.count > index) {
        [self.rootTabbarCtl setSelectedIndex:index];
    }
}

- (void)setSelectMsgTab{
    if (self.rootTabbarCtl.viewControllers.count > 2) {
//        if ([[UserData sharedInstance] getLoginType].integerValue == WDLoginType_Employer) {
//            [self setSelectWithIndex:1];
//        }else{
            [self setSelectWithIndex:3];
//        }
    }

}

//- (void)setApplyJobTab:(NSInteger)showIndex{
//    if ([[UserData sharedInstance] getLoginType].integerValue == WDLoginType_JianKe) {
//        self.rootTabbarCtl.selectedIndex = 1;
//        MainNavigation_VC *nav = [self.rootTabbarCtl.viewControllers objectAtIndex:1];
//        nav.view;
//        [nav popToRootViewControllerAnimated:YES];
//        ServiceMange_VC *vc = nav.viewControllers.firstObject;
//        vc.selectedIndex = showIndex;
//    }
//}

- (void)showMyApplyCtrlOnCtrl:(UIViewController *)vc{
    JKApplyJobListController *vc2 = [[JKApplyJobListController  alloc] init];
    vc2.hidesBottomBarWhenPushed = YES;
    if (vc.navigationController) {
        [vc.navigationController pushViewController:vc2 animated:YES];
    }
}

@end
