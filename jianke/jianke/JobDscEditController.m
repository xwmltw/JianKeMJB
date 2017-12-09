//
//  JobDscEditController.m
//  jianke
//
//  Created by fire on 15/10/7.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//  普通岗位描述编辑页面

#import "JobDscEditController.h"
#import "Masonry.h"
#import "PostJobCellModel.h"
#import "MutiSelectSheet.h"
#import "ConditionController.h"
#import "JobModel.h"

@interface JobDscEditController (){
    EPModel *_epModel;
}

@property (nonatomic, weak) UIButton *resBtn;
@property (nonatomic, weak) UIButton *waleBtn;

@end

@implementation JobDscEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    _epModel = [[UserData sharedInstance] getEpModelFromHave];
    self.title = @"内容及福利要求";
    self.view.backgroundColor = [UIColor whiteColor];

    UIView* viewTvBg = [[UIView alloc] init];
    viewTvBg.backgroundColor = [UIColor XSJColor_grayTinge];
    [self.view addSubview:viewTvBg];
    
    // textView
    UIPlaceHolderTextView *textView = [[UIPlaceHolderTextView alloc] init];
    textView.placeholder = @"为了方便您招到合适的兼客,请尽可能详细地填写该岗位的工作内容、福利和特殊要求";
    textView.font = [UIFont systemFontOfSize:16.0f];
    textView.maxLength = 500;
    textView.scrollEnabled = YES;
    textView.backgroundColor = [UIColor XSJColor_grayTinge];
    textView.placeholderColor = MKCOLOR_RGB(180, 180, 185);
    [self.view addSubview:textView];
    self.textView = textView;
    
    //限制条件 (只有当岗位不是包招 并且 开启限制条件 才显示)
    if (_epModel.apply_job_limit_enable.intValue == 1 && self.postJobType != PostJobType_bd) {
        self.resBtn = [self createCell:@"限制条件" leftImg:@"v250_place" rightImg:@"job_icon_push"];
        [self.resBtn addTarget:self action:@selector(pushRestrict:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    //福利保障
    self.waleBtn = [self createCell:@"福利保障" leftImg:@"v250_tag" rightImg:@"job_icon_xia"];
    [self.waleBtn addTarget:self action:@selector(showSheet:) forControlEvents:UIControlEventTouchUpInside];
    
    // 保存按钮
    UIButton *saveBtn = [[UIButton alloc] init];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_login_0"] forState:UIControlStateNormal];
    [saveBtn setBackgroundImage:[UIImage imageNamed:@"login_btn_login_1"] forState:UIControlStateHighlighted];
    [saveBtn setTitle:@"提交" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    
    WEAKSELF
    [viewTvBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.top.equalTo(weakSelf.view.mas_top).offset(12);
        make.height.mas_equalTo(140);
    }];
    
    // textView
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewTvBg).offset(8);
        make.right.equalTo(viewTvBg).offset(-8);
        make.top.equalTo(viewTvBg).offset(1);
        make.bottom.equalTo(viewTvBg).offset(-1);
    }];
    
    // 提交按钮
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.waleBtn.mas_bottom).offset(18);
        make.height.mas_equalTo(44);
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
    }];
    
    if (_epModel.apply_job_limit_enable.intValue == 1 && self.postJobType != PostJobType_bd) {
        [self.resBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(viewTvBg.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@61);
        }];
        [self.waleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.resBtn.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@61);
        }];

    }else{
        [self.waleBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(viewTvBg.mas_bottom);
            make.left.right.equalTo(self.view);
            make.height.equalTo(@61);
        }];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle)];
    [self.view addGestureRecognizer:tap];
    
    // 附旧值
    if (self.descStr && self.descStr.length > 0) {
        self.textView.text = self.descStr;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateStatus];
}

- (void)tapHandle{
    [self.view endEditing:YES];
}

//刷新视图
- (void)updateStatus{
    if (self.resBtn) {
        if ([self isSetCondition]) {
            [self.resBtn setTitle:@"已限制" forState:UIControlStateNormal];
        }else{
            [self.resBtn setTitle:@"限制条件" forState:UIControlStateNormal];
        }
    }
    [self updateBtn];
}

