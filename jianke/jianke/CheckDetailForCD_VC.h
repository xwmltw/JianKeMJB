//
//  CheckDetailForCD_VC.h
//  jianke
//
//  Created by xiaomk on 16/4/23.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewController.h"
#import "MKBaseModel.h"

typedef NS_ENUM(NSInteger, CheckDetailCellType) {
    CheckDetailCellType_title       = 1,
    CheckDetailCellType_leader      = 2,
    CheckDetailCellType_salaryInfo      = 3,
    CheckDetailCellType_cdJKList    = 4,

};

@interface CheckDetailForCD_VC : MKBaseTableViewController

@property (nonatomic, copy) NSString* jobBillId;

@end




@interface ApplyMatModel : MKBaseModel
@property (nonatomic, copy) NSString* job_bill_id;
@property (nonatomic, copy) NSString* expected_repayment_date;

@end