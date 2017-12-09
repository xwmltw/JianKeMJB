//
//  JobExaManage_VC.m
//  jianke
//
//  Created by xiaomk on 15/11/26.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "JobExaManage_VC.h"
#import "WDConst.h"
#import "EmployList_TV.h"
#import "ApplyJKController.h"
#import "DateView.h"
#import "EpSingleDay_VC.h"
#import "QrCodeViewController.h"
#import "ApplyCell.h"

@interface JobExaManage_VC ()<UIScrollViewDelegate>{
    NSArray* _dateModelArray;
    CGFloat _layoutLineForLeft;
    
    NSMutableArray* _viewArray;
    NSMutableArray* _vcArray;
    NSMutableArray *_btnArray;
    
//    NSArray* _dataArray;

}

@property (nonatomic, strong) UIView* topViewBg;
@property (nonatomic, strong) UIScrollView* topScrollView;
@property (nonatomic, strong) UIView* viewBtnLine;

@property (nonatomic, strong) UIScrollView* mainScrollView;

@property (nonatomic, strong) DateView *dateView;

@property (nonatomic, weak) UIButton *currentBtn;

@property (nonatomic, strong) UIButton *sjxBtn;
@property (nonatomic, strong) UIButton *dateBtn;

@end

@implementation JobExaManage_VC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.dateBtn = [[UIButton alloc] initWithFrame:CGRectMake(60+20, 0, 80, 44)];
    [self.dateBtn setTitle:@"兼客管理" forState:UIControlStateNormal];
    [self.dateBtn addTarget:self action:@selector(dateSelectClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.dateBtn];
    self.dateBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    self.sjxBtn = [[UIButton alloc] initWithFrame:CGRectMake(137+20, 12, 20, 20)];
    [self.sjxBtn setImage:[UIImage imageNamed:@"v230_arrow-drop-down_white"] forState:UIControlStateNormal];
    [self.sjxBtn addTarget:self action:@selector(dateSelectClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:self.sjxBtn];
    
    // 右边导航栏按钮
    UIBarButtonItem *scanItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"v220_scan"] style:UIBarButtonItemStylePlain target:self action:@selector(qrBtnClick)];
    self.navigationItem.rightBarButtonItem = scanItem;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (self.dateBtn) {
        [self.dateBtn removeFromSuperview];
    }
    if (self.sjxBtn) {
        [self.sjxBtn removeFromSuperview];
    }
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [WDNotificationCenter addObserver:self selector:@selector(setAllViewNewRefresh) name:ApplyCellReflushNotification object:nil];  //点击报名后

    [self getJobDateList];
    
    [self initTopView];
    
    [self initScrollView];
    
    if (self.showViewNum >= 0) {
        [self.mainScrollView setContentOffset:CGPointMake(self.showViewNum*SCREEN_WIDTH, 0)];
    }else{
        [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
    }
    
    if (self.mainScrollView.contentOffset.x == 0) {
        UIButton *btn = _btnArray.firstObject;
        btn.selected = YES;
        self.currentBtn = btn;
    }
    
}

- (void)getJobDateList{
    _dateModelArray = [ExpectOnBoardStuCountModel objectArrayWithKeyValuesArray:self.jobModel.expect_on_board_stu_counts];

}

