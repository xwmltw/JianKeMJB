//
//  JobDscEditController.h
//  jianke
//
//  Created by fire on 15/10/7.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//  普通岗位描述编辑页面

#import <UIKit/UIKit.h>
#import "UIPlaceHolderTextView.h"
#import "WDViewControllerBase.h"

@class PostJobCellModel;
@class JobModel;
@interface JobDscEditController : WDViewControllerBase

@property (nonatomic, weak) UIPlaceHolderTextView *textView;


//@property (nonatomic, strong) PostJobCellModel *postJobCellModel;
@property (nonatomic, copy) NSString *descStr;
@property (nonatomic, copy) MKDoubleBlock block;
@property (nonatomic, copy) NSArray *jobWelfareArray; //福利保障
@property (nonatomic, strong) JobModel *jobModel;
@property (nonatomic, strong) NSDate *startDate;    /*!< 开始日期 */
@property (nonatomic, strong) NSDate *endDate;      /*!< 结束日期 */
@property (nonatomic, assign) PostJobType postJobType;  /*!< 岗位类型 */


//if (self.postJobType == PostJobType_bd) {
//    [self.datasArray addObject:@(PostJobCellType_jobTag)];
//}
//    else{
//        //是否开启 限制条件
//        if (self.epModel.apply_job_limit_enable.intValue == 1) {
//            [self.datasArray addObject:@(PostJobCellType_restrict)];
//        }
//    }

@end
