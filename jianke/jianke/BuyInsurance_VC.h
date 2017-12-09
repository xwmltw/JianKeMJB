//
//  BuyInsurance_VC.h
//  jianke
//
//  Created by 时现 on 15/12/9.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDViewControllerBase.h"

@interface BuyInsurance_VC : WDViewControllerBase

@property (nonatomic, strong) NSNumber *jobID;
@property (nonatomic, strong) NSNumber* isAccurateJob; /*!< 是否为精确岗位 */
@property (nonatomic, weak) UIViewController *popToVC;

@end
