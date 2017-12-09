//
//  PaySelect_VC.m
//
//
//  Created by xiaomk on 15/10/9.
//
//

#import "PaySelect_VC.h"
#import "UIHelper.h"
#import "WDConst.h"
#import "WeChatRechargeModel.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "MoneyBag_VC.h"
#import "JobModel.h"
#import "PaySalaryModel.h"
#import "JobBillDetail_VC.h"
#import "QueryAccountMoneyModel.h"
#import "BuyInsuranceModel.h"
#import "InsuranceDetail_VC.h"
#import "MoneyBagPasswordManager.h"
#import "PaySelectCell.h"
#import "ForgotPassword_VC.h"
#import "PayWebView_VC.h"
#import "JobVasOrder_VC.h"

//#import "ParamModel.h"

@interface PaySelect_VC () <UITextFieldDelegate> {
    WDPayType _selectPayType;           /*!< 支付方式 */
    WeChatRechargeModel* _wxRechModel;  /*!< 微信 数据模型 */
    AlipayRechargeModel* _alipayRechModel;  /*!< alipay 数据模型 */
    PinganPayModel *_pinganPayModel;
    JKModel *_jkModel;                  /*!< 兼客模型 */
    ResumeListModel *_rlModel;          /*!< 简历模型 */
    NSMutableArray *_payTypeArray;
}
@property (nonatomic, strong) QueryAccountMoneyModel* moneyModel;   /*!< 钱袋子数据 */
@property (nonatomic, strong) NSMutableArray* insuranceArray;
@property (nonatomic, copy) NSNumber * accountMoneyDetailListId; /*!< 保险 流水ID */

@property (nonatomic, weak) UITextField *tfMoney;

@end

@implementation PaySelect_VC

#pragma mark - ***** viewDidLoad ******
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"支付";
    if (self.fromType == PaySelectFromType_inviteBalance && self.fromType == PaySelectFromType_partnerPostJob) {
        self.title = @"转入";
    }
    
    [WDNotificationCenter addObserver:self selector:@selector(wecharPayResponseInfo:) name:WXPayGetCodeNotification object:nil];

    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:@"忘记钱袋子密码" style:UIBarButtonItemStylePlain target:self action:@selector(forgetPwd)];
    self.navigationItem.rightBarButtonItem = rightItem;
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:15],NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    
    self.tableViewStyle = UITableViewStyleGrouped;
    [self setUIHaveBottomView];
    [self.btnBottom setTitle:@"确认支付" forState:UIControlStateNormal];
    
    _selectPayType = WDPayType_None;

    WEAKSELF
    [[MoneyBagPasswordManager sharedInstance] setPasswordSuccess:^(MoneyBagInfoModel* model) {
        if (model) {
            weakSelf.moneyModel = model.account_money_info;
            [weakSelf initSelectPayType];
        }else{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)initSelectPayType{
    if (self.moneyModel.available_amount.intValue >= self.needPayMoney) {
        _selectPayType = WDPayType_MoneyBag;
    }else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
        _selectPayType = WDPayType_WeChat;
    }else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]]) {
        _selectPayType = WDPayType_AliPay;
    }
    
    _payTypeArray = [[NSMutableArray alloc] init];
    [_payTypeArray addObject:@(WDPayType_MoneyBag)];
    [_payTypeArray addObject:@(WDPayType_WeChat)];
    [_payTypeArray addObject:@(WDPayType_AliPay)];
    [_payTypeArray addObject:@(WDPayType_Bank)];
    [self.tableView reloadData];
}

