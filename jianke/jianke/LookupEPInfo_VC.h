//
//  LookupEPInfo_VC.h
//  jianke
//
//  Created by xiaomk on 15/9/30.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDConst.h"
#import "WDViewControllerBase.h"

@interface LookupEPInfo_VC : WDViewControllerBase

@property (nonatomic, assign, getter=isLookOther) BOOL lookOther;
@property (nonatomic, copy) NSString* enterpriseId;

@property (nonatomic, copy) NSString* accountId;
@property (nonatomic, assign) BOOL isFromGroupMembers;

@end
