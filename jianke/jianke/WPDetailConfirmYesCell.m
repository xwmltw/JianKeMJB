//
//  WPDetailConfirmYesCell.m
//  jianke
//
//  Created by xiaomk on 16/4/27.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WPDetailConfirmYesCell.h"
#import "JKModel.h"
#import "WDConst.h"

@interface WPDetailConfirmYesCell(){
    JKModel* _jkModel;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UIImageView *imgTime;
@property (weak, nonatomic) IBOutlet UILabel *labTime;

@property (weak, nonatomic) IBOutlet UIButton *btnEmploy;
@property (weak, nonatomic) IBOutlet UILabel *labEmployYet;


@end

@implementation WPDetailConfirmYesCell

+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"WPDetailConfirmYesCell" bundle:nil];
    }
    WPDetailConfirmYesCell* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)refreshWithData:(JKModel*)model andIndexPath:(NSIndexPath *)indexPath{
    if (model) {
        _jkModel = model;
        
        [self.imgHead sd_setImageWithURL:[NSURL URLWithString:model.profile_url] placeholderImage:[UIHelper getDefaultHead]];
        self.labName.text = model.true_name;
        
        if (model.sex.intValue == 0) {
            [self.imgSex setImage:[UIImage imageNamed:@"v230_female"]];
        }else{
            [self.imgSex setImage:[UIImage imageNamed:@"v230_male"]];
        }
        
        NSString* labDate = [DateHelper getDateFromTimeNumber:model.stu_confirm_work_time withFormat:@"M/d HH:mm"];
        self.labTime.text = labDate;

        [self.btnEmploy addTarget:self action:@selector(btnEmployOnclick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (model.trade_loop_status.integerValue == 1) {
            self.btnEmploy.hidden = NO;
            self.labEmployYet.hidden = YES;
        }else if (model.trade_loop_status.integerValue == 2){
            self.btnEmploy.hidden = YES;
            self.labEmployYet.hidden = NO;
        }else{
            self.btnEmploy.hidden = YES;
            self.labEmployYet.hidden = NO;
            if (model.trade_loop_finish_type.integerValue == 2 || model.trade_loop_finish_type.integerValue == 5) {
                self.labEmployYet.text = @"已拒绝";
            }else if (model.trade_loop_finish_type.integerValue == 1){
                self.labEmployYet.text = @"取消报名";
            }else if (model.trade_loop_finish_type.integerValue == 3){
                self.labEmployYet.text = @"已录用";   //已完工
            }else if (model.trade_loop_finish_type.integerValue == 6){
                self.labEmployYet.text = @"岗位关闭";
            }
        }
    }
}

- (void)btnEmployOnclick:(UIButton*)sender{
    [TalkingData trackEvent:@"上岗详情_已确认_录用"];

    WEAKSELF
    [[UserData sharedInstance] entEmployApplyJobWithWithApplyJobIdList:@[_jkModel.apply_job_id.stringValue] employStatus:@(1) employMemo:nil block:^(ResponseInfo *response) {
        [UIHelper toast:@"录用成功"];
        weakSelf.btnEmploy.hidden = YES;
        weakSelf.labEmployYet.hidden = NO;
        _jkModel.trade_loop_status = @(2);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
