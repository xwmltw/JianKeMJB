//
//  PayWage_VC.h
//  jianke
//
//  Created by xiaomk on 16/7/7.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"

@interface PayWage_VC : WDViewControllerBase

@property (nonatomic, copy) NSString *jobId;
@property (nonatomic, weak) UIViewController *popToVC;

- (BOOL)getIsHaveAddPayJianke;

- (void)setNeedRefresh;
- (void)getDataWhenShow;
@end
