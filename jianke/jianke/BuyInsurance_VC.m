//
//  BuyInsurance_VC.m
//  jianke
//
//  Created by 时现 on 15/12/9.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "BuyInsurance_VC.h"
#import "BuyInsuranceCell.h"
#import "BuyInsuranceCell_2.h"
#import "WDConst.h"
#import "JKModel.h"
#import "BuyInsuranceModel.h"
#import "PaySelect_VC.h"
#import "WebView_VC.h"

@interface BuyInsurance_VC ()<UITableViewDelegate,UITableViewDataSource,InsuranceDelegate,InsuranceDelegate_2>
{
    NSMutableArray *_arrayData;
    ResumeLModel *_rlModel;
    InsurancePolicyModel *_ipModel;
    BuyInsuranceModel *_biModel;
    
    NSInteger _jobAllDays;          //岗位总天数
    int _allPayMoney;//总薪水
    
    BOOL _isNotAccurate;

}
//@property (weak, nonatomic) IBOutlet UIButton *insuranceDetailBtn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *agreeBtn;//已经阅读
@property (weak, nonatomic) IBOutlet UIButton *insuranceDuty;//保险责任
@property (weak, nonatomic) IBOutlet UIButton *noDutyBtn;//责任免除

@property (nonatomic,strong)NSNumber *insurancePrice;
@property (weak, nonatomic) IBOutlet UIButton *btnConfirm;

//@property (weak, nonatomic) IBOutlet UILabel *insuranceExplain;

@property (nonatomic, strong) NSMutableArray *ArrayTime;

@end

@implementation BuyInsurance_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [WDNotificationCenter addObserver:self selector:@selector(backAction) name:WDNotification_backFromMoneyBag object:nil];
    self.title = @"购买保险";
    _isNotAccurate = NO;

    [self.btnConfirm setTitle:@"确认投保" forState:UIControlStateNormal];
    self.agreeBtn.selected = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    _arrayData = [[NSMutableArray alloc]init];
    
    // 保险说明
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithTitle:@"保险说明" style:UIBarButtonItemStyleDone target:self action:@selector(insuranceDetailOnClick:)];
    self.navigationItem.rightBarButtonItem = rightBarItem;
    
    [self getLastData];
}

-(void)showAlert{
    if (self.isAccurateJob.intValue == 0) {
        NSDate *date = [NSDate date];
        long long numTime = date.timeIntervalSince1970*1000;
        
        if (_biModel.job_start_time.longLongValue < numTime ) {//岗位已经开始
            self.btnConfirm.enabled = NO;
            DLAVAlertView *alert = [[DLAVAlertView alloc]initWithTitle:@"提醒" message:@"兼职已开始，无法购买兼职保险" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 0) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }else{
            _isNotAccurate = YES;//松散岗位 且未开始
            _allPayMoney = 0;
        }
    }else{
        self.btnConfirm.enabled = NO;
    }
}

