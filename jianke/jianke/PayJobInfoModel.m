//
//  PayJobInfoModel.m
//  jianke
//
//  Created by xiaomk on 16/7/12.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "PayJobInfoModel.h"
#import "ParamModel.h"


@implementation PayJobInfoModel

- (NSDictionary *)objectClassInArray{
    return @{
             @"payment_list" : [PaymentPM class],
             @"add_payment_list" : [AddPaymentModel class]
             };
}
@end

@implementation AddPaymentModel
@end