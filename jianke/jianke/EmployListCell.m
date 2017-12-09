//
//  EmployListCell.m
//  jianke
//
//  Created by xiaomk on 15/11/24.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "EmployListCell.h"
#import "WDConst.h"
#import "XSJRequestHelper.h"

@interface EmployListCell()<UIAlertViewDelegate>{
    JKModel *_jkModel;
    NSIndexPath* _indexPath;
}

@property (nonatomic, strong) UIAlertView *evalAlertView;

@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labAddJkTag;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone;
@property (weak, nonatomic) IBOutlet UIButton *btnMore;

@property (weak, nonatomic) IBOutlet UIButton *btnNoComplete;   /*!< 未到岗 */
@property (weak, nonatomic) IBOutlet UIButton *btnComplete;     /*!< 完工 */

@property (weak, nonatomic) IBOutlet UIView *viewBotStar;
@property (weak, nonatomic) IBOutlet UIButton *btnWritePoint;   /*!< 评价按钮 */
@property (weak, nonatomic) IBOutlet UIButton *btnStar_1;
@property (weak, nonatomic) IBOutlet UIButton *btnStar_2;
@property (weak, nonatomic) IBOutlet UIButton *btnStar_3;
@property (weak, nonatomic) IBOutlet UIButton *btnStar_4;
@property (weak, nonatomic) IBOutlet UIButton *btnStar_5;

@end

@implementation EmployListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"EmployListCell";
    EmployListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"EmployListCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor whiteColor];
        [cell.labAddJkTag setBorderWidth:1 andColor:[UIColor XSJColor_grayLine]];
        [cell.labAddJkTag setCorner];
        [cell.imgHead setCorner];

    }
    return cell;
}


