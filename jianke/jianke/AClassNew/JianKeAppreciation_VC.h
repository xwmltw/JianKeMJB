//
//  JianKeAppreciation_VC.h
//  jianke
//
//  Created by fire on 16/9/23.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "BottomViewControllerBase.h"

typedef NS_ENUM(NSInteger, AppreciationType){
    Appreciation_stick_Type = 1,
    Appreciation_Refresh_Type,
    Appreciation_push_Type
};

@interface JianKeAppreciation_VC : BottomViewControllerBase

@property (nonatomic, assign) AppreciationType serviceType;
@property (nonatomic, copy) NSString *jobId;
@property (nonatomic, weak) UIViewController *popToVC;

@end
