//
//  EmployList_TV.h
//  jianke
//
//  Created by xiaomk on 15/11/24.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDViewControllerBase.h"
#import "MKSlideBase_VC.h"

@class JobModel;
@protocol EmployListDelegate <NSObject>

- (void)eld_setSelectVcWithIndex:(NSInteger)index;

@end

@interface EmployList_TV :WDViewControllerBase

@property (nonatomic, weak) id <EmployListDelegate> delegate;

@property (nonatomic, copy) NSString *jobId; /*!< 岗位ID */
@property (nonatomic, copy) NSNumber *isAccurateJob; /*!< 是否精确岗位 */
@property (nonatomic, assign) ManagerType managerType;
@property (nonatomic, strong) JobModel *jobModel;

- (void)setNeedRefresh;
- (void)getDataWhenShow;
@end
