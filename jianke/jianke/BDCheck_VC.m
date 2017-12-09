//
//  BDCheck_VC.m
//  jianke
//
//  Created by xiaomk on 16/4/14.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "BDCheck_VC.h"
#import "BDCheckPayCell.h"
#import "JobBillModel.h"
#import "BDCheckNoPayCell.h"
#import "WDConst.h"
#import "CheckDetail_VC.h"
#import "PaySelect_VC.h"

@interface BDCheck_VC (){
    NSNumber* _type;
}


@end

@implementation BDCheck_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.checkType == BDCheckType_PayYet) {
        _type = @(3);
    }else if (self.checkType == BDCheckType_NoPay){
        _type = @(2);
    }
    
    [self.view addSubview:self.tableView];

    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 36);
    [self.tableView setHeader:[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getLastData)]];
    [self.tableView setFooter:[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreData)]];

    [self initWithNoDataViewWithStr:@"暂无账单" onView:self.tableView];

    [self getLastData];
}

- (void)getLastData{
    if (!self.queryParam) {
        self.queryParam = [[QueryParamModel alloc] init];
        self.queryParam.page_num = @(1);
        self.queryParam.page_size = @(30);
    }
    
    BDCheckPM* model = [[BDCheckPM alloc] init];
    model.query_param = self.queryParam;
    model.bill_status = _type;
    
    NSString* content = [model getContent];
    WEAKSELF
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_entQueryBillList" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (response && [response success] ) {
            [weakSelf.datasArray removeAllObjects];
            NSArray* array = [JobBillModel objectArrayWithKeyValuesArray:response.content[@"job_bill_list"]];
            if (array.count) {
                [weakSelf.datasArray addObjectsFromArray:array];
                weakSelf.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
            }
            weakSelf.viewWithNoData.hidden = array.count;
            weakSelf.viewWithNoNetwork.hidden = YES;

            [weakSelf.tableView reloadData];
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
        [weakSelf.tableView.footer endRefreshing];
        [weakSelf.tableView.header endRefreshing];
    }];
}

- (void)getMoreData{
    NSInteger pageNum = self.queryParam.page_num.integerValue;
    pageNum++;
    
    QueryParamModel* qpModel = [[QueryParamModel alloc] init];
    qpModel.page_num = @(pageNum);
    qpModel.page_size = self.queryParam.page_size;
    qpModel.timestamp = self.queryParam.timestamp;
    
    BDCheckPM* model = [[BDCheckPM alloc] init];
    model.query_param = qpModel;
    model.bill_status = _type;
    
    NSString* content = [model getContent];
    WEAKSELF
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_entQueryBillList" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {

        if (response && [response success] ) {
            NSArray* array = [JobBillModel objectArrayWithKeyValuesArray:response.content[@"job_bill_list"]];
            if (array.count) {
                [weakSelf.datasArray addObjectsFromArray:array];
                weakSelf.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
            }else{
                [UIHelper toast:@"没有更多数据"];
            }
            [weakSelf.tableView reloadData];
        }
        [weakSelf.tableView.footer endRefreshing];
        [weakSelf.tableView.header endRefreshing];
    }];
}

#pragma mark - ***** UITableView delegate ******
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.checkType == BDCheckType_PayYet) {
        static NSString* cellIdentifier = @"BDCheckPayCell";
        BDCheckPayCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [BDCheckPayCell new];
        }
        JobBillModel* model = [self.datasArray objectAtIndex:indexPath.row];
        [cell refreshWithData:model andIndexPath:indexPath];
        return cell;
    }else if (self.checkType == BDCheckType_NoPay){
        static NSString* cellIdentifier = @"BDCheckNoPayCell";
        BDCheckNoPayCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [BDCheckNoPayCell new];
        }
        [cell.btnPay addTarget:self action:@selector(btnPayOnclick:) forControlEvents:UIControlEventTouchUpInside];
        cell.btnPay.tag = indexPath.row;
        
        JobBillModel* model = [self.datasArray objectAtIndex:indexPath.row];
        
        cell.labTitle.text = model.job_title;
        NSString *startDate = [DateHelper getShortDateFromTimeNumber:model.bill_start_date];
        NSString *endDate = [DateHelper getShortDateFromTimeNumber:model.bill_end_date];
        NSString* dateStr;
        if ([startDate isEqualToString:endDate]) {
            dateStr = startDate;
        }else{
            dateStr = [NSString stringWithFormat:@"%@至%@", startDate, endDate];
        }
        cell.labDate.text = [NSString stringWithFormat:@"账单日期:%@",dateStr];
        
        NSString *moneyStr = [NSString stringWithFormat:@"￥%0.2f", model.total_amount.floatValue/100];
        moneyStr = [moneyStr stringByReplacingOccurrencesOfString:@".00" withString:@""];
        
        NSMutableAttributedString *moneyAttrStr = [[NSMutableAttributedString alloc] initWithString:moneyStr attributes:@{NSFontAttributeName : [UIFont fontWithName:kFont_RSR size:20], NSForegroundColorAttributeName : [UIColor XSJColor_tRed]}];
        [moneyAttrStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:kFont_RSR size:12] range:NSMakeRange(0, 1)];
        [moneyAttrStr addAttribute:NSBaselineOffsetAttributeName value:@(6) range:NSMakeRange(0, 1)];
        cell.labMoney.attributedText = moneyAttrStr;
        
        cell.labWorkCount.text = [NSString stringWithFormat:@"上岗人数:%@",model.pay_stu_count];
        
        if (model.is_apply_mat.integerValue == 1) { //申请垫资
            cell.btnPay.hidden = YES;
            cell.labPayment.hidden = NO;
        }else{
            cell.btnPay.hidden = NO;
            cell.labPayment.hidden = YES;
        }
//        if (model.mat_apply_status.integerValue == 1) {
//            cell.labPayment.text = @"待雇主确认";
//        }else if (model.mat_apply_status.integerValue == 2) {
//            cell.labPayment.text = @"垫资审核中";
//        }else if (model.mat_apply_status.integerValue == 3) {
//            cell.labPayment.text = @"垫资已驳回 ";
//        }else if (model.mat_apply_status.integerValue == 4) {
//            cell.labPayment.text = @"垫资已垫资 ";
//        }else if (model.mat_apply_status.integerValue == 5) {
//            cell.labPayment.text = @"垫资已还款 ";
//        }
//        cell.labPayment.hidden = YES;;
        return cell;
    }
    return nil;
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.checkType == BDCheckType_PayYet) {
        return 72;
    }else if (self.checkType == BDCheckType_NoPay){
        return 96;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [TalkingData trackEvent:@"包招账单页面_账单详情"];

    JobBillModel* model = [self.datasArray objectAtIndex:indexPath.row];
    
    CheckDetail_VC* vc = [[CheckDetail_VC alloc] init];
    vc.jobBillId = model.job_bill_id.stringValue;
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - ***** 支付 ******
- (void)btnPayOnclick:(UIButton*)sender{
    
    [TalkingData trackEvent:@"包招账单页面_支付"];

    JobBillModel* model = [self.datasArray objectAtIndex:sender.tag];
    
    PaySelect_VC* vc = [[PaySelect_VC alloc] init];
    vc.fromType = PaySelectFromType_jobBill;
    vc.needPayMoney = model.total_amount.intValue;
    vc.job_bill_id = model.job_bill_id;
    vc.jobId = model.job_id;
    [self.navigationController pushViewController:vc animated:YES];
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

@implementation BDCheckPM
@end
