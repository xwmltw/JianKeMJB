//
//  EPNewsView.m
//  jianke
//
//  Created by fire on 16/2/24.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ScrollNewsView.h"
#import "UIView+MKExtension.h"
#import "Masonry.h"
#import "UserData.h"
#import "JKHomeModel.h"
#import "UIHelper.h"

@interface ScrollNewsView ()

@property (nonatomic, strong) NSArray<AdModel *> *modelArray;

@property (nonatomic, strong) NSMutableArray<UIButton *> *btnArray;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation ScrollNewsView

- (instancetype)initWithNewsModelArray:(NSArray<AdModel *> *)aModelArray size:(CGSize)aSize{
    if (self = [super init]) {
        self.backgroundColor = MKCOLOR_RGBA(0, 118, 255, 0.03);
        self.clipsToBounds = YES;
        self.width = aSize.width;
        self.height = aSize.height;
        self.modelArray = aModelArray;
        [self setup];
    }
    return self;
}

- (void)setup{
    if (!self.modelArray.count) {
        return;
    }
    
    AdModel *model = self.modelArray.firstObject;
    
    // 添加右边透明ImageView
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - 60, 0, 60, self.height)];
//    imageView.image = [UIImage imageNamed:@"v260_img_coverpic"];
//    imageView.contentMode = UIViewContentModeCenter;
//    [self addSubview:imageView];
    
    // 添加底部的线
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 1, self.width, 1)];
    lineView.backgroundColor = MKCOLOR_RGBA(74, 144, 226, 0.3);
    [self addSubview:lineView];
    
    // 关闭按钮
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 40, 0, 40, 40)];
    [closeBtn setImage:[UIImage imageNamed:@"v3_public_close_blue"] forState:UIControlStateNormal];
    closeBtn.imageEdgeInsets = UIEdgeInsetsMake(-6, 6, 6, 0);
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    
    // 计算新闻长度
//    model.ad_name = @"测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试测试";
    CGSize maxSize = CGSizeMake(MAXFLOAT, 15);
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:15];
    CGFloat headLineW = [model.ad_name boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
    
    if (headLineW < SCREEN_WIDTH - 60) { // 新闻较短, 不用滚动
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 60, self.height)];
        [btn setTitle:model.ad_name forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:MKCOLOR_RGB(0, 118, 255) forState:UIControlStateNormal];
        btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.x = 0;
        btn.y = 0;
        [self insertSubview:btn atIndex:0];
        
    } else { // 新闻较长, 需要滚动
        
        self.btnArray = [NSMutableArray array];
        CGFloat btnW = headLineW + 60;
        for (NSInteger i = 0; i < 2; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnW, self.height)];
            [btn setTitle:model.ad_name forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitleColor:MKCOLOR_RGB(74, 144, 226) forState:UIControlStateNormal];
            btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.x = i * btnW;
            btn.y = 0;
            [self insertSubview:btn atIndex:0];
            [self.btnArray addObject:btn];
        }
        [self playNews];
    }
    
    // 新闻按钮
    UIButton *newsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 60, self.height)];
    [newsBtn addTarget:self action:@selector(newsBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:newsBtn];
}


- (void)playNews{
    // 重置位置并滚动播放
    for (NSInteger i = 0; i < self.btnArray.count; i++) {
        UIButton *btn = self.btnArray[i];
        btn.x = i *btn.width;
        [self playNewsWithBtn:btn];
    }
}


- (void)playNewsWithBtn:(UIButton *)btn{
    NSTimeInterval duration = (btn.width / SCREEN_WIDTH) * 5.0;
    ELog(@"btn1:%f", btn.x);
    ELog(@"btn-width:%f", btn.width);
    [UIView animateWithDuration:duration delay:1.0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat animations:^{
        btn.x -= btn.width;
    } completion:^(BOOL finished) {
        if (btn.x < 0) {
            btn.x = btn.width;
        }
    }];
}

- (void)newsBtnClick{
    AdModel *model = self.modelArray.firstObject;
    DLog(@"兼客头条新闻点击");
    if ([self.delegate respondsToSelector:@selector(scrollNewsView:btnClickWithAdModel:)]) {
        [self.delegate scrollNewsView:self btnClickWithAdModel:model];
    }
}


- (void)closeBtnClick{
    AdModel *model = self.modelArray.firstObject;
    [[UserData sharedInstance] setEpHideNewsViewState:YES adId:model.ad_id];
    if ([self.delegate respondsToSelector:@selector(scrollNewsViewCloseBtnClick:)]) {
        [self.delegate scrollNewsViewCloseBtnClick:self];
    }
    

}

@end
