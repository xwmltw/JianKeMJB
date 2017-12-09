//
//  PostJobCell_time.h
//  jianke
//
//  Created by xiaomk on 16/4/20.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewCell.h"

@interface PostJobCell_time : MKBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIView *timeBgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutTimeBtnToTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutViewHeight;

@property (weak, nonatomic) IBOutlet UIButton *btnAddTime;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
