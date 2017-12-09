//
//  CheckDetailCell4.m
//  jianke
//
//  Created by xiaomk on 16/4/23.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "CheckDetailCell4.h"
#import "JobBillModel.h"
#import "WDConst.h"


@interface CheckDetailCell4(){
    PayListModel* _plModel;
    double _salaryNum;

}

@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UIImageView *imgLead;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labMoney;

@property (weak, nonatomic) IBOutlet UIView *viewEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnJian;
@property (weak, nonatomic) IBOutlet UIButton *btnJia;
@property (weak, nonatomic) IBOutlet UITextField *tfSalaryNum;
@end

@implementation CheckDetailCell4


+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"CheckDetailCell4" bundle:nil];
    }
    CheckDetailCell4* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)init{
    ELog(@"CheckDetailCell4 init");

    return self;
}
- (void)refreshWithData:(PayListModel*)model andIndexPath:(NSIndexPath *)indexPath{
    [self.btnJian addTarget:self action:@selector(btnJianOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnJia addTarget:self action:@selector(btnJiaOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.tfSalaryNum addTarget:self action:@selector(tfEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [self.tfSalaryNum addTarget:self action:@selector(tfEditingChanged:) forControlEvents:UIControlEventEditingChanged];
    
    if (model) {
        _plModel = model;
        _salaryNum = model.ent_publish_price.intValue * 0.01;

        [self.imgHead sd_setImageWithURL:[NSURL URLWithString:model.profile_url] placeholderImage:[UIHelper getDefaultHead]];
        //性别
        if (model.sex.intValue == 0) {
            [self.imgSex setImage:[UIImage imageNamed:@"v230_female"]];
        }else{
            [self.imgSex setImage:[UIImage imageNamed:@"v230_male"]];
        }
        //姓名
        self.labName.text = model.true_name;
        self.labMoney.text = [[NSString stringWithFormat:@"%.2f",_salaryNum] stringByReplacingOccurrencesOfString:@".00" withString:@""];
        
        
        if (self.isEditing) {
            self.viewEdit.hidden = NO;
            self.labMoney.hidden = YES;
            self.tfSalaryNum.text =  [[NSString stringWithFormat:@"%.2f", _salaryNum] stringByReplacingOccurrencesOfString:@".00" withString:@""];
        }else{
            self.viewEdit.hidden = YES;
            self.labMoney.hidden = NO;
        }
    }
}

/** - */
- (void)btnJianOnclick:(UIButton*)sender{
    if (_salaryNum >= 5) {
        _salaryNum -= 5;
    }else{
        _salaryNum = 0;
    }
    self.tfSalaryNum.text = [[NSString stringWithFormat:@"%.2f", _salaryNum] stringByReplacingOccurrencesOfString:@".00" withString:@""];
    [self changeMoney];
}

/** + */
- (void)btnJiaOnclick:(UIButton*)sender{
    _salaryNum += 5;
    if (_salaryNum > 999999) {
        _salaryNum = 999999;
    }
    self.tfSalaryNum.text = [[NSString stringWithFormat:@"%.2f", _salaryNum] stringByReplacingOccurrencesOfString:@".00" withString:@""];
    [self changeMoney];
}


- (void)tfEditingChanged:(UITextField *)sender {
    NSRange range = [sender.text rangeOfString:@"."];
    if (range.length != 0) { // 有小数点
        if (sender.text.length > 9) {
            sender.text = [sender.text substringToIndex:9];
        }
    } else { // 没有小数点
        if (sender.text.length > 6) {
            sender.text = [sender.text substringToIndex:6];
        }
    }
    _salaryNum = [self.tfSalaryNum.text doubleValue];
    if (!_salaryNum) {
        _salaryNum = 0;
    }
    [self changeMoney];
}

- (void)tfEditingEnd:(UITextField *)sender {
    [sender resignFirstResponder];
    [self changeMoney];
}

- (void)changeMoney{
    _plModel.ent_publish_price = @(_salaryNum*100);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
