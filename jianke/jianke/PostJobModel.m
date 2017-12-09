//
//  PostJobModel.m
//  jianke
//
//  Created by fire on 15/10/6.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//  发布岗位的模型

#import "PostJobModel.h"
#import "MJExtension.h"

@implementation PostJobModel

- (NSDictionary *)objectClassInArray
{
    return @{@"job_tags" : [WelfareModel class]};
}

@end
