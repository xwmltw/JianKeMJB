//
//  PayExactWage_VC.m
//  jianke
//
//  Created by xiaomk on 16/7/7.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "PayExactWage_VC.h"
#import "WebView_VC.h"
#import "PaySalaryModel.h"
#import "PaySelect_VC.h"
#import "ExactPayOnlineCell.h"
#import "XHPopMenuItem.h"
#import "XHPopMenu.h"
#import "AddPayJianke_VC.h"
#import "ManualAddPerson_VC.h"
#import "SalaryRecord_VC.h"
#import "BaseButton.h"

@interface PayExactWage_VC ()<UITableViewDelegate, UITableViewDataSource,PaySalaryDelegate>{
    int _allPayMoney;       /*!< 总薪水 */
    
    PaySalaryModel* _psModel;       /*!< 总model */


    NSMutableArray *_resumeArray;   /*!< 兼客简历列表 */
    NSArray* _nameFirstLetterArray; /*!< 拼音列表 */
    NSArray* _allSortJKResumeArray; /*!< 所有排序完的数组 */

    NSMutableArray *_addJiankeArray;/*!< 添加的兼客列表 */

    
    //已录用
    NSInteger _jobAllDays;          /*!< 岗位总天数 */
    NSMutableArray *_timeArray;     /*!< 开始到结束 的 日期数组 */
    
}


@property (nonatomic, strong) UIView *botView;
@property (nonatomic, strong) UIButton *btnPay;
@property (nonatomic, strong) UIButton *btnAgree;
@property (nonatomic, strong) UIButton *btnAddJianke;
@property (nonatomic, strong) UIButton *btnSelectAll;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation PayExactWage_VC


#pragma mark - ***** top bot View ******
- (void)initBotView{
    self.botView = [[UIView alloc] init];
    self.botView.backgroundColor = [UIColor XSJColor_grayTinge];
    [self.view addSubview:self.botView];
    
    self.btnAddJianke = [UIButton  buttonWithType:UIButtonTypeSystem];
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
    self.btnPay.titleLabel.font = [UIFont systemFontOfSize:17.0f];
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBotView];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor XSJColor_grayTinge];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];


    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.botView.mas_top);
    }];
    
    [self initWithNoDataViewWithStr:@"暂无发放对象" onView:self.tableView];
    
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
    self.tableView.tableHeaderView = headView;

        
    _allPayMoney = 0;
    _resumeArray = [[NSMutableArray alloc] init];
    _addJiankeArray = [[NSMutableArray alloc] init];
    _timeArray = [[NSMutableArray alloc] init];

//    [self getLastData];

}

- (void)getData{
    [UserData delayTask:0.2 onTimeEnd:^{
        [self getLastData];
    }];
}

