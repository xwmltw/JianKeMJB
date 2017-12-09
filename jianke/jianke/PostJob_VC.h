//
//  PostJob_VC.h
//  jianke
//
//  Created by xiaomk on 16/4/18.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewController.h"
#import "WDConst.h"

@class CityModel, JobModel;

typedef NS_ENUM(NSInteger, PostJobCellType) {
    PostJobCellType_title           = 1,
    PostJobCellType_jobType,
    PostJobCellType_date,               //选择 开始 结束日期
    PostJobCellType_time,
    PostJobCellType_applyEndDate,
    PostJobCellType_jobTag,
    PostJobCellType_restrict,
    PostJobCellType_welfare,
    PostJobCellType_detail,
    PostJobCellType_area,
    PostJobCellType_concentrate,
    PostJobCellType_contact,
    PostJobCellType_maxJKCount,         //总人数
    PostJobCellType_payMoney,
    PostJobCellType_payType,
    PostJobCellType_send,
    PostJobCellType_remind,
};


@interface PostJob_VC : MKBaseTableViewController

@property (nonatomic, assign) PostJobType postJobType;  /*!< 岗位发布类型 */
@end
