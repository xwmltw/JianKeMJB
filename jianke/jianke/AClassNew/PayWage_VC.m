//
//  PayWage_VC.m
//  jianke
//
//  Created by xiaomk on 16/7/7.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "PayWage_VC.h"
#import "XSJConst.h"
#import "WebView_VC.h"
#import "ApplyJobModel.h"
#import "PayOnlineCell.h"
#import "PaySelect_VC.h"
#import "ManualAddPerson_VC.h"
#import "SalaryRecord_VC.h"
#import "BaseButton.h"

@interface PayWage_VC ()<UITableViewDelegate, UITableViewDataSource,PayOnlineDelegate>{
    NSMutableArray *_jkModelArray;
    NSArray *_nameFirstLetterArray; //拼音列表
    NSArray *_allSortJK;
    
    NSMutableArray *_selectArray;
    NSMutableArray *_addJiankeArray;
    
    int _allPayMoney;
    
    BOOL _isRefreshWhenShow;
    
}

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) UIView *botView;
@property (nonatomic, strong) UIButton *btnPay;
@property (nonatomic, strong) UIButton *btnAgree;
@property (nonatomic, strong) UIButton *btnAddJianke;
@property (nonatomic, strong) UIButton *btnSelectAll;

@property (nonatomic, copy) NSString *jobStartTime;//岗位开始时间毫秒数
@property (nonatomic, copy) NSString *jobEndTime;

@property (nonatomic, strong) ApplyJobModel *ajModel;

@end

@implementation PayWage_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [WDNotificationCenter addObserver:self selector:@selector(backAction) name:WDNotification_backFromMoneyBag object:nil];
    
    self.title = @"发放工资";
    _jkModelArray = [[NSMutableArray alloc] init];
    _addJiankeArray = [[NSMutableArray alloc] init];
    
    [self initBotView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];


    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.botView.mas_top);
    }];
    
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    headView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headView];
    
    self.btnSelectAll = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSelectAll setImage:[UIImage imageNamed:@"v3_public_select_0"] forState:UIControlStateNormal];
    [self.btnSelectAll setImage:[UIImage imageNamed:@"v3_public_select_1"] forState:UIControlStateSelected];
    [self.btnSelectAll setImage:[UIImage imageNamed:@"v3_public_select_1"] forState:UIControlStateHighlighted];

    self.btnSelectAll.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnSelectAll setTitleColor:[UIColor XSJColor_tBlackTinge] forState:UIControlStateNormal];
    [self.btnSelectAll setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.btnSelectAll setContentEdgeInsets:UIEdgeInsetsMake(0, 12, 0,-12)];
    [self.btnSelectAll addTarget:self action:@selector(btnSelectAllOnclick:) forControlEvents:UIControlEventTouchUpInside];
    self.btnSelectAll.frame = headView.bounds;
//    [self.btnSelectAll addBorderInDirection:BorderDirectionTypeTop | BorderDirectionTypeBottom  borderWidth:0.5 borderColor:[UIColor XSJColor_grayLine] isConstraint:YES];
    [headView addSubview:self.btnSelectAll];
    
//    [self.btnSelectAll mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(headView);
//    }];
    self.tableView.tableHeaderView = headView;
    
    
    [self initWithNoDataViewWithStr:@"没有需要支付的兼客" onView:self.tableView];

//    [self getLastData];
    _isRefreshWhenShow = YES;
    
    [self getDataWhenShow];
}

- (void)setNeedRefresh{
    _isRefreshWhenShow = YES;
}

- (void)getDataWhenShow{
    if (_isRefreshWhenShow) {
        _isRefreshWhenShow = NO;
        [UserData delayTask:0.2 onTimeEnd:^{
            [self getLastData]; 
        }];
    }
}


- (void)btnSelectAllOnclick:(UIButton *)sender{
    sender.selected = !sender.selected;
    for (NSArray* array in _allSortJK) {
        for (JKModel* model in array){
            model.isSelect = sender.selected;
        }
    }
    [self.tableView reloadData];
    [self sumAllMoneyWithSelect];
}

- (void)getLastData{
    WEAKSELF
    [[UserData sharedInstance] entQueryApplyJobListWithJobId:self.jobId listType:@(5) boardDate:nil queryParam:nil isShowLoading:YES block:^(ResponseInfo* response){
        [weakSelf.tableView.header endRefreshing];
        if (response && [response success]) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            weakSelf.ajModel = [ApplyJobModel objectWithKeyValues:response.content];

            NSArray *dataArray = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];

            [_jkModelArray removeAllObjects];
            _jkModelArray = [NSMutableArray arrayWithArray:dataArray];
            
            weakSelf.jobStartTime = weakSelf.ajModel.job_start_time.stringValue;
            weakSelf.jobEndTime = weakSelf.ajModel.job_end_time.stringValue;
            
            [weakSelf initTableViewData];
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
    }];
}

