//
//  GroupMessageController.h
//  jianke
//
//  Created by fire on 15/12/9.
//  Copyright © 2015年 xianshijian. All rights reserved.
//  群发消息

#import "WDViewControllerBase.h"

@interface GroupMessageController : WDViewControllerBase

@property (nonatomic, copy) NSNumber *receiveDate;      /*!< 发送个这个上岗日期的兼客 */
@property (nonatomic, copy) NSString *account_id;       /*!< ID列表 ，分割 */
@property (nonatomic, copy) NSString *jobId;            /*!< 岗位ID */

@property (nonatomic, assign) BOOL isSendApplyYet;      /*!< 是否发送给已报名的兼客  否则为已录用*/
@end
