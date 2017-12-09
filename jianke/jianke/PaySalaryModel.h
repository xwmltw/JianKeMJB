//
//  PaySalaryModel.h
//  jianke
//
//  Created by 时现 on 15/11/24.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKModel.h"

@interface PaySalaryModel : NSObject
@property (nonatomic, copy) NSNumber *resume_list_count;    /*!< 投递数量 */
@property (nonatomic, copy) NSNumber *job_start_time;       /*!< 岗位开始日期 */
@property (nonatomic, copy) NSNumber *job_end_time;         /*!< 岗位结束日期 */
@property (nonatomic, copy) NSString *job_title;            /*!< 岗位名称 */
@property (nonatomic, copy) NSNumber *job_day_salary;       /*!< 日薪 */
@property (nonatomic, strong) NSArray *resume_list;         /*!< 兼客列表 */

//@property (nonatomic, strong) NSMutableArray *timeArray;    /*!< 日期数组 自定义 */
@end

@interface ResumeListModel : NSObject
@property (nonatomic, strong) JKModel  *resume_info;        /*!< 兼客信息 */
@property (nonatomic, copy) NSNumber *apply_job_id;         /*!< 申请岗位id */
@property (nonatomic, copy) NSNumber *ent_pay_salary;       /*!< 企业支付的薪水 */
@property (nonatomic, copy) NSNumber *stu_unPunck_num;      /*!< 兼客未打卡次数 */
@property (nonatomic, strong) NSArray  *on_board_time_list; /*!< 每个人的上岗信息 */

//====自定义添加  勿删======
@property (nonatomic, assign) BOOL isSelect;                /*!< cell 是否选中 */
@property (nonatomic, strong) NSArray   *exaPayArray;
@property (nonatomic, copy) NSNumber  *job_day_salary;      /*!< 日薪 */
@property (nonatomic, assign) NSInteger selectSumDays;
@property (nonatomic, copy) NSNumber  *job_start_time;      /*!< 岗位开始日期 */
@property (nonatomic, copy) NSNumber  *job_end_time;        /*!< 岗位结束日期 */
@property (nonatomic, assign) BOOL      isFromSingleDay;    /*!< 是否是 一天的 */
//@property (nonatomic, strong) NSNumber *onBoardStatus;//是否未到岗
//@property (nonatomic,strong ) NSNumber  *stuUnPunckNum;//兼客未打卡次数
@property (nonatomic, assign) NSInteger nowPaySalary;       /*!< 修改后的薪资  需要支付的金额 */
@property (nonatomic, strong) NSMutableArray *onBoardDate;  /*!< 需要支付薪资的日期的数组 */

@property (nonatomic, assign) CGFloat cellHeight;

@end

/** on_board_time_list 每个人的上岗信息*/
@interface BoardTimeListModel : NSObject
@property (nonatomic,strong) NSNumber *on_board_status; /*!< 到岗状态 1 到 0 未到 */
@property (nonatomic,strong) NSNumber *is_be_verify;    /*!< 是否被雇主确认 1 是 0 否 只有这个字段为1是的时候才有所谓的到岗状态 */
@property (nonatomic,strong) NSNumber *on_board_time_id;/*!< 上岗纪录id */
@property (nonatomic,strong) NSNumber *is_be_pay_salary;/*!< 是否被支付过薪水  1 是 0 否 */
@property (nonatomic,strong) NSNumber *on_board_time;   /*!< 上岗日期0点毫秒 */
@property (nonatomic,strong) NSNumber *stu_absent_type; /*!< 未到岗原因  1：沟通一致  2：放鸽 */
@end



//========
@interface ExaPayCellModel : NSObject
@property (nonatomic, assign) long long timeStamp;
@property (nonatomic, assign) NSInteger dayStatus;  //1 蓝块(有报名的天)  //2 绿色打勾(默认选中的天) //3 ￥图标(已支付的天) //4 红块(未到岗的天)
@end