- (void)initTopView{
    
    _topViewBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    _topViewBg.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topViewBg];
    
    CGFloat topSVWidth;       //top scrollView width
    CGFloat topBtnWidth;      //按钮宽度
    
    if (_dateModelArray.count < 2) {
        topBtnWidth = SCREEN_WIDTH/(2+_dateModelArray.count);
    }else{
        topBtnWidth = SCREEN_WIDTH/4;
    }
    
    if (_dateModelArray.count <= 2) {
        topSVWidth = SCREEN_WIDTH;
    }else{
        topSVWidth = topBtnWidth*2 + topBtnWidth*_dateModelArray.count;
    }
    
    self.topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    self.topScrollView.delegate = self;
    self.topScrollView.bounces = NO;
    self.topScrollView.pagingEnabled = NO;
    self.topScrollView.showsHorizontalScrollIndicator = NO;
    self.topScrollView.showsVerticalScrollIndicator = NO;
    self.topScrollView.contentSize = CGSizeMake(topSVWidth, 44);
    self.topScrollView.backgroundColor = [UIColor XSJColor_blackBase];
    self.topScrollView.tag = 601;
    [_topViewBg addSubview:self.topScrollView];
    
    
    _btnArray = [NSMutableArray array];
    UIButton* btnApply = [UIButton buttonWithType:UIButtonTypeCustom];
    btnApply.frame = CGRectMake(0, 0, topBtnWidth, 44);
    [self.topScrollView addSubview:btnApply];
    btnApply.backgroundColor = [UIColor clearColor];
    [btnApply setTitle:@"已报名" forState:UIControlStateNormal];
    btnApply.tag = 0;
    [btnApply addTarget:self action:@selector(topBtnOnclick:) forControlEvents:UIControlEventTouchUpInside];
    btnApply.titleLabel.font = [UIFont systemFontOfSize:14];
    [btnApply setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btnApply setTitleColor:MKCOLOR_RGBA(255, 255, 255, 0.7) forState:UIControlStateNormal];
    [_btnArray addObject:btnApply];

    UIButton* btnEmploy = [[UIButton alloc] initWithFrame:CGRectMake(topBtnWidth, 0, topBtnWidth, 44)];
    [self.topScrollView addSubview:btnEmploy];
    btnEmploy.backgroundColor = [UIColor clearColor];
    [btnEmploy setTitle:@"已录用" forState:UIControlStateNormal];
    btnEmploy.tag = 1;
    [btnEmploy addTarget:self action:@selector(topBtnOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnEmploy setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [btnEmploy setTitleColor:MKCOLOR_RGBA(255, 255, 255, 0.7) forState:UIControlStateNormal];
    btnEmploy.titleLabel.font = [UIFont systemFontOfSize:14];
    [_btnArray addObject:btnEmploy];

    for (NSInteger i = 0; i < _dateModelArray.count; i++) {
        UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(topBtnWidth*(i+2), 0, topBtnWidth, 44)];
        btn.tag = i+2;
        [self.topScrollView addSubview:btn];
        [btn addTarget:self action:@selector(topBtnOnclick:) forControlEvents:UIControlEventTouchUpInside];
        
        ExpectOnBoardStuCountModel* expModel = [_dateModelArray objectAtIndex:i];
        NSString* date = [DateHelper getShortDateFromTimeNumber:expModel.on_board_date];
        NSString* week = [DateHelper weekdayStringFromDate:expModel.on_board_date];
        NSString* showDate = [NSString stringWithFormat:@"%@ %@",date,week];
        [btn setTitle:showDate forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setTitleColor:MKCOLOR_RGBA(255, 255, 255, 0.7) forState:UIControlStateNormal];
        [_btnArray addObject:btn];
    }
    
    self.viewBtnLine = [[UIView alloc] init];
    self.viewBtnLine.backgroundColor = [UIColor XSJColor_base];
    [self.topViewBg addSubview:self.viewBtnLine];
    
    [self.viewBtnLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_topViewBg.mas_left);
        make.bottom.equalTo(_topViewBg.mas_bottom);
        make.height.mas_equalTo(@3);
        make.width.mas_equalTo(topBtnWidth);
    }];

}

