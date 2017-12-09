//
//  MakeCheck_VC.m
//  jianke
//
//  Created by xiaomk on 16/4/15.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MakeCheck_VC.h"
#import "WDConst.h"
#import "JobBillModel.h"
#import "MakeCheckCell.h"
#import "DateSelectView.h"
#import "ApplyJobModel.h"
#import "CheckDetailForCD_VC.h"
#import "JobModel.h"

@interface MakeCheck_VC (){
    
}
@property (nonatomic, strong) DateSelectView* dateView;
@property (nonatomic, strong) NSNumber* billStartTime;
@end


@implementation MakeCheck_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [WDNotificationCenter addObserver:self selector:@selector(backAction) name:WDNotification_backFromMoneyBag object:nil];
    self.title = @"账单";
    [self setUIHaveBottomView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self initWithNoDataViewWithStr:@"暂无账单" onView:self.tableView];
    [self.btnBottom setTitle:@"生成账单" forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadDataSource];
}

- (void)loadDataSource{
    NSString *content = [NSString stringWithFormat:@"job_id:%@",self.jobId];
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_queryJobBillList" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo * response) {
        if (response && response.success) {
            [weakSelf.datasArray removeAllObjects];
            NSArray* array = [JobBillModel objectArrayWithKeyValuesArray:response.content[@"job_bill_list"]];
            if (array && array.count) {
                weakSelf.datasArray = [[NSMutableArray alloc] initWithArray:array];
            }
            [weakSelf.tableView reloadData];
            
            weakSelf.viewWithNoData.hidden = array.count > 0;
            weakSelf.viewWithNoNetwork.hidden = YES;
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
    }];
}


/** 生成账单 */
- (void)btnBottomOnclick:(UIButton *)sender{
    [TalkingData trackEvent:@"账单_生成账单"];

    NSString *content = [NSString stringWithFormat:@"job_id:%@",self.jobId];
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_getJobNextBillStartTime" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo * response) {
        if (response && response.success) {
            weakSelf.billStartTime = response.content[@"bill_start_time"];
            [weakSelf showSelectCheckDateView];
        }else{
            [UIHelper toast:@"获取账单时间失败"];
        }
    }];
}

/** 显示选择账单时间日历 */
- (void)showSelectCheckDateView{
    DateSelectView *dateView = [[DateSelectView alloc] initWithFrame:CGRectMake(0, 0, 260, 260)];
    dateView.type = DateViewType_makeCheck;
    NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.jobModel.working_time_start_date.longLongValue/1000];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.jobModel.working_time_end_date.longLongValue/1000];
    NSDate *billStartDate = [NSDate dateWithTimeIntervalSince1970:self.billStartTime.longLongValue/1000];
    NSMutableArray* selAry = [NSMutableArray arrayWithObject:billStartDate];
    dateView.startDate = startDate;
    dateView.endDate = endDate;
    dateView.billStartDate = billStartDate;
    dateView.datesSelected = selAry;
    WEAKSELF
    [XSJUIHelper showConfirmWithView:dateView msg:nil title:@"选择账单时间段" cancelBtnTitle:@"取消" okBtnTitle:@"确定" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (dateView.datesSelected.count < 1) {
                [UIHelper toast:@"必须至少选择一天"];
                return;
            }
            GetJobBillModel* model = [[GetJobBillModel alloc] init];
            model.job_id = weakSelf.jobId;
            NSString* startDate = [DateHelper getDateDesc:dateView.datesSelected.firstObject withFormat:@"yyy-MM-dd"];
            NSString* endDate = [DateHelper getDateDesc:dateView.datesSelected.lastObject withFormat:@"yyy-MM-dd"];
            model.bill_start_date = startDate;
            model.bill_end_date = endDate;
            [weakSelf makeCheckWith:model];
        }
    }];
}
/** 生成账单 */
- (void)makeCheckWith:(GetJobBillModel*)model{
    NSString *content = [model getContent];
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_getJobBill" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo * response) {
        if (response && response.success) {
            JobBillModel* jbModel = [JobBillModel objectWithKeyValues:response.content];
            [weakSelf showCheckDetailWith:jbModel];
        }
    }];
}

- (void)showCheckDetailWith:(JobBillModel*)model{
    CheckDetailForCD_VC* vc = [[CheckDetailForCD_VC alloc] init];
    vc.jobBillId = model.job_bill_id.stringValue;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - ***** UITableView delegate ******
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MakeCheckCell* cell = [MakeCheckCell cellWithTableView:tableView];
    JobBillModel* model = [self.datasArray objectAtIndex:indexPath.row];
    [cell refreshWithData:model andIndexPath:indexPath];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 156;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JobBillModel* model = [self.datasArray objectAtIndex:indexPath.row];
    CheckDetailForCD_VC* vc = [[CheckDetailForCD_VC alloc] init];
    vc.jobBillId = model.job_bill_id.stringValue;
    [self.navigationController pushViewController:vc animated:YES];
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


@implementation GetJobBillModel
@end
