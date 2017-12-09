//
//  BDCheckNoPayCell.h
//  jianke
//
//  Created by xiaomk on 16/4/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewCell.h"

@interface BDCheckNoPayCell : MKBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labMoney;

@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labWorkCount;
@property (weak, nonatomic) IBOutlet UIButton *btnPay;
@property (weak, nonatomic) IBOutlet UILabel *labPayment;

+ (instancetype)new;
@end