#pragma mark - ***** PostJobCellType_welfare ******
- (void)welfareOnclick{
    [self.view endEditing:YES];
    if (!_jobWelfareArray || !_jobWelfareArray
        .count) {
        [UIHelper toast:@"获取福利列表失败"];
        return;
    }
    
    NSMutableArray *items = [NSMutableArray array];
    for (WelfareModel *jobTag in _jobWelfareArray) {
        MutiSelectSheetItem *item = [[MutiSelectSheetItem alloc] initWithTitle:jobTag.tag_title selected:jobTag.check_status.integerValue enable:YES arg:jobTag];
        [items addObject:item];
    }
    WEAKSELF
    MutiSelectSheet *walfareSelectView = [[MutiSelectSheet alloc] initWithTitle:@"福利保障" items:items selctedBlock:^(NSArray *selItems) {
        for (MutiSelectSheetItem *item in items) {
            WelfareModel *jobTag = item.arg;
            jobTag.check_status = item.selected ? @(1) : @(0);
        }
        [weakSelf updateBtn];
    }];
    [walfareSelectView show];
}

#pragma mark - ***** PostJobCellType_restrict ******
- (void)restrictOnclick{
    ConditionController *vc = [[ConditionController alloc] init];
    vc.jobModel = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.jobModel]];
    vc.startDate = self.startDate;
    vc.endDate = self.endDate;
    vc.block = ^(JobModel *jobModel){
        self.jobModel = jobModel;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

/** 是否进行条件筛选 */
- (BOOL)isSetCondition{
    JobModel *jobModel = self.jobModel;
    if (jobModel.sex
        || (jobModel.age && jobModel.age.intValue != 0)
        || (jobModel.height && jobModel.height.intValue != 0)
        || (jobModel.rel_name_verify && jobModel.rel_name_verify.intValue != 0)
        || (jobModel.life_photo && jobModel.life_photo.intValue != 0)
        || jobModel.apply_job_date
        || (jobModel.health_cer && jobModel.health_cer.intValue != 0)
        || (jobModel.stu_id_card && jobModel.stu_id_card.intValue != 0)
        ) {
        return YES;
    }
    return NO;
}

#pragma mark - 其他

- (void)saveBtnClick{
    if (self.textView.text.length < 1) {
        [UIHelper toast:@"岗位描述不能为空"];
        return;
    }
    self.jobModel.job_desc = self.textView.text;
    MKBlockExec(self.block, self.jobModel, self.jobWelfareArray);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)updateBtn{
    if (_jobWelfareArray && _jobWelfareArray.count) {
        NSArray *jobTagList = [_jobWelfareArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"check_status.integerValue == 1"]];
        NSString *titleStr;
        if (jobTagList.count) {
            NSArray *titleArray = [jobTagList valueForKeyPath:@"tag_title"];
            titleStr = [titleArray componentsJoinedByString:@","];
            if (titleStr.length) {
                [self.waleBtn setTitle:titleStr forState:UIControlStateNormal];
            }
        }else{
            [self.waleBtn setTitle:@"福利保障" forState:UIControlStateNormal];
        }
    }
}

- (void)pushRestrict:(UIButton *)sender{
    ELog(@"限制条件");
    [self restrictOnclick];
}

- (void)showSheet:(UIButton *)sender{
    ELog(@"福利保障");
    [self welfareOnclick];
}

- (UIButton *)createCell:(NSString *)title leftImg:(NSString *)leftImg rightImg:(NSString *)rightImg{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor XSJColor_tBlackTinge] forState:UIControlStateNormal];
    [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 56, 0, 0)];
    button.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    
    UIImageView *leftImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:leftImg]];
    UIImageView *rightImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:rightImg]];
    
    UIView *sepView = [[UIView alloc] init];
    sepView.backgroundColor = MKCOLOR_RGBA(230, 230, 230, 1);
    
    [self.view addSubview:button];
    [self.view addSubview:leftImgView];
    [self.view addSubview:rightImgView];
    [self.view addSubview:sepView];
    
    [leftImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(button);
        make.width.height.equalTo(@20);
        make.left.equalTo(button.mas_left).offset(20);
    }];
    [rightImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.width.height.equalTo(leftImgView);
        make.right.equalTo(button.mas_right).offset(-20);
    }];
    
    [sepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(button).offset(-0.7);
        make.left.equalTo(leftImgView.mas_right).offset(20);
        make.right.equalTo(button);
        make.height.equalTo(@(0.7));
    }];
    
    return button;
}

@end
