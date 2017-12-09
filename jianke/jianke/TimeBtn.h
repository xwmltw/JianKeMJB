//
//  TimeBtn.h
//  jianke
//
//  Created by fire on 15/11/5.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeBtn : UIButton

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

+ (instancetype)timeBtnWithStartTime:(NSDate *)aStartTime endTime:(NSDate *)aEndTime target:(id)aTarget selector:(SEL)aSelector;

- (void)updateDisplay;

@end
