//
//  ApplyCell.m
//  jianke
//
//  Created by fire on 15/9/29.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "ApplyCell.h"
#import "UIImageView+WebCache.h"
#import "JKModel.h"
#import "DateHelper.h"
#import "UserData.h"
#import "CellModel.h"
#import "DateSelectView.h"
#import "DateTools.h"
#import "XSJRequestHelper.h"


@interface ApplyCell() <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView; /*!< 头像 */
@property (weak, nonatomic) IBOutlet UIImageView *sexImgView; /*!< 性别图片 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel; /*!< 用户名 */
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel; /*!< 分数 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel; /*!< 日期 */
@property (weak, nonatomic) IBOutlet UILabel *breakCountLabel; /*!< 放鸽子/完工次数 */


@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UIButton *unUsedBtn;
@property (weak, nonatomic) IBOutlet UIButton *employBtn;

@property (nonatomic, strong) UIAlertView *otherReasonAlertView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeftConstrain;//用户名和头像约束

@property (weak, nonatomic) IBOutlet UIButton *adjustDateBtn; /*!< 调整日期按钮 */

@property (nonatomic, strong) DLAVAlertView *dateAlertView;
@property (nonatomic, weak) DateSelectView *dateSelectView;

@property (weak, nonatomic) IBOutlet UILabel *schoolLabel; /*!< 学校Label */

@end


@implementation ApplyCell


- (void)setCellModel:(CellModel *)cellModel{
    _cellModel = cellModel;
    JKModel *jkModel = cellModel.jkModel;

    // 头像
    self.iconImgView.layer.cornerRadius = 2;
    self.iconImgView.clipsToBounds = YES;
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:jkModel.user_profile_url] placeholderImage:[UIImage imageNamed:@"main_icon_avatar"]];
    
    //没有完善性别
    if (jkModel.sex == nil) {
        self.sexImgView.hidden = YES;
        self.nameLeftConstrain.constant = 8;        
    }
    
    // 性别
    if (jkModel.sex.integerValue) { // 男
        
        self.sexImgView.image = [UIImage imageNamed:@"main_sex_male"];
        
    } else { // 女
        
        self.sexImgView.image = [UIImage imageNamed:@"main_sex_female"];
    }
  
    // 用户名
    self.nameLabel.text = jkModel.true_name;
    
    // 分数
    self.scoreLabel.text = [NSString stringWithFormat:@" %.1lf ", (long)jkModel.evalu_byent_level_avg * 1.0];
    
    // 日期
    self.dateLabel.font = [UIFont fontWithName:kFont_RSR size:15];
    if (jkModel.stu_work_time_type.integerValue == 2) { // 默认
        
        NSString *startDate = [DateHelper getDateWithNumber:jkModel.stu_work_time.firstObject];
        NSString *endDate = [DateHelper getDateWithNumber:jkModel.stu_work_time.lastObject];
        self.dateLabel.text = [NSString stringWithFormat:@"%@ 至 %@", startDate, endDate];
        
    } else { // 兼客选择
        // 日期排序
        NSArray *tmpWorkTime = [self sortForWorkDate];
        
        self.dateLabel.text = [DateHelper dateRangeStrWithMicroSecondNumArray:tmpWorkTime];
    }
    
    // 学校
    self.schoolLabel.text = jkModel.school_name.length ? jkModel.school_name : @"无";
    
    // 放鸽子 & 完工 次数
    self.breakCountLabel.text = [NSString stringWithFormat:@"%@ 次放鸽子  |  %@ 次完工", jkModel.break_promise_count.description, jkModel.work_experice_count.description];
    self.breakCountLabel.font = [UIFont fontWithName:kFont_RSR size:13];
    
    // 录用状态
    if (jkModel.trade_loop_status.integerValue == 1) { // 已报名
        
        self.unUsedBtn.hidden = NO;
        self.employBtn.hidden = NO;
        self.resultLabel.hidden = YES;
        
        if (self.isAccurateJob.integerValue == 1) {
            self.adjustDateBtn.hidden = NO;
        } else {
            self.adjustDateBtn.hidden = YES;
        }
        
    } else if (jkModel.trade_loop_status.integerValue == 2) { // 录用成功
        
        self.unUsedBtn.hidden = YES;
        self.employBtn.hidden = YES;
        self.resultLabel.hidden = NO;
        self.adjustDateBtn.hidden = YES;
        self.resultLabel.text = @"录用成功";
        
//        [TalkingData trackEvent:@"已报名_兼客条目_录用"];
        
    } else if (jkModel.trade_loop_status.integerValue == 3) { // 投递结束
    
        self.unUsedBtn.hidden = YES;
        self.employBtn.hidden = YES;
        self.resultLabel.hidden = NO;
        self.adjustDateBtn.hidden = YES;
        
        if (jkModel.trade_loop_finish_type.integerValue == 2 || jkModel.trade_loop_finish_type.integerValue == 5) { // 雇主拒绝
            self.resultLabel.text = @"已拒绝";
        } else if (jkModel.trade_loop_finish_type.integerValue == 3) { // 雇主确认完成
            self.resultLabel.text = @"完工";
        } else if (jkModel.trade_loop_finish_type.integerValue == 4) { // 未到岗(沟通一致/放鸽子)
            if (jkModel.stu_absent_type.integerValue == 1) { // 沟通一致
                self.resultLabel.text = @"经沟通同意";
            } else { // 放鸽子
                self.resultLabel.text = @"放鸽子";
            }
        }
    }
    
    // 小红点
    if (jkModel.ent_big_red_point_status && jkModel.ent_big_red_point_status.intValue) {
        self.redDot.hidden = NO;
    } else {
        self.redDot.hidden = YES;
    }
}


