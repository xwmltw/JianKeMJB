//
//  CheckDetailCell2.m
//  jianke
//
//  Created by xiaomk on 16/4/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "CheckDetailCell2.h"
#import "JobBillModel.h"

@interface CheckDetailCell2(){
    
}
@property (weak, nonatomic) IBOutlet UILabel *labTitle1;
@property (weak, nonatomic) IBOutlet UILabel *labNum1;
@property (weak, nonatomic) IBOutlet UILabel *labTitle2;
@property (weak, nonatomic) IBOutlet UILabel *labNum2;
@property (weak, nonatomic) IBOutlet UILabel *labUnit2;
@property (weak, nonatomic) IBOutlet UILabel *labTitle3;
@property (weak, nonatomic) IBOutlet UILabel *labNum3;
@end

@implementation CheckDetailCell2

+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"CheckDetailCell2" bundle:nil];
    }
    CheckDetailCell2* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
    }
    return cell;
}

- (void)refreshWithData:(JobBillModel*)model andIndexPath:(NSIndexPath *)indexPath{

}

- (void)CD_refreshWithData:(JobBillModel*)model{
    self.labTitle1.text = @"兼客人数";
    self.labTitle2.text = @"兼客工资总额";
    self.labTitle3.text = @"雇主支付总额";
    self.labUnit2.hidden = YES;
    
    self.labNum1.text = model.pay_stu_count.stringValue;
    self.labNum2.text = [NSString stringWithFormat:@"%.2f",model.salary_amount.floatValue/100];
    self.labNum3.text = [NSString stringWithFormat:@"%.2f",model.total_amount.floatValue/100];
}

- (void)EP_refreshWithData:(JobBillModel*)model{
    self.labTitle1.text = @"兼客人数";
    self.labTitle2.text = @"发布价";
    self.labTitle3.text = @"合计";
    self.labUnit2.hidden = YES;
    
    self.labNum1.text = model.pay_stu_count.stringValue;
    self.labNum2.text = [NSString stringWithFormat:@"%.2f",model.ent_publish_price.floatValue/100];
    self.labNum3.text = [NSString stringWithFormat:@"%.2f",model.total_amount.floatValue/100];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
