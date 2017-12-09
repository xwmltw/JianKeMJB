//
//  InsuranceDetailModel.h
//  jianke
//
//  Created by 时现 on 16/1/12.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsuranceDetailModel : NSObject

@property (nonatomic, strong) NSNumber *account_id;
@property (nonatomic, copy) NSString *true_name;
@property (nonatomic, copy) NSString *user_profile_url;
@property (nonatomic, strong) NSNumber *sex;
@property (nonatomic, strong) NSNumber *insurance_ent_unit_price;//保险金额，单位为分
@property (nonatomic, strong) NSNumber *insurance_policy_status;//投保状态，1进行中，2结束
@property (nonatomic, strong) NSNumber *insurance_policy_close_type;//保单关闭状态，1成功，2失败
@property (nonatomic, strong) NSNumber *insurance_time;//保险生效日期的毫秒数


@end

/**
 *  “stu_list”: [{
 “account_id”: <long> // 账号id
 “true_name”: “xxxx”, // 姓名
 “profile_url”:”xxx”,//头像
 “sex”: xx, // 枚举，具体定义请参考数据字典
 “insurance_ent_unit_price”,<int>, // 保险金额，单位为分      
 “insurance_policy_status”: <int>投保状态，1进行中，2结束
 “insurance_policy_close_type”: <int>保单关闭状态，1成功，2失败
 “insurance_time”: <long> 保险生效日期的毫秒数
	}
 */