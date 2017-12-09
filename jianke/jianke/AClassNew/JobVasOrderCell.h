//
//  JobVasOrderCell.h
//  jianke
//
//  Created by fire on 16/9/24.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

@class JobVasOrderCell;
#import <UIKit/UIKit.h>

@protocol JobVasOrderCellDelegate <NSObject>

- (void)jobVasOrderCell:(JobVasOrderCell *)cell actionType:(NSInteger)type;

@end

@interface JobVasOrderCell : UITableViewCell

@property (nonatomic, weak) id<JobVasOrderCellDelegate> delegate;
- (void)setData:(id)model andType:(NSInteger)type cellDic:(NSMutableDictionary *)cellHeightDic;

@end
