//
//  CheckDetailForCD_VC.m
//  jianke
//
//  Created by xiaomk on 16/4/23.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "CheckDetailForCD_VC.h"
#import "JobBillModel.h"
#import "CheckDetailCell1.h"
#import "CheckDetailCell2.h"
#import "CheckDetailCell4.h"
#import "CheckDetailCell5.h"

@interface CheckDetailForCD_VC (){
    BOOL _isEidting;
    NSMutableArray* _sectionArray;
    BOOL _isSendYet;
}

@property (nonatomic, strong) JobBillModel* jbModel;
@property (nonatomic, strong) NSMutableArray *payListArray;
@property (nonatomic, strong) NSMutableArray *leaderArray;

//@property (nonatomic, strong) UIView* viewDianziBtnBg;
@property (nonatomic, strong) UIButton* btnDianzi;
@property (nonatomic, strong) UIButton* btnSendCheck;

@property (nonatomic, strong) UIBarButtonItem* btnEidtMoney;

@end

@implementation CheckDetailForCD_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账单详情";
    self.tableViewStyle = UITableViewStyleGrouped;
    [self setUIHaveBottomView];
    
    
    self.btnEidtMoney = [[UIBarButtonItem alloc] initWithTitle:@"修改" style:UIBarButtonItemStyleDone target:self action:@selector(btnEidtMoneyOnClick:)];
    self.navigationItem.rightBarButtonItem = self.btnEidtMoney;
    
//    self.viewDianziBtnBg = [[UIView alloc] init];
//    self.viewDianziBtnBg.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:self.viewDianziBtnBg];
    
    self.btnDianzi = [UIButton  buttonWithType:UIButtonTypeCustom];
    [self.btnDianzi setTitleColor:[UIColor XSJColor_base] forState:UIControlStateNormal];
    [self.btnDianzi setBackgroundColor:[UIColor whiteColor]];
    self.btnDianzi.titleLabel.font = HHFontSys(kFontSize_3);
    [self.btnDianzi addTarget:self action:@selector(btnDianziOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnDianzi];
    self.btnDianzi.hidden = YES;
    
    self.btnSendCheck = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnSendCheck setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnSendCheck setBackgroundColor:[UIColor XSJColor_base]];
    self.btnSendCheck.titleLabel.font = HHFontSys(kFontSize_3);
    [self.btnSendCheck addTarget:self action:@selector(btnSendCheckOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.btnSendCheck];
    self.btnSendCheck.hidden = YES;

    WEAKSELF
//    [self.viewDianziBtnBg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(weakSelf.bottomView);
//    }];
    [self.btnDianzi mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(weakSelf.bottomView);
        make.right.equalTo(weakSelf.btnSendCheck.mas_left);
    }];
    [self.btnSendCheck mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.bottom.equalTo(weakSelf.bottomView);
        make.left.equalTo(weakSelf.btnDianzi.mas_right);
        make.width.equalTo(weakSelf.btnDianzi.mas_width);
    }];
    
    
    _isEidting = NO;
    _payListArray = [[NSMutableArray alloc] init];
    _leaderArray = [[NSMutableArray alloc] init];
    _sectionArray = [[NSMutableArray alloc] init];
    
    [self loadDataSource];
}

- (void)loadDataSource{
    NSString *content = [NSString stringWithFormat:@"job_bill_id:%@",self.jobBillId];
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_queryJobBillDetail" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (response && response.success) {
            _jbModel = [JobBillModel objectWithKeyValues:response.content[@"job_bill"]];
            if (_jbModel.stu_pay_list && _jbModel.stu_pay_list.count > 0) {
                NSArray* ary1 = [PayListModel objectArrayWithKeyValuesArray:_jbModel.stu_pay_list];
                _payListArray = [NSMutableArray arrayWithArray:ary1];
            }
            
            if (_jbModel.leader_pay_list && _jbModel.leader_pay_list.count > 0) {
                NSArray *ary2 = [PayListModel objectArrayWithKeyValuesArray:_jbModel.leader_pay_list];
                _leaderArray = [NSMutableArray arrayWithArray:ary2];
                // 设置领队标识
                [weakSelf setPayListArrayLeaderTag];
            }
        }
        [weakSelf initBtnView];
        [weakSelf initSectionArray];
    }];
}

