//
//  PostJobCell_send.h
//  jianke
//
//  Created by xiaomk on 16/4/18.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewCell.h"

@interface PostJobCell_send : MKBaseTableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIButton *btnAgreement;
@property (weak, nonatomic) IBOutlet UIButton *btnAgreeChoose;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
