//
//  EpSingleDayCell.h
//  jianke
//
//  Created by xiaomk on 15/11/28.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKModel.h"
#import "EmployListCell.h"

@interface EpSingleDayCell : UITableViewCell

@property (nonatomic, weak) id <EmployListCellDelegate> delegate;
@property (nonatomic, copy) NSNumber* boardDate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;


- (void)refreshWithData:(JKModel*)model andIndexPath:(NSIndexPath*)indexPath;

@end
