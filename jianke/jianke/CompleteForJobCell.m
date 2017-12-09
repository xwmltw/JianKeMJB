//
//  CompleteForJobCell.m
//  jianke
//
//  Created by xiaomk on 15/9/15.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "CompleteForJobCell.h"
#import "JobModel.h"
#import "UIHelper.h"

@interface CompleteForJobCell(){
    
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutImgQiang;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labSalaryValue;
@property (weak, nonatomic) IBOutlet UILabel *labSalaryUnit;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgJobStatus;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutImgTuoW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutImgTuoLeft;



@end

@implementation CompleteForJobCell

+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"CompleteForJobCell" bundle:nil];
    }
    CompleteForJobCell* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    
    return cell;
}

- (void)refreshWithData:(JobModel*)model{

    if (model) {
        self.labTitle.text = model.job_title;
        
        NSString *moneyStr = [NSString stringWithFormat:@"￥%.1f", model.salary.value.floatValue];
        moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@".0" withString:@""];
        
        NSMutableAttributedString *moneyAttrStr = [[NSMutableAttributedString alloc] initWithString:moneyStr attributes:@{NSFontAttributeName : [UIFont fontWithName:kFont_RSR size:20], NSForegroundColorAttributeName : MKCOLOR_RGB(255, 87, 34)}];
        [moneyAttrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFont_RSR size:13] range:NSMakeRange(0, 1)];
        [moneyAttrStr addAttribute:NSBaselineOffsetAttributeName value:@(4) range:NSMakeRange(0, 1)];
        
        self.labSalaryValue.attributedText = moneyAttrStr;
        self.labSalaryUnit.text = [NSString stringWithFormat:@"%@", model.salary.getTypeDesc];
        
        //人数
        self.labDate.text = [NSString stringWithFormat:@"%@人", model.recruitment_num];
        self.labDate.font = [UIFont fontWithName:kFont_RSR size:13];

        //时间
//        NSMutableString* dateStr = [UIHelper replaceString:model.dead_time_start_end_str str1:@"." toStr2:@"/"];
//        dateStr = [UIHelper replaceString:dateStr str1:@"-" toStr2:@"至"];
        NSString* dateStr = [[model.dead_time_start_end_str stringByReplacingOccurrencesOfString:@"." withString:@"/"]
                             stringByReplacingOccurrencesOfString:@"-" withString:@"至"];
        
        self.labAddress.text = dateStr;
        self.labAddress.font = [UIFont fontWithName:kFont_RSR size:13];
        
        //抢单 标记
        if (self.managerType == ManagerTypeEP) { // 雇主视角
            
            if (model.job_type.integerValue == 2 && model.enable_recruitment_service.integerValue == 1) { // 抢 & 托
                
                self.layoutImgQiang.constant = 16;
                self.layoutImgTuoW.constant = 16;
                self.layoutImgTuoLeft.constant = 35;
                self.layoutTitle.constant = 56;
                
            } else if (model.job_type.integerValue == 2 && model.enable_recruitment_service.integerValue != 1) { // 抢
                
                self.layoutImgQiang.constant = 16;
                self.layoutImgTuoW.constant = 0;
                self.layoutTitle.constant = 35;
                
            } else if (model.job_type.integerValue != 2 && model.enable_recruitment_service.integerValue == 1) { // 托
                
                self.layoutImgQiang.constant = 0;
                self.layoutImgTuoW.constant = 16;
                self.layoutImgTuoLeft.constant = 14;
                self.layoutTitle.constant = 35;
                
            } else { // 都不显示
                
                self.layoutImgQiang.constant = 0;
                self.layoutImgTuoW.constant = 0;
                self.layoutTitle.constant = 14;
            }
            
  
        } else if (self.managerType == ManagerTypeBD) { // BD视角
            
            if (model.job_type.integerValue == 2) {
                
                self.layoutImgQiang.constant = 16;
                self.layoutImgTuoW.constant = 0;
                self.layoutTitle.constant = 35;
                
            } else {
             
                self.layoutImgQiang.constant = 0;
                self.layoutImgTuoW.constant = 0;
                self.layoutTitle.constant = 14;
            }
        }
        
        
        if (model.job_close_reason.intValue == 3) { //被举报
            [self.imgJobStatus setImage:[UIImage imageNamed:@"ep_home_bjb"]];
            self.imgJobStatus.hidden = NO;
        }else if (model.job_close_reason.intValue == 4) { //审核没通过
            [self.imgJobStatus setImage:[UIImage imageNamed:@"ep_home_shsb"]];
            self.imgJobStatus.hidden = NO;
        }else{
            self.imgJobStatus.hidden = YES;
        }
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
