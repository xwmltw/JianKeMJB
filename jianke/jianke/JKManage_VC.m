//
//  JKManage_VC.m
//  jianke
//
//  Created by xiaomk on 15/11/23.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "JKManage_VC.h"
#import "EmployList_TV.h"
#import "ApplyJKController.h"
#import "QrCodeViewController.h"

@interface JKManage_VC ()<UIScrollViewDelegate>{
    
    CGFloat _layoutLineForLeft;
    CGFloat _btnHeight;
    EmployList_TV* _employTV;

}

@property (nonatomic, strong) UIView* viewBtnBg;
@property (nonatomic, strong) UIButton* btnLeft;
@property (nonatomic, strong) UIButton* btnRight;
@property (nonatomic, strong) UIView* viewBtnLine;

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) UIView* rightView;
@property (nonatomic, weak) UIView *leftView;
@end

@implementation JKManage_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"兼客管理";
    
    _btnHeight = 36;
    
    // 右边导航栏按钮
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"v220_scan"] style:UIBarButtonItemStylePlain target:self action:@selector(qrBtnClick)];
    self.navigationItem.rightBarButtonItem = scanItem;
    
    [self initTopBtn];
    [self initScrollView];
    [self moveLineToLeft:YES];
}

- (void)initTopBtn{
    self.viewBtnBg = [[UIView alloc] init];
    self.viewBtnBg.backgroundColor = [UIColor XSJColor_blackBase];
    [self.view addSubview:self.viewBtnBg];
    
    self.btnLeft = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnLeft.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.btnLeft addTarget:self action:@selector(btnLeftOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnLeft setTitleColor:MKCOLOR_RGBA(255, 255, 255, 0.7) forState:UIControlStateNormal];
    [self.btnLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.btnLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.btnLeft setTitle:@"已报名" forState:UIControlStateNormal];
    
    self.btnRight = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnRight.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.btnRight addTarget:self action:@selector(btnRightOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRight setTitleColor:MKCOLOR_RGBA(255, 255, 255, 0.7) forState:UIControlStateNormal];
    [self.btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.btnRight setTitle:@"已录用" forState:UIControlStateNormal];
    
    self.viewBtnLine = [[UIView alloc] init];
    self.viewBtnLine.backgroundColor = [UIColor XSJColor_base];
    
    [self.viewBtnBg addSubview:self.btnLeft];
    [self.viewBtnBg addSubview:self.btnRight];
    [self.viewBtnBg addSubview:self.viewBtnLine];
    
    WEAKSELF
    [self.viewBtnBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
        make.top.equalTo(weakSelf.view.mas_top).with.offset(0);
        make.height.mas_equalTo(_btnHeight);
    }];
    [self.btnLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.viewBtnBg.mas_left);
        make.top.equalTo(weakSelf.viewBtnBg.mas_top);
        make.bottom.equalTo(weakSelf.viewBtnBg.mas_bottom);
        make.width.mas_equalTo(SCREEN_WIDTH/2);
    }];
    [self.btnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.btnLeft.mas_right);
        make.right.equalTo(weakSelf.viewBtnBg.mas_right);
        make.top.equalTo(weakSelf.viewBtnBg.mas_top);
        make.bottom.equalTo(weakSelf.viewBtnBg.mas_bottom);
    }];
    [self.viewBtnLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.viewBtnBg.mas_left).offset(0);
        make.bottom.equalTo(weakSelf.viewBtnBg.mas_bottom).offset(0);
        make.height.mas_equalTo(@3);
        make.width.mas_equalTo(weakSelf.btnLeft.mas_width);
    }];
}

- (void)initScrollView{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _btnHeight, SCREEN_WIDTH, SCREEN_HEIGHT-64-_btnHeight)];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*2, SCREEN_HEIGHT-64-_btnHeight);
    [self.view addSubview:self.scrollView];
    self.scrollView.backgroundColor = [UIColor grayColor];
    

    ApplyJKController *applyVC = [[ApplyJKController alloc] init];
    [self addChildViewController:applyVC];
