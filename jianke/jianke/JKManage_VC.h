//
//  JKManage_VC.h
//  jianke
//
//  Created by xiaomk on 15/11/23.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"

@interface JKManage_VC : WDViewControllerBase

@property (nonatomic, copy) NSString *jobId; /*!< 岗位ID */
@property (nonatomic, assign) ManagerType managerType;
@property (nonatomic, copy) NSNumber* status;                       /*!< 岗位状态   1待审核, 2已发布 , 3已结束 */

- (void)allJkApplyBtnClick; /*!< 全部录用按钮点击 */

- (void)setApplyCount:(NSNumber *)num; /*!< 设置已报名人数 */
- (void)setEmployCount:(NSNumber *)num; /*!< 设置已录用人数 */

@end
