//
//  cellModel.h
//  jianke
//
//  Created by fire on 15/9/29.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JKModel.h"

@interface CellModel : NSObject

@property (nonatomic, strong) JKModel *jkModel;
@property (nonatomic, copy) NSString *dateStr;
@property (nonatomic, copy) NSNumber *date;


+ (NSMutableArray *)cellModelArrayWithJkModel:(NSArray *)jkModelArray;

+ (NSArray *)getSortDateStrArrayWithJkModelArray:(NSArray *)jkModelArray;


@end
