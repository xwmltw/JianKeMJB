//
//  SalaryModel.m
//  jianke
//
//  Created by xiaomk on 15/9/16.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "SalaryModel.h"
#import "MJExtension.h"

@implementation SalaryModel

MJCodingImplementation

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

#pragma mark - ***** 薪资单位 ******
- (NSString*)getTypeDesc{
    switch (self.unit.intValue) {
        case 1:
            return @"/天";
        case 2:
            return @"/时";
        case 3:
            return @"/月";
        case 4:
            return @"/次";
        default:
            return @"/天";
    }
}

- (NSString*)getUnitValue{
    switch (self.unit.integerValue) {
        case 1:
            return @"元/天";
        case 2:
            return @"元/时";
        case 3:
            return @"元/月";
        case 4:
            return @"元/次";
        default:
            return @"元/天";
    }
}

+ (NSString*)getTypeDescWithNumber:(NSNumber *)unit{
    switch (unit.integerValue) {
        case 1:
            return @"元/天";
        case 2:
            return @"元/时";
        case 3:
            return @"元/月";
        case 4:
            return @"元/次";
        default:
            return @"元/天";
    }
}

+ (NSArray *)salaryArray{
    SalaryModel *salary1 = [[SalaryModel alloc] initWithUint:@(1) unitStr:@"元/天"];
    SalaryModel *salary2 = [[SalaryModel alloc] initWithUint:@(2) unitStr:@"元/时"];
    SalaryModel *salary3 = [[SalaryModel alloc] initWithUint:@(3) unitStr:@"元/月"];
    SalaryModel *salary4 = [[SalaryModel alloc] initWithUint:@(4) unitStr:@"元/次"];
    
    NSArray *array = @[salary1, salary2, salary3, salary4];
    return array;
}

- (instancetype)initWithUint:(NSNumber *)unit unitStr:(NSString *)unitStr{
    if (self = [super init]) {
        self.unit = unit;
        self.unit_value = unitStr;
    }
    return self;
}


#pragma mark - ***** 结算 ******
- (NSString*)getSettlementDesc{
    switch (self.settlement.intValue) {
        case 1:
            return @"当天结算";
        case 2:
            return @"周末结算";
        case 3:
            return @"月末结算";
        case 4:
            return @"完工结算";
        default:
            return @"不限";
    }
}


- (NSNumber *)getSettlementNum{
    if ([self.settlement_value isEqualToString:@"当天结算"]) {
        return @(1);
    }
    if ([self.settlement_value isEqualToString:@"周末结算"]) {
        return @(2);
    }
    if ([self.settlement_value isEqualToString:@"月末结算"]) {
        return @(3);
    }
    if ([self.settlement_value isEqualToString:@"完工结算"]) {
        return @(4);
    }
    return nil;
}


+ (NSNumber *)getSettlementWithDesc:(NSString *)desc{
    if ([desc isEqualToString:@"当天结算"]) {
        return @(1);
    }
    if ([desc isEqualToString:@"周末结算"]) {
        return @(2);
    }
    if ([desc isEqualToString:@"月末结算"]) {
        return @(3);
    }
    if ([desc isEqualToString:@"完工结算"]) {
        return @(4);
    }
    return nil;
}

+ (NSArray *)salaryArrayForSettlement{
    SalaryModel *salary1 = [[SalaryModel alloc] initWithSettlement:@(1) settlementStr:@"当天结算"];
    SalaryModel *salary2 = [[SalaryModel alloc] initWithSettlement:@(2) settlementStr:@"周末结算"];
    SalaryModel *salary3 = [[SalaryModel alloc] initWithSettlement:@(3) settlementStr:@"月末结算"];
    SalaryModel *salary4 = [[SalaryModel alloc] initWithSettlement:@(4) settlementStr:@"完工结算"];
    
    NSArray *array = @[salary1, salary2, salary3, salary4];
    return array;
}

- (instancetype)initWithSettlement:(NSNumber *)settlement settlementStr:(NSString *)settlementStr{
    if (self = [super init]) {
        self.settlement = settlement;
        self.settlement_value = settlementStr;
    }
    return self;
}


#pragma mark - ***** 支付方式 ******
- (NSString *)getPayWayStr{
    if (self.pay_type.integerValue == 1) {
        return @"在线支付";
    }else if (self.pay_type.integerValue == 2){
        return @"现金支付";
    }
    return nil;
}

+ (NSNumber *)getPayWayWith:(NSString *)desc{
    if ([desc isEqualToString:@"在线支付"]) {
        return @(1);
    }
    if ([desc isEqualToString:@"现金支付"]) {
        return @(2);
    }
    return nil;
}


+ (NSArray *)salaryPayWayArray{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:2];
    [array addObject:@"在线支付"];
    [array addObject:@"现金支付"];
    return [NSArray arrayWithArray:array];
}


@end