- (void)pop{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)initScrollView{
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT-64-44)];
    self.mainScrollView.delegate = self;
    self.mainScrollView.bounces = NO;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    self.mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*(_dateModelArray.count + 2), SCREEN_HEIGHT - 64-44);
    self.mainScrollView.tag = 602;
    [self.view addSubview:self.mainScrollView];
    self.mainScrollView.backgroundColor = [UIColor XSJColor_grayTinge];
    
    _viewArray = [[NSMutableArray alloc] init];
    _vcArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < _dateModelArray.count+2; i++ ) {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-44)];
        [_viewArray addObject:view];
    }

    
    
    for (NSInteger i = 0; i < _viewArray.count; i++) {
        __unused UIView* viewBg = [_viewArray objectAtIndex:i];
        UIViewController* vc;
        if ( i == 0) {
            ApplyJKController *applyVC = [[ApplyJKController alloc] init];
            [self addChildViewController:applyVC];
//            applyVC.owner = self;
            applyVC.jobId = self.jobId;
            applyVC.isAccurateJob = @(1);
            applyVC.managerType = self.managerType;

            viewBg = applyVC.view;
            vc = applyVC;
        }else if (i == 1){
            EmployList_TV* employVC = [[EmployList_TV alloc] init];
            [self addChildViewController:employVC];
//            employVC.owner = self;
            employVC.jobId = self.jobId;
            employVC.isAccurateJob = @(1);
            employVC.managerType = self.managerType;
//            employVC.status = self.status;
            viewBg = employVC.view;
            vc = employVC;
        }else{
            EpSingleDay_VC* singleVC = [[EpSingleDay_VC alloc] init];
            [self addChildViewController:singleVC];
//            singleVC.owner = self;
            singleVC.jobId = self.jobId;
            singleVC.isAccurateJob = @(1);
            singleVC.managerType = self.managerType;
            singleVC.status = self.status;
            ExpectOnBoardStuCountModel* model = [_dateModelArray objectAtIndex:i-2];
            singleVC.boardDate = model.on_board_date;
            singleVC.boardDateArray = _dateModelArray;
            if (self.jobModel.tadayNum > 1 && i == self.jobModel.tadayNum) {
                singleVC.isTaday = YES;
            }
            viewBg = singleVC.view;
            vc = singleVC;
        }
        viewBg.frame = CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-44);
        [self.mainScrollView addSubview:viewBg];
        [_vcArray addObject:vc];
    }
    
//    [self getDateWithIndex:0];
}

- (void)getDateWithIndex:(NSInteger)index{
//    EmployList_TV* tv = [_vcArray objectAtIndex:index];
//    [tv getLastDataList];
}


#pragma mark - UIScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.tag == 602) {
        CGPoint p = scrollView.contentOffset;
//        ELog(@"====p.x:%f",p.x);
        
        CGFloat btnShowCount;
        if (_viewArray.count < 4) {
            btnShowCount = 3;
        }else{
            btnShowCount = 4;
        }
        
        //按钮 scrollView sel
//        if (p.x >= SCREEN_WIDTH && self.topScrollView.contentOffset.x <= (self.topScrollView.contentSize.width-SCREEN_WIDTH)) {
//        if (p.x >= SCREEN_WIDTH && p.x <= SCREEN_WIDTH * (_viewArray.count-btnShowCount+1)) {
        
        if (p.x >= SCREEN_WIDTH ) {
            if (p.x > SCREEN_WIDTH*(_viewArray.count-btnShowCount+1)) {
                [self.topScrollView setContentOffset:CGPointMake(self.topScrollView.contentSize.width-SCREEN_WIDTH, 0)];
            }else{
                [self.topScrollView setContentOffset:CGPointMake((p.x-SCREEN_WIDTH)/btnShowCount, 0)];
            }
        }
        
        int i = (int)(p.x / SCREEN_WIDTH);
        if (i > 1) {
            __unused EpSingleDay_VC* vc = [_vcArray objectAtIndex:i];
//            [vc getDataWhenShow];
        }
        
        //控制 按钮条
        if (p.x <= SCREEN_WIDTH) {
            _layoutLineForLeft = p.x/btnShowCount;
        }else if (p.x > SCREEN_WIDTH * (_viewArray.count-btnShowCount+1)){
            _layoutLineForLeft = (p.x-SCREEN_WIDTH*(_viewArray.count-btnShowCount))/btnShowCount;
        }else{
            _layoutLineForLeft = SCREEN_WIDTH/btnShowCount;
        }
        
        [self.viewBtnLine mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topViewBg.mas_left).offset(_layoutLineForLeft);
        }];
        
        if (self.currentBtn) {
            self.currentBtn.selected = NO;
        }
        NSInteger index = (NSInteger)(p.x / SCREEN_WIDTH);
        UIButton *btn = _btnArray[index];
        btn.selected = YES;
        self.currentBtn = btn;
        
    }else if (scrollView.tag == 601){
//        CGPoint p = scrollView.contentOffset;
//        CGFloat* move =
//        _layoutLineForLeft
        
    }
    
    
    
    
}

