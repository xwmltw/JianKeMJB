//
//  TalentModel.h
//  jianke
//
//  Created by fire on 15/10/22.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface TalentModel : NSObject

@property (nonatomic, copy) NSString *resume_id; /*!< 简历id */
@property (nonatomic, copy) NSString *true_name; /*!< 姓名 */
@property (nonatomic, copy) NSString *profile_url; /*!< 头像 */
@property (nonatomic, copy) NSString *account_id; /*!< 账户id */
@property (nonatomic, strong) NSNumber *evalu_byent_level_avg; /*!< 评价星级平均值 */
@property (nonatomic, strong) NSNumber *talent_pool_status; /*!< 人才库的状态：1：未删除；2：被删除 */
@property (nonatomic, copy) NSString *talent_pool_id; /*!< 人才库id */

@end



/** 
 请求Service	shijianke_entQueryTalentPool
 请求content	“content”:{
	“query_param”:{
 // 分页查询参数，请参考全局数据结构
 }，
 “talent_pool_status”: <int>查询内容的类型：1：未删除的；2：被删除的
 }
 应答content	“content”:{
 “list”:[ // 字段名与resumeInfo中的一致，只有以下字段有效
 “resume_id”: xxxx, // 简历id
 “true_name”: “xxxx”, // 姓名
 “profile_url”:”xxx”,//头像
 “account_id”:”xxx”//账户id
	“evalu_byent_level_avg” ; // 评价星级平均值
 “talent_pool_status”:  <int>人才库的状态：1：未删除；2：被删除，
 “talent_pool_id”: <int>人才库id
 ]
 “normal_count”: <int>未删除的数量,
 “deleted_count”:<int>被删除的数量
 }
 
 */