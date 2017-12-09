//
//  PostJobModel.h
//  jianke
//
//  Created by fire on 15/10/6.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//  发布岗位的模型

#import <Foundation/Foundation.h>
#import "SalaryModel.h"
#import "ContactModel.h"
#import "EPModel.h"
#import "ShareInfoModel.h"
#import "ParamModel.h"
#import "MJExtension.h"
#import "WorkTimePeriodModel.h"
#import "WelfareModel.h"

@interface PostJobModel : ParamModel

@property (nonatomic, copy) NSNumber* job_id;               /*!< 岗位id */
@property (nonatomic, copy) NSString* job_title;            /*!< 岗位名称 */
@property (nonatomic, copy) NSNumber* job_type_id;          /*!< 岗位分类id */
@property (nonatomic, copy) NSNumber* job_type;             /*!< 岗位类型，1表示普通岗位，2表示抢单岗位，如果没传这个字段，默认是1 */
@property (nonatomic, copy) NSArray* job_label;                /*!< 岗位标签，只有抢单抢单岗位有这个字段 */
@property (nonatomic, copy) NSString* working_place;        /*!< 工作地点 */
@property (nonatomic, copy) NSNumber* work_time_start;      /*!< <long> 工作开始时间，1970年1月1日至今的秒数， */
@property (nonatomic, copy) NSNumber* work_time_end;        /*!< <long> 工作结束开始时间，1970年1月1日至今的秒数， */
@property (nonatomic, copy) NSNumber* recruitment_num;      /*!< 招聘人数 */
@property (nonatomic, copy) NSString* job_desc;             /*!< 岗位描述 */
@property (nonatomic, copy) NSNumber* city_id;              /*!< 城市ID, 整形数字  */
@property (nonatomic, copy) NSNumber* address_area_id;      /*!< 区域ID , 整形数字 */
@property (nonatomic, copy) NSString *area_code;            /*!< 城市区号 */
@property (nonatomic, copy) NSString *admin_code;           /*!< 区域行政区号 */
@property (nonatomic, copy) NSString* address_area_name;    /*!< 区域名称 */
@property (nonatomic, strong) SalaryModel* salary;                  /*!< 薪水 */
@property (nonatomic, strong) ContactModel* contact;                /*!<联系人 */
@property (nonatomic, copy) NSString *map_coordinates; /*!< 岗位地图坐标,横坐标和纵坐标以逗号隔开,如 10.123456, 20.123456 */

// 2.2
@property (nonatomic, strong) NSNumber *working_time_start_date; /*!< <long>工作时间的开始日期，1970年1月1日至今的毫秒数 */
@property (nonatomic, strong) NSNumber *working_time_end_date; /*!< <long>工作结束的日期，1970年1月1日至今的毫秒数 */
@property (nonatomic, strong) WorkTimePeriodModel *working_time_period; /*!< 工作时间段 */

// 2.3
@property (nonatomic, strong) NSNumber *sex; /*!< 性别限制 空：不限制 1：限制男 0：限制女 */
@property (nonatomic, strong) NSNumber *age; /*!< 年龄限制 0：不限制 1：18周岁以上 2：18-25周岁 3：25周岁以上 */
@property (nonatomic, strong) NSNumber *height; /*!< 身高限制 0：不限 1：160cm以上 2：165cm以上 3：168cm以上 4：170cm以上 5：175cm以上 6：180cm以上 */
@property (nonatomic, strong) NSNumber *rel_name_verify; /*!< 身份证限制 0：不限 1：限制 */
@property (nonatomic, strong) NSNumber *life_photo; /*!< 生活照限制 0：不限 1：限制 */
@property (nonatomic, strong) NSNumber *apply_job_date; /*!< 上岗时间限制 0：不限 1：2天以上 2：3天以上 3：5天以上 4：全部到岗 */
@property (nonatomic, strong) NSNumber *health_cer; /*!< 健康证限制 0：不限 1：限制 */
@property (nonatomic, strong) NSNumber *stu_id_card; /*!< 学生证限制 0：不限 1：限制 */

@property (nonatomic, copy) NSString *job_classfie_name; /*!< 岗位分类名称 */
@property (nonatomic, strong) NSNumber *enable_recruitment_service; /*!< <int>是否委托招聘(包招) 0否 1是，默认0 */

@property (nonatomic, strong) NSArray *job_tags;

@property (nonatomic, strong) NSNumber *apply_dead_time; /*!< 报名截止时间, 1970.1.1至今毫秒数 */
//2.8
@property (nonatomic, strong) NSArray *job_type_label; /*!< 发布包招岗位选择的岗位分类标签 */
@property (nonatomic, strong) NSNumber *ent_publish_price;   /*!< 雇主发布价 以分为单位 */

/** 自定义添加   */
@property (nonatomic, copy) NSNumber *recruitment_amount;       /*!< 招聘余额 合伙人发布岗位用 */

@end



