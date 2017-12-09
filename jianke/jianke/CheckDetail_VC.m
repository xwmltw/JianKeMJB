//
//  CheckDetail_VC.m
//  jianke
//
//  Created by xiaomk on 16/4/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "CheckDetail_VC.h"
#import "CheckDetailCell1.h"
#import "CheckDetailCell2.h"
#import "CheckDetailCell3.h"
#import "JobBillModel.h"
#import "PaySelect_VC.h"

@interface CheckDetail_VC ()

@property (nonatomic, strong) JobBillModel* jbModel;
@property (nonatomic, strong) NSMutableArray *payListArray;

@end

@implementation CheckDetail_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"账单详情";
    self.tableViewStyle = UITableViewStyleGrouped;
    [self setUIHaveBottomView];
    
    _payListArray = [[NSMutableArray alloc] init];
    
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
 
            [weakSelf initBtnView];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)initBtnView{
//    NSNumber* mat_apply_status;   /*!< 垫资申请状态:1待雇主确认 2审核中 3已驳回 4已垫资 5已还款' */
//    NSNumber* is_apply_mat;   /*!< '是否申请垫资 0未申请 1已申请' */
//     NSNumber *bill_status;/*!< <int>岗位账单状态： 1未发送 2已发送 3已支付 */
  
    if (self.jbModel.is_apply_mat.integerValue == 1) {
        if (self.jbModel.mat_apply_status.integerValue == 1) {
            [self.btnBottom setTitle:@"确认申请垫资" forState:UIControlStateNormal];
        }else if (self.jbModel.mat_apply_status.integerValue == 2) {
            [self.btnBottom setTitle:@"垫资申请中" forState:UIControlStateNormal];
            self.btnBottom.enabled = NO;
        }else if (self.jbModel.mat_apply_status.integerValue == 4) {
            [self.btnBottom setTitle:@"垫资成功" forState:UIControlStateNormal];
            self.btnBottom.enabled = NO;
        }else if (self.jbModel.mat_apply_status.integerValue == 5) {
            [self.btnBottom setTitle:@"已还款" forState:UIControlStateNormal];
            self.btnBottom.enabled = NO;
        }
    }else{
        
        if (self.jbModel.bill_status.integerValue == 3) {
            [self.btnBottom setTitle:@"已支付" forState:UIControlStateNormal];
            self.btnBottom.enabled = NO;
        }else if (self.jbModel.bill_status.integerValue == 2){
            NSString* str = [[NSString stringWithFormat:@"确认支付￥%.2f",self.jbModel.total_amount.floatValue *0.01] stringByReplacingOccurrencesOfString:@".00" withString:@""];
            [self.btnBottom setTitle:str forState:UIControlStateNormal];
        }
    }
    
}

- (void)btnBottomOnclick:(UIButton *)sender{
    //确认 垫资申请
    if (self.jbModel.is_apply_mat.integerValue == 1 && self.jbModel.mat_apply_status.integerValue == 1) {
        WEAKSELF
        NSString *content = [NSString stringWithFormat:@"bill_id:%@",self.jobBillId];
        RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_confirmApplyMat" andContent:content];
        [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
            if (response && [response success]) {
                [UIHelper toast:@"确认成功"];
                weakSelf.jbModel.mat_apply_status = @(2);
                [weakSelf initBtnView];
            }
        }];
    }//支付
    else if (self.jbModel.is_apply_mat.integerValue == 0 && self.jbModel.bill_status.integerValue != 3){

        PaySelect_VC* vc = [[PaySelect_VC alloc] init];
        vc.fromType = PaySelectFromType_jobBill;
        vc.needPayMoney = _jbModel.total_amount.intValue;
        vc.job_bill_id = _jbModel.job_bill_id;
        vc.jobId = _jbModel.job_id;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - ***** UITableView delegate ******
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* cellIdentifier = [NSString stringWithFormat:@"CheckDetailCell_%ld",(long)indexPath.section];
    if (indexPath.section == 0) {
        CheckDetailCell1* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [CheckDetailCell1 new];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (self.jbModel.is_apply_mat.integerValue == 1) {
            [cell EP_refreshWithData:self.jbModel];
        }else{
            [cell refreshWithData:self.jbModel andIndexPath:indexPath];
        }
        return cell;
    }else if (indexPath.section == 1){
        CheckDetailCell2* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [CheckDetailCell2 new];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell EP_refreshWithData:self.jbModel];
        return cell;
    }else if (indexPath.section == 2){
        CheckDetailCell3* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [CheckDetailCell3 new];
        }
        PayListModel* model = [_payListArray objectAtIndex:indexPath.row];
        [cell refreshWithData:model andIndexPath:indexPath];

        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 ) {
        return 66;
    }else if (indexPath.section == 1){
        return 88;
    }else if (indexPath.section == 2){
        return 64;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0 || section == 1) {
        return 1;
    }else if (section == 2){
        return self.payListArray.count ? self.payListArray.count : 0;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }else if (section == 1){
        return 8;
    }else if (section == 2){
        return 0.1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
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
