//
//  PayExactWageManager_VC.h
//  jianke
//
//  Created by xiaomk on 16/7/25.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"

@class JobModel;
@interface PayExactWageManager_VC : WDViewControllerBase

@property (nonatomic, copy) NSString *jobId;
@property (nonatomic, copy) NSNumber *isAccurateJob;    /*!< 是否为精确岗位 */
@property (nonatomic, strong) JobModel *jobModel;

@property (nonatomic, assign) BOOL isFromSingleDay;    /*!< 来自某一个日期不是已录用 */
@property (nonatomic, assign) BOOL isMutiVC;  /*!< 是否是独立的VC 影响到self.view的height问题 */
@property (nonatomic, weak) UIViewController *popToVC;

- (void)setNeedRefresh;
- (void)getDataWhenShow;

@end