/** 设置领队标识 */
- (void)setPayListArrayLeaderTag{
    for (PayListModel *pmodel in _payListArray) {
        for (PayListModel *lModel in _leaderArray) {
            lModel.isLeader = YES;
            if (pmodel.stu_account_id.integerValue == lModel.stu_account_id.integerValue) {
                pmodel.isLeader = YES;
            }
        }
    }
}

- (void)initBtnView{
//    is_apply_mat;   /*!< '是否申请垫资 0未申请 1已申请' */
//    mat_apply_status;   /*!< 垫资申请状态:1待雇主确认 2审核中 3已驳回 4已垫资 5已还款' */
    
    if (self.jbModel.is_apply_mat.integerValue == 1 ) { //垫资
        _isSendYet = YES;
        self.btnEidtMoney.enabled = NO;
        
        self.btnBottom.hidden = NO;
        self.btnBottom.enabled = NO;
        
        if (self.jbModel.mat_apply_status.integerValue == 1) {
            [self.btnBottom setTitle:@"待雇主确认垫资" forState:UIControlStateNormal];
        }else if (self.jbModel.mat_apply_status.integerValue == 2) {
            [self.btnBottom setTitle:@"垫资申请中" forState:UIControlStateNormal];
        }else if (self.jbModel.mat_apply_status.integerValue == 4) {
            [self.btnBottom setTitle:@"已垫资" forState:UIControlStateNormal];
        }else if (self.jbModel.mat_apply_status.integerValue == 5) {
            [self.btnBottom setTitle:@"已还款" forState:UIControlStateNormal];
        }
        //        else if (self.jbModel.mat_apply_status.integerValue == 3) {
        //            [self.btnBottom setTitle:@"已驳回" forState:UIControlStateNormal];
        //        }
    }else{  //未垫资
        if (self.jbModel.bill_status.integerValue == 1) {  //未发送
            self.btnEidtMoney.enabled = YES;
            self.btnBottom.enabled = YES;
            if (_isSendYet) {       //修改后 强制改 的 未发送
                self.btnBottom.hidden = NO;
                [self.btnBottom setTitle:@"发送账单" forState:UIControlStateNormal];
            }else{
                if (self.jbModel.is_apply_mat.integerValue == 0 ) {     //初始未发送
                    self.btnBottom.hidden = YES;
                    [self.btnDianzi setTitle:@"申请垫资" forState:UIControlStateNormal];
                    [self.btnSendCheck setTitle:@"发送账单" forState:UIControlStateNormal];
                }
            }
        }else if (self.jbModel.bill_status.integerValue == 2){ //已发送
            _isSendYet = YES;
            self.btnEidtMoney.enabled = YES;
            self.btnBottom.hidden = NO;
            self.btnBottom.enabled = NO;
            [self.btnBottom setTitle:@"已发送" forState:UIControlStateNormal];
        }else if (self.jbModel.bill_status.integerValue == 3){ //已支付
            self.btnEidtMoney.enabled = NO;
            self.btnBottom.hidden = NO;
            self.btnBottom.enabled = NO;
            [self.btnBottom setTitle:@"已支付" forState:UIControlStateNormal];
        }
    }
    self.btnDianzi.hidden = !self.btnBottom.hidden;
    self.btnSendCheck.hidden = !self.btnBottom.hidden;
}

- (void)initSectionArray{
    [_sectionArray addObject:@(CheckDetailCellType_title)];
    if (_leaderArray && _leaderArray.count > 0) {
        [_sectionArray addObject:@(CheckDetailCellType_leader)];
    }
    [_sectionArray addObject:@(CheckDetailCellType_salaryInfo)];
    [_sectionArray addObject:@(CheckDetailCellType_cdJKList)];
    [self.tableView reloadData];
}

#pragma mark - ***** 按钮事件 ******

