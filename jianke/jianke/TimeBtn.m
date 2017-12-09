//
//  TimeBtn.m
//  jianke
//
//  Created by fire on 15/11/5.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "TimeBtn.h"
#import "UIView+MKExtension.h"
#import "DateTools.h"

@implementation TimeBtn

+ (instancetype)timeBtnWithStartTime:(NSDate *)aStartTime endTime:(NSDate *)aEndTime target:(id)aTarget selector:(SEL)aSelector;
{
    NSString *startTimeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)aStartTime.hour, (long)aStartTime.minute];
    NSString *endTimeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)aEndTime.hour, (long)aEndTime.minute];
    NSString *aTimeString = [NSString stringWithFormat:@"%@ 至 %@", startTimeStr, endTimeStr];
    
    TimeBtn *timeBtn = [[TimeBtn alloc] init];
    
    timeBtn.startTime = aStartTime;
    timeBtn.endTime = aEndTime;
    
    [timeBtn addTarget:aTarget action:aSelector forControlEvents:UIControlEventTouchUpInside];
    
    timeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [timeBtn setTitleColor:MKCOLOR_RGB(74, 144, 226) forState:UIControlStateNormal];
    [timeBtn setTitle:aTimeString forState:UIControlStateNormal];
    [timeBtn setImage:[UIImage imageNamed:@"v220_cancel"] forState:UIControlStateNormal];
    [timeBtn setBackgroundColor:MKCOLOR_RGBA(74, 144, 226, 0.17)];
    
    timeBtn.height = 26;
    
    // 计算按钮宽度
    CGSize maxSize = CGSizeMake(MAXFLOAT, 30);
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    CGFloat titleWidth = [aTimeString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
    CGFloat imageWidth = 16;
    CGFloat padding = 25;
    timeBtn.width = titleWidth + imageWidth + padding;
    
    timeBtn.layer.cornerRadius = 13;
    timeBtn.layer.masksToBounds = YES;
    
    return timeBtn;
}


- (void)updateDisplay
{
    NSString *startTimeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)self.startTime.hour, (long)self.startTime.minute];
    NSString *endTimeStr = [NSString stringWithFormat:@"%ld:%02ld", (long)self.endTime.hour, (long)self.endTime.minute];
    NSString *aTimeString = [NSString stringWithFormat:@"%@ 至 %@", startTimeStr, endTimeStr];
    
    
    // 计算按钮宽度
    CGSize maxSize = CGSizeMake(MAXFLOAT, 30);
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    CGFloat titleWidth = [aTimeString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.width;
    CGFloat imageWidth = 16;
    CGFloat padding = 25;
    self.width = titleWidth + imageWidth + padding;
    
    [self setTitle:aTimeString forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect titleFrame = self.titleLabel.frame;
    CGRect imageFrame = self.imageView.frame;
    
    titleFrame.origin.x = 10;
    imageFrame.origin.x = titleFrame.origin.x + titleFrame.size.width + 5;
    
    self.titleLabel.frame = titleFrame;
    self.imageView.frame = imageFrame;
}


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect touchRect = self.frame;
    touchRect.size.width = 20;
    touchRect.origin.y = 0;
    touchRect.origin.x = self.width - 20;
    
    if (CGRectContainsPoint(touchRect, point)) {
        return YES;
    }
    
    return NO;
}


@end
