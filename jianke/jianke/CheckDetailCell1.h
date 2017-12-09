//
//  CheckDetailCell1.h
//  jianke
//
//  Created by xiaomk on 16/4/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewCell.h"

@class JobBillModel;

@interface CheckDetailCell1 : MKBaseTableViewCell

+ (instancetype)new;

- (void)EP_refreshWithData:(JobBillModel*)model;
@end
