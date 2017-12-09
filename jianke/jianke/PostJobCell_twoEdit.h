//
//  PostJobCell_twoEdit.h
//  jianke
//
//  Created by xiaomk on 16/4/18.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewCell.h"

@interface PostJobCell_twoEdit : MKBaseTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgXiaLeft;
@property (weak, nonatomic) IBOutlet UIImageView *imgXiaRight;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UITextField *tfLeft;
@property (weak, nonatomic) IBOutlet UITextField *tfRight;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
