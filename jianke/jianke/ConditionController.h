//
//  ConditionController.h
//  jianke
//
//  Created by fire on 15/11/18.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MKBaseTableViewController.h"

@class JobModel;

@interface ConditionController : MKBaseTableViewController

@property (nonatomic, strong) JobModel *jobModel;
@property (nonatomic, strong) NSDate *startDate;    /*!< 开始日期 */
@property (nonatomic, strong) NSDate *endDate;      /*!< 结束日期 */
@property (nonatomic, copy) MKBlock block;  /*!< 回调赋值 */
@end
