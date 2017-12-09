//
//  PersonnelManager_VC.h
//  jianke
//
//  Created by xiaomk on 16/7/3.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"
#import "MKSlideBase_VC.h"

@protocol PersonnelManagerDelegate <NSObject>
- (void)pmd_setTitle:(NSString *)title withIndex:(NSInteger)titleIndex;
- (void)pmd_setOtherVcRefreshStatus;
@end

@interface PersonnelManager_VC : WDViewControllerBase

@property (nonatomic, weak) id <PersonnelManagerDelegate> delegate;

@property (nonatomic, copy) NSString *jobId;            /*!< 岗位ID */
@property (nonatomic, copy) NSNumber *isAccurateJob;    /*!< 1是，0否 */
@property (nonatomic, assign) ManagerType managerType;  /*!< ManagerTypeEP | ManagerTypeBD */

- (void)getData;

@end
