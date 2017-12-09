//
//  MakeCheck_VC.h
//  jianke
//
//  Created by xiaomk on 16/4/15.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewController.h"
#import "MKBaseModel.h"

@class ApplyJobModel,JobModel;

@interface MakeCheck_VC : MKBaseTableViewController

//@property (nonatomic, strong) ApplyJobModel* ajModel;
@property (nonatomic, strong) JobModel *jobModel;
@property (nonatomic, copy) NSString* jobId;
@property (nonatomic, weak) UIViewController *popToVC;
@end


@interface GetJobBillModel : MKBaseModel
@property (nonatomic, copy) NSString* bill_start_date;
@property (nonatomic, copy) NSString* bill_end_date;
@property (nonatomic, copy) NSString* job_id;
@end
