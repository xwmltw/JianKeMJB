//
//  WorkPostDetailConfirm_VC.h
//  jianke
//
//  Created by xiaomk on 16/4/26.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewController.h"

typedef NS_ENUM(NSInteger, WorkPostDetailCellType) {
    WorkPostDetailCellType_NO       = 1,
    WorkPostDetailCellType_YES      = 2,
};

@interface WorkPostDetailConfirm_VC : MKBaseTableViewController
@property (nonatomic, assign) WorkPostDetailCellType type;
@property (nonatomic, copy) NSString* jobId;
@end