/** 垫资申请 */
- (void)btnDianziOnclick:(UIButton*)sender{
    [TalkingData trackEvent:@"账单详情_申请垫资"];

    UIDatePicker *datepicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, 300, 180)];
    [datepicker setDatePickerMode:UIDatePickerModeDate];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置 为中文
    datepicker.locale = locale;
    datepicker.timeZone = [NSTimeZone timeZoneWithName:@"Asia/beijing"];
    
    // 设置时间限制
    NSDate *minDate = [DateHelper zeroTimeOfToday];
    [datepicker setMinimumDate:minDate];
    [datepicker setDate:[DateHelper zeroTimeOfToday]];
    WEAKSELF
    [XSJUIHelper showConfirmWithView:datepicker msg:nil title:@"选择时间" cancelBtnTitle:@"取消" okBtnTitle:@"确定" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            NSDate* selectDate = datepicker.date;
            NSNumber* date = @(selectDate.timeIntervalSince1970*1000);
            
            ApplyMatModel* model = [[ApplyMatModel alloc] init];
            model.job_bill_id = self.jbModel.job_bill_id.stringValue;
            model.expected_repayment_date = date.stringValue;
            NSString* content = [model getContent];
            
            RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_applyMat" andContent:content];
            [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
                if (response && [response success]) {
                    [UIHelper toast:@"垫资申请成功"];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }];
}

/** 发送账单 */
- (void)btnSendCheckOnclick:(UIButton*)sender{
    [self sendCheck];
}
- (void)btnBottomOnclick:(UIButton *)sender{
    if (self.jbModel.bill_status.integerValue == 1 && self.jbModel.is_apply_mat.integerValue != 1) {
        [self sendCheck];
    }
}

- (void)sendCheck{
    NSString *content = [NSString stringWithFormat:@"job_bill_id:%@",_jbModel.job_bill_id];
    NSString *service = @"shijianke_sendJobBillToEnt";
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc]initWithService:service andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (response && response.success) {
            [UIHelper toast:@"发送成功"];
            weakSelf.jbModel.bill_status = @(2);   //已发送 后修改
            [weakSelf initBtnView];
        }else{
            [UIHelper toast:@"发送失败"];
        }
    }];
}


