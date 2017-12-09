//
//  JobCountCell.m
//  jianke
//
//  Created by 时现 on 15/11/5.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "JobCountCell.h"
#import "JobModel.h"
#import "WDConst.h"

@interface JobCountCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgJobType;
@property (weak, nonatomic) IBOutlet UIImageView *imgAuth;
@property (weak, nonatomic) IBOutlet UILabel *labJobTitle;
@property (weak, nonatomic) IBOutlet UILabel *labJobTime;
@property (weak, nonatomic) IBOutlet UILabel *labJobAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgHot;
@property (weak, nonatomic) IBOutlet UILabel *labSalary;
@property (weak, nonatomic) IBOutlet UILabel *labSalaryUnit;


@end
@implementation JobCountCell
+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"JobCountCell" bundle:nil];
    }
    JobCountCell* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    
    return cell;
}

- (void)refreshWithData:(JobModel *)model
{
    _model = model;
    
    //头像
    [self.imgJobType sd_setImageWithURL:[NSURL URLWithString:model.job_classfie_img_url]placeholderImage:[UIHelper getDefaultImage]];
    //标题
    self.labJobTitle.text = model.job_title;
    //时间
    NSString *starTime = [DateHelper getDateWithNumber:model.work_time_start];
    NSString *endTime = [DateHelper getDateWithNumber:model.work_time_end];
    self.labJobTime.text = [NSString stringWithFormat:@"%@ 至 %@",starTime,endTime];
    //地点
    if (model.distance) {
        int dis = model.distance.intValue;
        if (dis < 1000) {
            self.labJobAddress.text = [NSString stringWithFormat:@"%dm",dis];
        }else{
            float num = dis/1000;
            self.labJobAddress.text = [NSString stringWithFormat:@"%.1fkm",num];
        }
    }else{
        self.labJobAddress.text = model.working_place;
    }
    //工资
    NSString *money = [NSString stringWithFormat:@"%.1f", model.salary.value.doubleValue];
    money = [money stringByReplacingOccurrencesOfString:@".0" withString:@""];
    self.labSalary.text = [NSString stringWithFormat:@"%@",money];
    self.labSalaryUnit.text = [NSString stringWithFormat:@"%@",model.salary.getTypeDesc];
    
    //hot
    if (model.hot.intValue == 1) {
        self.imgHot.hidden = NO;
    }else{
        self.imgHot.hidden = YES;
    }
    //认证
    if (model.enterprise_verified.intValue == 3) {
        self.imgAuth.hidden = NO;
    }else{
        self.imgAuth.hidden = YES;
    }
    //暑假工
    
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