-(void)getLastData{
    NSString *content = [NSString stringWithFormat:@"job_id:%@",self.jobID];
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_entQueryPayPingAnInsurancePolicyStuList" andContent:content];
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (response && response.success) {
            _biModel = [BuyInsuranceModel objectWithKeyValues:response.content];
//            self.insuranceExplain.text = [NSString stringWithFormat:@"每天%.0f元保%.0f万，兼职意外保险说明",_biModel.insurance_unit_price.intValue * 0.01,_biModel.insurance_unit_payment_price.intValue * 0.01 * 0.0001];
//            self.insuranceExplain.font = [UIFont systemFontOfSize:16];
            NSArray *rlArray = [ResumeLModel objectArrayWithKeyValuesArray:_biModel.resume_list];

            weakSelf.insurancePrice = _biModel.insurance_unit_price;
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:[_biModel.job_start_time longLongValue]/1000];
            NSDate * endDate = [NSDate dateWithTimeIntervalSince1970:[_biModel.job_end_time longLongValue]/1000];

            NSDate* tempDate = [DateHelper zeroTimeOfDate:startDate];
            long long startT = tempDate.timeIntervalSince1970*1000;
            long long dayTime = 24*3600*1000;
            long long endT = [DateHelper zeroTimeOfDate:endDate].timeIntervalSince1970 * 1000;
            _jobAllDays = 0;
            _biModel.timeArray = [[NSMutableArray alloc]init];
            [weakSelf showAlert];

            do{
                _jobAllDays++;
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:startT/1000];
                [_biModel.timeArray addObject:date];
                startT += dayTime;
            }while (startT <= endT);
            
            weakSelf.ArrayTime = [[NSMutableArray alloc]init];
            NSMutableArray *array_1 = [[NSMutableArray alloc]init];
            for (NSDate *date  in _biModel.timeArray) {
//                NSNumber *number = [NSNumber numberWithLongLong:num.longLongValue * 1000];
                long long tempNum = date.timeIntervalSince1970 * 1000;
                NSNumber *number = [NSNumber numberWithLongLong:tempNum];
                [array_1 addObject:number];
            }
            
            [weakSelf.ArrayTime addObjectsFromArray:array_1];
            startT = tempDate.timeIntervalSince1970*1000;

            for (ResumeLModel *rlModel in rlArray) {
                NSMutableArray *epcArray = [NSMutableArray array];
                NSArray *insuranceArray = rlModel.ping_an_insurance_policy_list;
                rlModel.job_start_time = _biModel.job_start_time;
                rlModel.job_end_time = _biModel.job_end_time;
                rlModel.insurance_unit_price = _biModel.insurance_unit_price;
                rlModel.allDays = _jobAllDays;

                for (NSInteger i = 0; i < _jobAllDays; i++) {
                    ExaBuyCellModel *epcModel = [[ExaBuyCellModel alloc]init];
                    epcModel.timeStamp = startT +dayTime * i;
                    epcModel.buyStatus = 0;

                    for (InsurancePolicyModel *ipModel in insuranceArray) {
                        if (ipModel.ping_an_insurance_policy_time.longLongValue == epcModel.timeStamp) {
                            if (ipModel.buy_status.intValue == 1) {
                                epcModel.buyStatus = 1;//不可购买
                                
                            }else if (ipModel.buy_status.intValue == 2){//已经购买
                                epcModel.buyStatus = 2;
                            }else if (ipModel.buy_status.intValue == 3){//可购买
                                epcModel.buyStatus = 4;
                                rlModel.nowPay += rlModel.insurance_unit_price.integerValue;
                                if (_isNotAccurate) {
                                    weakSelf.btnConfirm.enabled = YES;
                                }else{
                                    if (_rlModel.isHasDate) {
                                        weakSelf.btnConfirm.enabled = YES;
                                    }else{
                                        weakSelf.btnConfirm.enabled = NO;
                                    }
                                    rlModel.isSelect = YES;
                                }
                            }
                        }
                    }
                    [epcArray addObject:epcModel];
                }
                NSArray *tempArray = [NSArray arrayWithArray:epcArray];
                rlModel.exapcArray = tempArray;
                [_arrayData addObject:rlModel];
            }
            [weakSelf allMoneyWithSelect];
            //成功
        }
        [weakSelf.tableView reloadData];
    }];
}
//    保险说明
- (void)insuranceDetailOnClick:(UIButton *)sender {
    WebView_VC* vc = [[WebView_VC alloc] init];
    vc.url = [NSString stringWithFormat:@"%@%@", URL_HttpServer, kUrl_baoxianIntor];
    vc.title = @"兼职保险";
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)verifiedInsurance:(UIButton *)sender {
    
    if (_isNotAccurate) {//松散岗位
        if (_allPayMoney != 0) {
            //跳转到支付保单
            PaySelect_VC* vc = [[PaySelect_VC alloc] init];
            vc.fromType = PaySelectFromType_insurance;
            vc.arrayData = _arrayData;
            vc.needPayMoney = _allPayMoney * 100;
            vc.isAccurateJob = self.isAccurateJob;
//            vc.ArrayTime = self.ArrayTime;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
            if (self.agreeBtn.selected == NO) {
                [UIHelper toast:@"请先阅读保险责任条款"];
                
            }else{
                [UIHelper toast:@"请选择保险人"];
                
            }
        }
        
    }else{
        if (self.agreeBtn.selected == YES && _rlModel.isSelect == YES) {
            //跳转到支付保单
            PaySelect_VC* vc = [[PaySelect_VC alloc] init];
            vc.fromType = PaySelectFromType_insurance;
            vc.arrayData = _arrayData;
            vc.needPayMoney = _allPayMoney;
            vc.isAccurateJob = self.isAccurateJob;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            
            if (self.agreeBtn.selected == NO) {
                [UIHelper toast:@"请先阅读保险责任条款"];
                
            }else{
                [UIHelper toast:@"请选择保险人"];
                
            }
        }

    }
}
//保险责任
- (IBAction)insuranceDuty:(UIButton *)sender {
    WebView_VC* vc = [[WebView_VC alloc] init];
    vc.url = [NSString stringWithFormat:@"%@%@", URL_HttpServer, kUrl_baoxianResponsibility];
    vc.title = @"保险责任";
    [self.navigationController pushViewController:vc animated:YES];

}
//免除责任
- (IBAction)noDuty:(UIButton *)sender {
    WebView_VC* vc = [[WebView_VC alloc] init];
    vc.url = [NSString stringWithFormat:@"%@%@", URL_HttpServer, kUrl_remitResponsibility];
    vc.title = @"责任免除";
    [self.navigationController pushViewController:vc animated:YES];
 
}
- (IBAction)agreeBtnOnClick:(UIButton *)sender {
    DLog(@"同意");
    self.agreeBtn.selected = !sender.selected;

}

