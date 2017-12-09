//
//  PostJobAlertView.m
//  jianke
//
//  Created by xuzhi on 16/7/20.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "PostJobAlertView.h"
#import "UIView+MKExtension.h"
#import "UIButton+Extension.h"
#import "PostJobModel.h"
#import "UIColor+Extension.h"
#import "UIView+MKException.h"
#import "Masonry.h"
#import "UILabel+MKExtension.h"
#import "MKBlurView.h"
#import "XSJConst.h"

@interface PostJobAlertView (){
    PostJobModel *_postJobModel;
}

@property (strong,nonatomic) UILabel *titleLabel;   //标题label
@property (strong,nonatomic) UIButton *confirmBtn;  //确认按钮
@property (strong,nonatomic) UILabel *tipsLabel;    //提示label
@property (strong,nonatomic) UIButton *closeBtn;    //关闭按钮
@property (strong,nonatomic) PostJobAlertViewItem *firstItem;   //总人数
@property (strong,nonatomic) PostJobAlertViewItem *secondItem;  //工作天数
@property (strong,nonatomic) PostJobAlertViewItem *thirdItem;   //报酬
@property (strong,nonatomic) PostJobAlertViewItem *fourthItem; //报酬
@property (strong,nonatomic) PostJobAlertViewItem *fifthItem;  //预计佣金 or 报酬
@property (assign,nonatomic) ActionType actionType;

@property (strong,nonatomic) UIWindow *window;

@property (nonatomic, assign) NSInteger needPayMoney;

@end

@implementation PostJobAlertView

+ (instancetype)showAlertView{
    PostJobAlertView *alertView = [[PostJobAlertView alloc] initWithFrame:SCREEN_BOUNDS];
    [alertView show];
    return alertView;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = SCREEN_BOUNDS;
        self.backgroundColor = [UIColor clearColor];
        MKBlurView *blueView = [[MKBlurView alloc] initWithFrame:self.bounds];
        [self addSubview:blueView];
        [self sendSubviewToBack:blueView];
        
        [self setUI];
    }
    return self;
}


- (void)setUI{
    
    //标题label
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = [UIColor XSJColor_grayLine];
    
    UIView *rightView = [[UIView alloc] init];
    rightView.backgroundColor = [UIColor XSJColor_grayLine];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"佣金详情";
    titleLabel.font = [UIFont systemFontOfSize:13.0f];
    titleLabel.textColor = [UIColor XSJColor_tGray];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:leftView];
    [self addSubview:rightView];
    [self addSubview:titleLabel];
    
    //主界面
    
    CGFloat height = 32;
    self.firstItem =    [[PostJobAlertViewItem alloc] initWithLeftText:@"总人数" rightText:@""];
    self.secondItem =   [[PostJobAlertViewItem alloc] initWithLeftText:@"工作天数" rightText:@""];
    self.thirdItem =    [[PostJobAlertViewItem alloc] initWithLeftText:@"报酬" rightText:@""];
    self.fourthItem =   [[PostJobAlertViewItem alloc] initWithLeftText:@"佣金比率" rightText:@""];
    self.fifthItem =    [[PostJobAlertViewItem alloc] initWithLeftText:@"预计总佣金" rightText:@""];

    [self addSubview:self.firstItem];
    [self addSubview:self.secondItem];
    [self addSubview:self.thirdItem];
    [self addSubview:self.fourthItem];
    [self addSubview:self.fifthItem];
    
    //确认按钮
    _confirmBtn = [UIButton buttonWithTitle:@"确定" bgColor:nil image:nil target:self sector:@selector(confirmAction:)];
    [_confirmBtn setTitleColor:[UIColor XSJColor_tBlue] forState:UIControlStateNormal];
    [self addSubview:_confirmBtn];
    
    //关闭按钮
    _closeBtn = [UIButton buttonWithTitle:nil bgColor:nil image:@"v3_public_close_white" target:self sector:@selector(closeAction:)];
    [self addSubview:_closeBtn];
    
    //约束

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(@90);
        make.height.equalTo(@18);
    }];
    
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@60);
        make.centerY.equalTo(titleLabel);
        make.height.equalTo(@1);
        make.right.equalTo(titleLabel.mas_left).offset(-8);
    }];
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-60));
        make.centerY.equalTo(titleLabel);
        make.height.equalTo(leftView);
        make.left.equalTo(titleLabel.mas_right).offset(8);
    }];
    
    [self.firstItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel).offset(32);
        make.left.equalTo(@60);
        make.right.equalTo(@-60);
        make.height.equalTo(@(height));
        
        make.left.right.height.equalTo(self.secondItem);
        make.left.right.height.equalTo(self.thirdItem);
        make.left.right.height.equalTo(self.fourthItem);
        make.left.right.height.equalTo(self.fifthItem);

    }];
    
    [self.secondItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.firstItem.mas_bottom);
    }];
    
    [self.thirdItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.secondItem.mas_bottom);
    }];
    
    [self.fourthItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.thirdItem.mas_bottom);
    }];
    
    [self.fifthItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fourthItem.mas_bottom);
    }];
    
    [_confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fifthItem).offset(50);
        make.left.equalTo(self).offset(60);
        make.right.equalTo(self).offset(-60);
        make.height.equalTo(@48);
    }];
    [_confirmBtn addBorderInDirection:BorderDirectionTypeTop | BorderDirectionTypeBottom borderWidth:0.5f borderColor:[UIColor XSJColor_grayLine] isConstraint:YES];

    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@38);
        make.centerX.equalTo(self);
        make.bottom.equalTo(@-62);
    }];
}

