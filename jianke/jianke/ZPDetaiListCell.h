//
//  ZPDetaiListCell.h
//  jianke
//
//  Created by xuzhi on 16/7/25.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

@class PayDetailModel;
#import <UIKit/UIKit.h>

@interface ZPDetaiListCell : UITableViewCell

@property (nonatomic, strong) PayDetailModel *pdModel;
+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
