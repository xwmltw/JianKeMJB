//
//  PostJobCellModel.h
//  jianke
//
//  Created by fire on 15/9/23.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JobModel.h"
#import "CityModel.h"

@class GrabJobClassModel;
@interface PostJobCellModel : NSObject

@property (nonatomic, strong) JobModel *jobModel;
@property (nonatomic, strong) NSArray *grabJobClassModelArray;      /*!< 急速招人岗位分类数组, 存放GrabJobClassModel模型 */
@property (nonatomic, strong) NSArray *jobClassArray;               /*!< 普通岗位分类列表, 存放JobClassifierModel模型*/
@property (nonatomic, strong) GrabJobClassModel *selGrabJobClass;   /*!< 当前选择的急速招聘岗位类型 */

//@property (nonatomic, assign) CGFloat headerHeight;
//@property (nonatomic, assign) CGFloat middleHeight;
//@property (nonatomic, assign) CGFloat footerHeight;
//@property (nonatomic, assign) CGFloat normalJobMidellHeight;
//@property (nonatomic, assign) CGFloat defaultMiddleHeight;

@property (nonatomic, strong) NSDate *startDate;    /*!< 开始日期 */
@property (nonatomic, strong) NSDate *endDate;      /*!< 结束日期 */
@property (nonatomic, strong) NSDate *applyEndDate; /*!< 报名截止日期 */

//@property (nonatomic, strong) NSDate *startTime;
//@property (nonatomic, strong) NSDate *endTime;

@property (nonatomic, copy) NSString *normalMoneyStr;
@property (nonatomic, copy) NSString *quickMoneyStr;

@property (nonatomic, strong) CityModel *city;

@end