#pragma mark - UITableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.isAccurateJob.intValue == 1) {
        UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            return cell.frame.size.height;
        }
        return 0;
    }else{
        return 64;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrayData.count ? _arrayData.count : 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.isAccurateJob.intValue == 1) {//精确岗位
        BuyInsuranceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BuyInsuranceCell"];
        if (cell == nil) {
            cell = [BuyInsuranceCell new];
            cell.delegate = self;
            cell.insurancePrice = self.insurancePrice;
        }
        if (_arrayData.count <= indexPath.row) {
            return cell;
        }
        _rlModel = _arrayData[indexPath.row];
        [cell refreshWithData:_rlModel andIndexPath:indexPath];
        return cell;
        
    }else{//松散岗位
        BuyInsuranceCell_2 *cell = [tableView dequeueReusableCellWithIdentifier:@"BuyInsuranceCell_2"];
        if (cell == nil) {
            cell = [BuyInsuranceCell_2 new];
            cell.delegate = self;
            cell.insurancePrice = self.insurancePrice;
        }
        if (_arrayData.count <= indexPath.row) {
            return cell;
        }
        ResumeLModel *model = _arrayData[indexPath.row];
        [cell refreshWithData:model andIndexPath:indexPath];
        return cell;
    }
    return nil;
}


#pragma mark - InsuranceDelegate
- (void)elCell_changeDataWithModel:(ResumeLModel *)model andIndexPath:(NSIndexPath*)indexPath
{
    [_arrayData replaceObjectAtIndex:indexPath.row withObject:model];
    NSArray *array = @[indexPath];
    if (model.isHasDate) {
        self.btnConfirm.enabled = YES;
    }else{
        self.btnConfirm.enabled = NO;
    }
    [self.tableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
}

-(void)allMoneyWithSelect{
    _allPayMoney = 0;
    for (ResumeLModel* model in _arrayData) {
        if (model.isSelect) {
            _allPayMoney += model.nowPay;
        }
    }
    if (_allPayMoney != 0) {
        [self.btnConfirm setTitle:[[NSString stringWithFormat:@"确认投保 ￥%.2f",_allPayMoney*0.01 ]stringByReplacingOccurrencesOfString:@".00" withString:@""] forState:UIControlStateNormal];
        self.btnConfirm.enabled = YES;
    }else{
        [self.btnConfirm setTitle:@"确认投保" forState:UIControlStateNormal];
        self.btnConfirm.enabled = NO;
    }

}

-(void)allMoneyWithSelect_2
{
    _allPayMoney = 0;
    for (ResumeLModel* model in _arrayData) {
        if (model.isSelect) {
            _rlModel.isSelect = model.isSelect;
            _allPayMoney += model.nowPay;
        }
    }
    if (_allPayMoney != 0) {
        [self.btnConfirm setTitle:[[NSString stringWithFormat:@"确认投保 ￥%.2d",_allPayMoney]stringByReplacingOccurrencesOfString:@".00" withString:@""] forState:UIControlStateNormal];
        self.btnConfirm.enabled = YES;
    }else{
        [self.btnConfirm setTitle:@"确认投保" forState:UIControlStateNormal];
        self.btnConfirm.enabled = NO;
    }
}

- (void)backAction{
    [self.navigationController popToViewController:self.popToVC animated:YES];
}

@end