- (void)getLastData{
    
    GetQueryApplyJobModel *model = [[GetQueryApplyJobModel alloc] init];
    model.job_id = self.jobId;
    if (self.on_board_time) {
        model.on_board_date = @(self.on_board_time.integerValue);
    }
    model.is_need_pagination = @(0);
    NSString *content = [model getContent];
    
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_entQueryPaySalaryStuList" andContent:content];
    request.isShowLoading = YES;
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        [weakSelf.tableView.header endRefreshing];
        if (response && response.success) {

            _psModel = [PaySalaryModel objectWithKeyValues:response.content];
            
            [_resumeArray removeAllObjects];
            
            NSArray* rlArray = [ResumeListModel objectArrayWithKeyValuesArray:_psModel.resume_list];
            [weakSelf.btnSelectAll setTitle:[NSString stringWithFormat:@"全选（%lu）",(unsigned long)rlArray.count] forState:UIControlStateNormal];
            weakSelf.btnSelectAll.selected = NO;
            
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[_psModel.job_start_time longLongValue]/1000];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[_psModel.job_end_time longLongValue]/1000];
            
            long long startT = [DateHelper zeroTimeOfDate:startDate].timeIntervalSince1970*1000;
            long long dayTime = 24*3600*1000;
            long long endT = [DateHelper zeroTimeOfDate:endDate].timeIntervalSince1970 * 1000;
            
            if (!weakSelf.isFromSingleDay) {
       
                _jobAllDays = 0;
                _timeArray = [[NSMutableArray alloc]init];

                do {
                    _jobAllDays++;
                    NSDate *date = [NSDate dateWithTimeIntervalSince1970:startT/1000];
                    [_timeArray addObject:date];
                    startT += dayTime;
                    
                } while (startT <= endT);
                startT = [DateHelper zeroTimeOfDate:startDate].timeIntervalSince1970*1000;
            }
            
 
            
            for (ResumeListModel* rlModel in rlArray) {                    //遍历有多少个cell
                rlModel.job_day_salary = _psModel.job_day_salary;
                rlModel.isFromSingleDay = weakSelf.isFromSingleDay;

                if (weakSelf.isFromSingleDay){
                    rlModel.nowPaySalary = rlModel.job_day_salary.integerValue;
                }else{
                    rlModel.selectSumDays = 0;
                    rlModel.job_start_time = _psModel.job_start_time;
                    rlModel.job_end_time = _psModel.job_end_time;
                    
                    //报名的列表
                    NSArray* boardTimeListAry = [BoardTimeListModel objectArrayWithKeyValuesArray:rlModel.on_board_time_list];
                    //方块数据
                    NSMutableArray* epcArray = [[NSMutableArray alloc] init];
                    for (NSInteger i = 0; i < _jobAllDays; i++) {  //岗位有多少天，就有多少个方块
                        ExaPayCellModel* epcModel = [[ExaPayCellModel alloc] init];
                        epcModel.timeStamp = startT + dayTime*i;
                        epcModel.dayStatus = 0;     //默认转态灰色
                        for (BoardTimeListModel* btModel in boardTimeListAry) {//遍历有报名的那几天
                            if (btModel.on_board_time.longLongValue == epcModel.timeStamp) {//如果这一天有报名
                                if (btModel.is_be_verify.intValue == 0 || (btModel.is_be_pay_salary.intValue == 0 && btModel.on_board_status.intValue == 1)) { //非未到岗并且没付过钱
                                    epcModel.dayStatus = 1;  //蓝块(有报名的天)
                                }
                                NSDate* dateBoard = [NSDate dateWithTimeIntervalSince1970:[btModel.on_board_time longLongValue]/1000];
                                NSDate* dateToday = [DateHelper zeroTimeOfToday];
                                if ([dateBoard isEarlierThanOrEqualTo:dateToday] && ((btModel.is_be_verify.intValue == 0 && btModel.is_be_pay_salary.intValue == 0) || (btModel.is_be_pay_salary.intValue == 0 && btModel.on_board_status.intValue == 1))) {//今天之前，默认选中
                                    epcModel.dayStatus = 2; //绿色打勾(默认选中的天)
                                    rlModel.selectSumDays += 1;
                                    rlModel.isSelect = YES;
                                }
                                
                                //                            if (btModel.is_be_pay_salary.intValue == 1 || btModel.on_board_status.intValue == 0) {
                                //                                rlModel.isSelect = NO;
                                //                            }
                                if (btModel.on_board_status.intValue == 0 && btModel.is_be_verify.intValue == 1) {//已经确认 未到岗
                                    epcModel.dayStatus = 4; //4 红块(未到岗的天)
                                }
                                if (btModel.is_be_pay_salary.intValue == 1) {//已付款
                                    epcModel.dayStatus = 3; //3 ￥图标(已支付的天)
                                }
                            }
                        }
                        [epcArray addObject:epcModel];
                    }
                    rlModel.exaPayArray = [NSArray arrayWithArray:epcArray];
                    rlModel.nowPaySalary = rlModel.selectSumDays * rlModel.job_day_salary.integerValue;
                }
               
                [_resumeArray addObject:rlModel];
            }
            [weakSelf initTableViewData];
        }
    }];
}

- (void)initTableViewData{
    if (_addJiankeArray.count > 0) {
        NSMutableArray *tempAry = [[NSMutableArray alloc] init];
        for (JKModel *addModel in _addJiankeArray) {
            BOOL isHave = NO;
            for (ResumeListModel *resumeModel in _resumeArray) {
                if ([addModel.telphone isEqualToString:resumeModel.resume_info.telphone]) {
                    isHave = YES;
                    break;
                }
            }
            if (!isHave) {
                ResumeListModel *model = [[ResumeListModel alloc] init];
                model.resume_info = addModel;
                model.nowPaySalary = addModel.salary_num.integerValue;
                model.isSelect = YES;
                [tempAry addObject:model];
            }
        }

        [_resumeArray addObjectsFromArray:tempAry];
        
    }
    
    if (_resumeArray.count > 0) {
        self.viewWithNoData.hidden = YES;
    }else{
        self.viewWithNoData.hidden = NO;
    }
    
    [self.btnSelectAll setTitle:[NSString stringWithFormat:@"全选（%lu）",(unsigned long)_resumeArray.count] forState:UIControlStateNormal];

    
    
    NSArray* tempArray = [_resumeArray valueForKey:@"resume_info"];
    
    NSArray* array = [MKCommonHelper getNoRepeatSortLetterArray:tempArray letterKey:@"name_first_letter"];
    _nameFirstLetterArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:array]];
    
    NSMutableArray* sortJk = [NSMutableArray array];
    for (NSString* letter in _nameFirstLetterArray) {
        NSArray* tempArray = [_resumeArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"resume_info.name_first_letter = %@", letter.lowercaseString]];
        [sortJk addObject:tempArray];
    }
    _allSortJKResumeArray = [[NSArray alloc] initWithArray:sortJk];
    [self psCell_allMoneyWithSelect];
    [self.tableView reloadData];
}

