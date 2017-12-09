//
//  ZPSalaryCell.m
//  jianke
//
//  Created by xuzhi on 16/7/20.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ZPSalaryCell.h"
#import "ResponseInfo.h"
#import "DateHelper.h"
#import "Masonry.h"
#import "UIView+MKExtension.h"

@interface ZPSalaryCell ()
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *pointView;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;

@end

@implementation ZPSalaryCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"ZPSalaryCell";
    ZPSalaryCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"ZPSalaryCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setAvModel:(AcctVirtualModel *)avModel{
    _avModel = avModel;
    
    self.detailLabel.text = avModel.virtual_money_detail_title;
    self.pointView.hidden = (avModel.small_red_point.integerValue == 0);
    if (avModel.virtual_money_detail_type.integerValue == 1) {  //充值
        self.amountLabel.text = [NSString stringWithFormat:@"+%.2f",(avModel.actual_amount.floatValue/100.00)];
    }else{
        self.amountLabel.text = [NSString stringWithFormat:@"%.2f",(avModel.actual_amount.floatValue/100.00)];
    }
    self.dateLabel.text = [DateHelper getDateTimeFromTimeNumber:avModel.update_time];
    CGFloat width = [self.amountLabel sizeThatFits:CGSizeMake(MAXFLOAT, 21)].width;
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.lessThanOrEqualTo(@(SCREEN_WIDTH - 48 - width));
    }];
}

- (void)awakeFromNib{
    [self.pointView setCornerValue:2.5f];
}

@end