//** 拼音分组 */
- (void)initTableViewData{
    if (_addJiankeArray.count > 0) {
        NSMutableArray *tempAry = [[NSMutableArray alloc] init];
        for (JKModel *addModel in _addJiankeArray) {
            BOOL isHave = NO;
            for (JKModel *jkModel in _jkModelArray) {
                if ([addModel.telphone isEqualToString:jkModel.telphone]) {
                    isHave = YES;
                    break;
                }
            }
            if (!isHave) {
                [tempAry addObject:addModel];
            }
        }
        [_jkModelArray addObjectsFromArray:tempAry];
    }
   
    if (_jkModelArray.count > 0) {
        self.viewWithNoData.hidden = YES;
    }else{
        self.viewWithNoData.hidden = NO;
    }
    
    NSString *str = [NSString stringWithFormat:@"全选 (%lu)",(unsigned long)_jkModelArray.count];
    [self.btnSelectAll setTitle:str forState:UIControlStateNormal];
    
    NSArray* array = [MKCommonHelper getNoRepeatSortLetterArray:_jkModelArray letterKey:@"name_first_letter"];
    _nameFirstLetterArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:array]];
    
    NSMutableArray* sortJk = [NSMutableArray array];
    for (NSString* letter in _nameFirstLetterArray) {
        NSArray* tempArray = [_jkModelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name_first_letter = %@", letter.lowercaseString]];
        [sortJk addObject:tempArray];
    }
    _allSortJK = [[NSArray alloc] initWithArray:sortJk];
    [self.tableView reloadData];
    [self sumAllMoneyWithSelect];
}

#pragma mark - ***** UITableView delegate ******
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PayOnlineCell* cell = [PayOnlineCell cellWithTableView:tableView];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    
    if (_allSortJK.count <= indexPath.section || [_allSortJK[indexPath.section] count] <= indexPath.row) {
        return cell;
    }
    
    JKModel* model = _allSortJK[indexPath.section][indexPath.row];
    [cell refreshWithData:model];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_allSortJK[section] count] ? [_allSortJK[section] count] : 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allSortJK.count > 0 ? _allSortJK.count : 0;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView{
    return _nameFirstLetterArray;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = [UIColor XSJColor_grayTinge];
    [view addBorderInDirection:BorderDirectionTypeAll borderWidth:0.5 borderColor:[UIColor XSJColor_grayLine] isConstraint:YES];
    
    UILabel* labTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 100, 20)];
    labTitle.textColor = MKCOLOR_RGB(128, 128, 128);
    labTitle.font = [UIFont systemFontOfSize:14];
    labTitle.text = _nameFirstLetterArray[section];
    [view addSubview:labTitle];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
}

#pragma mark - ***** initBotView ******
- (void)initBotView{
    self.botView = [[UIView alloc] init];
    self.botView.backgroundColor = [UIColor XSJColor_grayTinge];
    [self.view addSubview:self.botView];

    self.btnAddJianke = [UIButton  buttonWithType:UIButtonTypeCustom];
    [self.btnAddJianke setTitleColor:[UIColor XSJColor_tBlackTinge] forState:UIControlStateNormal];
    [self.btnAddJianke setTitle:@"添加发放对象" forState:UIControlStateNormal];
    self.btnAddJianke.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.btnAddJianke setBorderWidth:0.5 andColor:[UIColor XSJColor_grayLine]];
    [self.btnAddJianke addTarget:self action:@selector(btnAddJiankeOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.botView addSubview:self.btnAddJianke];
    
    self.btnPay = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnPay setBackgroundImage:[UIImage imageNamed:@"login_btn_login_0"] forState:UIControlStateNormal];
    [self.btnPay setBackgroundImage:[UIImage imageNamed:@"login_btn_login_1"] forState:UIControlStateHighlighted];
    [self.btnPay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnPay setTitle:@"确认支付" forState: UIControlStateNormal];
    [self.btnPay addTarget:self action:@selector(btnPayOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.botView addSubview:self.btnPay];
    
    self.btnAgree = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnAgree setImage:[UIImage imageNamed:@"v3_public_sel_r_0"] forState:UIControlStateNormal];
    [self.btnAgree setImage:[UIImage imageNamed:@"v3_public_sel_r_1"] forState:UIControlStateSelected];
    [self.btnAgree setImage:[UIImage imageNamed:@"v3_public_sel_r_1"] forState:UIControlStateHighlighted];
    [self.btnAgree setTitle:@"我同意" forState:UIControlStateNormal];
    [self.btnAgree setTitleColor:[UIColor XSJColor_tGray] forState:UIControlStateNormal];
    self.btnAgree.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.btnAgree addTarget:self action:@selector(btnAgreeOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.botView addSubview:self.btnAgree];
    self.btnAgree.selected = YES;
    
    UIButton *btnAgreeAuth = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnAgreeAuth setTitle:@"《兼客兼职企业服务协议》" forState:UIControlStateNormal];
    [btnAgreeAuth setTitleColor:[UIColor XSJColor_tBlue] forState:UIControlStateNormal];
    btnAgreeAuth.titleLabel.font = [UIFont systemFontOfSize:12];
    [btnAgreeAuth addTarget:self action:@selector(btnAgreeAuthOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.botView addSubview:btnAgreeAuth];
    
    BaseButton *recordBtn = [BaseButton buttonWithType:UIButtonTypeCustom];
    [recordBtn setTitle:@"发放记录" forState:UIControlStateNormal];
    [recordBtn setImage:[UIImage imageNamed:@"info_icon_push_2"] forState:UIControlStateNormal];
    [recordBtn addTarget:self action:@selector(pushSalaryRecord) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn setMarginForImg:-1 marginForTitle:0];
    recordBtn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [recordBtn setTitleColor:[UIColor XSJColor_tGray] forState:UIControlStateNormal];
    [self.botView addSubview:recordBtn];
    
    [self.botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(144-8);
    }];
    
    [self.btnAddJianke mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.botView);
        make.top.equalTo(self.botView);
        make.height.mas_equalTo(44);
    }];
    
    [self.btnPay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.botView).offset(16);
        make.right.equalTo(self.botView).offset(-16);
        make.top.equalTo(self.btnAddJianke.mas_bottom).offset(12);
        make.height.mas_equalTo(44);
    }];
    
    [self.btnAgree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(32);
        make.left.equalTo(self.botView).offset(12);
        make.bottom.equalTo(self.botView).offset(-4);
    }];
    
    [btnAgreeAuth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.btnAgree);
        make.left.equalTo(self.btnAgree.mas_right);
    }];
    
    [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.btnAgree);
        make.right.equalTo(self.botView).offset(-16);
    }];
}

