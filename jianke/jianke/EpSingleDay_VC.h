//
//  EpSingleDay_VC.h
//  jianke
//
//  Created by xiaomk on 15/11/28.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"
#import "EmployExaList.h"

@interface EpSingleDay_VC : WDViewControllerBase

@property (nonatomic, weak) id <EmployListManagerDelegate> delegate;

@property (nonatomic, copy) NSString *jobId; /*!< 岗位ID */
@property (nonatomic, copy) NSNumber *isAccurateJob;
@property (nonatomic, assign) ManagerType managerType;

@property (nonatomic, copy) NSNumber* boardDate;
@property (nonatomic, assign) BOOL isTaday;
@property (nonatomic, assign) BOOL isHaveShow;
@property (nonatomic, copy) NSNumber *status;                       /*!< 岗位状态   1待审核, 2已发布 , 3已结束 */

@property (nonatomic, strong) NSArray *boardDateArray;

//- (void)getLastDataList;

- (void)getDatas;
@end
