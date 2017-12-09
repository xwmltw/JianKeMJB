//
//  PostJobCell_jobTag.h
//  jianke
//
//  Created by xiaomk on 16/4/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewCell.h"

@interface PostJobCell_jobTag : MKBaseTableViewCell

@property (weak, nonatomic) IBOutlet UITextField *labTitle;
@property (weak, nonatomic) IBOutlet UIView *viewTagSel;
@property (weak, nonatomic) IBOutlet UIView *viewTag;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutViewTagSelHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutViewTagHeight;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
