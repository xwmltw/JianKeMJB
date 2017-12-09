//
//  PayOnlineCell.m
//  jianke
//
//  Created by xiaomk on 15/9/29.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "PayOnlineCell.h"
#import "WDConst.h"
#import "JKModel.h"


@interface PayOnlineCell(){
    double _salaryNum;  /** 支付金额 */
    JKModel* _jkModel;
    
}
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UITextField *tfEditMoney;
@property (weak, nonatomic) IBOutlet UILabel *labAddJkTag;
@end

@implementation PayOnlineCell


+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"PayOnlineCell";
    PayOnlineCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"PayOnlineCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        [cell.labAddJkTag setBorderWidth:1 andColor:[UIColor XSJColor_grayLine]];
        [cell.labAddJkTag setCorner];
    }
    return cell;
}

- (void)refreshWithData:(JKModel*)model{
    if (model) {
        _jkModel = model;
        _salaryNum = _jkModel.salary_num.doubleValue*0.01;
        
        self.btnSelect.selected = _jkModel.isSelect;
        //头像
        [self.imgHead setCorner];
        [self.imgHead sd_setImageWithURL:[NSURL URLWithString:model.profile_url] placeholderImage:[UIHelper getDefaultHeadRect]];
        //名字
        self.labName.text = model.true_name;
        
        // 人员补录      
        if (_jkModel.isFromPayAdd) {
            self.labAddJkTag.text = @"人员补录";
        }else {
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
        }
        
        // 日期
        if (_jkModel.stu_work_time_type.integerValue == 2 || _jkModel.isFromPayAdd) { // 默认
            NSString *startDate = [DateHelper getDateWithNumber:_jkModel.stu_work_time.firstObject];
            NSString *endDate = [DateHelper getDateWithNumber:_jkModel.stu_work_time.lastObject];
            self.labTime.text = [NSString stringWithFormat:@"%@ 至 %@", startDate, endDate];
        } else { // 兼客选择
            self.labTime.text = [DateHelper dateRangeStrWithSecondNumArray:_jkModel.stu_work_time];
        }
        
        self.tfEditMoney.text = [[NSString stringWithFormat:@"%.2f", _salaryNum] stringByReplacingOccurrencesOfString:@".00" withString:@""];
    }
}

//修改金钱
- (IBAction)textFileChange:(UITextField *)sender {
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
    
    _salaryNum = [self.tfEditMoney.text doubleValue];
    if (!_salaryNum) {
        _salaryNum = 0;
    }
    [self changeMoney];
}


- (IBAction)textFileEndEdit:(UITextField *)textField{
    [textField resignFirstResponder];
    _salaryNum = [self.tfEditMoney.text doubleValue];
    if (!_salaryNum) {
        _salaryNum = 0;
    }
    [self changeMoney];
}

- (void)changeMoney{
    _jkModel.salary_num = @(_salaryNum*100);
    
    self.btnSelect.selected = _salaryNum != 0;
    _jkModel.isSelect = self.btnSelect.selected;
    
    if ([self.delegate respondsToSelector:@selector(sumAllMoneyWithSelect)]) {
        [self.delegate sumAllMoneyWithSelect];
    }
}

//选择按钮
- (IBAction)btnSelectOnclick:(UIButton *)sender {
    if (!_jkModel.isSelect && _salaryNum == 0) {
        [UIHelper toast:@"金额为0，不能选择"];
        return;
    }
    sender.selected = !sender.selected;
    _jkModel.isSelect = sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(sumAllMoneyWithSelect)]) {
        [self.delegate sumAllMoneyWithSelect];
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
