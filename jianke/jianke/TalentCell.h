//
//  TalentCell.h
//  jianke
//
//  Created by fire on 15/10/22.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TalentModel;

/** 删除人才通知 */
static NSString * const DelTalentPoolNotification = @"DelTalentPoolNotification";
static NSString * const DelTalentPoolInfo = @"DelTalentPoolInfo";

/** 恢复人才通知 */
static NSString * const RecoverTalentPoolNotification = @"RecoverTalentPoolNotification";
static NSString * const RecoverTalentPoolInfo = @"RecoverTalentPoolInfo";


@interface TalentCell : UITableViewCell

@property (nonatomic, strong) TalentModel *talentModel;

@end
