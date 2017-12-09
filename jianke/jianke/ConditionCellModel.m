//
//  ConditionCellModel.m
//  jianke
//
//  Created by fire on 15/11/18.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "ConditionCellModel.h"

@implementation ConditionCellModel

+ (instancetype)cellModelWithTitle:(NSString *)title type:(ConditionCellType)type swichState:(BOOL)state btnBlock:(MKBlock)btnBlock
{
    
    ConditionCellModel *model = [[ConditionCellModel alloc] init];
    model.title = title;
    model.cellType = type;
    model.switchOn = state;
    model.btnBlock = btnBlock;
    return model;
}

@end
