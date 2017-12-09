//
//  JiankeCollection_VC.h
//  jianke
//
//  Created by fire on 16/9/6.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

typedef NS_ENUM(NSUInteger, JKBannerType) {
    JKBannerType_JianLi,
    JKBannerType_Add,
    JKBannerType_Manage,
    JKBannerType_IM,
    JKBannerType_Record,
    JKBannerType_Salary,
    JKBannerType_NotifRecord,
    JKBannerType_OutPut,
    JKBannerType_jobVas
};

@class JobModel;
#import "WDViewControllerBase.h"

@interface JiankeCollection_VC : WDViewControllerBase

@property (nonatomic, copy) NSString *jobId; /*!< 岗位ID */
@property (nonatomic, copy) NSNumber *isAccurateJob;    /*!< 1是，0否 */
@property (nonatomic, assign) ManagerType managerType;
@property (nonatomic, strong) JobModel *jobModel;
@property (nonatomic, assign) BOOL isClose;
//@property (nonatomic, copy) NSNumber *jobId;

@end
