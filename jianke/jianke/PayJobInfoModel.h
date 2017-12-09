//
//  PayJobInfoModel.h
//  jianke
//
//  Created by xiaomk on 16/7/12.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKBaseModel.h"


@interface PayJobInfoModel : MKBaseModel;
@property (nonatomic, copy, nullable) NSNumber *job_id;                 /*!< 岗位ID */
@property (nonatomic, copy, nonnull) NSNumber *pay_channel;              /*!< 1"钱袋子";2"支付宝";3"微信";4微信公众号”，5平安付 */
@property (nonatomic, copy, nullable) NSString *acct_encpt_password;      /*!< 支付密码 */
@property (nonatomic, copy, nonnull) NSString *client_time_millseconds;  /*!< 必填, 客户端请求时间戳 */
//账单支付
@property (nonatomic, copy, nullable) NSNumber* job_bill_id;              /*!<必填 岗位账单id */
//雇主直接支付
@property (nonatomic, copy, nonnull) NSString* client_sign;              /*!< 客户端为本次交互生成的签名 */
@property (nonatomic, copy, nullable) NSArray *payment_list;              /*!< 支付信息列表 PaymentPM */
@property (nonatomic, copy, nullable) NSArray *add_payment_list;          /*!< 手动添加的发放对象列表 */
//保险支付
@property (nonatomic, copy, nullable) NSArray *insurance_policy_list;     /*!< 支付保险列表 InsuranceDataListModel */

//V303
@property (nonatomic, copy, nullable) NSNumber *recharge_amount;        /*!< 招聘余额 充值金额 */

//V308
@property (nonatomic, copy, nullable) NSNumber *job_vas_order_id;                 /*!< 岗位增值服务订单id */

- (NSDictionary * __nullable)objectClassInArray;
@end

@interface AddPaymentModel : MKBaseModel
@property (nonatomic, copy, nonnull) NSString *telphone;     /*!< 手机号 */
@property (nonatomic, copy, nonnull) NSString *true_name;    /*!< 名字 */
@property (nonatomic, copy, nonnull) NSNumber *salary_num;   /*!< 薪资 */
@property (nonatomic, copy, nullable) NSString *add_date;     /*!< 新增发放对象日期(在精确岗位的某一天增加发放对象需传 */

//“telphone”: <string> 要发工资的手机号
//“add_date”：”141414141414” // )
//“true_name”: <string> 要发工资的兼客姓名
//“salary_num”: <int> 需要支付的薪水，精确到分，不包含小数

@end

//“content”: {
//    “pay_channel”: // 1, "钱袋子";2, "支付宝";3, "微信";4, “微信公众号”
//    “acct_encpt_password”:xxx支付密码 // 支付渠道为钱袋子余额支付的时候必填.
//    “client_time_millseconds”:xxx // 必填, 客户端请求时间戳
//    “job_bill_id”: xxx //<必填>岗位账单id
//}


//“content”: {
//    “pay_channel”: // 1, "钱袋子";2, "支付宝";3, "微信";4, “微信公众号”
//    “acct_encpt_password”:xxx支付密码 // 支付渠道为钱袋子余额支付的时候必填. 使用challenge加密，加密方式与登录时一致，加密的challenge就是create_session阶段的challenge
//    “client_time_millseconds”:xxx // 必填, 客户端请求时间戳
//    “client_sign”: // 客户端为本次交互生成的签名
//    “payment_list”:[ // 必填
//                    “apply_job_id”: <long> 岗位申请id
//                    “on_board_date”：[“1414141414141”,”1414141414141”] // 表示为哪几天付了工资  时间戳 当天0点毫秒数。
//                    “salary_num”: <long> 需要支付的薪水，精确到分，不包含小数
//                    ]
//}

//“content”: {
//    “pay_channel”: // 1, "钱袋子";2, "支付宝";3, "微信";4, “微信公众号”
//    “acct_encpt_password”:xxx支付密码 // 支付渠道为钱袋子余额支付的时候必填. 使用challenge加密，加密方式与登录时一致，加密的challenge就是create_session阶段的challenge
//    “client_time_millseconds”:xxx // 必填, 客户端请求时间戳
//    “insurance_policy_list” :[ // 必填
//                              “apply_job_id”: <long>岗位投递id，
//                              “insurance_date_list”：[
//                                                     <long> // 购买保险的天数
//                                                     ]
//                              ]
//}
