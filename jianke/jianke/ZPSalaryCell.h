//
//  ZPSalaryCell.h
//  jianke
//
//  Created by xuzhi on 16/7/20.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

@class AcctVirtualModel;
#import <UIKit/UIKit.h>

@interface ZPSalaryCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) AcctVirtualModel *avModel;

@end
