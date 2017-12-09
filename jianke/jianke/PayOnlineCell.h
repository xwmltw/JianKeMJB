//
//  PayOnlineCell.h
//  jianke
//
//  Created by xiaomk on 15/9/29.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKModel.h"

@protocol PayOnlineDelegate <NSObject>

- (void)sumAllMoneyWithSelect;
@end


@interface PayOnlineCell : UITableViewCell

@property (nonatomic, weak) id <PayOnlineDelegate> delegate;
@property (nonatomic, assign) BOOL isEidt;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)refreshWithData:(id)data;

@end