#pragma mark - ***** UITableView delegate ******
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        static NSString* cellIdentifier = @"PaySelectCell0";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.imageView.image = [UIImage imageNamed:@"v250_cellphoneMoney"];
            
            UITextField *tfMoney = [[UITextField alloc] init];
            tfMoney.tag = 100;
            tfMoney.delegate = self;
            tfMoney.font = [UIFont fontWithName:kFont_RSR size:kFontSize_4];
            tfMoney.textColor = [UIColor XSJColor_tRed];
            tfMoney.placeholder = @"请输入金额";
            tfMoney.returnKeyType = UIReturnKeyDone;
            tfMoney.keyboardType = UIKeyboardTypeDecimalPad;
            [tfMoney addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
            [cell.contentView addSubview:tfMoney];
            [tfMoney mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.right.equalTo(cell.contentView);
                make.left.equalTo(@66);
            }];
            self.tfMoney = tfMoney;
        }
        if (self.fromType == PaySelectFromType_inviteBalance) {
            self.tfMoney.enabled = YES;
        }else{
            self.tfMoney.text = [NSString stringWithFormat:@"%.2f 元", self.needPayMoney/100.0];
            self.tfMoney.enabled = NO;
        }
        return cell;
        
    }else if (indexPath.section == 1){
        WDPayType payType = [_payTypeArray[indexPath.row] integerValue];
        
        static NSString* cellIdentifier = @"PaySelectCell1";
        PaySelectCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [PaySelectCell new];
        }

        cell.balanceView.hidden = YES;
        if (payType == WDPayType_MoneyBag) {
            cell.balanceView.hidden = NO;
            cell.labTitle.hidden = YES;
            cell.labSubTitle.hidden = YES;
            
            cell.payType = WDPayType_MoneyBag;
            cell.imgIcon.image = [UIImage imageNamed:@"pay_icon_logo"];
            cell.labMoney.text = [NSString stringWithFormat:@"￥%0.2f",(float)self.moneyModel.available_amount.intValue/100];
        }else if (payType == WDPayType_WeChat){
            cell.imgIcon.image = [UIImage imageNamed:@"logo_wechat"];
            cell.labTitle.text = @"微信支付";
            cell.labSubTitle.text = @"推荐安装微信5.0及以上版本的使用";
            cell.payType = WDPayType_WeChat;
        }else if (payType == WDPayType_Bank){
            cell.imgIcon.image = [UIImage imageNamed:@"pay_icon_bank"];
            cell.labTitle.text = @"银行卡";
            cell.labSubTitle.text = @"到账需24小时";
            cell.payType = WDPayType_Bank;
        }else if (payType == WDPayType_AliPay){
            cell.imgIcon.image = [UIImage imageNamed:@"logo_zhifubao"];
            cell.labTitle.text = @"支付宝支付";
            cell.labSubTitle.text = @"推荐有支付宝账号的用户使用";
            cell.payType = WDPayType_AliPay;
        }
        cell.btnSelect.selected = _selectPayType == cell.payType;
        return cell;
    }
    
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 56;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }else if (section == 1){
        return _payTypeArray.count ? _payTypeArray.count : 0;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 16;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    WDPayType payType = [_payTypeArray[indexPath.row] integerValue];

    if (indexPath.section == 1) {
        if (payType == WDPayType_MoneyBag) {   /*!< 钱袋子 */
            if (self.moneyModel.available_amount.intValue < self.needPayMoney) {
                [UIHelper toast:@"你的余额不足，请选择其他方式支付"];
                return;
            }else{
                _selectPayType = WDPayType_MoneyBag;
            }
        }else if (payType == WDPayType_WeChat){  //微信
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]]) {
                _selectPayType = WDPayType_WeChat;
            }else{
                [UIHelper toast:@"你没有安装微信"];
                return;
            }
        }else if (payType == WDPayType_Bank){  //银行
            _selectPayType = WDPayType_Bank;
        }else if (payType == WDPayType_AliPay){  //支付宝
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipay://"]]) {
                _selectPayType = WDPayType_AliPay;
            }else{
                [UIHelper toast:@"你没有安装支付宝"];
                return;
            }
        }
        [self.tableView reloadData];
    }
}

#pragma mark - ***** 按钮事件 支付******
/** 忘记钱袋子密码 */
- (void)forgetPwd{
    ForgotPassword_VC* vc = [UIHelper getVCFromStoryboard:@"Main" identify:@"sid_forgotPwd"];
    vc.pwdAccountType = PwdAccountType_MoneyBag;
    [self.navigationController pushViewController:vc animated:YES];
}

///** 点击支付 */
- (void)btnBottomOnclick:(UIButton *)sender{
    
    if (_selectPayType == WDPayType_None) {
        [UIHelper toast:@"请选择支付类型"];
        return;
    }
    
    if (self.fromType == PaySelectFromType_inviteBalance) {
        if (self.tfMoney.text.length == 0) {
            [UIHelper toast:@"转入余额不能为空"];
            return;
        }
        if (self.tfMoney.text.floatValue <= 0) {
            [UIHelper toast:@"转入余额必须大于0"];
            return;
        }
    }
    
    if (_selectPayType == WDPayType_MoneyBag) {
        WEAKSELF
       [[MoneyBagPasswordManager sharedInstance] showCommitPassword:^(NSString* password) {
           if (password) {
               [weakSelf sendPayRequestWithPassword:password];
           }
       }];
    }else{
        [self sendPayRequestWithPassword:nil];
    }
}

