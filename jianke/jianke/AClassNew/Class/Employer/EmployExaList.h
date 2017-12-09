//
//  EmployExaList.h
//  jianke
//
//  Created by xiaomk on 16/7/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//


@class JobModel;
#import "WDViewControllerBase.h"

@protocol EmployListManagerDelegate <NSObject>
- (void)elm_changeToPayVC;    /*!< 设置显示的 vc */
@end


@interface EmployExaList : WDViewControllerBase

@property (nonatomic, weak) id <EmployListManagerDelegate> delegate;

@property (nonatomic, copy) NSString *jobId;            /*!< 岗位ID */
@property (nonatomic, copy) NSNumber *isAccurateJob;    /*!< 1是，0否 */
@property (nonatomic, assign) ManagerType managerType;  /*!< ManagerTypeEP | ManagerTypeBD */
@property (nonatomic, strong) JobModel *jobModel;

- (void)getData;

@end
