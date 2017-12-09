//
//  PostJobAlertView.h
//  jianke
//
//  Created by xuzhi on 16/7/20.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

typedef NS_ENUM(NSInteger, ActionType) {
    ActionTypeConfirm,  //确认动作
    ActionTypePay   //充值动作
};

@class PostJobAlertView;
@class PostJobModel;
@class EPModel;
@protocol PostJobAlertViewDelegate <NSObject>

- (void)PostJobAlertView:(PostJobAlertView *)view actionType:(ActionType)actionType needPayMoney:(NSInteger)money;

@end

#import <UIKit/UIKit.h>

@interface PostJobAlertView : UIView

@property(nonatomic,weak) id<PostJobAlertViewDelegate> delegate;

+ (instancetype)showAlertView;

- (void)setPostJobModel:(PostJobModel *)postJobModel andEpModel:(EPModel *)epModel;
@end

@interface PostJobAlertViewItem : UIView

@property (strong,nonatomic) UILabel *leftLabel;
@property (strong,nonatomic) UILabel *rightLabel;
- (instancetype)initWithLeftText:(NSString *)leftText rightText:(NSString *)rightText;
@end