- (NSNumber*)getPayChannel{
    if (_selectPayType == WDPayType_MoneyBag) {
        return @(1);
    }else if (_selectPayType == WDPayType_AliPay){
        return @(2);
    }else if (_selectPayType == WDPayType_WeChat){
        return @(3);
    }else if (_selectPayType == WDPayType_Bank){
        return @(5);
    }
    return nil;
}

#pragma mark - ***** 支付 ******
- (void)sendPayRequestWithPassword:(NSString*)password{
    NSNumber* payChannel = [self getPayChannel];
    if (payChannel == nil) {
        [UIHelper toast:@"请选择支付方式"];
        return;
    }
    
    PayJobInfoModel* payModel = [[PayJobInfoModel alloc] init];
    payModel.job_id = self.jobId;
    payModel.pay_channel = payChannel;

    if (_selectPayType == WDPayType_MoneyBag && password.length > 0) {
        NSString* pwdEncrypt = [[[NSString stringWithFormat:@"%@%@", password, [XSJNetWork getChallenge]] MD5] uppercaseString];
        payModel.acct_encpt_password = pwdEncrypt;
    }
    
    NSString* time = [NSString stringWithFormat:@"%lld",(long long)[DateHelper getTimeStamp]];
    payModel.client_time_millseconds = time;
    
    if (self.fromType == PaySelectFromType_epPay){ //雇主直接支付
        [self payForEPToJKWith:payModel];
    }else if (self.fromType == PaySelectFromType_jobBill) {    //支付账单
        [self payForBillWith:payModel];
    }else if (self.fromType == PaySelectFromType_insurance){ //保险支付
        [self payForInsuranceWith:payModel];
    }else if (self.fromType == PaySelectFromType_inviteBalance || self.fromType == PaySelectFromType_partnerPostJob){ //ep个人中心 余额
        [self payForInviteBalance:payModel];
    }else if (self.fromType == PaySelectFromType_JobVasOrder){  //岗位增值服务(置顶/刷新/推送)
        [self payForJobVasOrder:payModel];
    }
}

#pragma mark - ***** PaySelectFromType  支付类型：账单，保险，直接支付给兼客,岗位余额，合伙人发布  ******
/** 账单支付 */
- (void)payForBillWith:(PayJobInfoModel *)payModel{
    payModel.job_bill_id = self.job_bill_id;
    NSString *content = [payModel getContent];
    
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_payJobBill290" andContent:content];
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (response && response.success) {
            [weakSelf payEventWithResponse:response];
        }
    }];
}

/** 保险支付 */
- (void)payForInsuranceWith:(PayJobInfoModel *)payModel{
    self.insuranceArray = [[NSMutableArray alloc]init];
    if (self.isAccurateJob.intValue == 1) {//精确岗位保险
        for (ResumeLModel *rModel in self.arrayData) {
            if (rModel.isSelect) {
                InsuranceDataListModel* idlModel = [[InsuranceDataListModel alloc] init];
                NSNumber *number;
                
                idlModel.apply_job_id = rModel.apply_job_id;
                NSMutableArray *tempArray = [[NSMutableArray alloc]init];
                
                for (NSDate *date  in rModel.onBoardDate) {
                    long long tempNum = date.timeIntervalSince1970 *1000;
                    number = [NSNumber numberWithLongLong:tempNum];
                    [tempArray addObject:number];
                }
                idlModel.insurance_date_list = [[NSArray alloc] initWithArray:tempArray];
                
                NSMutableArray *tempArr = [NSMutableArray array];
                
                [tempArr addObject:idlModel];
                
                if (rModel.onBoardDate.count == 0) {
                    [tempArr removeObject:idlModel];
                }
                [self.insuranceArray addObjectsFromArray:tempArr];
            }
        }
    }else{//松散岗位保险
        for (ResumeLModel *model in self.arrayData) {
            if (model.isSelect) {
                
                InsuranceDataListModel *idlModel = [[InsuranceDataListModel alloc]init];
                idlModel.apply_job_id = model.apply_job_id;
                NSMutableArray *tempArr = [[NSMutableArray alloc]init];
                
                for (InsurancePolicyModel *ipModel in model.ping_an_insurance_policy_list) {
                    if (ipModel.buy_status.intValue == 3) {
                        [tempArr addObject:ipModel.ping_an_insurance_policy_time];
                    }
                }
                idlModel.insurance_date_list = [[NSArray alloc]initWithArray:tempArr];
                [self.insuranceArray addObject:idlModel];
            }
        }
    }
    
    payModel.insurance_policy_list = [[NSArray alloc] initWithArray:self.insuranceArray];
    
    NSString* content = [payModel getContent];
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_entPayInsurancePolicyForStu290" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (response && response.success) {
            if (response.content[@"account_money_detail_list_id"]) {
                _accountMoneyDetailListId = response.content[@"account_money_detail_list_id"];
            }
            [weakSelf payEventWithResponse:response];
        }
    }];
}

