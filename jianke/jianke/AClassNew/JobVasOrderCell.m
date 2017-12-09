//
//  JobVasOrderCell.m
//  jianke
//
//  Created by fire on 16/9/24.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JobVasOrderCell.h"
#import "WDConst.h"


#define HEIGHTFORIMG 104
#define WIDTHFORIMG 343

@interface JobVasOrderCell ()

@property (weak, nonatomic) IBOutlet UILabel *labName;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (weak, nonatomic) IBOutlet UILabel *labTip;
@property (weak, nonatomic) IBOutlet UILabel *labPushDes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutImgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutBtnTop;

@end

@implementation JobVasOrderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.payBtn setCornerValue:2.0f];
    [self.payBtn addTarget:self action:@selector(payAction:) forControlEvents:UIControlEventTouchUpInside];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.payBtn setBackgroundImage:[UIImage imageNamed:@"v3_public_btn_bg_2"] forState:UIControlStateDisabled];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setData:(JobVasResponse *)model andType:(NSInteger)type cellDic:(NSMutableDictionary *)cellHeightDic{
    
    self.payBtn.tag = type;
    self.payBtn.enabled = YES;
    self.labPushDes.hidden = YES;
    self.labTip.hidden = YES;
//    self.layoutBtnTop.constant = 2;
    switch (type) {
        case 1:{
            self.labName.text = @"岗位置顶：排名在第一页，曝光效果翻倍，快来试试吧";
            self.imgView.image = [UIImage imageNamed:@"job_vas_stick_type"];
            if (model.top_dead_time && model.top_dead_time.longLongValue > 0) { //有购买记录
                self.labTip.hidden = NO;
                if ((model.top_dead_time.doubleValue * 0.001) >= [NSDate date].timeIntervalSince1970) { //置顶中
                    self.labTip.text = [NSString stringWithFormat:@"置顶截止:%@", [DateHelper getDateFromTimeNumber:model.top_dead_time withFormat:@"yyyy-M-d H:mm"]];
                    [self.payBtn setTitle:@"已购买" forState:UIControlStateNormal];
                    self.payBtn.enabled = NO;
                }else{
                    self.labTip.text = @"置顶已过期";
                }
            }
            
        }
            break;
        case 2:{
            self.labName.text = @"刷新岗位：排名靠前，时间显示最新，效率提高3.5倍";
            self.imgView.image = [UIImage imageNamed:@"job_vas_refresh_type"];
            if (model.last_refresh_time && model.last_refresh_time.longLongValue > 0) {
                self.labTip.hidden = NO;
                self.labTip.text = [NSString stringWithFormat:@"上次刷新:%@", [DateHelper getDateFromTimeNumber:model.last_refresh_time withFormat:@"yyyy-M-d H:mm"]];
                [self.payBtn setTitle:@"去购买" forState:UIControlStateNormal];
            }
        }
            break;
        case 3:{
            self.labName.text = @"推送推广：精准推送岗位信息给城市中的兼客，招聘效率提升2倍";
            self.imgView.image = [UIImage imageNamed:@"job_vas_push_type"];
            if (model.last_push_time && model.last_push_time.longLongValue > 0) {
                self.labTip.hidden = NO;
                self.labPushDes.hidden = NO;
                self.labTip.text = [NSString stringWithFormat:@"上次推送:%@", [DateHelper getDateFromTimeNumber:model.last_push_time withFormat:@"yyyy-M-d H:mm"]];
                [self.payBtn setTitle:@"去购买" forState:UIControlStateNormal];
                self.labPushDes.text = model.last_push_desc;
//                self.layoutBtnTop.constant = 10;
            }
        }
            break;
        default:
            break;
    }
    CGFloat width = SCREEN_WIDTH - 32;  //图片宽度
    CGFloat clips = (width - WIDTHFORIMG) / WIDTHFORIMG;  //图片压缩比例
    CGFloat height = HEIGHTFORIMG + clips * HEIGHTFORIMG;
    self.layoutImgHeight.constant = height;
    
    CGFloat cellHeight = 12 + [self.labName contentSizeWithWidth:SCREEN_WIDTH - 32].height + 5 + height + 31 + 12 + ((self.labPushDes.hidden) ? 0 : [self.labPushDes contentSizeWithWidth:SCREEN_WIDTH - 77].height) ;
    [cellHeightDic setObject:@(cellHeight) forKey:@(type)];
    
    ELog(@"%ld*******%f",type , cellHeight);
}

- (void)payAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(jobVasOrderCell:actionType:)]) {
        [self.delegate jobVasOrderCell:self actionType:sender.tag];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
