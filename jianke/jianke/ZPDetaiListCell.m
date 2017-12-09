//
//  ZPDetaiListCell.m
//  jianke
//
//  Created by xuzhi on 16/7/25.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ZPDetaiListCell.h"
#import "PayDetailModel.h"
#import "UIImageView+WebCache.h"
#import "UIHelper.h"
#import "XSJConst.h"

@interface ZPDetaiListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;


@end

@implementation ZPDetaiListCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"ZPDetaiListCell";
    ZPDetaiListCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"ZPDetaiListCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)awakeFromNib{
    [self.tagLabel setCornerValue:2.0f];
    self.tagLabel.layer.borderWidth = 0.5f;
    self.tagLabel.layer.borderColor = [UIColor XSJColor_tGrayTinge].CGColor;
    [self.profileImageView setCornerValue:3.0f];
}

- (void)setPdModel:(PayDetailModel *)pdModel{
    _pdModel = pdModel;
    
    //头像
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:pdModel.user_profile_url] placeholderImage:[UIHelper getDefaultHeadRect]];
    
    //性别
    if (pdModel.sex.intValue == 0) {
        [self.sexImageView setImage:[UIImage imageNamed:@"v230_female"]];
    }else{
        [self.sexImageView setImage:[UIImage imageNamed:@"v230_male"]];
    }
    
    //姓名
    self.nameLabel.text = pdModel.true_name;
    self.tagLabel.hidden = NO;
    //报名来源
    switch (pdModel.apply_job_source.integerValue) {
        case 1:
            self.tagLabel.text = @"平台报名";
            self.tagLabel.hidden = YES;
            break;
        case 2:
            self.tagLabel.text = @"人员补录";
            break;
        case 3:
            self.tagLabel.text = @"人员推广";
            break;
    }
    
    //工资
    self.moneyLabel.text = [NSString stringWithFormat:@"%.2f",pdModel.actual_amount.floatValue/100];
}

@end
