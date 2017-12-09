//
//  HistoryPostJob_VC.h
//  jianke
//
//  Created by xiaomk on 16/8/23.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"

@interface HistoryPostJob_VC : WDViewControllerBase

@property (nonatomic, assign) PostJobType postJobType;  /*!< 岗位发布类型 */

@property (nonatomic, copy) MKBlock block;

@end