/** 报名日期排序 */
- (NSArray *)sortForWorkDate{
    NSArray *tmpWorkTime = [self.cellModel.jkModel.stu_work_time sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        if (obj1.longLongValue < obj2.longLongValue) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    return tmpWorkTime;
}


/** 刷新cell通知 */
- (void)reflushCell{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[ApplyCellReflushInfo] = self.cellModel;
    [WDNotificationCenter postNotificationName:ApplyCellReflushNotification object:self userInfo:dic];
}

- (void)callBack:(ActionType)actionType{
    [self.delegate applyCell:self cellModel:self.cellModel actionType:actionType];
}

#pragma mark - 按钮点击
/** 调整报名日期 */
- (IBAction)adjustWorkDateBtnClick:(UIButton *)sender{
    JKModel *jkModel = self.cellModel.jkModel;
    
    WEAKSELF
    [[UserData sharedInstance] queryJobCanApplyDateWithJobId:@(self.jobId.integerValue) resumeId:jkModel.resume_id block:^(ResponseInfo *response) {
       
        // 可报名日期
//        NSString *dateStr = response.content[@"job_can_apply_date"];
//        dateStr = [dateStr stringByReplacingOccurrencesOfString:@"[" withString:@""];
//        dateStr = [dateStr stringByReplacingOccurrencesOfString:@"]" withString:@""];
//        NSArray *tmpArray = [dateStr componentsSeparatedByString:@","];
        
        NSArray *tmpArray = response.content[@"job_can_apply_date"];
        
        NSMutableArray *canSelDateArray = [NSMutableArray array];
        for (NSString *str in tmpArray) {
            [canSelDateArray addObject:[NSDate dateWithTimeIntervalSince1970:str.longLongValue * 0.001]];
        }        
        
        // 已报名日期
        NSArray *tmpNumArray = [self sortForWorkDate];
        NSMutableArray *applyDateArray = [NSMutableArray array];
        for (NSNumber *num in tmpNumArray) {

            [applyDateArray addObject:[NSDate dateWithTimeIntervalSince1970:num.longLongValue]];
        }
        
        // 日期控件
        weakSelf.dateAlertView = [[DLAVAlertView alloc] initWithTitle:@"调整日期" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 300)];
        
        DateSelectView *dateSelectView = [[DateSelectView alloc] initWithFrame:CGRectMake(0, 0, 260, 260)];
        dateSelectView.type = DateViewTypeAdjust;
        weakSelf.dateSelectView = dateSelectView;
        [containerView addSubview:dateSelectView];
        weakSelf.dateAlertView.contentView = containerView;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 260, 280, 1)];
        lineView.backgroundColor = MKCOLOR_RGB(210, 210, 210);
        [containerView addSubview:lineView];
        
        UILabel *adjustLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 260, 280, 40)];
        adjustLabel.numberOfLines = 0;
        adjustLabel.textColor = MKCOLOR_RGB(136, 136, 136);
        adjustLabel.font = [UIFont systemFontOfSize:12];
        adjustLabel.text = @"通过点击，增加或减少上岗日期";
        [containerView addSubview:adjustLabel];
        
        weakSelf.dateSelectView.canSelDateArray = canSelDateArray;
        weakSelf.dateSelectView.datesApply = applyDateArray;
        weakSelf.dateSelectView.didClickBlock = ^(id obj){
            
            NSString *addDateStr = @"";
            for (NSDate *date in dateSelectView.datesAdd) {
                addDateStr = [NSString stringWithFormat:@"%@%ld、", addDateStr, (long)date.day];
            }
            
            NSString *reduceDateStr = @"";
            for (NSDate *date in dateSelectView.datesReduce) {
                reduceDateStr = [NSString stringWithFormat:@"%@%ld、", reduceDateStr, (long)date.day];
            }
            
            NSString *adjustDateStr = @"";
            if (reduceDateStr.length > 0) {
                adjustDateStr = [NSString stringWithFormat:@"减少了%@号; ", reduceDateStr];
            }
            
            if (addDateStr.length > 0) {
                adjustDateStr = [NSString stringWithFormat:@"%@增加了%@号", adjustDateStr, addDateStr];
            }
            
            if (adjustDateStr.length > 0) {
                adjustDateStr = [adjustDateStr stringByReplacingOccurrencesOfString:@"、号" withString:@"号"];
            }
            
            if (adjustDateStr.length < 1) {
                adjustDateStr = @"通过点击，增加或减少上岗日期";
            }
            
            adjustLabel.text = adjustDateStr;
        };
        
        [weakSelf.dateAlertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
            
            if (buttonIndex == 1) {
                
                NSMutableArray *applyDateArrayNew = [NSMutableArray arrayWithArray:applyDateArray];
                
                // 加上新增的
                [applyDateArrayNew addObjectsFromArray:dateSelectView.datesAdd];
                
                // 减去取消的
                NSMutableArray *delDateArray = [NSMutableArray array];
                for (NSDate *date in dateSelectView.datesReduce) {
                    
                    for (NSDate *applyDate in applyDateArrayNew) {
                     
                        if ([date isSameDay:applyDate]) {
                            [delDateArray addObject:applyDate];
                        }
                    }
                }
                
                for (NSDate *delDate in delDateArray) {
                    
                    [applyDateArrayNew removeObject:delDate];
                }
                
                // 转换成字符串数组
                NSMutableArray *applyDateStrArrayNew = [NSMutableArray array];
                for (NSDate *date in applyDateArrayNew) {
                 
                    NSString *dateStr = [NSString stringWithFormat:@"%.0f", date.timeIntervalSince1970 * 1000];
                    [applyDateStrArrayNew addObject:dateStr];
                }
                
                // 调整发送请求
                [[UserData sharedInstance] entChangeStuOnBoardDateWithApplyJobId:self.cellModel.jkModel.apply_job_id dayArray:applyDateStrArrayNew block:^(ResponseInfo *response) {
                   
                    [UserData delayTask:0.3 onTimeEnd:^{
                       
                        [UIHelper toast:@"调整成功"];
                    }];
                    
                    // 修改日期呈现
                    NSMutableArray *applyDateStrArray = [NSMutableArray array];
                    for (NSString *str in applyDateStrArrayNew) {
                    
                        NSNumber *sortNum = @(str.longLongValue * 0.001);
                        [applyDateStrArray addObject:sortNum];
                    }
                    
                    weakSelf.cellModel.jkModel.stu_work_time = applyDateStrArray;
                    
                    [weakSelf reflushCell];
                }];
            }
        }];
    }];
}

