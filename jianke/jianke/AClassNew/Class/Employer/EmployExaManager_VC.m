//
//  EmployExaManager_VC.m
//  jianke
//
//  Created by xiaomk on 16/7/5.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "EmployExaManager_VC.h"
#import "JobModel.h"
#import "EpSingleDay_VC.h"
#import "EmployExaList.h"
#import "DateView.h"
#import "DateSelectView.h"
#import "PayExactWageManager_VC.h"
#import "MakeCheck_VC.h"
#import "PayWage_VC.h"
#import "BaseButton.h"
#import "BuyInsurance_VC.h"

@interface EmployExaManager_VC ()<UIScrollViewDelegate,EmployListManagerDelegate>{
    NSArray *_dateModelArray;
    
    BOOL _isRefreshWhenShowLeft;
    BOOL _isRefreshWhenShowRight;

    NSInteger _nowSelectDateIndex;   //首页显示的 当前天 如果没有当前天 就显示下一天
//    int _todayNum;    //精确的 是否是当天 ，否则为 -1；
    BOOL _isShowLeft;
}

@property (nonatomic, strong) UIView *mainSingleView;           /*!< single View */
@property (nonatomic, weak) UIButton *btnLeft;
@property (nonatomic, weak) UIButton *btnRight;
@property (nonatomic, strong) UIView *leftPoint;
@property (nonatomic, strong) UIView *rightPoint;

@property (nonatomic, weak) UIButton *btnDate;
@property (nonatomic, strong) DateView *dateView;



@property (nonatomic, weak) EmployExaList *pmVC;
@property (nonatomic, weak) EpSingleDay_VC *sdVC;

@property (nonatomic, strong) NSMutableArray *dateTitleArray;
@end

@implementation EmployExaManager_VC

- (UIButton *)createHeadBtnWithTitle:(NSString *)title{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitleColor: [UIColor XSJColor_tGray] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:title forState:UIControlStateNormal];
    return btn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"兼客管理";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *topBtnBgView = [[UIView alloc] init];
    [self.view addSubview:topBtnBgView];
    topBtnBgView.backgroundColor = [UIColor whiteColor];
    [topBtnBgView setBorderWidth:0.5 andColor:[UIColor XSJColor_grayLine]];
    
    [topBtnBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];

    UIButton *btnLeft = [self createHeadBtnWithTitle:@"已录用"];
    [btnLeft addTarget:self action:@selector(btnLeftOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [topBtnBgView addSubview:btnLeft];
    self.btnLeft = btnLeft;
    
    UIButton *btnRight = [self createHeadBtnWithTitle:@"日期"];
    [btnRight addTarget:self action:@selector(btnRightOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [topBtnBgView addSubview:btnRight];
    self.btnRight = btnRight;

    UIButton *btnDate = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDate addTarget:self action:@selector(btnDateOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnDate setImage:[UIImage imageNamed:@"v3_mgr_date"] forState:UIControlStateNormal];
    [btnDate setImage:[UIImage imageNamed:@"v3_mgr_date"] forState:UIControlStateHighlighted];
    [topBtnBgView addSubview:btnDate];
    self.btnDate = btnDate;
    
    UIView *leftPoint = [[UIView alloc] init];
    leftPoint.frame = CGRectMake(0, 0, 5, 5);
    leftPoint.backgroundColor = [UIColor XSJColor_base];
    [leftPoint setToCircle];
    [self.btnLeft addSubview:leftPoint];
    self.leftPoint = leftPoint;
    
    UIView *rightPoint = [[UIView alloc] init];
    rightPoint.frame = CGRectMake(0, 0, 5, 5);
    rightPoint.backgroundColor = [UIColor XSJColor_base];
    [rightPoint setToCircle];
    [self.btnRight addSubview:rightPoint];
    self.rightPoint = rightPoint;
    
    BaseButton *button = [[BaseButton alloc] init];
    [button setTitle:@"兼客兼职保障,购买兼职意外保险" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor XSJColor_tBlue] forState:UIControlStateNormal];
    button.backgroundColor = MKCOLOR_RGBA(0, 118, 255, 0.03);
    button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [button setImage:[UIImage imageNamed:@"push_icon_blue"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pushBuyInsurance:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    [button setMarginForImg:-16 marginForTitle:16];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topBtnBgView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.equalTo(@44);
    }];
    
    self.mainSingleView = [[UIView alloc] initWithFrame:CGRectMake(0, 88, self.view.width, SCREEN_HEIGHT-64-88)];
    self.mainSingleView.backgroundColor = [UIColor XSJColor_grayTinge];
    [self.view addSubview:self.mainSingleView];
    
    [btnDate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(topBtnBgView);
        make.width.mas_equalTo(48);
    }];
    
    [btnLeft mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(topBtnBgView);
    }];
    
    [btnRight mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(topBtnBgView);
        make.left.equalTo(btnLeft.mas_right);
        make.right.equalTo(btnDate.mas_left);
        make.width.equalTo(btnLeft);
    }];
    
    [leftPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.btnLeft);
        make.bottom.equalTo(self.btnLeft).offset(-2);
        make.width.height.mas_equalTo(5);
    }];
    
    [rightPoint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.btnRight);
        make.bottom.equalTo(self.btnLeft).offset(-2);
        make.width.height.mas_equalTo(5);
    }];
 
    EmployExaList *vc = [[EmployExaList alloc] init];
    self.pmVC = vc;
    vc.jobId = self.jobId;
    vc.isAccurateJob = self.isAccurateJob;
    vc.managerType = self.managerType;
    vc.delegate = self;
    _isShowLeft = YES;
    _isRefreshWhenShowLeft = YES;
    _isRefreshWhenShowRight = YES;
    CGRect frame;
    if (self.isMutiVC) {
        frame = CGRectMake(0, 0, self.mainSingleView.width, self.mainSingleView.height - 44);
    }else{
        frame = CGRectMake(0, 0, self.mainSingleView.width, self.mainSingleView.height);
        [self getDataWhenShow];
    }
    vc.view.frame = frame;
    [self addChildViewController:vc];
    [self.mainSingleView addSubview:vc.view];
    _nowSelectDateIndex = -1;

    
    _dateModelArray = [[NSArray alloc] init];
    [self getJobDateList];

}