/** 修改 保存 账单 */
- (void)btnEidtMoneyOnClick:(UIBarButtonItem*)sender{
    _isEidting = !_isEidting;
    
    self.btnSendCheck.enabled = !_isEidting;
    self.btnDianzi.enabled = !_isEidting;
    self.btnBottom.enabled = !_isEidting;
    
    if (_isEidting) {
        [sender setTitle:@"保存"];
        [self.tableView reloadData];
    }else{
        [sender setTitle:@"修改"];
        NSInteger jkSalaryAll = 0;
        NSInteger epPayAll = 0;
        for (PayListModel* model in _payListArray) {
            jkSalaryAll += model.salary.integerValue;
            epPayAll += model.ent_publish_price.integerValue;
        }
        self.jbModel.salary_amount = @(jkSalaryAll);
        self.jbModel.total_amount = @(epPayAll);
        
        NSMutableArray *tempStuArray = [[NSMutableArray alloc]init];
        for (PayListModel *plModel in _payListArray) {
            UpdateStuJobBillPM *info = [[UpdateStuJobBillPM alloc] init];
            info.stu_account_id = plModel.stu_account_id.stringValue;
            info.salary = plModel.salary.stringValue;
            info.ent_publish_price = plModel.ent_publish_price.stringValue;
            [tempStuArray addObject:info];
        }
        
        NSMutableArray *tempLeaderArray = [[NSMutableArray alloc]init];
        if (_leaderArray && _leaderArray.count > 0) {
            for (PayListModel *plModel in _leaderArray) {
                UpdateStuJobBillPM *info = [[UpdateStuJobBillPM alloc]init];
                info.stu_account_id = plModel.stu_account_id.stringValue;
                info.salary = plModel.salary.stringValue;
                [tempLeaderArray addObject:info];
            }
        }
        
        NSArray *value1 = [UpdateStuJobBillPM keyValuesArrayWithObjectArray:tempStuArray];
        NSArray *value2 = [UpdateStuJobBillPM keyValuesArrayWithObjectArray:tempLeaderArray];
        
        NSString *jsonString1 = [value1 jsonStringWithPrettyPrint:YES];
        NSString *jsonString2 = [value2 jsonStringWithPrettyPrint:YES];
        
        if (jsonString1.length > 0) {
            jsonString1 = [jsonString1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
            jsonString1 = [jsonString1 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            jsonString1 = [jsonString1 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            jsonString1 = [jsonString1 stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
       
        if (jsonString2.length > 0) {
            jsonString2 = [jsonString2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
            jsonString2 = [jsonString2 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            jsonString2 = [jsonString2 stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            jsonString2 = [jsonString2 stringByReplacingOccurrencesOfString:@" " withString:@""];
        }

        
        UpdateJobBillModel *model = [[UpdateJobBillModel alloc]init];
        model.job_bill_id = [NSString stringWithFormat:@"%@",_jbModel.job_bill_id];
//        model.service_fee = [NSString stringWithFormat:@"%@",_jbModel.service_fee];
        model.stu_pay_list = jsonString1;
        model.leader_pay_list = jsonString2;
        
        NSString *content = [model getContent];
        WEAKSELF
        RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_updateJobBill" andContent:content];
        [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
            if (response && response.success) {
                [UIHelper toast:@"修改成功"];
                weakSelf.jbModel.bill_status = @(1);    //修改后 将 发送转态改为 未发送
                [weakSelf initBtnView];
                [weakSelf.tableView reloadData];
            }
        }];
    }
}




#pragma mark - ***** UITableView delegate ******
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* cellIdentifier = [NSString stringWithFormat:@"CheckDetailCell_%ld",(long)indexPath.section];
    CheckDetailCellType sectionType = [[_sectionArray objectAtIndex:indexPath.section] integerValue];
    
    if (sectionType == CheckDetailCellType_title) {
        CheckDetailCell1* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [CheckDetailCell1 new];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell refreshWithData:self.jbModel andIndexPath:indexPath];

        return cell;
    }else if (sectionType == CheckDetailCellType_leader){
        CheckDetailCell4* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [CheckDetailCell4 new];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.isEditing = _isEidting;

        PayListModel* model = [_leaderArray objectAtIndex:indexPath.row];
        [cell refreshWithData:model andIndexPath:indexPath];
    
        return cell;
    }else if (sectionType == CheckDetailCellType_salaryInfo){
        CheckDetailCell2* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [CheckDetailCell2 new];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell CD_refreshWithData:_jbModel];
        return cell;
    }else if (sectionType == CheckDetailCellType_cdJKList){
        CheckDetailCell5* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [CheckDetailCell5 new];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.isEditing = _isEidting;
        if (_leaderArray.count) {
            
        }
        PayListModel* model = [_payListArray objectAtIndex:indexPath.row];
        [cell refreshWithData:model andIndexPath:indexPath];
    
        return cell;
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    CheckDetailCellType sectionType = [[_sectionArray objectAtIndex:section] integerValue];
    switch (sectionType) {
        case CheckDetailCellType_title:
        case CheckDetailCellType_salaryInfo:
            return 1;
        case CheckDetailCellType_leader:
            return _leaderArray.count ? _leaderArray.count : 0;
        case CheckDetailCellType_cdJKList:
            return _payListArray.count ? _payListArray.count : 0;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CheckDetailCellType sectionType = [[_sectionArray objectAtIndex:indexPath.section] integerValue];
    switch (sectionType) {
        case CheckDetailCellType_title:
            return 66;
        case CheckDetailCellType_leader:
            return 66;
        case CheckDetailCellType_salaryInfo:
            return 88;
        case CheckDetailCellType_cdJKList:
            return 80;
        default:
            return 0;
            break;
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    CheckDetailCellType sectionType = [[_sectionArray objectAtIndex:section] integerValue];
    switch (sectionType) {
        case CheckDetailCellType_cdJKList:{
            UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 26)];
            view.backgroundColor = [UIColor XSJColor_grayTinge];
            
            UILabel *lab1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 1, 100, 24)];
            lab1.text = @"兼客详情";
            lab1.font = HHFontSys(kFontSize_2);
            lab1.textColor = [UIColor XSJColor_tGray];
            [view addSubview:lab1];
            
            UILabel* lab2 = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-216, 1, 200, 24)];
            lab2.text = @"兼客工资/雇主支付";
            lab2.font = HHFontSys(kFontSize_2);
            lab2.textColor = [UIColor XSJColor_tGray];
            lab2.textAlignment = NSTextAlignmentRight;
            [view addSubview:lab2];
            return view;
        }
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CheckDetailCellType sectionType = [[_sectionArray objectAtIndex:section] integerValue];
    switch (sectionType) {
        case CheckDetailCellType_title:
            return 0.1;
        case CheckDetailCellType_leader:
            return 8;
        case CheckDetailCellType_salaryInfo:
            return 8;
        case CheckDetailCellType_cdJKList:
            return 26;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _sectionArray.count ? _sectionArray.count : 0;
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


@implementation ApplyMatModel
@end