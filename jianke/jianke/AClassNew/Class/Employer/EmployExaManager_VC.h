//
//  EmployExaManager_VC.h
//  jianke
//
//  Created by xiaomk on 16/7/5.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"
#import "MKSlideBase_VC.h"

@class JobModel;

@protocol EmployExaManagerDelegate <NSObject>

- (void)changeSelectVcWithIndex:(NSInteger)vcIndex showDetailIndex:(NSInteger)detailIndex;
@end


@interface EmployExaManager_VC : WDViewControllerBase

@property (nonatomic, weak) id <EmployExaManagerDelegate> delegate;

@property (nonatomic, copy) NSString *jobId; /*!< 岗位ID */
@property (nonatomic, copy) NSNumber *isAccurateJob;    /*!< 1是，0否 */
@property (nonatomic, assign) ManagerType managerType; /*!< ManagerTypeEP | ManagerTypeBD */

@property (nonatomic, strong) JobModel *jobModel;
@property (nonatomic, assign) BOOL isMutiVC;    /*!< 是否为单个VC 自V3.0.7 有高度及业务问题 */


- (void)setNeedRefresh;
- (void)getDataWhenShow;

@end
