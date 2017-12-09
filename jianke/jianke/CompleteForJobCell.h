//
//  CompleteForJobCell.h
//  jianke
//
//  Created by xiaomk on 15/9/15.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDConst.h"

@interface CompleteForJobCell : UITableViewCell

+ (instancetype)new;

- (void)refreshWithData:(id)data;

@property (nonatomic, assign) ManagerType managerType;

@end