//    applyVC.owner = self;
    applyVC.jobId = self.jobId;
    applyVC.isAccurateJob = @(0);
    applyVC.managerType = self.managerType;
    self.leftView = applyVC.view;
    [self.scrollView addSubview:self.leftView];
    
    EmployList_TV* employVC = [[EmployList_TV alloc] init];
    [self addChildViewController:employVC];
//    employVC.owner = self;
    employVC.jobId = self.jobId;
    employVC.isAccurateJob = @(0);
    employVC.managerType = self.managerType;
//    employVC.status = self.status;

    self.rightView = employVC.view;
    [self.scrollView addSubview:self.rightView];
    
    WEAKSELF
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.viewBtnBg.mas_bottom);
        make.bottom.equalTo(weakSelf.view.mas_bottom);
        make.left.equalTo(weakSelf.scrollView.mas_left);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.viewBtnBg.mas_bottom);
        make.bottom.equalTo(weakSelf.view.mas_bottom);
        make.left.equalTo(weakSelf.leftView.mas_right);
        make.width.mas_equalTo(SCREEN_WIDTH);
    }];
}


#pragma mark - 按钮事件
- (void)btnLeftOnclick:(UIButton*)sender{
    [self moveLineToLeft:YES];
}

- (void)btnRightOnclick:(UIButton*)sender{
    [self moveLineToLeft:NO];
}

- (void)moveLineToLeft:(BOOL)bLeft{
    if (bLeft) {
        self.btnLeft.selected = YES;
        self.btnRight.selected = NO;
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
        self.btnLeft.selected = NO;
        self.btnRight.selected = YES;
        [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0) animated:YES];
    }
}

- (void)qrBtnClick{
    [TalkingData trackEvent:@"兼客管理_补录二维码"];

    WEAKSELF
    [[UserData sharedInstance] entRefreshJobQrCodeWithJobId:self.jobId block:^(ResponseInfo *response) {
        if (response.success) {
            NSString *qrCode = response.content[@"qr_code"];
            NSString *expireTime = response.content[@"expire_time"];
            QrCodeViewController *vc = [[QrCodeViewController alloc] init];
            vc.qrCode = qrCode;
            vc.expireTime = @(expireTime.longLongValue);
            vc.jobId = weakSelf.jobId;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    }];
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGPoint p = scrollView.contentOffset;

    if (p.x <= SCREEN_WIDTH/4) {
        self.btnLeft.selected = YES;
        self.btnRight.selected = NO;
    }else if (p.x >= SCREEN_WIDTH/4*3){
        self.btnLeft.selected = NO;
        self.btnRight.selected = YES;
    }
    
    _layoutLineForLeft = p.x/2;
    
    [self.viewBtnLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.viewBtnBg.mas_left).with.offset(_layoutLineForLeft);
    }];
}

/** 全部录用按钮点击 */
- (void)allJkApplyBtnClick;{
//    [self btnRightOnclick:nil];
    
//    EmployList_TV *vc = nil;
//    for (UIViewController *childVc in self.childViewControllers) {
//        if ([childVc isKindOfClass:[EmployList_TV class]]) {
//            vc = (EmployList_TV *)childVc;
//            break;
//        }
//    }
    
//    [UserData delayTask:0.5 onTimeEnd:^{
//        [vc getLastDataList];
//    }];
}

/*!< 设置已报名人数 */
- (void)setApplyCount:(NSNumber *)num{
    [self.btnLeft setTitle:[NSString stringWithFormat:@"已报名 (%@)", num] forState:UIControlStateNormal];
}

/*!< 设置已录用人数 */
- (void)setEmployCount:(NSNumber *)num{
    [self.btnRight setTitle:[NSString stringWithFormat:@"已录用 (%@)", num] forState:UIControlStateNormal];
}

- (void)dealloc{
    DLog(@"JKManage dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

