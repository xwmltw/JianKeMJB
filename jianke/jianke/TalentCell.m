//
//  TalentCell.m
//  jianke
//
//  Created by fire on 15/10/22.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "TalentCell.h"
#import "TalentModel.h"
#import "UIImageView+WebCache.h"
#import "WDConst.h"

@interface TalentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView; /*!< 头像 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel; /*!< 姓名 */
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel; /*!< 分数 */
@property (weak, nonatomic) IBOutlet UIButton *actionBtn; /*!< 操作按钮 */

@end


@implementation TalentCell

- (void)setTalentModel:(TalentModel *)talentModel{
    _talentModel = talentModel;
    
    // 头像
    self.iconImgView.layer.cornerRadius = 2;
    self.iconImgView.clipsToBounds = YES;
    if (talentModel.profile_url) {
        [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:talentModel.profile_url] placeholderImage:[UIImage imageNamed:@"info_person_fang"]];
    }
    
    // 姓名
    if (talentModel.true_name && talentModel.true_name.length) {
        self.nameLabel.text = talentModel.true_name;
    } else {
        self.nameLabel.text = @"兼客用户";
    }
    
    // 分数
    if (talentModel.evalu_byent_level_avg) {
        self.scoreLabel.text = [NSString stringWithFormat:@"%@分", talentModel.evalu_byent_level_avg];
    } else {
        self.scoreLabel.text = @"0分";
    }
    
    // 操作按钮
    if (talentModel.talent_pool_status && talentModel.talent_pool_status.integerValue == 1) { // 未删除
        [self.actionBtn setTitle:@"删除" forState:UIControlStateNormal];
    } else { // 已删除
        [self.actionBtn setTitle:@"恢复" forState:UIControlStateNormal];
    }
}

/** 删除/恢复按钮点击 */
- (IBAction)actionClick:(UIButton *)sender{
    [TalkingData trackEvent:@"人才库_删除"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.talentModel.talent_pool_status && self.talentModel.talent_pool_status.integerValue == 1) {
        dic[DelTalentPoolInfo] = self.talentModel;
        // 发布删除通知
        [WDNotificationCenter postNotificationName:DelTalentPoolNotification object:self userInfo:dic];
    } else {
        dic[RecoverTalentPoolInfo] = self.talentModel;
        // 发布恢复通知
         [WDNotificationCenter postNotificationName:RecoverTalentPoolNotification object:self userInfo:dic];
    }
}




@end
