//
//  EmployListCell.h
//  jianke
//
//  Created by xiaomk on 15/11/24.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKModel.h"

@protocol EmployListCellDelegate <NSObject>
- (void)elCell_updateCellIndex:(NSIndexPath*)indexPath withModel:(JKModel*)model;

@optional
- (void)elCell_moreEventWithIndex:(NSIndexPath *)indexPath withModel:(JKModel *)model;
@end

@interface EmployListCell : UITableViewCell
@property (nonatomic, weak) id <EmployListCellDelegate> delegate;
@property (nonatomic, copy) NSNumber* isAccurateJob;    //是否是精确岗位

+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (void)refreshWithData:(JKModel*)model andIndexPath:(NSIndexPath*)indexPath;



@end
