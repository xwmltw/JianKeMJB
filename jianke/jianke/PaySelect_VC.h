//
//  PaySelect_VC.h
//  
//
//  Created by xiaomk on 15/10/9.
//
//

#import <UIKit/UIKit.h>
//#import "QueryAccountMoneyModel.h"
//#import "PaySalaryModel.h"
#import "MKBaseTableViewController.h"
#import "PayJobInfoModel.h"


typedef NS_ENUM(NSInteger, PaySelectFromType) {
    PaySelectFromType_noType                = 0,
    PaySelectFromType_epPay,                    /*!< 雇主直接支付 */
    PaySelectFromType_jobBill,                  /*!< 账单支付 */
    PaySelectFromType_insurance,                /*!< 保险支付 */
    PaySelectFromType_partnerPostJob,           /*!< 合伙人发布岗位  */
    PaySelectFromType_inviteBalance,            /*!< 个人中心招聘余额 */
    PaySelectFromType_JobVasOrder               /*!< 岗位增值服务订单(置顶/刷新/推送) */
};

@interface PaySelect_VC : MKBaseTableViewController

@property (nonatomic, assign) int needPayMoney;                 /*!< 支付的金额 单位分*/
@property (nonatomic, copy, nullable) NSArray* arrayData;       /*!< 支付列表 */

@property (nonatomic, copy, nullable) NSNumber *job_bill_id;    /*!< 岗位账单id */
@property (nonatomic, copy, nullable) NSNumber *jobId;          /*!< 岗位ID */

@property (nonatomic, copy, nullable) NSNumber* isAccurateJob;  /*!< 是否为精确岗位 */

@property (nonatomic, copy, nullable) NSString *on_board_time;  /*!< 上岗日期0点毫秒 精确岗位 单天 添加发放对象 支付用*/
@property (nonatomic, assign) PaySelectFromType fromType;       /*!< 来源 必传 */

@property (nonatomic, copy, nullable) NSNumber *job_vas_order_id; /*!< 岗位增值服务订单id */

@property (nonatomic, copy, nullable) MKBlock partnerPostJobPayBlock;



@end