// 提示label
- (UILabel *)tipsLabel{
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.textColor = [UIColor XSJColor_tGrayMiddle];
        _tipsLabel.font = [UIFont systemFontOfSize:13.0f];
        [self addSubview:_tipsLabel];
        [_tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.confirmBtn.mas_bottom).offset(12);
            make.centerX.equalTo(self);
            make.height.equalTo(@18);
        }];
    }
    return _tipsLabel;
}

- (void)setPostJobModel:(PostJobModel *)postJobModel andEpModel:(EPModel *)epModel{
    _postJobModel = postJobModel;
    //总人数
    int personNumbers = postJobModel.recruitment_num.intValue;
    self.firstItem.rightLabel.text = [NSString stringWithFormat:@"%d人",personNumbers];
    
    //工作天数

    NSTimeInterval seconds = postJobModel.working_time_end_date.longLongValue - postJobModel.working_time_start_date.longLongValue;  //日期
    int day = (int)(seconds/(60*60*24*1000))+1;
    self.secondItem.rightLabel.text = [NSString stringWithFormat:@"%d天",day];
    
    //预计佣金 or 报酬
    NSInteger sumSala = 0;
    if (epModel.partner_service_fee_type.integerValue == 1) {   //比例
        self.thirdItem.leftLabel.text = @"报酬";
        self.fourthItem.leftLabel.text = @"佣金比例";
        self.fifthItem.leftLabel.text = @"预计总佣金";

        CGFloat sumFee = postJobModel.salary.value.floatValue;  //报酬 单位:元
        self.thirdItem.rightLabel.text = [NSString stringWithFormat:@"%0.2f元/天",sumFee];

        CGFloat fee = epModel.partner_service_fee.floatValue/10;
        self.fourthItem.rightLabel.text = [NSString stringWithFormat:@"%.2f%%",fee];
        
        CGFloat tmpSumSala = personNumbers * day * sumFee*100 * (fee/100.f);
        sumSala = (tmpSumSala < 1) ? ceil(tmpSumSala) : tmpSumSala ;
        self.fifthItem.rightLabel.text = [NSString stringWithFormat:@"%.2f元",(sumSala/100.00)];
    }else{
        self.thirdItem.leftLabel.text = @"佣金";
        self.fourthItem.leftLabel.text = @"预计总佣金";
        
        CGFloat fee = epModel.partner_service_fee.floatValue / 100;   //单位:分
        self.thirdItem.rightLabel.text = [NSString stringWithFormat:@"%0.2f元/人/天",fee];

        sumSala = personNumbers * day * fee * 100 ;
        self.fourthItem.rightLabel.text = [NSString stringWithFormat:@"%.2f元",(sumSala/100.00)];
        self.fifthItem.hidden = YES;
    }
    
    if (postJobModel.recruitment_amount.integerValue < sumSala) { //余额不足
        self.needPayMoney = sumSala - postJobModel.recruitment_amount.integerValue;
        self.tipsLabel.text = @"当前招聘余额不足，请先充值";
        self.actionType = ActionTypePay;
        [self.confirmBtn setTitle:@"去充值" forState:UIControlStateNormal];
    }else{
        self.actionType = ActionTypeConfirm;
        [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    }
}

#pragma mark - 事件响应
- (void)show{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevel_custom;
    [self.window addSubview:self];
    self.window.hidden = NO;

    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:@"animationKey"];
}

- (void)closeAction:(UIButton *)button{
    [self close];
}

- (void)close{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)confirmAction:(UIButton *)button{
    [self close];
    if ([self.delegate respondsToSelector:@selector(PostJobAlertView:actionType:needPayMoney:)]) {
        [self.delegate PostJobAlertView:self actionType:_actionType needPayMoney:self.needPayMoney];
    }
}

- (void)dealloc{
    ELog(@"消失~~");
}

@end

#pragma mrak - PostJobAlertViewItem类
@interface PostJobAlertViewItem ()

@end

@implementation PostJobAlertViewItem

- (instancetype)initWithLeftText:(NSString *)leftText rightText:(NSString *)rightText{
    self = [super init];
    if (self) {
        self.leftLabel = [UILabel labelWithText:leftText textColor:[UIColor XSJColor_tGrayDeep] fontSize:17.0f];
        self.leftLabel.textAlignment = NSTextAlignmentLeft;
        self.rightLabel = [UILabel labelWithText:rightText textColor:[UIColor XSJColor_tGrayDeep] fontSize:17.0f];
        self.rightLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.leftLabel];
        [self addSubview:self.rightLabel];
        [self makeConstraint];
    }
    return self;
}

- (void)makeConstraint{
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.centerY.equalTo(self);
    }];
    
    [self.rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.centerY.equalTo(self);
    }];
}

@end

