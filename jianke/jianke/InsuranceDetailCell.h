//
//  InsuranceDetailCell.h
//  jianke
//
//  Created by 时现 on 15/12/7.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InsuranceDetailModel.h"
@interface InsuranceDetailCell : UITableViewCell


+ (instancetype)new;

-(void)refreshWithData:(InsuranceDetailModel *)model;

@end
