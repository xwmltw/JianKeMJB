//
//  PostJobCell_remind.h
//  jianke
//
//  Created by xiaomk on 16/4/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewCell.h"

@interface PostJobCell_remind : MKBaseTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labRemind;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
