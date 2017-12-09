//
//  PersonnelManagerCell.h
//  jianke
//
//  Created by xiaomk on 16/7/4.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JKModel;
@interface PersonnelManagerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labAddTag;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)refreshWithData:(JKModel*)jkmodel;

@end