/** 直接支付 */
- (void)payForEPToJKWith:(PayJobInfoModel *)payModel{
    NSMutableArray* payArray = [[NSMutableArray alloc] init];
    NSMutableArray* addJKArray = [[NSMutableArray alloc] init];

    if (self.isAccurateJob.intValue == 1) { //精确岗位
        for (ResumeListModel *rlModel in self.arrayData) {
            if (rlModel.isSelect && rlModel.nowPaySalary > 0) {
                if (rlModel.resume_info.isFromPayAdd) {
                    AddPaymentModel *info = [[AddPaymentModel alloc] init];
                    info.telphone = rlModel.resume_info.telphone;
                    info.true_name = rlModel.resume_info.true_name;
                    info.salary_num = @(rlModel.nowPaySalary);
                    info.add_date = self.on_board_time;
                    [addJKArray addObject:info];
                }else{
                    PaymentPM* info = [[PaymentPM alloc]init];
                    info.apply_job_id = rlModel.apply_job_id;
                    info.salary_num = [NSNumber numberWithInteger:rlModel.nowPaySalary];
                    info.on_board_date = rlModel.onBoardDate;
                    [payArray addObject:info];
                }
            }
        }
    }else{
        for (JKModel* jkModel in self.arrayData) {
            if (jkModel.isSelect && jkModel.salary_num.integerValue > 0) {
                if (jkModel.isFromPayAdd) {
                    AddPaymentModel *info = [[AddPaymentModel alloc] init];
                    info.telphone = jkModel.telphone;
                    info.true_name = jkModel.true_name;
                    info.salary_num = jkModel.salary_num;
                    [addJKArray addObject:info];
                }else{
                    PaymentPM* info = [[PaymentPM alloc] init];
                    info.apply_job_id = jkModel.apply_job_id;
                    info.salary_num = jkModel.salary_num;
                    [payArray addObject:info];
                }
            }
        }
    }
    
    NSArray* value = [PaymentPM keyValuesArrayWithObjectArray:payArray];
    NSString* jsonString = [value mk_jsonStringWithPrettyPrint:YES];
    
    NSString *addJsonString = nil;
    if (addJKArray.count > 0) {
        NSArray *addValue = [AddPaymentModel keyValuesArrayWithObjectArray:addJKArray];
        addJsonString = [addValue mk_jsonStringWithPrettyPrint:YES];
    }
//    ELog(@"====jsonString:%@",jsonString);
    
    //        jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    //        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    //        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //        jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    //        ELog(@"====jsonString:%@",jsonString);
//    if (payModel.acct_encpt_password) {
//        signStr = [NSString stringWithFormat:@"%@%@%@",jsonString,payModel.acct_encpt_password,payModel.client_time_millseconds];
//    }else{
//        signStr = [NSString stringWithFormat:@"%@%@",jsonString,payModel.client_time_millseconds];
//    }
    NSString *signStr = [NSString stringWithString:jsonString];
    if (addJsonString) {
        signStr = [signStr stringByAppendingString:addJsonString];
    }
    if (payModel.acct_encpt_password) {
        signStr = [signStr stringByAppendingString:payModel.acct_encpt_password];
    }
    signStr = [signStr stringByAppendingString:payModel.client_time_millseconds];

    
//    ELog(@"====signStr:%@",signStr);
    NSString* signStrMd5 = [[signStr MD5] uppercaseString];
//    ELog(@"====signStrMd5:%@",signStrMd5);
    
    payModel.payment_list = [NSArray arrayWithArray:payArray];
    if (addJKArray.count > 0) {
        payModel.add_payment_list = [NSArray arrayWithArray:addJKArray];
    }
    payModel.client_sign = signStrMd5;
    
    NSString* content = [payModel getContent];
    DLog(@"_______________++++%@",self.jobId);
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_entPayforStu290" andContent:content];
    request.isShowLoading = YES;
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            [weakSelf payEventWithResponse:response];
        }
    }];
}


