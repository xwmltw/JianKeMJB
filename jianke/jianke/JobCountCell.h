//
//  JobCountCell.h
//  jianke
//
//  Created by 时现 on 15/11/5.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JobModel;
@interface JobCountCell : UITableViewCell

+ (instancetype)new;

- (void)refreshWithData:(id)data;
@property (nonatomic ,strong) JobModel *model;
@end
