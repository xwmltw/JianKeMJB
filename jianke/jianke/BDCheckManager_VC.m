//
//  BDCheckManager_VC.m
//  jianke
//
//  Created by xiaomk on 16/4/14.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "BDCheckManager_VC.h"
#import "BDCheck_VC.h"

@interface BDCheckManager_VC (){
    

}

@end

@implementation BDCheckManager_VC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [XSJUserInfoData sharedInstance].isShowEpBaozhaoCheckRedPoint = NO;
    if (![[XSJUserInfoData sharedInstance] getIsShowMyInfoTabBarSmallRedPoint]) {
        [self.tabBarController.tabBar hideSmallBadgeOnItemIndex:2];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"包招账单";

    [self initTopWithLeftTitle:@"未支付" rightTitle:@"已支付"];
    
    BDCheck_VC* leftVC = [[BDCheck_VC alloc] init];
    leftVC.checkType = BDCheckType_NoPay;
    [self addChildViewController:leftVC];
    [self setLView:leftVC.view];
    
    BDCheck_VC* rightVC = [[BDCheck_VC alloc] init];
    rightVC.checkType = BDCheckType_PayYet;
    [self addChildViewController:rightVC];
    [self setRView:rightVC.view];
}

- (void)dealloc{
    DLog(@"BDCheckManager_VC dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
