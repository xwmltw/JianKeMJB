//
//  ClockRecordCell.m
//  jianke
//
//  Created by fire on 16/7/8.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ClockRecordCell.h"
#import "ResponseInfo.h"
#import "DateHelper.h"
#import "XSJConst.h"
#import "UIColor+Extension.h"

@interface ClockRecordCell (){
    PunchResponseModel *_prModel;
}

@property (weak, nonatomic) IBOutlet UILabel *clockPersonLabel;
@property (weak, nonatomic) IBOutlet UILabel *clockTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *clorkBtn;
- (IBAction)endPunch:(id)sender;

@end

@implementation ClockRecordCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.clorkBtn setTitle:@"已结束" forState:UIControlStateDisabled];
    [self.clorkBtn setTitleColor:[UIColor XSJColor_tGrayTinge] forState:UIControlStateDisabled];
    [self.clorkBtn setCornerValue:2];
}

- (void)setData:(PunchResponseModel *)prModel{
    _prModel = prModel;
    
    NSInteger hasPunchCount = [prModel.has_punch_count integerValue];
    NSInteger needPunchCount = [prModel.need_punch_count integerValue];
    self.clockPersonLabel.text = [NSString stringWithFormat:@"签到人数:%ld/%ld",(long)hasPunchCount,(long)needPunchCount];
    
    NSString *dateString = [DateHelper getDateFromTimeNumber:prModel.create_time];
    self.clockTimeLabel.text = [NSString stringWithFormat:@"发起时间:%@",dateString];
    
    [self setButtonStatus:[prModel.request_status integerValue]];
}

- (IBAction)endPunch:(id)sender {
//    [self setButtonStatus:2];
    if ([self.delegate respondsToSelector:@selector(closePunch:andPunchResponseModel:)]) {
        [self.delegate closePunch:_prModel.punch_the_clock_request_id andPunchResponseModel:_prModel];
    }
}

- (void)setButtonStatus:(NSInteger)status{
    if (status == 1) {
        [self.clorkBtn setBackgroundColor:[UIColor XSJColor_base]];
        self.clorkBtn.enabled = YES;
    }else if (status == 2){
        [self.clorkBtn setBackgroundColor:[UIColor whiteColor]];
        self.clorkBtn.enabled = NO;
    }
}

@end
