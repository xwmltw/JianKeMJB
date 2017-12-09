//
//  cellModel.m
//  jianke
//
//  Created by fire on 15/9/29.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "CellModel.h"
#import "DateHelper.h"

@implementation CellModel


+ (NSMutableArray *)cellModelArrayWithJkModel:(NSArray *)jkModelArray
{
//    [jkModelArray[0] setStu_apply_resume_time:@(1443508671000)];
//    [jkModelArray[1] setStu_apply_resume_time:@(1443558671000)];
//    [jkModelArray[2] setStu_apply_resume_time:@(1443408671000)];
//    [jkModelArray[3] setStu_apply_resume_time:@(1443501671000)];
    
    NSMutableArray *cellModelArray = [NSMutableArray array];
    NSMutableArray *otherCellModelArray = [NSMutableArray array];
    
    NSArray *needSortArray = [jkModelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"trade_loop_status.integerValue == 1"]];
    NSArray *otherArray = [jkModelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"trade_loop_status.integerValue != 1"]];
    
    if (otherArray && otherArray.count) {
        
        [otherArray enumerateObjectsUsingBlock:^(JKModel *model, NSUInteger idx, BOOL *stop) {
            
            CellModel *cellModel = [[CellModel alloc] init];
            
            cellModel.jkModel = otherArray[idx];
            [otherCellModelArray addObject:cellModel];
        }];
    }
    
    
    
    [needSortArray enumerateObjectsUsingBlock:^(JKModel *model, NSUInteger idx, BOOL *stop) {
        
        CellModel *cellModel = [[CellModel alloc] init];
        cellModel.dateStr = [DateHelper getDayWithNumber:@(model.stu_apply_resume_time.doubleValue * 0.001) format:@"M月d日"];
        cellModel.date = @([DateHelper getDayWithNumber:@(model.stu_apply_resume_time.doubleValue * 0.001) format:@"yyyyMMdd"].doubleValue);
        
        NSNumber *today = @([DateHelper getDayWithNumber:@([NSDate date].timeIntervalSince1970) format:@"yyyyMMdd"].doubleValue);
        if (cellModel.date.doubleValue == today.doubleValue) {
            cellModel.dateStr = @"今天";
        }
    
        cellModel.jkModel = needSortArray[idx];
        [cellModelArray addObject:cellModel];
    }];
    
    // 排序
    NSArray *sortArray = [cellModelArray sortedArrayUsingComparator:^NSComparisonResult(CellModel *obj1, CellModel *obj2) {
        
        if (obj1.date.longLongValue > obj2.date.longLongValue) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
        
    }];
    
    // 获取X月X日数组
    NSArray *dateArray = [sortArray valueForKeyPath:@"date"];
    
    // 去重
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSNumber *date in dateArray) {
        [dic setObject:date forKey:date];
    }
    NSArray *sortStrArray = [dic allKeys];
    
    sortStrArray = [sortStrArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        
        if (obj1.longLongValue > obj2.longLongValue) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    NSMutableArray *sortDateStrArray = [NSMutableArray array];
    for (NSNumber *obj in sortStrArray) {
        
        NSString *dateStr = [DateHelper getDateStrFromString:obj.description format:@"yyyyMMdd"];
        
        NSNumber *today = @([DateHelper getDayWithNumber:@([NSDate date].timeIntervalSince1970) format:@"yyyyMMdd"].doubleValue);
        if (obj.doubleValue == today.doubleValue) {
            dateStr = @"今天";
        }
        
        [sortDateStrArray addObject:dateStr];
    }
    
    
    // 转换成二维数组
    NSMutableArray *sortCellModelArray = [NSMutableArray array];
    for (NSString *str in sortDateStrArray) {
        NSArray *tmpArray = [sortArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"dateStr like[cd] %@", str]];
        
        [sortCellModelArray addObject:tmpArray];
    }
    
    // 添加不排序的
    if (otherArray.count) {
        [sortCellModelArray addObject:otherCellModelArray];
    }
    
    return sortCellModelArray;
}

+ (NSArray *)getSortDateStrArrayWithJkModelArray:(NSArray *)jkModelArray
{
    
    NSMutableArray *cellModelArray = [NSMutableArray array];
    
    NSArray *needSortArray = [jkModelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"trade_loop_status.integerValue == 1"]];
    NSArray *otherArray = [jkModelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"trade_loop_status.integerValue != 1"]];
    
    [needSortArray enumerateObjectsUsingBlock:^(JKModel *model, NSUInteger idx, BOOL *stop) {
        
        CellModel *cellModel = [[CellModel alloc] init];
        cellModel.dateStr = [DateHelper getDayWithNumber:@(model.stu_apply_resume_time.doubleValue * 0.001) format:@"M月d日"];
        cellModel.date = @([DateHelper getDayWithNumber:@(model.stu_apply_resume_time.doubleValue * 0.001) format:@"yyyyMMdd"].doubleValue);
        
        NSNumber *today = @([DateHelper getDayWithNumber:@([NSDate date].timeIntervalSince1970) format:@"yyyyMMdd"].doubleValue);
        if (cellModel.date.doubleValue == today.doubleValue) {
            cellModel.dateStr = @"今天";
        }
        
        cellModel.jkModel = needSortArray[idx];
        [cellModelArray addObject:cellModel];
    }];
    
    // 排序
    NSArray *sortArray = [cellModelArray sortedArrayUsingComparator:^NSComparisonResult(CellModel *obj1, CellModel *obj2) {
        
        if (obj1.date.longLongValue > obj2.date.longLongValue) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
        
    }];
    
    // 获取X月X日数组
    NSArray *dateArray = [sortArray valueForKeyPath:@"date"];
    
    // 去重
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSNumber *date in dateArray) {
        [dic setObject:date forKey:date];
    }
    NSArray *sortStrArray = [dic allKeys];
    
    sortStrArray = [sortStrArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        
        if (obj1.longLongValue > obj2.longLongValue) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
        
    }];
    
    NSMutableArray *sortDateStrArray = [NSMutableArray array];
    for (NSNumber *obj in sortStrArray) {
        
        NSString *dateStr = [DateHelper getDateStrFromString:obj.description format:@"yyyyMMdd"];
        
        NSNumber *today = @([DateHelper getDayWithNumber:@([NSDate date].timeIntervalSince1970) format:@"yyyyMMdd"].doubleValue);
        if (obj.doubleValue == today.doubleValue) {
            dateStr = @"今天";
        }
        
        
        [sortDateStrArray addObject:dateStr];
    }
    
    if (otherArray.count) {
        [sortDateStrArray addObject:[NSString stringWithFormat:@"已拒绝 (%lu)", (unsigned long)otherArray.count]];
    }
    
    return sortDateStrArray;
}




@end
