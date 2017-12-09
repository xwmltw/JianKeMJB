//
//  BDCheckPayCell.m
//  jianke
//
//  Created by xiaomk on 16/4/14.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "BDCheckPayCell.h"
#import "JobBillModel.h"
#import "WDConst.h"

@interface BDCheckPayCell()
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labMoney;
@property (weak, nonatomic) IBOutlet UILabel *labPayTime;


@end

@implementation BDCheckPayCell

+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"BDCheckPayCell" bundle:nil];
    }
    BDCheckPayCell* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    return cell;
}

- (void)refreshWithData:(JobBillModel*)model andIndexPath:(NSIndexPath *)indexPath{
    [self setCellHeight:72];
    
    if (model) {
        self.labTitle.text = model.job_title;

        NSString *startDate = [DateHelper getShortDateFromTimeNumber:model.bill_start_date];
        NSString *endDate = [DateHelper getShortDateFromTimeNumber:model.bill_end_date];
        NSString *dateStr;
        if ([startDate isEqualToString:endDate]) {
            dateStr = startDate;
        }else{
            dateStr = [NSString stringWithFormat:@"%@至%@",startDate,endDate];
        }
        self.labDate.text = [NSString stringWithFormat:@"账单日期:%@",dateStr];
  
        NSString *moneyStr = [NSString stringWithFormat:@"￥%0.2f", model.total_amount.floatValue/100];
        moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@".00" withString:@""];
        
        NSMutableAttributedString *moneyAttrStr = [[NSMutableAttributedString alloc] initWithString:moneyStr attributes:@{NSFontAttributeName : [UIFont fontWithName:kFont_RSR size:20], NSForegroundColorAttributeName : [UIColor XSJColor_tRed]}];
        [moneyAttrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFont_RSR size:12] range:NSMakeRange(0, 1)];
        [moneyAttrStr addAttribute:NSBaselineOffsetAttributeName value:@(6) range:NSMakeRange(0, 1)];
        self.labMoney.attributedText = moneyAttrStr;
        
        self.labPayTime.text = [DateHelper getDateFromTimeNumber:model.pay_bill_time withFormat:@"M/d HH:mm"];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