/** 发消息 */
- (IBAction)megBtnClick:(UIButton *)sender{
    [TalkingData trackEvent:@"兼客管理_已报名_发送IM"];

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[ApplyChatWithJkInfo] = self.cellModel.jkModel;
    [WDNotificationCenter postNotificationName:ApplyChatWithJkNotification object:self userInfo:dic];
}

/** 打电话 */
- (IBAction)phoneBtnClick:(UIButton *)sender{
    [TalkingData trackEvent:@"兼客管理_已报名_拨打电话"];
    if ([[UserData sharedInstance] getLoginType].integerValue == 1 && [[UserData sharedInstance] getEpModelFromHave].identity_mark.integerValue == 2) {
        [[XSJRequestHelper sharedInstance] callFreePhoneWithCalled:self.cellModel.jkModel.contact.phone_num block:nil];
    }else{
        [[MKOpenUrlHelper sharedInstance] callWithPhone:self.cellModel.jkModel.contact.phone_num];
    }
    
}

/** 不合格 */
- (IBAction)unuseBtnClick:(UIButton *)sender{    // 隐藏小红点
    [TalkingData trackEvent:@"兼客管理_已报名_不合格"];

    [self hideRedPoint];
    
    DLAVAlertView *unUsedAlertView = [[DLAVAlertView alloc] initWithTitle:@"不合格理由" message:@"你为什么不录用这名兼客?" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"已经招满了", @"信息太少,无法判断", @"放鸽子次数过多", @"其他原因", @"取消", nil];
    [unUsedAlertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0:{
                [self noUseWithReason:@"已经招满了"];
            }
                break;
            case 1:{
                [self noUseWithReason:@"信息太少,无法判断"];
            }
                break;
            case 2:{
                [self noUseWithReason:@"放鸽子次数过多"];
            }
                break;
            case 3:{
                // 弹框显示其他原因输入框
                UIAlertView *otherReasonAlertView = [[UIAlertView alloc] initWithTitle:@"其他原因" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                self.otherReasonAlertView = otherReasonAlertView;
                otherReasonAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [otherReasonAlertView show];
            }
                break;
            default:
                break;
        }
    }];
}


