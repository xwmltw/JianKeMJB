//
//  BuyInsuranceModel.h
//  jianke
//
//  Created by 时现 on 16/1/9.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKModel.h"
@interface BuyInsuranceModel : NSObject

@property (nonatomic,strong) NSArray *resume_list;
@property (nonatomic,strong) NSNumber *resume_list_count;//投递数量
@property (nonatomic,strong) NSNumber *insurance_unit_price;//<int> 保险单价，单位为分
@property (nonatomic,strong) NSNumber *insurance_unit_payment_price;//<int>保险赔付总额，单位为分
@property (nonatomic,strong) NSNumber *job_start_time;
@property (nonatomic,strong) NSNumber *job_end_time;
@property (nonatomic, strong) NSMutableArray *timeArray;//日期数组


@end

@interface InsurancePolicyModel : NSObject

@property (nonatomic,strong) NSNumber *ping_an_insurance_policy_id;//上岗记录id
@property (nonatomic,strong) NSNumber *ping_an_insurance_policy_time;//上岗日期 0点毫秒
@property (nonatomic,strong) NSNumber *buy_status;//是否可购买保险，1：不可购买，2，已购买, 3，可购买

@end

@interface ResumeLModel : NSObject

@property (nonatomic, strong) JKModel  *resume_info;
@property (nonatomic, strong) NSNumber *apply_job_id;
@property (nonatomic, strong) NSArray *ping_an_insurance_policy_list;


@property (nonatomic, strong) NSArray *exapcArray;
@property (nonatomic, strong) NSNumber  *job_start_time;//岗位开始日期
@property (nonatomic, strong) NSNumber  *job_end_time;//岗位结束日期
@property (nonatomic,strong) NSNumber *insurance_unit_price;//<int> 保险单价，单位为分
@property (nonatomic, assign) NSInteger nowPay;//修改后的薪资  需要支付的金额
@property (nonatomic, strong) NSMutableArray *onBoardDate;//需要支付薪资的日期的数组
@property (nonatomic, assign) long long allDays;

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, assign) BOOL isHasDate;

@end






@interface ExaBuyCellModel : NSObject
@property (nonatomic, assign) long long timeStamp;
@property (nonatomic, assign) NSInteger buyStatus;  //，1：不可购买，2，已购买, 3，可购买
@end



@interface InsuranceDataListModel : NSObject

@property (nonatomic,strong) NSNumber *apply_job_id;
@property (nonatomic,strong) NSArray  *insurance_date_list;

@end
//“content”:
//{
//    “resume_list”:[:
//                   {
//                       “apply_job_id”:// 申请岗位id
//                       “resume_info”:
//                          {
//                           “true_name”:// 兼客姓名
//                           “user_profile_url”：// 兼客头像
//                           “sex”:// 性别
//                           “stu_work_time”:[
//                                            “1447862400000”,
//                                            “1447862400000”
//                                            ]// 上岗时间时间戳数组（秒数）
//                           “stu_work_time_type”:// 1：兼客选择    2：默认
//                          }
//                       “ping_an_insurance_policy_list”:[
//                                                        {
//                                                            “ping_an_insurance_policy_id”:xxxx, 上岗记录id
//                                                            “ping_an_insurance_policy_time”::xxxx, 上岗日期 0点毫秒
//                                                            “buy_status”: <int> 是否可购买保险，1：不可购买，2，已购买, 3，可购买
//                                                            
//                                                        }
//                                                        ]
//                   }
//                   ]，
//    “resume_list_count”://投递数量
//    “insurance_unit_price: <int> 保险单价，单位为分
//    “insurance_unit_payment_price”:<int>保险赔付总额，单位为分
//}