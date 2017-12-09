//
//  PostJobCell_textField.h
//  jianke
//
//  Created by xiaomk on 16/4/18.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewCell.h"

@interface PostJobCell_textField : MKBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UITextField *tfText;
@property (weak, nonatomic) IBOutlet UIButton *btnGetLocation;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