- (void)getJobDateList{
    if (self.jobModel.expect_on_board_stu_counts) {
        _dateModelArray = [ExpectOnBoardStuCountModel objectArrayWithKeyValuesArray:self.jobModel.expect_on_board_stu_counts];
    }
    
    
    NSString* strDateNow =[DateHelper getDateFromTimeNumber:[NSNumber numberWithLongLong:[DateHelper getTimeStamp]] withFormat:@"yyMMdd"];
    int nowDate = strDateNow.intValue;  //现在的日期时间
    
    self.dateTitleArray = [[NSMutableArray alloc] init];
    if (_dateModelArray && _dateModelArray.count > 0) {
        for (NSInteger i = 0; i < _dateModelArray.count; i++) {
            ExpectOnBoardStuCountModel *expModel = [_dateModelArray objectAtIndex:i];
            NSString* date = [DateHelper getShortDateFromTimeNumber:expModel.on_board_date];
            NSString* week = [DateHelper weekdayStringFromDate:expModel.on_board_date];
            NSString* showDate = [NSString stringWithFormat:@"%@ %@",date,week];
            [self.dateTitleArray addObject:showDate];
        }
        for (NSInteger i = 0; i < _dateModelArray.count; i++) {
            ExpectOnBoardStuCountModel *expModel = [_dateModelArray objectAtIndex:i];
            NSString* dateStr = [DateHelper getDateFromTimeNumber:expModel.on_board_date withFormat:@"yyMMdd"];
            int boardDate = dateStr.intValue;
            if (boardDate >= nowDate) {
                _nowSelectDateIndex = i;
                break;
            }
        }
        if (_nowSelectDateIndex < 0) {
            _nowSelectDateIndex = _dateModelArray.count - 1;
        }
    }
    
    [self.btnRight setTitle:[self.dateTitleArray objectAtIndex:_nowSelectDateIndex] forState:UIControlStateNormal];
    
    [self setSelectBtnIsLeft:_isShowLeft isNeedRefresh:NO];

}

- (void)setNeedRefresh{
    _isRefreshWhenShowLeft = YES;
    _isRefreshWhenShowRight = YES;
}

- (void)getDataWhenShow{
    [self setSelectBtnIsLeft:_isShowLeft];
}


#pragma mark - ***** 按钮事件 ******
- (void)btnLeftOnclick:(UIButton *)sender{
    _isShowLeft = YES;
    [self setSelectBtnIsLeft:_isShowLeft];
}

- (void)btnRightOnclick:(UIButton *)sender{
    _isShowLeft = NO;
    [self setSelectBtnIsLeft:_isShowLeft];

}

- (void)setSelectBtnIsLeft:(BOOL)isLeft{
    [self setSelectBtnIsLeft:isLeft isNeedRefresh:YES];
}

- (void)setSelectBtnIsLeft:(BOOL)isLeft isNeedRefresh:(BOOL)isRefresh{
    
    self.btnLeft.selected = isLeft;
    self.leftPoint.hidden = !isLeft;
    
    self.btnRight.selected = !isLeft;
    self.rightPoint.hidden = isLeft;
    
    self.pmVC.view.hidden = !isLeft;
    self.sdVC.view.hidden = isLeft;
    
    if (isRefresh) {
        if (isLeft) {
            if (_isRefreshWhenShowLeft) {
                _isRefreshWhenShowLeft = NO;
                [self.pmVC getData];
            }
        }else{
            if (_isRefreshWhenShowRight) {
                _isRefreshWhenShowRight = NO;
                
                ExpectOnBoardStuCountModel *expModel = [_dateModelArray objectAtIndex:_nowSelectDateIndex];
                self.sdVC.boardDate = expModel.on_board_date;
                [self.sdVC getDatas];
            }
        }
    }
}


