//
//  CheckDetailCell1.m
//  jianke
//
//  Created by xiaomk on 16/4/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "CheckDetailCell1.h"
#import "JobBillModel.h"
#import "DateHelper.h"

@interface CheckDetailCell1(){
    
}
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@end

@implementation CheckDetailCell1

+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"CheckDetailCell1" bundle:nil];
    }
    CheckDetailCell1* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    return cell;
}

- (void)refreshWithData:(JobBillModel*)model andIndexPath:(NSIndexPath *)indexPath{
    self.labTitle.text = [NSString stringWithFormat:@"· %@",model.job_title];;
    
    NSString* dateStrStart = [DateHelper getDateFromTimeNumber:model.bill_start_date withFormat:@"M月dd日"];
    NSString* dateStrEnd = [DateHelper getDateFromTimeNumber:model.bill_end_date withFormat:@"M月dd日"];
    NSString* dateStr;
    if (model.bill_start_date.longLongValue == model.bill_end_date.longLongValue) {
        dateStr = [NSString stringWithFormat:@"%@",dateStrStart];
    }else{
        dateStr = [NSString stringWithFormat:@"%@-%@",dateStrStart,dateStrEnd];
    }
    self.labDate.text = [NSString stringWithFormat:@"· 账单日期:%@",dateStr];

}

- (void)EP_refreshWithData:(JobBillModel*)model{
    self.labTitle.text = [NSString stringWithFormat:@"· %@",model.job_title];
    NSString *dateStr = [DateHelper getDateFromTimeNumber:@(model.expect_repayment_time.integerValue) withFormat:@"M月d日"];
    self.labDate.text = [NSString stringWithFormat:@"· 预计还款日期:%@",dateStr];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
 */

@end
