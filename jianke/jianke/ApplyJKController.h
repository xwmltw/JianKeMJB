//
//  ApplyJKController.h
//  jianke
//
//  Created by fire on 15/9/29.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDViewControllerBase.h"

@interface ApplyJKController : WDViewControllerBase

@property (nonatomic, copy) NSString *jobId; /*!< 岗位ID */
@property (nonatomic, copy) NSNumber *isAccurateJob;
@property (nonatomic, assign) ManagerType managerType;
@property (nonatomic, copy) MKBoolBlock blockBack;

@end