- (void)psCell_allMoneyWithSelect{
    BOOL isAllSelect = YES;

    _allPayMoney = 0;
    for (NSArray* array in _allSortJKResumeArray) {
        for (ResumeListModel* model in array){
            if (model.isSelect) {
                _allPayMoney += model.nowPaySalary;
            }else{
                isAllSelect = NO;
            }
        }
    }
    
    self.btnSelectAll.selected = isAllSelect;
    
    if (_allPayMoney != 0) {
        [self.btnPay setTitle:[[NSString stringWithFormat:@"确认支付 ￥%.2f",_allPayMoney*0.01 ]stringByReplacingOccurrencesOfString:@".00" withString:@""] forState:UIControlStateNormal];
    }else{
        [self.btnPay setTitle:@"确认支付" forState:UIControlStateNormal];
    }
}

#pragma mark - payonline delegate
- (void)psCell_updateCellIndex:(NSIndexPath*)indexPath withModel:(ResumeListModel *)model{
    //    [_resumeArray replaceObjectAtIndex:indexPath.row withObject:model];
    //    [self AllMoneyWithSelect];
    NSArray* array = @[indexPath];
    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - ***** UITableView delegate ******
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ExactPayOnlineCell *cell = [ExactPayOnlineCell cellWithTableView:tableView];
    cell.delegate = self;
    
    ResumeListModel* model = _allSortJKResumeArray[indexPath.section][indexPath.row];
    [cell refreshWithData:model andIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ResumeListModel* model = _allSortJKResumeArray[indexPath.section][indexPath.row];
    return model.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_allSortJKResumeArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allSortJKResumeArray.count > 0 ? _allSortJKResumeArray.count : 0;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView{
    return _nameFirstLetterArray;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = [UIColor XSJColor_grayTinge];
    [view setBorderWidth:0.5 andColor:[UIColor XSJColor_grayLine]];
    
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

#pragma mark - ***** 按钮事件 ******

/** 点击支付 */
- (void)btnPayOnclick:(UIButton *)sender{
    
    if (_allPayMoney <= 0) {
        [UIHelper toast:@"当前总支付金额为0，无需支付。"];
        return;
    }
    if (!self.btnAgree.selected) {
        [UIHelper toast:@"您必须同意《兼客兼职企业服务协议》，才能支付。"];
        return;
    }
    NSMutableArray* tempAry = [[NSMutableArray alloc] init];
    for (NSArray* ary in _allSortJKResumeArray) {
        for (ResumeListModel* model in ary) {
            [tempAry addObject:model];
        }
    }
    
    PaySelect_VC* vc = [[PaySelect_VC alloc] init];
    vc.fromType = PaySelectFromType_epPay;
    vc.needPayMoney = _allPayMoney;
    vc.arrayData = tempAry;
    vc.jobId = [[NSNumber alloc] initWithInt:self.jobId.intValue];
    vc.isAccurateJob = self.isAccurateJob;
    vc.on_board_time = self.on_board_time;
    [self.navigationController pushViewController:vc animated:YES];
}

/** 添加 */
- (void)btnAddJiankeOnclick:(UIButton*)sender{
    if (self.isFromSingleDay && self.on_board_time) {
        AddPayJianke_VC *vc = [[AddPayJianke_VC alloc] init];
        vc.jobId = self.jobId;
        vc.on_board_date = self.on_board_time;
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
    }else{
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
}

- (void)btnAgreeOnclick:(UIButton *)sender{
    sender.selected = !sender.selected;
}

- (void)btnAgreeAuthOnclick:(UIButton*)sender {
    WebView_VC *vc = [[WebView_VC alloc] init];
    vc.url = [NSString stringWithFormat:@"%@%@",URL_HttpServer,kUrl_epPayAgree];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushSalaryRecord{
    SalaryRecord_VC *viewCtrl = [[SalaryRecord_VC alloc] init];
    viewCtrl.jobId = self.jobId;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

/** 全选按钮 */
- (void)btnSelectAllOnclick:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    for (NSArray* array in _allSortJKResumeArray) {
        for (ResumeListModel* model in array){
            model.isSelect = sender.selected;
        }
    }
    [self.tableView reloadData];
    [self psCell_allMoneyWithSelect];
}

/*!< 获取是否有添加发放对象 */
- (BOOL)getIsHaveAddPayJianke{
    if (_addJiankeArray.count > 0) {
        return YES;
    }
    return NO;
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
