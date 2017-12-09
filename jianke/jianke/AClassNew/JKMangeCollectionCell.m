//
//  JKMangeCollectionCell.m
//  jianke
//
//  Created by fire on 16/9/6.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JKMangeCollectionCell.h"
#import "WDConst.h"

@implementation JKMangeCollectionCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    [self.redPoint setCornerValue:12.0f];
    [self.feturePoint setCornerValue:5.0f];
}

@end
