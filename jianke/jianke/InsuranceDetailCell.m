//
//  InsuranceDetailCell.m
//  jianke
//
//  Created by 时现 on 15/12/7.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "InsuranceDetailCell.h"
#import "InsuranceDetailModel.h"
#import "UIImageView+WebCache.h"
#import "WDConst.h"
@interface InsuranceDetailCell()
{
    InsuranceDetailModel *_idModel;
}
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;//头像
@property (weak, nonatomic) IBOutlet UIImageView *sexImgView;//性别

@property (weak, nonatomic) IBOutlet UILabel *labelName;//姓名
@property (weak, nonatomic) IBOutlet UILabel *labelMoney;//保险金额
@property (weak, nonatomic) IBOutlet UIImageView *imageResult;//是否投保成功
@property (weak, nonatomic) IBOutlet UIImageView *imageApplying;
@property (weak, nonatomic) IBOutlet UIView *lostView;

@end
@implementation InsuranceDetailCell


+ (instancetype)new
{
    static UINib *_nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"InsuranceDetailCell" bundle:nil];
    }
    InsuranceDetailCell *cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(void)refreshWithData:(InsuranceDetailModel *)model
{
    if (model) {
        _idModel = model;
        // 头像
        self.iconImgView.layer.cornerRadius = 2;
        self.iconImgView.clipsToBounds = YES;
        [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:_idModel.user_profile_url]placeholderImage:[UIHelper getDefaultHeadRect]];
        self.lostView.backgroundColor = MKCOLOR_RGB(229, 229, 229);

        
        // 姓名
        if (_idModel.true_name && _idModel.true_name.length) {
            self.labelName.text = _idModel.true_name;
        }
        if (_idModel.sex.intValue == 0) {
            [self.sexImgView setImage:[UIImage imageNamed:@"v230_female"]];
        }else{
            [self.sexImgView setImage:[UIImage imageNamed:@"v230_male"]];
        }
        
        self.labelMoney.text = [NSString stringWithFormat:@"%.2f",_idModel.insurance_ent_unit_price.intValue * 0.01];
        
        if (_idModel.insurance_policy_status.intValue == 1) {//投保进行中
            self.imageResult.hidden = YES;
            self.imageApplying.hidden = NO;
            self.lostView.hidden = YES;
        }else{
            if (_idModel.insurance_policy_close_type.intValue == 1) {//投保结束且成功
                self.imageResult.hidden = YES;
                self.imageApplying.hidden = YES;
                self.lostView.hidden = YES;
            }else{//投保失败
                self.lostView.alpha = 0.4;
                self.lostView.hidden = NO;
                self.imageResult.hidden = NO;
                self.imageApplying.hidden = YES;
                
            }
        }
    }
    
    
    
}
@end