//日历按钮
- (void)btnDateOnclick:(UIButton *)sender{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    
    DLAVAlertView* exportAlertView = [[DLAVAlertView alloc] initWithTitle:@"选择兼职日期" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
    
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.jobModel.work_time_start.longLongValue];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.jobModel.work_time_end.longLongValue];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 300)];
    
    // 日期控件
    DateSelectView *dateView = [[DateSelectView alloc] initWithFrame:CGRectMake(0, 0, 260, 260)];
    dateView.type = DateViewTypeNormal;
    dateView.startDate = startDate;
    dateView.endDate = endDate;
    WEAKSELF
    dateView.didClickBlock = ^(NSArray *selectDateArray){
        DLog(@"选中日期:%@", selectDateArray.lastObject);
        
        [exportAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        NSNumber* time = [NSNumber numberWithLongLong:[selectDateArray.lastObject timeIntervalSince1970]*1000];
        NSString* strDateSelect = [DateHelper getDateFromTimeNumber:time withFormat:@"yyMMdd"];
        NSInteger selectDate = strDateSelect.integerValue;
        ELog(@"=====selectDate:%ld",(long)selectDate);
        
        for (NSInteger i = 0; i < _dateModelArray.count; i++) {
            ExpectOnBoardStuCountModel* model = [_dateModelArray objectAtIndex:i];
            NSString* dateStr = [DateHelper getDateFromTimeNumber:model.on_board_date withFormat:@"yyMMdd"];
            NSInteger boardDate = dateStr.integerValue;
            //            ELog(@"=====boardDate:%ld",(long)boardDate);
            if (boardDate == selectDate) {
                _nowSelectDateIndex = i;
                ELog(@"_nowSelectDateIndex:%ld",(long)i);
                break;
            }
        }
        [weakSelf selectDateRefresh];
    };
    [containerView addSubview:dateView];
    
    exportAlertView.contentView = containerView;
    [exportAlertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        
    }];
}


- (void)selectDateRefresh{
    [self.btnRight setTitle:[self.dateTitleArray objectAtIndex:_nowSelectDateIndex] forState:UIControlStateNormal];
    _isRefreshWhenShowRight = YES;
    [self setSelectBtnIsLeft:NO];
}
    

- (EpSingleDay_VC *)sdVC{
    if (!_sdVC) {
        EpSingleDay_VC *vc = [[EpSingleDay_VC alloc] init];
        _sdVC = vc;
        vc.jobId = self.jobId;
        vc.isAccurateJob = self.isAccurateJob;
        vc.managerType = self.managerType;
        vc.delegate = self;
        CGRect frame;
        if (self.isMutiVC) {
            frame = CGRectMake(0, 0, self.mainSingleView.width, self.mainSingleView.height-44);
        }else{
            frame = CGRectMake(0, 0, self.mainSingleView.width, self.mainSingleView.height);
        }
        
        vc.view.frame = frame;
        [self addChildViewController:vc];
        [self.mainSingleView addSubview:vc.view];
    }
    return _sdVC;
}

- (void)elm_changeToPayVC{
//    if ([self.delegate respondsToSelector:@selector(changeSelectVcWithIndex:showDetailIndex:)]) {
//        [self.delegate changeSelectVcWithIndex:2 showDetailIndex:_nowSelectDateIndex];
//    }
    if (self.managerType == ManagerTypeEP) {
        if (self.isAccurateJob.integerValue == 1) {
            PayExactWageManager_VC *payVc = [[PayExactWageManager_VC alloc] init];
            payVc.jobId = self.jobId;
            payVc.isAccurateJob = self.isAccurateJob;
            payVc.jobModel = self.jobModel;
            payVc.popToVC = self;
            [self.navigationController pushViewController:payVc animated:YES];
        }else{
            PayWage_VC *payVc = [[PayWage_VC alloc] init];
            payVc.jobId = self.jobId;
            [self.navigationController pushViewController:payVc animated:YES];
        }
    }else{
        MakeCheck_VC *mcVc = [[MakeCheck_VC alloc] init];
        mcVc.jobId = self.jobId;
        mcVc.jobModel =  self.jobModel;
        [self.navigationController pushViewController:mcVc animated:YES];
    }
}

- (void)pushBuyInsurance:(UIButton *)sender{
    BuyInsurance_VC *viewCtrl = [UIHelper getVCFromStoryboard:@"EP" identify:@"sid_BuyInsurance_VC"];
    viewCtrl.jobID = @(self.jobId.integerValue);
    viewCtrl.isAccurateJob = self.isAccurateJob;
    viewCtrl.popToVC = self;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
