//
//  PayExactWage_VC.h
//  jianke
//
//  Created by xiaomk on 16/7/7.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"

@interface PayExactWage_VC : WDViewControllerBase

@property (nonatomic, copy) NSString *jobId;
@property (nonatomic, copy) NSNumber *isAccurateJob;    /*!< 是否为精确岗位 */

@property (nonatomic, assign) BOOL isFromSingleDay;    /*!< 来自某一个日期不是已录用 */
@property (nonatomic, copy) NSString *on_board_time;    /*!< 上岗日期0点毫秒 */

- (void)getData;

- (BOOL)getIsHaveAddPayJianke;

@end
