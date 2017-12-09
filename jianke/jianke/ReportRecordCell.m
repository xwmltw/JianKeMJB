//
//  ReportRecordCell.m
//  jianke
//
//  Created by 时现 on 15/10/27.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "ReportRecordCell.h"
#import "UIImageView+WebCache.h"
#import "ReportRecordModel.h"
#import "DateHelper.h"


@interface ReportRecordCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;//头像
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;//性别
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//姓名
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;//打卡时间
@property (weak, nonatomic) IBOutlet UILabel *adressLabel;//所在地点
@property (weak, nonatomic) IBOutlet UILabel *notFinishLabel;//未完成Label
@property (weak, nonatomic) IBOutlet UIButton *punchBtn;
- (IBAction)punchAction:(id)sender;

@end
@implementation ReportRecordCell

- (void)setReportRecordModel:(ReportRecordModel *)reportRecordModel
{
    _reportRecordModel = reportRecordModel;
    
    // 头像
    self.iconImageView.layer.cornerRadius = 2;
    self.iconImageView.clipsToBounds = YES;
    if (reportRecordModel.profile_url) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:reportRecordModel.profile_url] placeholderImage:[UIImage imageNamed:@"info_person_fang"]];
    }
    
    //性别
    if ([reportRecordModel.sex integerValue]) {
        [self.sexImageView setImage:[UIImage imageNamed:@"main_sex_female"]];
    }else{
        [self.sexImageView setImage:[UIImage imageNamed:@"main_sex_male"]];
    }
    
    // 姓名
    if (reportRecordModel.true_name && reportRecordModel.true_name.length) {
        self.nameLabel.text = reportRecordModel.true_name;
    } else {
        self.nameLabel.text = @"兼客用户";
    }
    //打卡时间
    if (reportRecordModel.punch_the_clock_time) {
        //时间设置
        self.timeLabel.text = [DateHelper getTimeWithNumber:@(reportRecordModel.punch_the_clock_time.longLongValue * 0.001)];

        self.notFinishLabel.hidden = YES;
    }
    //所在地点
    if (reportRecordModel.punch_the_clock_location && reportRecordModel.punch_the_clock_location.length) {
        self.adressLabel.text = reportRecordModel.punch_the_clock_location;
        self.adressLabel.hidden = NO;
        self.timeLabel.hidden = NO;
        self.punchBtn.hidden = YES;
    }
    
    //未完成
    if (!reportRecordModel.punch_the_clock_time && !reportRecordModel.punch_the_clock_location.length) {
        self.punchBtn.hidden = NO;
        self.adressLabel.hidden = YES;
        self.timeLabel.hidden = YES;
    }
}
- (IBAction)punchAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(manualPunch:)]) {
        [self.delegate manualPunch:_reportRecordModel];
    }
}
@end
