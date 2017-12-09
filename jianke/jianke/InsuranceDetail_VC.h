//
//  InsuranceDetail_VC.h
//  jianke
//
//  Created by 时现 on 15/12/7.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDViewControllerBase.h"

@interface InsuranceDetail_VC : WDViewControllerBase
@property (nonatomic, copy) NSString* account_money_detail_list_id; //流水记录id
@property (nonatomic, assign) BOOL isFromMoneyBag;

@end
