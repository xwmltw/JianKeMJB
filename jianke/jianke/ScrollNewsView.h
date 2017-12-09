//
//  EPNewsView.h
//  jianke
//
//  Created by fire on 16/2/24.
//  Copyright © 2016年 xianshijian. All rights reserved.
//  

#import <UIKit/UIKit.h>

@class ScrollNewsView,AdModel;

@protocol ScrollNewsViewDelegate <NSObject>

- (void)scrollNewsView:(ScrollNewsView *)aScrollNewsView btnClickWithAdModel:(AdModel *)model;
- (void)scrollNewsViewCloseBtnClick:(ScrollNewsView *)aScrollNewsView;

@end



@interface ScrollNewsView : UIView

- (instancetype)initWithNewsModelArray:(NSArray<AdModel *> *)aModelArray size:(CGSize)aSize;
@property (nonatomic, weak) id<ScrollNewsViewDelegate> delegate;

- (void)playNews;

@end
