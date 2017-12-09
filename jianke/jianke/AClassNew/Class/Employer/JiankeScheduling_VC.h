//
//  JiankeScheduling_VC.h
//  jianke
//
//  Created by xiaomk on 16/7/20.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"

@interface JiankeScheduling_VC : WDViewControllerBase

@property (nonatomic, copy) NSString *jobId;
@property (nonatomic, copy) NSNumber *on_board_date;
@property (nonatomic, copy) MKBlock block;

@end
