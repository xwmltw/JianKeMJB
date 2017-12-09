//
//  BuyInsuranceCell_2.m
//  jianke
//
//  Created by 时现 on 16/1/13.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "BuyInsuranceCell_2.h"
#import "JKModel.h"
#import "WDConst.h"
@interface BuyInsuranceCell_2 ()
{
    ResumeLModel *_rlModel;
    JKModel  *_jkModel;
    BOOL _isSelectBtn;

    NSIndexPath* _indexPath;

}
@property (weak, nonatomic) IBOutlet UIButton *btnAgree;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labSalary;


@end
@implementation BuyInsuranceCell_2
+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"BuyInsuranceCell_2" bundle:nil];
    }
    BuyInsuranceCell_2* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}
- (instancetype)init{
    _isSelectBtn = NO;
    return self;
}

- (void)refreshWithData:(ResumeLModel  *)model andIndexPath:(NSIndexPath *)indexPath
{
    if (model) {
        _jkModel = model.resume_info;
        _rlModel = model;
        _indexPath = indexPath;
        //姓名性别头像
//        if (_rlModel.isSelect) {
//            self.btnAgree.selected = YES;
//            _isSelectBtn = YES;
//        }
        self.labName.text = _jkModel.true_name;
        if (_jkModel.sex.intValue == 0) {
            [self.imgSex setImage:[UIImage imageNamed:@"v230_female"]];
        }else{
            [self.imgSex setImage:[UIImage imageNamed:@"v230_male"]];
        }
        [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:_jkModel.user_profile_url]placeholderImage:[UIHelper getDefaultHeadRect]];
        //时间
        self.labTime.text = [DateHelper dateRangeStrWithMicroSecondNumArray:_jkModel.stu_work_time];
        self.labTime.font = [UIFont fontWithName:kFont_RSR size:13];
    }
    if (_jkModel.stu_work_time.count) {
        self.labSalary.text = [NSString stringWithFormat:@"%.2f", _rlModel.allDays * self.insurancePrice.integerValue * 0.01];
//        self.btnAgree.selected = YES;
    }else{
        self.labSalary.text = @"0";
    }
    
}

- (IBAction)btnAgreeOnClick:(UIButton *)sender {
    
    _isSelectBtn = !_isSelectBtn;
    sender.selected = _isSelectBtn;
    _rlModel.isSelect = _isSelectBtn;
    _rlModel.nowPay = _rlModel.allDays * self.insurancePrice.integerValue * 0.01;
    [_delegate allMoneyWithSelect_2];
//    [_delegate elCell_changeData_2WithModel:_rlModel andIndexPath:_indexPath];
}

@end
