//
//  ApplyJobModel.h
//  jianke
//
//  Created by xiaomk on 16/4/23.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseModel.h"

@interface ApplyJobModel : MKBaseModel
@property (nonatomic, copy) NSArray* apply_job_resume_list;     /*!<  参考全局数据结构的简历信息 */
@property (nonatomic, copy) NSNumber* job_start_time;           /*!< 岗位开始日期 时间戳(毫秒) */
@property (nonatomic, copy) NSNumber* job_end_time;             /*!< 岗位结束日期 */
@property (nonatomic, copy) NSString* job_title;                /*!< 岗位名称 */
@property (nonatomic, copy) NSNumber* apply_job_list_count;     /*!< 投递数量 */
@property (nonatomic, copy) NSNumber* apply_list_page_count;    /*!< 已报名列表页面数量 */
@property (nonatomic, copy) NSNumber* hire_list_page_count;     /*!< 已录用列表页面数量 */

@end


//“content”:{
//    “apply_job_resume_list”:[:
//                             { resumeInfo  // 参考全局数据结构的简历信息
//                             }
//                             ]，
//    “job_title”://岗位名称
//    “job_start_time”:// 岗位开始日期 时间戳(毫秒)
//    “job_end_time”:// 岗位结束日期
//    “apply_job_list_count”://投递数量
//    “apply_list_page_count”:// 已报名列表页面数量
//    “hire_list_page_count”:// 已录用列表页面数量
//    “query_param”: {
//        // 分页参数，请参考全局数据结构
//    },
//}
