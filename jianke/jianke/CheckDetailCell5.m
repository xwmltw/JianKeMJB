//
//  CheckDetailCell5.m
//  jianke
//
//  Created by xiaomk on 16/4/25.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "CheckDetailCell5.h"
#import "JobBillModel.h"
#import "WDConst.h"

@interface CheckDetailCell5(){
    PayListModel* _plModel;
    double _salaryNum1;
    double _salaryNum2;

}
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UIImageView *imgLeader;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labSalary_1;
@property (weak, nonatomic) IBOutlet UILabel *labSalary_2;
@property (weak, nonatomic) IBOutlet UILabel *labWorkDay;

@property (weak, nonatomic) IBOutlet UIView *viewEdit_1;
@property (weak, nonatomic) IBOutlet UIButton *btnJian_1;
@property (weak, nonatomic) IBOutlet UIButton *btnJia_1;
@property (weak, nonatomic) IBOutlet UITextField *tfSalary_1;

@property (weak, nonatomic) IBOutlet UIView *viewEdit_2;
@property (weak, nonatomic) IBOutlet UIButton *btnJian_2;
@property (weak, nonatomic) IBOutlet UIButton *btnJia_2;
@property (weak, nonatomic) IBOutlet UITextField *tfSalary_2;

@end

@implementation CheckDetailCell5

+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"CheckDetailCell5" bundle:nil];
    }
    CheckDetailCell5* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    return cell;
}

- (void)refreshWithData:(PayListModel*)model andIndexPath:(NSIndexPath *)indexPath{
    if (model) {
        _plModel = model;
        _salaryNum1 = model.salary.intValue * 0.01;
        _salaryNum2 = model.ent_publish_price.intValue * 0.01;
        
        [self.btnJian_1 addTarget:self action:@selector(btnJianOnclick:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnJia_1 addTarget:self action:@selector(btnJiaOnclick:) forControlEvents:UIControlEventTouchUpInside];
        [self.tfSalary_1 addTarget:self action:@selector(tfEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self.tfSalary_1 addTarget:self action:@selector(tfEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        self.btnJian_1.tag = 100;
        self.btnJia_1.tag = 100;
        self.tfSalary_1.tag = 100;
        
        [self.btnJian_2 addTarget:self action:@selector(btnJianOnclick:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnJia_2 addTarget:self action:@selector(btnJiaOnclick:) forControlEvents:UIControlEventTouchUpInside];
        [self.tfSalary_2 addTarget:self action:@selector(tfEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self.tfSalary_2 addTarget:self action:@selector(tfEditingChanged:) forControlEvents:UIControlEventEditingChanged];
        self.btnJian_2.tag = 200;
        self.btnJia_2.tag = 200;
        self.tfSalary_2.tag = 200;
        
        [self.imgHead sd_setImageWithURL:[NSURL URLWithString:model.profile_url] placeholderImage:[UIHelper getDefaultHead]];
        self.imgLeader.hidden = !model.isLeader;
        //性别
        if (model.sex.intValue == 0) {
            [self.imgSex setImage:[UIImage imageNamed:@"v230_female"]];
        }else{
            [self.imgSex setImage:[UIImage imageNamed:@"v230_male"]];
        }
        //姓名
        self.labName.text = model.true_name;
        
        if (model.real_work_day && model.real_work_day.integerValue > 0) {
             self.labWorkDay.text = [NSString stringWithFormat:@" %@ ",model.real_work_day];
        }else{
            self.labWorkDay.hidden = YES;
        }
        [UIHelper setCorner:self.labWorkDay];
        
        self.labSalary_1.text = [[NSString stringWithFormat:@"%.2f",_salaryNum1] stringByReplacingOccurrencesOfString:@".00" withString:@""];
        self.labSalary_2.text = [[NSString stringWithFormat:@"%.2f",_salaryNum2] stringByReplacingOccurrencesOfString:@".00" withString:@""];
        
        self.tfSalary_1.text = [[NSString stringWithFormat:@"%.2f", _salaryNum1] stringByReplacingOccurrencesOfString:@".00" withString:@""];
        self.tfSalary_2.text = [[NSString stringWithFormat:@"%.2f", _salaryNum2] stringByReplacingOccurrencesOfString:@".00" withString:@""];
        
        self.viewEdit_1.hidden = !self.isEditing;
        self.viewEdit_2.hidden = !self.isEditing;
        self.labSalary_1.hidden = self.isEditing;
        self.labSalary_2.hidden = self.isEditing;
    }
}

- (void)btnJianOnclick:(UIButton*)sender{
    if (sender.tag == 100) {
        _salaryNum1 -= 5;
        if (_salaryNum1 < 0) {
            _salaryNum1 = 0;
        }
        self.tfSalary_1.text = [[NSString stringWithFormat:@"%.2f", _salaryNum1] stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }else if (sender.tag == 200){
        _salaryNum2 -= 5;
        if (_salaryNum2 < 0) {
            _salaryNum2 = 0;
        }
        self.tfSalary_2.text = [[NSString stringWithFormat:@"%.2f", _salaryNum2] stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }
    [self changeMoney];

}

- (void)btnJiaOnclick:(UIButton*)sender{
    if (sender.tag == 100) {
        _salaryNum1 += 5;
        if (_salaryNum1 > 999999) {
            _salaryNum1 = 999999;
        }
        self.tfSalary_1.text = [[NSString stringWithFormat:@"%.2f", _salaryNum1] stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }else if (sender.tag == 200){
        _salaryNum2 += 5;
        if (_salaryNum2 > 999999) {
            _salaryNum2 = 999999;
        }
        self.tfSalary_2.text = [[NSString stringWithFormat:@"%.2f", _salaryNum2] stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }
    [self changeMoney];
}

- (void)tfEditingChanged:(UITextField *)sender {
    NSRange range = [sender.text rangeOfString:@"."];
    if (range.location != NSNotFound) { // 有小数点
        if (sender.text.length > 9) {
            sender.text = [sender.text substringToIndex:9];
        }
    } else { // 没有小数点
        if (sender.text.length > 6) {
            sender.text = [sender.text substringToIndex:6];
        }
    }
    
    if (sender.tag == 100) {
        _salaryNum1 = [sender.text doubleValue];
        if (!_salaryNum1) {
            _salaryNum1 = 0;
        }
    }else if (sender.tag == 200){
        _salaryNum2 = [sender.text doubleValue];
        if (!_salaryNum2) {
            _salaryNum2 = 0;
        }
    }
    [self changeMoney];
}

- (void)tfEditingEnd:(UITextField*)textField{
    [textField resignFirstResponder];
    if (textField.tag == 100) {
        _salaryNum1 = [textField.text doubleValue];
        if (!_salaryNum1) {
            _salaryNum1 = 0;
        }
    }else if (textField.tag == 200){
        _salaryNum2 = [textField.text doubleValue];
        if (!_salaryNum2) {
            _salaryNum2 = 0;
        }
    }
    [self changeMoney];
}

- (void)changeMoney{    
    _plModel.salary = @(_salaryNum1*100);
    _plModel.ent_publish_price = @(_salaryNum2*100);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
