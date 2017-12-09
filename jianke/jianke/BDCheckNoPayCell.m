//
//  BDCheckNoPayCell.m
//  jianke
//
//  Created by xiaomk on 16/4/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "BDCheckNoPayCell.h"

@implementation BDCheckNoPayCell


+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"BDCheckNoPayCell" bundle:nil];
    }
    BDCheckNoPayCell* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    return cell;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
