//
//  WPDetailConfirmNoCell.m
//  jianke
//
//  Created by xiaomk on 16/4/27.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WPDetailConfirmNoCell.h"
#import "JKModel.h"
#import "WDConst.h"


@interface WPDetailConfirmNoCell(){
    JKModel* _jkModel;
}
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UIButton *btnDisqualification;
@property (weak, nonatomic) IBOutlet UILabel *labRefuse;

@end
@implementation WPDetailConfirmNoCell

+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"WPDetailConfirmNoCell" bundle:nil];
    }
    WPDetailConfirmNoCell* cell;
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
        
        [self.btnDisqualification setBorderColor:[UIColor XSJColor_base]];
        [self.btnDisqualification setCorner];
        [self.btnDisqualification addTarget:self action:@selector(btnDisOnclick:) forControlEvents:UIControlEventTouchUpInside];
        
        if (model.trade_loop_status.integerValue == 1) {
            self.btnDisqualification.hidden = NO;
            self.labRefuse.hidden = YES;
        }else if (model.trade_loop_status.integerValue == 2){
            self.btnDisqualification.hidden = YES;
            self.labRefuse.hidden = NO;
            self.labRefuse.text = @"录用成功";
            self.labRefuse.textColor = [UIColor XSJColor_base];
        }else{
            self.btnDisqualification.hidden = YES;
            if (model.trade_loop_finish_type.integerValue == 2 || model.trade_loop_finish_type.integerValue == 5) {
                self.labRefuse.text = @"已拒绝";
                self.labRefuse.textColor = [UIColor XSJColor_tGray];
            }else if (model.trade_loop_finish_type.integerValue == 1){
                self.labRefuse.text = @"取消报名";
                self.labRefuse.textColor = [UIColor XSJColor_tGray];
            }else if (model.trade_loop_finish_type.integerValue == 3){
                self.labRefuse.text = @"已完工";
                self.labRefuse.textColor = [UIColor XSJColor_tGray];
            }else if (model.trade_loop_finish_type.integerValue == 6){
                self.labRefuse.text = @"岗位关闭";
                self.labRefuse.textColor = [UIColor XSJColor_tGray];
            }
        }
    }
}

- (void)btnDisOnclick:(UIButton*)sender{
    [TalkingData trackEvent:@"上岗详情_未确认_不合格"];

    WEAKSELF
    [[UserData sharedInstance] entEmployApplyJobWithWithApplyJobIdList:@[_jkModel.apply_job_id] employStatus:@(2) employMemo:@"" block:^(ResponseInfo *response) {
        weakSelf.btnDisqualification.hidden = YES;
        weakSelf.labRefuse.text = @"已拒绝";
        weakSelf.labRefuse.hidden = NO;
        
        _jkModel.trade_loop_status = @(3);
        _jkModel.trade_loop_finish_type = @(2);
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
