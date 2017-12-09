//
//  ApplyCell.h
//  jianke
//
//  Created by fire on 15/9/29.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

typedef NS_ENUM(NSInteger, ActionType){
    ActionTypeHire,
    ActionTypeFire,
    ActionTypeAdjust
};
@class ApplyCell;
@class CellModel;
#import <UIKit/UIKit.h>

@protocol ApplyCellDelegate <NSObject>

- (void)applyCell:(ApplyCell *)cell cellModel:(CellModel *)model actionType:(ActionType)actionType;

@end
// tableView刷新通知
static NSString * const ApplyCellReflushNotification = @"ApplyCellReflushNotification";
static NSString * const ApplyCellReflushInfo = @"ApplyCellReflushInfo";

static NSString * const ApplyChatWithJkNotification = @"ApplyChatWithJkNotification";
static NSString * const ApplyChatWithJkInfo = @"ApplyChatWithJkInfo";


@interface ApplyCell : UITableViewCell

@property (nonatomic, strong) CellModel *cellModel;

@property (nonatomic, strong) NSString *jobId;

@property (nonatomic, strong) NSNumber* isAccurateJob; /*!< 是否为精确岗位 */

@property (weak, nonatomic) IBOutlet UIImageView *redDot; /*!< 小红点 */

@property (nonatomic, weak) id<ApplyCellDelegate> delegate;

@end
