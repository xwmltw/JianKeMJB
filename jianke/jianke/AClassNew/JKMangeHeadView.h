//
//  JKMangeHeadView.h
//  jianke
//
//  Created by fire on 16/9/6.
//  Copyright © 2016年 xianshijian. All rights reserved.
//


@class JKMangeHeadView;
#import <UIKit/UIKit.h>
@protocol JKMangeHeaderViewDalegate <NSObject>

- (void)jkHeadView:(JKMangeHeadView *)headView btnOnClick:(UIButton *)sender;

@end

@interface JKMangeHeadView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIButton *titleBtn;
@property(nonatomic, weak) id <JKMangeHeaderViewDalegate> delegate;
- (void)setData:(id)model;

@end
