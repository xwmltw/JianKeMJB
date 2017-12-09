//
//  CheckDetailCell3.m
//  jianke
//
//  Created by xiaomk on 16/4/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "CheckDetailCell3.h"
#import "JobBillModel.h"
#import "WDConst.h"

@interface CheckDetailCell3(){
    
}

@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labDay;
@property (weak, nonatomic) IBOutlet UILabel *labMoney;
@end

@implementation CheckDetailCell3


+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"CheckDetailCell3" bundle:nil];
    }
    CheckDetailCell3* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)refreshWithData:(PayListModel*)model andIndexPath:(NSIndexPath*)indexPath{
    if (model) {
        [self.imgIcon sd_setImageWithURL:[NSURL URLWithString:model.profile_url] placeholderImage:[UIHelper getDefaultHeadRect]];
        //性别
        if (model.sex.intValue == 0) {
            [self.imgSex setImage:[UIImage imageNamed:@"v230_female"]];
        }else{
            [self.imgSex setImage:[UIImage imageNamed:@"v230_male"]];
        }
        self.labTitle.text = model.true_name;
        if (model.real_work_day && model.real_work_day.integerValue > 0) {
            self.labDay.text = [NSString stringWithFormat:@" %@天 ", model.real_work_day.stringValue];
            [UIHelper setCorner:self.labDay];
        }else{
            self.labDay.hidden = YES;
        }
        self.labMoney.text = [[NSString stringWithFormat:@"%.2f",model.ent_publish_price.floatValue * 0.01] stringByReplacingOccurrencesOfString:@".00" withString:@""];
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
