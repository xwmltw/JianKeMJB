//
//  MakeCheckCell.m
//  jianke
//
//  Created by xiaomk on 16/4/15.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MakeCheckCell.h"
#import "JobBillModel.h"
#import "WDConst.h"

@interface MakeCheckCell ()
@property (weak, nonatomic) IBOutlet UILabel *labJKWageAll;
@property (weak, nonatomic) IBOutlet UILabel *labEPPayAll;
@property (weak, nonatomic) IBOutlet UILabel *labCheckDate;
@property (weak, nonatomic) IBOutlet UILabel *labSend;

@end

@implementation MakeCheckCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"MakeCheckCell";
    MakeCheckCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"MakeCheckCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
    }
    return cell;
}


- (void)refreshWithData:(JobBillModel*)model andIndexPath:(NSIndexPath *)indexPath{
    if (indexPath) {
        self.indexPath = indexPath;
    }
    if (model) {
        self.labJKWageAll.text = [NSString stringWithFormat:@"%.2f",model.salary_amount.floatValue*0.01];
        self.labEPPayAll.text = [NSString stringWithFormat:@"%.2f",model.total_amount.floatValue*0.01];
        self.labCheckDate.text = model.job_bill_title;
        if (model.bill_status.intValue == 1) {  //1未发送 2已发送 3已支付
            self.labSend.text = @"未发送";
        }else if (model.bill_status.intValue == 2){
            self.labSend.text = @"已发送";
        }else if (model.bill_status.intValue == 3){
            self.labSend.text = @"已支付";
            self.labSend.textColor = [UIColor XSJColor_tGray];
        }
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
