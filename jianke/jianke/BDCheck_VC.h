//
//  BDCheck_VC.h
//  jianke
//
//  Created by xiaomk on 16/4/14.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"
#import "MKBaseTableViewController.h"
#import "MKBaseModel.h"

typedef NS_ENUM(NSInteger, BDCheckType) {
    BDCheckType_PayYet      = 0,        //已支付
    BDCheckType_NoPay        = 1,        //未支付
};

@class BDCheckPM;

@interface BDCheck_VC : MKBaseTableViewController
@property (nonatomic, assign) BDCheckType checkType;

@end


@interface BDCheckPM : MKBaseModel
@property (nonatomic, strong) QueryParamModel* query_param;
@property (nonatomic, copy) NSNumber* bill_status;
@end