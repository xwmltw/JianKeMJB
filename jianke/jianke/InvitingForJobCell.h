//
//  InvitingForJobCell.h
//  jianke
//
//  Created by xiaomk on 15/9/15.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JobModel.h"
#import "WDConst.h"

@protocol InvitingForJobDelegate <NSObject>

//- (void)cell_didSelectRowAtIndex:(JobModel*)model;
- (void)cell_btnBotOnClick:(JobModel *)model;
//- (void)cell_btnRefreshJobOnClick:(JobModel*)model;
//- (void)cell_btnOverJobOnClick:(JobModel*)model;
//- (void)cell_btnShareClick:(JobModel*)model;
//- (void)cell_btnApplyListOnclick:(JobModel*)model;
//- (void)cell_quickPublishClick:(JobModel*)model;

@end

@interface InvitingForJobCell : UITableViewCell

@property (nonatomic, weak) id <InvitingForJobDelegate> delegate;
@property (nonatomic, assign) ManagerType managerType;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (void)refreshWithData:(id)data;

@end
