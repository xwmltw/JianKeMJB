//
//  ConditionCellModel.h
//  jianke
//
//  Created by fire on 15/11/18.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ConditionCellType) {
    
    ConditionCellTypeSwitch,
    ConditionCellTypeIndecator
};


@interface ConditionCellModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) ConditionCellType cellType;

@property (nonatomic, assign, getter=isSwitchOn) BOOL switchOn;

@property (nonatomic, copy) MKBlock btnBlock;


+ (instancetype)cellModelWithTitle:(NSString *)title type:(ConditionCellType)type swichState:(BOOL)state btnBlock:(MKBlock)btnBlock;


@end
