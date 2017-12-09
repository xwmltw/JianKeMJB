//
//  ReportRecordModel.h
//  jianke
//
//  Created by 时现 on 15/10/27.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReportRecordModel : NSObject

@property (nonatomic, copy) NSString *resume_id;// 简历id
@property (nonatomic, copy) NSString *accont_id;//账户id
@property (nonatomic, copy) NSString *true_name;//姓名
@property (nonatomic, copy) NSString *profile_url;//头像
@property(nonatomic,strong) NSNumber *sex;  //性别
@property (nonatomic, strong) NSNumber *punch_the_clock_time;//<long>实际打卡时间，单位毫秒
@property (nonatomic, copy) NSString *punch_the_clock_lat; //纬度 小数点后六位
@property (nonatomic, copy) NSString *punch_the_clock_lng; //经度 小数点后六位
@property (nonatomic, copy) NSString *punch_the_clock_location;//打卡的具体位置
@property(nonatomic,strong) NSString *apply_job_id; //岗位id

@end
/*
请求Service:shijianke_entQueryStuPunchTheClockRecord
请求content
“content”: {
    “query_param”:{
        // 分页查询参数，请参考全局数据结构
    }，
    “”: <long>打卡请求id
   “punch_the_clock_request_id”: <long>打卡请求的id
}
应答content
“content”:{
    “punch_the_clock_list” : [   打卡列表(字段名与resumeInfo中的一致，只有以下字段有效)
                              {
                                  “resume_id”: xxxx, // 简历id
                                  “accont_id”:”xxx”//账户id
                                  “true_name”: “xxxx”, // 姓名
                                  “profile_url”:”xxx”,//头像
                                  “punch_the_clock_time”: <long>打卡时间的毫秒数
                                  “punch_the_clock_lat”:”xxxxxx”//纬度 小数点后六位
                                  “punch_the_clock_lng”:”xxxxxx”//经度 小数点后六位
                                  “punch_the_clock_location”: <string>打卡的具体位置
                                  
                              }
                              ]
}
*/