- (void)refreshWithData:(JKModel*)model andIndexPath:(NSIndexPath*)indexPath{
    
    if (!model) {
        return;
    }
    _indexPath = indexPath;
    _jkModel = model;
    
    self.btnStar_1.tag = 1;
    self.btnStar_2.tag = 2;
    self.btnStar_3.tag = 3;
    self.btnStar_4.tag = 4;
    self.btnStar_5.tag = 5;
    
    [self.btnStar_1 addTarget:self action:@selector(starBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnStar_2 addTarget:self action:@selector(starBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnStar_3 addTarget:self action:@selector(starBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnStar_4 addTarget:self action:@selector(starBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnStar_5 addTarget:self action:@selector(starBtnClick:) forControlEvents:UIControlEventTouchUpInside];

    [self.btnPhone addTarget:self action:@selector(btnPhoneOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnMore addTarget:self action:@selector(btnMoreOnclick:) forControlEvents:UIControlEventTouchUpInside];

    //头像
    [self.imgHead sd_setImageWithURL:[NSURL URLWithString:_jkModel.user_profile_url] placeholderImage:[UIHelper getDefaultHead]];
    
    //性别
    self.imgSex.image = _jkModel.sex.integerValue == 1 ?  [UIImage imageNamed:@"main_sex_male"] : [UIImage imageNamed:@"main_sex_female"];
    
    //名字
    self.labName.text = _jkModel.true_name;
    self.labAddJkTag.hidden = NO;
    switch (_jkModel.apply_job_source.integerValue) {
        case 1:
            self.labAddJkTag.text = @"平台报名";
            self.labAddJkTag.hidden = YES;
            break;
        case 2:
            self.labAddJkTag.text = @"人员补录";
            break;
        case 3:
            self.labAddJkTag.text = @"人员推广";
            break;
        default:
            break;
    }
    
    // 日期
    if (_jkModel.stu_work_time_type.integerValue == 2) { // 默认
        NSString *startDate = [DateHelper getDateWithNumber:_jkModel.stu_work_time.firstObject];
        NSString *endDate = [DateHelper getDateWithNumber:_jkModel.stu_work_time.lastObject];
        self.labDate.text = [NSString stringWithFormat:@"%@ 至 %@", startDate, endDate];
    } else { // 兼客选择
        self.labDate.text = [DateHelper dateRangeStrWithSecondNumArray:_jkModel.stu_work_time];
    }

//    CGSize labSize = [self.labDate contentSizeWithWidth:SCREEN_WIDTH-76];
    
    
    
    self.btnComplete.hidden = YES;
    self.btnNoComplete.hidden = YES;
    self.btnWritePoint.hidden = YES;
    
    self.btnStar_1.hidden = YES;
    self.btnStar_2.hidden = YES;
    self.btnStar_3.hidden = YES;
    self.btnStar_4.hidden = YES;
    self.btnStar_5.hidden = YES;
    
    self.viewBotStar.hidden = YES;
    
    if (self.isAccurateJob.integerValue == 1) {     //精确岗位
        self.btnMore.hidden = NO;
        self.btnPhone.hidden = YES;
        
        
        self.btnComplete.hidden = YES;
        self.btnNoComplete.hidden = YES;
        
        if (_jkModel.trade_loop_finish_type.integerValue == 3) { //雇主确认完成
            self.viewBotStar.hidden = NO;
            _jkModel.cellHeight = 116;
            
            self.btnStar_1.hidden = NO;
            self.btnStar_2.hidden = NO;
            self.btnStar_3.hidden = NO;
            self.btnStar_4.hidden = NO;
            self.btnStar_5.hidden = NO;
            self.btnWritePoint.hidden = NO;

            if (_jkModel.ent_evalu_level && _jkModel.ent_evalu_level.integerValue > 0) { //已评级
                //星星
                self.btnStar_1.selected = _jkModel.ent_evalu_level.integerValue > 0;
                self.btnStar_2.selected = _jkModel.ent_evalu_level.integerValue > 1;
                self.btnStar_3.selected = _jkModel.ent_evalu_level.integerValue > 2;
                self.btnStar_4.selected = _jkModel.ent_evalu_level.integerValue > 3;
                self.btnStar_5.selected = _jkModel.ent_evalu_level.integerValue > 4;
            }
            
            if (_jkModel.ent_evalu_content && _jkModel.ent_evalu_content.length > 0) {  //已评价
                [self.btnWritePoint setTitle:@"已评价" forState:UIControlStateNormal];
                [self.btnWritePoint setEnabled:NO];
            }else{//未评价
                [self.btnWritePoint setTitle:@"去评价" forState:UIControlStateNormal];
                [self.btnWritePoint setEnabled:YES];
            }
        }else{
            self.viewBotStar.hidden = YES;
            _jkModel.cellHeight = 64;
        }
        
    }else{              //松散岗位
        self.btnMore.hidden = YES;
        self.btnPhone.hidden = NO;
        
        self.viewBotStar.hidden = NO;
        _jkModel.cellHeight = 116;
        //其他
        if (_jkModel.trade_loop_status.integerValue == 2) {// 录用成功
            self.btnNoComplete.hidden = NO;
            self.btnComplete.hidden = NO;
        }else{
            self.btnWritePoint.hidden = NO;
            
            if (_jkModel.trade_loop_finish_type.integerValue == 3) { //雇主确认完成
                self.btnStar_1.hidden = NO;
                self.btnStar_2.hidden = NO;
                self.btnStar_3.hidden = NO;
                self.btnStar_4.hidden = NO;
                self.btnStar_5.hidden = NO;
                
                if (_jkModel.ent_evalu_level && _jkModel.ent_evalu_level.integerValue > 0) { //已评级
                    //星星
                    self.btnStar_1.selected = _jkModel.ent_evalu_level.integerValue > 0;
                    self.btnStar_2.selected = _jkModel.ent_evalu_level.integerValue > 1;
                    self.btnStar_3.selected = _jkModel.ent_evalu_level.integerValue > 2;
                    self.btnStar_4.selected = _jkModel.ent_evalu_level.integerValue > 3;
                    self.btnStar_5.selected = _jkModel.ent_evalu_level.integerValue > 4;
                }
                if (_jkModel.ent_evalu_content && _jkModel.ent_evalu_content.length > 0) {  //已评价
                    [self.btnWritePoint setTitle:@"已评价" forState:UIControlStateNormal];
                    [self.btnWritePoint setEnabled:NO];
                }else{//未评价
                    [self.btnWritePoint setTitle:@"去评价" forState:UIControlStateNormal];
                    [self.btnWritePoint setEnabled:YES];
                }
                
            }else{  //未到岗 沟通一致  放鸽子
                if (_jkModel.stu_absent_type.integerValue == 1) { //沟通一一致
                    [self.btnWritePoint setTitle:@"经沟通同意" forState:UIControlStateNormal];
                    [self.btnWritePoint setEnabled:NO];
                }else{//放鸽子
                    [self.btnWritePoint setTitle:@"放鸽子" forState:UIControlStateNormal];
                    [self.btnWritePoint setEnabled:NO];
                }
            }
        }
    }
}


#pragma mark - 按钮事件
- (void)btnMoreOnclick:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(elCell_moreEventWithIndex:withModel:)]) {
        [self.delegate elCell_moreEventWithIndex:_indexPath withModel:_jkModel];
    }
}

/** 打电话号 */
- (void)btnPhoneOnclick:(UIButton *)sender{
    if ([[UserData sharedInstance] getLoginType].integerValue == 1 && [[UserData sharedInstance] getEpModelFromHave].identity_mark.integerValue == 2) {
        [[XSJRequestHelper sharedInstance] callFreePhoneWithCalled:_jkModel.contact.phone_num block:nil];
    }else{
        [[MKOpenUrlHelper sharedInstance] callWithPhone:_jkModel.contact.phone_num];
    }
}

/** 未到岗按钮点击 */
- (IBAction)breakBtnClick:(UIButton*)sender{
    [TalkingData trackEvent:@"兼客管理_未到岗"];
    WEAKSELF
    [MKActionSheet sheetWithTitle:@"请选择未到岗原因" buttonTitleArray:@[@"放鸽子",@"经沟通同意"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [[UserData sharedInstance] entConfirmStuBreakPromiseWithApplyJobId:_jkModel.apply_job_id.stringValue block:^(ResponseInfo *response) {
                _jkModel.trade_loop_status = @(3); // 投递结束
                _jkModel.trade_loop_finish_type = @(4); // 兼客未到岗
                _jkModel.stu_absent_type = @(2); // 放鸽子
                [weakSelf reflushCell];
            }];
        }else if (buttonIndex == 1){
            [[UserData sharedInstance] entConfirmStuNotCompleteWorkWithApplyJobId:_jkModel.apply_job_id.stringValue block:^(ResponseInfo *response) {
                _jkModel.trade_loop_status = @(3); // 投递结束
                _jkModel.trade_loop_finish_type = @(4); // 兼客未到岗
                _jkModel.stu_absent_type = @(1); // 双方沟通一致
                [weakSelf reflushCell];
            }];
        }
    }];
}

/** 完工按钮点击 */
- (IBAction)completeBtnClick:(UIButton*)sender{
    [TalkingData trackEvent:@"兼客管理_完工"];
    if (_jkModel.apply_job_id) {
        NSArray* array = [[NSArray alloc] initWithObjects:_jkModel.apply_job_id.stringValue, nil];
        WEAKSELF
        [[UserData sharedInstance] entConfirmWorkCompleteWithApplyJobIdList:array block:^(ResponseInfo *response) {
            _jkModel.trade_loop_status = @(3); // 投递结束
            _jkModel.trade_loop_finish_type = @(3); // 雇主确认完成
            [weakSelf reflushCell];
        }];
    }else{
        [UIHelper toast:@"报名岗位ID为空"];
    }

}
/** 点星星 */
- (void)starBtnClick:(UIButton*)sender{
    ELog(@"第%ld个星星被点击了...", (long)sender.tag);
    
    WEAKSELF
    [[UserData sharedInstance] entScoreStuApplyJobWithApplyJobId:_jkModel.apply_job_id.description evaluLevel:@(sender.tag) block:^(ResponseInfo *response) {
        if (response.success) {
            _jkModel.ent_evalu_level = @(sender.tag);
            [UIHelper toast:@"评价成功"];
        } else if (response.errCode.integerValue == 68) {
            [UIHelper toast:@"评级完成超过2分钟后无法再修改评级"];
            _jkModel.is_can_evaluate = NO;
        }
        [weakSelf reflushCell];
    }];
}

//写评价按钮
- (IBAction)btnEvalOnclick:(UIButton *)sender {
    UIAlertView *evalAlertView = [[UIAlertView alloc] initWithTitle:@"写评价" message:@"请填写对该兼客的评价" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    evalAlertView.tag = 301;
    evalAlertView.delegate = self;
    evalAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.evalAlertView = evalAlertView;
    [evalAlertView show];
}



#pragma mark - alertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    ELog(@"didDismissWithButtonIndex ===== %ld", (long)buttonIndex);
    if (alertView.tag == 301) {
        if (buttonIndex == 1) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            NSString *evaluContent = textField.text;
            [TalkingData trackEvent:@"已完成_兼客管理_写评价" label:evaluContent];
            if (!evaluContent || evaluContent.length < 6) {
                [UIHelper toast:@"评价不能小于6个字符"];
                [alertView show];
                return;
            }
            
            WEAKSELF
            [[UserData sharedInstance] entCommetStuApplyJobWithApplyJobId:_jkModel.apply_job_id.stringValue evaluContent:evaluContent block:^(ResponseInfo *response) {
                _jkModel.ent_evalu_content = evaluContent;
                [weakSelf reflushCell];
                [UIHelper toast:@"评价成功"];
            }];
        }
    }
}


/** 刷新cell通知 */
- (void)reflushCell{
    if ([self.delegate respondsToSelector:@selector(elCell_updateCellIndex:withModel:)]) {
        [self.delegate elCell_updateCellIndex:_indexPath withModel:_jkModel];
    }
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
