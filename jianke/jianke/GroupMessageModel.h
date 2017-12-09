//
//  GroupMessageModel.h
//  jianke
//
//  Created by fire on 15/12/9.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface GroupMessageModel : NSObject

@property (nonatomic, strong) NSNumber *jobId; /*!< 岗位ID */
@property (nonatomic, copy) NSString *receiver; /*!< 接收者 */
@property (nonatomic, strong) NSNumber *postTime; /*!< 发布时间 */
@property (nonatomic, copy) NSString *postContent; /*!< 消息内容 */


@end