/** 不录用 */
- (void)noUseWithReason:(NSString *)reason{
    [TalkingData trackEvent:@"兼客管理_已报名_不合格"];
    WEAKSELF
    [[UserData sharedInstance] entEmployApplyJobWithWithApplyJobIdList:@[self.cellModel.jkModel.apply_job_id] employStatus:@(2) employMemo:reason block:^(ResponseInfo *response) {
        weakSelf.cellModel.jkModel.trade_loop_status = @(3);
        weakSelf.cellModel.jkModel.trade_loop_finish_type = @(2);
//        [weakSelf reflushCell];
        [weakSelf callBack:ActionTypeFire];
    }];
}

/** 录用 */
- (IBAction)applyBtnClick:(UIButton *)sender{
    [TalkingData trackEvent:@"兼客管理_已报名_录用"];
    // 隐藏小红点
    [self hideRedPoint];
    WEAKSELF
    [[UserData sharedInstance] entEmployApplyJobWithWithApplyJobIdList:@[self.cellModel.jkModel.apply_job_id] employStatus:@(1) employMemo:nil block:^(ResponseInfo *response) {
        weakSelf.cellModel.jkModel.trade_loop_status = @(2);
//        [weakSelf reflushCell];
        [weakSelf callBack:ActionTypeHire];
    }];
}


- (void)hideRedPoint{
    self.cellModel.jkModel.ent_big_red_point_status = @(0);
    [[UserData sharedInstance] entReadApplyJobResumeWithApplyJobId:self.cellModel.jkModel.apply_job_id.stringValue block:nil];
}



#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"其他原因"] && buttonIndex == 1) {
        UITextField *reasonTextField = [alertView textFieldAtIndex:0];
        if (!reasonTextField.text || reasonTextField.text.length < 6) {
            [UIHelper toast:@"不合格原因不能小于6个字符"];
            [alertView show];
        } else {
            [self noUseWithReason:reasonTextField.text];
        }
    }
}

@end