/** 转入招聘余额 */
- (void)payForInviteBalance:(PayJobInfoModel *)payModel{
    payModel.recharge_amount = @(ceil(self.tfMoney.text.floatValue*100));
    WEAKSELF
    [[XSJRequestHelper sharedInstance] rechargeRecruitmentAmount:payModel block:^(ResponseInfo *result) {
        [weakSelf payEventWithResponse:result];
    }];
}

/** 增值服务(置顶/刷新/推送) */
- (void)payForJobVasOrder:(PayJobInfoModel *)payModel{
    payModel.recharge_amount = @(ceil(self.tfMoney.text.floatValue*100));
    payModel.job_vas_order_id = self.job_vas_order_id;
    WEAKSELF
    [[XSJRequestHelper sharedInstance] payJobVasOrder:payModel block:^(ResponseInfo *result) {
        [weakSelf payEventWithResponse:result];
    }];
}

/** 根据支付类型操作 */
- (void)payEventWithResponse:(ResponseInfo*)response{
    if (_selectPayType == WDPayType_MoneyBag) {
        [self paySuccessJumpTo];
    }else if (_selectPayType == WDPayType_WeChat){
        _wxRechModel = [WeChatRechargeModel objectWithKeyValues:response.content];
        [self showWeixinPay];
    }else if (_selectPayType == WDPayType_AliPay){
        _alipayRechModel = [AlipayRechargeModel objectWithKeyValues:response.content];
        [self showAlipay];
    }else if (_selectPayType == WDPayType_Bank){
        _pinganPayModel = [PinganPayModel objectWithKeyValues:response.content];
        
        PayWebView_VC *vc = [[PayWebView_VC alloc] init];
        vc.url = [NSString stringWithFormat:@"%@%@%@",URL_HttpServer,kUrl_pinganPay, _pinganPayModel.ping_an_pay_form_token];
        if (self.fromType == PaySelectFromType_partnerPostJob) {
            WEAKSELF
            vc.block = ^(id obj){
                [weakSelf paySuccessJumpTo];
            };
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/** 支付成功跳转 */
- (void)paySuccessJumpTo{
    if(self.fromType == PaySelectFromType_epPay){                   // 雇主直接支付
        MoneyBag_VC *viewCtrl = [UIHelper getVCFromStoryboard:@"JK" identify:@"sid_moneybag"];
        viewCtrl.isFromPay = YES;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }else if (self.fromType == PaySelectFromType_jobBill) {         //支付账单
        JobBillDetail_VC *vc = [[JobBillDetail_VC alloc]init];
        vc.job_id = self.jobId;
        vc.isFromPay = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(self.fromType == PaySelectFromType_insurance){         //支付保险
        InsuranceDetail_VC *vc = [[InsuranceDetail_VC alloc]init];
        vc.account_money_detail_list_id = _accountMoneyDetailListId.stringValue;
        vc.isFromMoneyBag = NO;
        [self.navigationController pushViewController:vc animated:YES];
    }else if(self.fromType == PaySelectFromType_inviteBalance){     //招聘余额转入
        [UIHelper toast:@"转入成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.fromType == PaySelectFromType_partnerPostJob){
        [UIHelper toast:@"转入成功"];
        MKBlockExec(self.partnerPostJobPayBlock, @(1));
        [self.navigationController popViewControllerAnimated:YES];
    }else if (self.fromType == PaySelectFromType_JobVasOrder){
        MoneyBag_VC *viewCtrl = [UIHelper getVCFromStoryboard:@"JK" identify:@"sid_moneybag"];
        viewCtrl.isFromPay = YES;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
}

#pragma mark - ***** 第三方支付 ******
#pragma mark - ***** 平安付 ******
- (void)pingAnPay{
    
}
#pragma mark - ***** 微信支付 ******
- (void)showWeixinPay{
    NSString* nonceStr = [XSJUserInfoData createRandom32UppStr];
    ELog("==nonceStr:%@",nonceStr);
    
    NSString* package = @"Sign=WXPay";
    
    UInt32 timeStampInt = [DateHelper getTimeStamp4Second];
    NSString* timeStamp = [NSString stringWithFormat:@"%d",(unsigned int)timeStampInt];
    ELog(@"timeStamp=%@",timeStamp);
    
    PayReq* request = [[PayReq alloc] init];
    request.openID = _wxRechModel.appid;
    request.partnerId = _wxRechModel.mch_id;
    request.prepayId = _wxRechModel.prepay_id;
    request.package = @"Sign=WXPay";
    request.nonceStr = nonceStr;
    request.timeStamp = timeStampInt;
    
    NSMutableDictionary* signParams = [NSMutableDictionary dictionary];
    [signParams setObject:_wxRechModel.appid        forKey:@"appid"];
    [signParams setObject:_wxRechModel.mch_id       forKey:@"partnerid"];
    [signParams setObject:_wxRechModel.prepay_id    forKey:@"prepayid"];
    [signParams setObject:nonceStr                  forKey:@"noncestr"];
    [signParams setObject:package                   forKey:@"package"];
    [signParams setObject:timeStamp                 forKey:@"timestamp"];
    
    NSString* sign = [self createMd5Sign:signParams];
    
    request.sign = sign;
    ELog("====signParams:%@",signParams);
    ELog("====sign:%@",sign);
    [WXApi sendReq:request];
}

- (NSString*)createMd5Sign:(NSMutableDictionary*)dict{
    NSMutableString* contentString = [NSMutableString string];
    NSArray* keys = [dict allKeys];
    NSArray* sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString* categoryId in sortedArray) {
        if (![[dict objectForKey:categoryId] isEqualToString:@""] && ![categoryId isEqualToString:@"sign"] && ![categoryId isEqualToString:@"key"]) {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
    }
    [contentString appendFormat:@"key=%@",_wxRechModel.mch_key];
    //    ELog("====contentString:%@",contentString);
    NSString* md5Sign = [[contentString MD5] uppercaseString];
    return  md5Sign;
}

/** 微信回调 支付成功*/
- (void)wecharPayResponseInfo:(NSNotification *)notification{
    ELog("=======wecharPayResponseInfo");
    [self paySuccessJumpTo];
}


#pragma mark - ***** aliPay ******
- (void)showAlipay{
    ELog(@"=====showAlipay");

    AlipayOredrModel* model = [[AlipayOredrModel alloc] init];
    model.partner = _alipayRechModel.alipay_partner;
    model.seller_id = _alipayRechModel.alipay_account;
    model.out_trade_no = _alipayRechModel.recharge_serail_id;
    model.subject = _alipayRechModel.recharge_title;
    model.body = _alipayRechModel.recharge_title;
    model.total_fee = [NSString stringWithFormat:@"%0.2f", ((float)_alipayRechModel.recharge_amount.intValue)/100];
    model.notify_url = _alipayRechModel.callback_url;
    model.service = @"mobile.securitypay.pay";
    model.payment_type = @"1";
    model._input_charset = @"utf-8";
    model.it_b_pay = @"30m";
    model.show_url = @"m.alipay.com";
    
    NSString* orderSpec = [model description];
    ELog(@"======orderSpec:%@",orderSpec);
    
    id<DataSigner> signer = CreateRSADataSigner(_alipayRechModel.recharge_private_key);
    NSString* signedString = [signer signString:orderSpec];
    
    NSString* orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderSpec,signedString,@"RSA"];
        ELog(@"===========orderString:%@",orderString);
        NSString* fromScheme = @"jiankeapp";
        WEAKSELF
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:fromScheme callback:^(NSDictionary *resultDic) {
            ELog("=========resultDic:%@",resultDic);
            NSString* resultStatus = resultDic[@"resultStatus"];
            if ([resultStatus isEqualToString:@"9000"]) {
                [weakSelf paySuccessJumpTo];
                [UIHelper toast:@"支付成功"];
            }else{
                [UIHelper toast:@"支付失败"];
            }
        }];
    }
}

#pragma mark - UITextField delegate
- (void)textFieldDidChange:(UITextField *)sender{
    NSRange range = [sender.text rangeOfString:@"."];
    if (range.length != 0) { // 有小数点
        if (sender.text.length > 9) {
            sender.text = [sender.text substringToIndex:9];
        }
    } else { // 没有小数点
        if (sender.text.length > 6) {
            sender.text = [sender.text substringToIndex:6];
        }
    }
}


#pragma mark - ***** other ******
- (void)backToLastView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [WDNotificationCenter removeObserver:self];
}

- (void)dealloc{
    [WDNotificationCenter removeObserver:self];

    _wxRechModel = nil;
    _alipayRechModel = nil;
    _jkModel = nil;
    _rlModel = nil;
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

