//
//  EditEPInfoDetailCell.h
//  jianke
//
//  Created by xiaomk on 16/3/15.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"

@interface EditEPInfoDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *tfEPDetail;

+ (instancetype)new;
@end