- (void)setAllViewNewRefresh{
    ELog(@"=====收到报名的通知");
    for (int i = 1; i < _vcArray.count; i++) {
        if (i == 1) {
            __unused EmployList_TV* vc = [_vcArray objectAtIndex:1];
//            [vc getLastDataList];
        }else{
            __unused EpSingleDay_VC* vc = [_vcArray objectAtIndex:i];
            [vc setIsHaveShow:NO];
        }
    }
}


#pragma mark = 按钮事件
- (void)topBtnOnclick:(UIButton*)sender{
    NSInteger tag = sender.tag;
    [self.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*tag, 0) animated:YES];
    ELog("====tag:%ld",(long)tag);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)dateSelectClick
{
    if (!self.dateView) {
        self.dateView = [[DateView alloc] initWithParentView:self.view];
    }
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.jobModel.work_time_start.longLongValue];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.jobModel.work_time_end.longLongValue];
    
    // 旋转三角形
    if (![self.dateView isShow]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.sjxBtn.transform = CGAffineTransformRotate(self.sjxBtn.transform, M_PI);
        }];
    }
    
    WEAKSELF
    [self.dateView showDateViewWithStartDate:startDate endDate:endDate clickBlock:^(NSArray *selectDateArray) {
        
        [weakSelf.dateView hide];

        // 旋转三角形
        [UIView animateWithDuration:0.3 animations:^{
            self.sjxBtn.transform = CGAffineTransformRotate(self.sjxBtn.transform, M_PI);
        }];
        
        DLog(@"选中日期:%@", selectDateArray.lastObject);
        NSNumber* time = [NSNumber numberWithLongLong:[selectDateArray.lastObject timeIntervalSince1970]*1000];
        NSString* strDateSelect = [DateHelper getDateFromTimeNumber:time withFormat:@"yyMMdd"];
        NSInteger selectDate = strDateSelect.integerValue;
        ELog(@"=====selectDate:%ld",(long)selectDate);
        for (NSInteger i = 0; i < _dateModelArray.count; i++) {
            ExpectOnBoardStuCountModel* model = [_dateModelArray objectAtIndex:i];
            NSString* dateStr = [DateHelper getDateFromTimeNumber:model.on_board_date withFormat:@"yyMMdd"];
            NSInteger boardDate = dateStr.integerValue;
            ELog(@"=====boardDate:%ld",(long)boardDate);
            if (boardDate == selectDate) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf.mainScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*(i+2), 0) animated:YES];
                });
            }
        }
        
    } hideBlock:^(id obj) {
        
        // 旋转三角形
        [UIView animateWithDuration:0.3 animations:^{
            self.sjxBtn.transform = CGAffineTransformRotate(self.sjxBtn.transform, M_PI);
        }];
        
    }];
}


/** 二维码补录 */
- (void)qrBtnClick{
    [[UserData sharedInstance] entRefreshJobQrCodeWithJobId:self.jobId block:^(ResponseInfo *response) {
        if (response.success) {
            NSString *qrCode = response.content[@"qr_code"];
            NSString *expireTime = response.content[@"expire_time"];
            
            QrCodeViewController *vc = [[QrCodeViewController alloc] init];
            vc.qrCode = qrCode;
            vc.expireTime = @(expireTime.longLongValue);
            vc.jobId = self.jobId;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}


/** 全部录用按钮点击 */
- (void)allJkApplyBtnClick;{
    [self topBtnOnclick:_btnArray[1]];
    __unused EmployList_TV *vc = _vcArray[1];
    
    [UserData delayTask:0.5 onTimeEnd:^{
//        [vc getLastDataList];
    }];
    
}


/*!< 设置已报名人数 */
- (void)setApplyCount:(NSNumber *)num
{
    [((UIButton *)_btnArray[0]) setTitle:[NSString stringWithFormat:@"已报名 (%@)", num] forState:UIControlStateNormal];
}


/*!< 设置已录用人数 */
- (void)setEmployCount:(NSNumber *)num
{
    [((UIButton *)_btnArray[1]) setTitle:[NSString stringWithFormat:@"已录用 (%@)", num] forState:UIControlStateNormal];
    
}

@end
