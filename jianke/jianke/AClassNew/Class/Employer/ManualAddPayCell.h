//
//  ManualAddPayCell.h
//  jianke
//
//  Created by xiaomk on 16/7/11.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ManualAddCellDelegate <NSObject>

- (void)deleteCellForIndexPath:(NSIndexPath *)indexPath;
- (void)queryAccountInfo:(NSString *)param withIndexPath:(NSIndexPath *)indexPath;

@end

@class JKModel;
@interface ManualAddPayCell : UITableViewCell

@property (nonatomic, weak) id<ManualAddCellDelegate> delegate;
@property (nonatomic, assign) BOOL isFromPayView;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
- (void)setJkModel:(JKModel *)jkModel withIndexPath:(NSIndexPath*)indexPath isLastItem:(BOOL)isLastItem;
- (void)updateCell:(JKModel *)jkModel;

@end
