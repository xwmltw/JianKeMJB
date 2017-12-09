//
//  JobComplaintCell.m
//  jianke
//
//  Created by 时现 on 15/11/6.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "JobComplaintCell.h"
#import "JobModel.h"
#import "WDConst.h"

@interface JobComplaintCell()

@property (weak, nonatomic) IBOutlet UIImageView *imgQiang;
@property (weak, nonatomic) IBOutlet UILabel *labJobTitle;
@property (weak, nonatomic) IBOutlet UILabel *labTime;
@property (weak, nonatomic) IBOutlet UILabel *labAddress;
@property (weak, nonatomic) IBOutlet UILabel *labSalary;
@property (weak, nonatomic) IBOutlet UILabel *labSalaryUnit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleToQiangConstraint;

@end
@implementation JobComplaintCell

+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"JobComplaintCell" bundle:nil];
    }
    JobComplaintCell* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    
    return cell;
}

- (void)refreshWithData:(JobModel *)model
{
    
    _model = model;
    if (model.job_type.intValue == 2) {
        self.imgQiang.hidden = NO;
        self.titleToQiangConstraint.constant = 40;
    }else{
        self.imgQiang.hidden = YES;
        self.titleToQiangConstraint.constant = 8;
    }
    //标题
    self.labJobTitle.text = model.job_title;
    //时间
    NSString *starTime = [DateHelper getShortDateFromTimeNumber:model.working_time_start_date];
    NSString *endTime = [DateHelper getShortDateFromTimeNumber:model.working_time_start_date];
    self.labTime.text = [NSString stringWithFormat:@"%@ 至 %@",starTime,endTime];
    //地点
    self.labAddress.text = model.working_place;
    //工资
    NSString *money = [NSString stringWithFormat:@"%.1f", model.salary.value.doubleValue];
    money = [money stringByReplacingOccurrencesOfString:@".0" withString:@""];
    
    self.labSalary.text = [NSString stringWithFormat:@"%@",money];
    self.labSalaryUnit.text = [NSString stringWithFormat:@"%@",model.salary.getTypeDesc];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