#pragma mark - ***** 底部按钮事件 ******
- (void)btnAgreeOnclick:(UIButton *)sender{
    sender.selected = !sender.selected;
}

- (void)btnAgreeAuthOnclick:(UIButton*)sender {
    WebView_VC *vc = [[WebView_VC alloc] init];
    vc.url = [NSString stringWithFormat:@"%@%@",URL_HttpServer,kUrl_epPayAgree];
    [self.navigationController pushViewController:vc animated:YES];
}

/** 点击支付 */
- (void)btnPayOnclick:(UIButton *)sender{
    [TalkingData trackEvent:@"兼客管理_确定在线支付"];
    if (_allPayMoney <= 0) {
        [UIHelper toast:@"当前总支付金额为0，无需支付。"];
        return;
    }
    
    if (!self.btnAgree.selected) {
        [UIHelper toast:@"您必须同意《兼客兼职企业服务协议》，才能支付。"];
        return;
    }
    
    PaySelect_VC* vc = [[PaySelect_VC alloc] init];
    vc.fromType = PaySelectFromType_epPay;
    vc.needPayMoney = _allPayMoney;
    vc.arrayData = _jkModelArray;
    vc.jobId = @(self.jobId.integerValue);
    [self.navigationController pushViewController:vc animated:YES];
}

/** 添加 */
- (void)btnAddJiankeOnclick:(UIButton*)sender{
    ManualAddPerson_VC *vc = [[ManualAddPerson_VC alloc] init];
    vc.title = @"添加发放对象";
    vc.isFromPayView = YES;
    vc.job_id = self.jobId;
    WEAKSELF
    vc.block = ^(NSArray *array){
        if (array && array.count > 0) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (JKModel *addModel in array) {
                BOOL isHave = NO;
                for (JKModel *jkModel in _addJiankeArray) {
                    if ([addModel.telphone isEqualToString:jkModel.telphone]) {
                        isHave = YES;
                        break;
                    }
                }
                if (!isHave) {
                    [tempArray addObject:addModel];
                }
            }
            [_addJiankeArray addObjectsFromArray:tempArray];
            [weakSelf initTableViewData];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushSalaryRecord{
    SalaryRecord_VC *viewCtrl = [[SalaryRecord_VC alloc] init];
    viewCtrl.jobId = self.jobId;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

#pragma mark - ***** payonline delegate ******
- (void)sumAllMoneyWithSelect{
    BOOL isAllSelect = YES;
    _allPayMoney = 0;
    for (NSArray* array in _allSortJK) {
        for (JKModel *model in array) {
            if (model.isSelect) {
                _allPayMoney += model.salary_num.intValue;
            }else{
                isAllSelect = NO;
            }
        }
    }
    
    self.btnSelectAll.selected = isAllSelect;
    
    if (_allPayMoney > 0) {
        [self.btnPay setTitle:[[NSString stringWithFormat:@"确认支付 ￥%.2f",_allPayMoney/100.0] stringByReplacingOccurrencesOfString:@".00" withString:@""] forState:UIControlStateNormal];
    }else{
        [self.btnPay setTitle:@"确认支付" forState:UIControlStateNormal];
    }
}

/*!< 获取是否有添加发放对象 */
- (BOOL)getIsHaveAddPayJianke{
    if (_addJiankeArray.count > 0) {
        return YES;
    }
    return NO;
}

- (void)backAction{
    [self.navigationController popToViewController:self.popToVC animated:YES];
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
