//
//  AreaSelectView.h
//  jianke
//
//  Created by fire on 16/8/16.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

@class AreaSelectView;
#import <UIKit/UIKit.h>

@protocol AreaSelectViewDelegate <NSObject>

- (void)areaSelectView:(AreaSelectView *)searchView searchAction:(UITextField *)sender;
- (void)areaSelectView:(AreaSelectView *)searchView;

@end

@interface AreaSelectView : UIView

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) id <AreaSelectViewDelegate> delegate;
+ (instancetype)showOnView:(UIView *)view;

@end
