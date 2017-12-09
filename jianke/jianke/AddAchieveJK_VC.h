//
//  AddAchieveJK_VC.h
//  jianke
//
//  Created by xiaomk on 16/4/26.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MKBaseTableViewController.h"
#import "MKBaseModel.h"

@interface AddAchieveJK_VC : MKBaseTableViewController
@property (nonatomic, copy) NSString* job_id;
@property (nonatomic, copy) MKBoolBlock block;
@end



@interface QueryConfirmModel : MKBaseModel
@property (nonatomic, copy) NSString* job_id;
@property (nonatomic, strong) NSNumber* list_type;
@end
