//
//  PaySelectCell.h
//  jianke
//
//  Created by xiaomk on 16/5/11.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewCell.h"
#import "WDConst.h"

@interface PaySelectCell : MKBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labSubTitle;

@property (weak, nonatomic) IBOutlet UIView *balanceView;
@property (weak, nonatomic) IBOutlet UILabel *labMoney;

@property (weak, nonatomic) IBOutlet UIButton *btnSelect;

@property (nonatomic, assign) WDPayType payType;

+ (instancetype)new;
@end
