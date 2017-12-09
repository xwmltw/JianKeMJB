//
//  ReportRecordCell.h
//  jianke
//
//  Created by 时现 on 15/10/27.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

@class ReportRecordModel;
@protocol ReportRecordModelDelegate <NSObject>

- (void)manualPunch:(ReportRecordModel *)reportRecordModel;

@end

#import <UIKit/UIKit.h>

@class ReportRecordModel;

@interface ReportRecordCell : UITableViewCell

@property(nonatomic,weak) id<ReportRecordModelDelegate> delegate;
@property(nonatomic,strong) ReportRecordModel *reportRecordModel;

@end
