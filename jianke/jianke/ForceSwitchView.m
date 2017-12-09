//
//  ForceSwitchView.m
//  jianke
//
//  Created by yanqb on 2016/11/25.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ForceSwitchView.h"
#import "WDConst.h"
#import "WebView_VC.h"

@interface ForceSwitchView ()

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIVisualEffectView *effectView;

@end

@implementation ForceSwitchView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.effectView = [[UIVisualEffectView alloc] initWithFrame:self.bounds];
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        self.effectView.effect = blur;
        [self addSubview:self.effectView];
        [self setupViews];
//        MKBlurView *blueView = [[MKBlurView alloc] initWithFrame:self.bounds];
//        [blueView setColor:MKCOLOR_RGBA(0, 0, 0, 1)];
//        [self addSubview:blueView];
//        [self sendSubviewToBack:blueView];

        [self sendSubviewToBack:self.effectView];
        
    }
    return self;
}

- (void)setupViews{
    UIView *contentView = [[UIView alloc] init];
    contentView.backgroundColor = [UIColor colorWithPatternImage:[[UIImage imageNamed:@"force_switch_blueBg"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    
    UIButton *btnSwitch = [UIButton buttonWithTitle:@"切换为兼客 >" bgColor:nil image:nil target:self sector:@selector(switchToJK:)];
    
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jianke_youpin_logo"]];
    
    
    UILabel *labTitle = [UILabel labelWithText:@"雇主端全新升级兼客优聘" textColor:[UIColor XSJColor_tGrayDeepTinge] fontSize:22.0f];
    labTitle.numberOfLines = 0;
    labTitle.textAlignment = NSTextAlignmentCenter;
    
    UILabel *labDetail = [UILabel labelWithText:@"为了您能体验到更好的招聘服务，我们全新上线了兼客优聘APP，在优聘中，保留现有雇主端所有功能同时，新上线找高端兼职人才（模特、礼仪、商演、主持、家教、促销）、找团队服务功能。" textColor:[UIColor XSJColor_tGrayDeepTransparent2] fontSize:13.0f];
    labDetail.numberOfLines = 0;
    labDetail.textAlignment = NSTextAlignmentCenter;
    
    UIButton *btnDownLoad = [UIButton buttonWithTitle:@"立即下载" bgColor:nil image:nil target:self sector:@selector(btnDownloadOnClick:)];
    [btnDownLoad setTitleColor:MKCOLOR_RGB(44, 144, 156) forState:UIControlStateNormal];
    btnDownLoad.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [btnDownLoad setCornerValue:22.0f];
    [btnDownLoad setBorderWidth:1.0f andColor:MKCOLOR_RGB(44, 144, 156)];
    
    [self.effectView.contentView addSubview:contentView];
    [self.effectView.contentView addSubview:btnSwitch];
    [contentView addSubview:imgView];
    [contentView addSubview:labTitle];
    [contentView addSubview:labDetail];
    [contentView addSubview:btnDownLoad];
    

    
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.effectView.contentView);
        make.width.equalTo(@296);
        make.height.equalTo(@403);
    }];
    
    [btnSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.effectView.contentView);
        make.bottom.equalTo(self).offset(-32);
        make.height.equalTo(@30);
    }];
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView).offset(47);
        make.centerX.equalTo(contentView);
    }];
    
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgView.mas_bottom).offset(32);
        make.left.equalTo(contentView).offset(16);
        make.right.equalTo(contentView).offset(-16);
    }];
    
    [labDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(labTitle.mas_bottom).offset(12);
        make.left.equalTo(contentView).offset(12);
        make.right.equalTo(contentView).offset(-12);
    }];
    
    [btnDownLoad mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView).offset(16);
        make.bottom.equalTo(contentView).offset(-24);
        make.right.equalTo(contentView).offset(-16);
        make.height.equalTo(@44);
    }];
    
    [self show];
}

- (void)btnDownloadOnClick:(UIButton *)sender{
    
    if ([[UIDevice currentDevice] systemVersion].floatValue < 10.0) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"JKHireapp://"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"JKHireapp://"]];
        }else{
            WEAKSELF
            [[XSJRequestHelper sharedInstance] getClientGlobalInfoWithBlock:^(ClientGlobalInfoRM *globalModel) {
                if (globalModel && globalModel.wap_url_list.guide_youpin_intro_download_url) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[globalModel.wap_url_list.guide_youpin_intro_download_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
                }
            }];
        }
    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"JKHireapp://"] options:@{UIApplicationOpenURLOptionUniversalLinksOnly : @NO} completionHandler:^(BOOL success) {
            if (!success) {
                WEAKSELF
                [[XSJRequestHelper sharedInstance] getClientGlobalInfoWithBlock:^(ClientGlobalInfoRM *globalModel) {
                    if (globalModel && globalModel.wap_url_list.guide_youpin_intro_download_url) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[globalModel.wap_url_list.guide_youpin_intro_download_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ]];
                    }
                }];
            }
        }];
    }
    
}

- (void)switchToJK:(UIButton *)sender{
    [XSJUIHelper switchRequestIsToEP:NO];
    [UserData delayTask:1.0f onTimeEnd:^{
        [self removeFromSuperview];
    }];
    
}

- (void)show{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.windowLevel = UIWindowLevel_custom;
    [self.window addSubview:self];
    self.window.hidden = NO;
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromBottom;
    [self.layer addAnimation:transition forKey:@"animationKey"];
}

@end
