//
//  ConditionCell.h
//  jianke
//
//  Created by fire on 15/11/18.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConditionCellModel.h"

@interface ConditionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *switchBtn;

@property (nonatomic, strong) ConditionCellModel *model;

@end
