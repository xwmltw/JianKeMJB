//
//  EpSingleDayCell.m
//  jianke
//
//  Created by xiaomk on 15/11/28.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "EpSingleDayCell.h"
#import "WDConst.h"

@interface EpSingleDayCell(){
    JKModel* _jkModel;
    NSIndexPath* _indexPath;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UIButton *btnNoComplete;
@property (weak, nonatomic) IBOutlet UIButton *btnComplete;
@property (weak, nonatomic) IBOutlet UILabel *labGtyz;
@property (weak, nonatomic) IBOutlet UIButton *btnPhone;
@property (weak, nonatomic) IBOutlet UILabel *labAddJkTag;


//@property (weak, nonatomic) IBOutlet UIImageView *imgStatus;
//@property (weak, nonatomic) IBOutlet UILabel *labCheck_1;
//@property (weak, nonatomic) IBOutlet UILabel *labCheck_2;
//@property (weak, nonatomic) IBOutlet UILabel *labCheck_3;
//@property (weak, nonatomic) IBOutlet UILabel *labCheck_4;
//@property (weak, nonatomic) IBOutlet UILabel *labCheck_5;
//@property (weak, nonatomic) IBOutlet UILabel *labCheck_6;
//
//@property (weak, nonatomic) IBOutlet UILabel *labPoint;


@end

@implementation EpSingleDayCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"EpSingleDayCell";
    EpSingleDayCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"EpSingleDayCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor whiteColor];
        [cell.labAddJkTag setBorderWidth:1 andColor:[UIColor XSJColor_grayLine]];
        [cell.labAddJkTag setCorner];
        cell.labAddJkTag.hidden = YES;
    }
    return cell;
}

- (void)refreshWithData:(JKModel*)model andIndexPath:(NSIndexPath*)indexPath{
    _indexPath = indexPath;
    _jkModel = model;
    
    if (!_jkModel) {
        return;
    }
    
    [self.btnPhone addTarget:self action:@selector(btnPhoneOnclick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imgHead sd_setImageWithURL:[NSURL URLWithString:_jkModel.user_profile_url] placeholderImage:[UIHelper getDefaultHead]];
    [self.imgHead setCorner];
    
    //性别
    self.imgSex.image = _jkModel.sex.integerValue == 1 ?  [UIImage imageNamed:@"main_sex_male"] : [UIImage imageNamed:@"main_sex_female"];

    //名字
    self.labName.text = _jkModel.true_name;
    
    if (_jkModel.apply_job_type.integerValue > 1) {
        self.labAddJkTag.hidden = NO;
    }else{
        self.labAddJkTag.hidden = YES;
    }
    //其他
    self.labGtyz.hidden = YES;
    self.btnNoComplete.hidden = YES;
    self.btnComplete.hidden = YES;
    
    if (_jkModel.on_board_status.integerValue == 2) { // 未处理
        self.btnNoComplete.hidden = NO;
        self.btnComplete.hidden = NO;
        
        //现在的日期时间
        NSString* strDateNow =[DateHelper getDateFromTimeNumber:[NSNumber numberWithLongLong:[DateHelper getTimeStamp]] withFormat:@"yyMMdd"];
        
        NSString* boardDate = [DateHelper getDateFromTimeNumber:self.boardDate withFormat:@"yyMMdd"];

        if (boardDate.intValue > strDateNow.intValue) {
            self.btnNoComplete.enabled = NO;
            self.btnComplete.enabled = NO;
        }else{
            self.btnNoComplete.enabled = YES;
            self.btnComplete.enabled = YES;
        }
        
    }else if (_jkModel.on_board_status.integerValue == 1){   //到岗
        self.labGtyz.text = @"完工";
        self.labGtyz.hidden = NO;
    }else{//未到岗
        if (_jkModel.day_stu_absent_type.integerValue == 1) {   //沟通一致
            self.labGtyz.hidden = NO;
            self.labGtyz.text = @"经沟通同意";
        }else if (_jkModel.day_stu_absent_type.integerValue == 2){ //放鸽子
            self.labGtyz.hidden = NO;
            self.labGtyz.text = @"放鸽子";
        }
    }
}

- (IBAction)btnNoCompleteOnclick:(UIButton *)sender {
    [TalkingData trackEvent:@"已完成_兼客管理_未到岗"];
    [MKActionSheet sheetWithTitle:@"请选择未到岗原因" buttonTitleArray:@[@"放鸽子",@"经沟通同意"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            WEAKSELF
            [[UserData sharedInstance] entConfirmStuBreakPromiseWithApplyJobId:_jkModel.apply_job_id.stringValue andDate:self.boardDate.stringValue block:^(ResponseInfo *response){
                [TalkingData trackEvent:@"已完成_兼客管理_未到岗原因" label:@"放鸽子"];
                _jkModel.on_board_status = @(0);// 兼客未到岗
                _jkModel.day_stu_absent_type = @(2);// 放鸽子
                [weakSelf reflushCell];
            }];

        }else if (buttonIndex == 1){
            WEAKSELF
            [[UserData sharedInstance] entConfirmStuNotCompleteWorkWithApplyJobId:_jkModel.apply_job_id.stringValue andDate:self.boardDate.stringValue block:^(ResponseInfo *response){
                [TalkingData trackEvent:@"已完成_兼客管理_未到岗原因" label:@"经沟通同意"];
                _jkModel.on_board_status = @(0);// 兼客未到岗
                _jkModel.day_stu_absent_type = @(1);// 双方沟通一致
                [weakSelf reflushCell];
            }];

        }
    }];
}

- (IBAction)btnCompleteOnclick:(UIButton *)sender {
    [TalkingData trackEvent:@"已完成_兼客管理_完工"];
    
    if (_jkModel) {
        if (_jkModel.apply_job_id) {
            NSMutableArray* applyAry = [[NSMutableArray alloc] init];
            [applyAry addObject: _jkModel.apply_job_id.stringValue];
            WEAKSELF
            [[UserData sharedInstance] entConfirmWorkCompleteWithApplyJobIdList:applyAry andDate:self.boardDate.stringValue block:^(ResponseInfo *response){
                _jkModel.on_board_status = @(1); // 投递结束
                [weakSelf reflushCell];
            }];
        }else{
            [UIHelper toast:@"报名 岗位 ID 为空"];
        }
      
    }else{
        [UIHelper toast:@"数据异常"];
    }
}

- (void)btnPhoneOnclick:(UIButton *)sender{
    if ([[UserData sharedInstance] getLoginType].integerValue == 1 && [[UserData sharedInstance] getEpModelFromHave].identity_mark.integerValue == 2) {
        [[XSJRequestHelper sharedInstance] callFreePhoneWithCalled:_jkModel.contact.phone_num block:nil];
    }else{
        [[MKOpenUrlHelper sharedInstance] callWithPhone:_jkModel.contact.phone_num];
    }
}

/** 刷新cell通知 */
- (void)reflushCell{
    [self.delegate elCell_updateCellIndex:_indexPath withModel:_jkModel];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
