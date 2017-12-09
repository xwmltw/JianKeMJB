//
//  PostJobButton.m
//  jianke
//
//  Created by fire on 15/9/24.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "PostJobButton.h"
#import "UIView+MKExtension.h"

@implementation PostJobButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}


- (void)setup
{
    self.titleLabel.numberOfLines = 0;
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self setTitleColor:MKCOLOR_RGB(43, 187, 210) forState:UIControlStateSelected];
    [self setBackgroundImage:[UIImage imageNamed:@"ep_rectangle"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"bg_card_2"] forState:UIControlStateSelected];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.titleLabel.text.length > 3) {
        
        self.titleLabel.frame = CGRectMake(18, 15, 28, 30);
    }
}


@end
