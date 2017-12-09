//
//  JiankeManage_VC.h
//  jianke
//
//  Created by xiaomk on 16/6/29.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKSlideBase_VC.h"

@class JobModel;
@interface JiankeManage_VC : MKSlideBase_VC

@property (nonatomic, copy) NSString *jobId; /*!< 岗位ID */
@property (nonatomic, copy) NSNumber *isAccurateJob;    /*!< 1是，0否 */
@property (nonatomic, assign) ManagerType managerType;
@property (nonatomic, strong) JobModel *jobModel;
@property (nonatomic, assign) BOOL isClose;

@end
