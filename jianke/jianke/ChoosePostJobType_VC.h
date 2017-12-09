//
//  ChoosePostJobType_VC.h
//  jianke
//
//  Created by xiaomk on 16/4/18.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewController.h"
#import "MKBaseModel.h"

@interface ChoosePostJobType_VC : MKBaseTableViewController

@end


@interface JobTypeModel : MKBaseModel
@property (nonatomic, copy) NSString *imgName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@end