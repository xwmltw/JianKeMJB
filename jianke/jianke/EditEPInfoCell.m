//
//  EditEPInfoCell.m
//  jianke
//
//  Created by xiaomk on 16/3/2.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "EditEPInfoCell.h"
#import "EPModel.h"

@interface EditEPInfoCell ()

@property (nonatomic, strong) EPModel *epModel;

@end

@implementation EditEPInfoCell

+ (instancetype)cellWithTableView:(UITableView *)tableview{
    static NSString *idetifier = @"EditEPInfoCell";
    EditEPInfoCell *cell = [tableview dequeueReusableCellWithIdentifier:idetifier];
    if (!cell) {
        static UINib* _nib;
        if (_nib == nil) {
            _nib = [UINib nibWithNibName:@"EditEPInfoCell" bundle:nil];
        }
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
    }
    return cell;
}

- (void)setData:(EPModel *)epModel atIndexPath:(NSIndexPath *)indexPath{
    _epModel = epModel;
    
    [self.btnAuth addTarget:self action:@selector(btnAuthUserNameOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnNext addTarget:self action:@selector(btnAuthUserNameOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.tfText addTarget:self action:@selector(tfTextOnClick:) forControlEvents:UIControlEventEditingChanged];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                self.imgIcom.image = [UIImage imageNamed:@"v240_account-box"];
                self.tfText.placeholder = @"姓名";
                self.tfText.tag = EditEpCellType_Name;
                self.btnAuth.tag = EditEpCellType_Name;
                self.btnNext.tag = EditEpCellType_Name;
                self.tfText.text = epModel.true_name ? epModel.true_name : @"";
                [self updateVertifyStatus:epModel.id_card_verify_status.integerValue atIndex:0];
                [self setBtnHidden:NO];
            }
                break;
            case 1:{
                self.imgIcom.image = [UIImage imageNamed:@"info_ep_gongsi"];
                self.tfText.placeholder = @"公司名";
                self.tfText.tag = EditEpCellType_Enterprase;
                self.btnAuth.tag = EditEpCellType_Enterprase;
                self.btnNext.tag = EditEpCellType_Enterprase;
                self.tfText.text = epModel.enterprise_name ? epModel.enterprise_name : @"";
                [self updateVertifyStatus:epModel.verifiy_status.integerValue atIndex:1];
                [self setBtnHidden:NO];
            }
                break;
            case 2:{
                self.imgIcom.image = [UIImage imageNamed:@"v240_sms-failed"];
                self.tfText.placeholder = @"邮箱";
                self.tfText.tag = EditEpCellType_Email;
                self.tfText.text = epModel.email ? self.epModel.email : @"";
                [self setBtnHidden:YES];
                self.layoutBtnAutoWidth.constant = 1;
                self.layoutBtnAutoWidth.constant = 1;
            }
                break;
            default:
                break;
        }
    }
    
  }

- (void)updateVertifyStatus:(NSInteger)verifyStatus atIndex:(NSInteger)index{
    if (verifyStatus == 1 || verifyStatus == 4) {
        [self.btnAuth setImage:[UIImage imageNamed:@"info_auth_no"] forState:UIControlStateNormal];
        [self setBtnEnabled:YES];
    }else if (verifyStatus == 2) {
        [self.btnAuth setImage:[UIImage imageNamed:@"info_auth_ing"] forState:UIControlStateNormal];
        [self setBtnEnabled:NO];
    }else if (verifyStatus == 3) {
        if (index == 0) {
            [self.btnAuth setImage:[UIImage imageNamed:@"info_auth_yes"] forState:UIControlStateNormal];
        }else if (index == 1){
            [self.btnAuth setImage:[UIImage imageNamed:@"info_auth_ep_1"] forState:UIControlStateNormal];
        }
        [self setBtnEnabled:NO];
    }

}

- (void)setBtnEnabled:(BOOL)enabled{
    self.btnAuth.userInteractionEnabled = enabled;
    self.btnNext.userInteractionEnabled = enabled;
    self.tfText.enabled = enabled;
}

- (void)setBtnHidden:(BOOL)hidden{
    self.btnAuth.hidden = hidden;
    self.btnNext.hidden = hidden;
}

- (void)btnAuthUserNameOnclick:(UIButton *)sender{
    [self.delegate pushAction:sender.tag];
}

- (void)tfTextOnClick:(UITextField *)sender{
    switch (sender.tag) {
        case EditEpCellType_Name:
            self.epModel.true_name = sender.text;
            break;
        case EditEpCellType_Enterprase:
            self.epModel.enterprise_name = sender.text;
            break;
        case EditEpCellType_Email:
//            ELog(@"self.epModel.email:%@",sender.text);
            self.epModel.email = sender.text;
            break;
    }
}

@end
