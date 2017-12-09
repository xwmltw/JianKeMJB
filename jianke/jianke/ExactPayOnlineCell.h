//
//  ExactPayOnlineCell.h
//  jianke
//
//  Created by 时现 on 15/11/23.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaySalaryModel.h"


@protocol PaySalaryDelegate <NSObject>

- (void)psCell_allMoneyWithSelect;
- (void)psCell_updateCellIndex:(NSIndexPath*)indexPath withModel:(ResumeListModel*)model;



@end

@interface ExactPayOnlineCell : UITableViewCell

@property (nonatomic, weak) id <PaySalaryDelegate> delegate;
@property (nonatomic, copy) NSString *on_board_time;//上岗日期0点毫秒

+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (void)refreshWithData:(id)data andIndexPath:(NSIndexPath*)indexPath;
@end
