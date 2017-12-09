//
//  ManualAddPerson_VC.h
//  jianke
//
//  Created by fire on 16/7/5.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDViewControllerBase.h"

@interface ManualAddPerson_VC : WDViewControllerBase


@property (nonatomic, copy) NSString *job_id;   /** 岗位ID */
@property (nonatomic, copy)  MKBlock block;

@property (nonatomic, assign) BOOL isFromPayView;

@end
