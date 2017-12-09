//
//  JianKeAppreciation_VC.m
//  jianke
//
//  Created by fire on 16/9/23.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JianKeAppreciation_VC.h"
#import "JKAppreciteCell.h"
#import "PaySelect_VC.h"

@interface JianKeAppreciation_VC ()

@property (nonatomic, strong) JobVasModel *selectedModel;   /*!< 需要支付的模型 */

@end

@implementation JianKeAppreciation_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [WDNotificationCenter addObserver:self selector:@selector(backAction) name:WDNotification_backFromMoneyBag object:nil];
    self.tableViewStyle = UITableViewStyleGrouped;
    self.btntitles = @[@"去付款"];
    [self initUIWithType:DisplayTypeTableViewAndBottom];
    if (self.serviceType == Appreciation_stick_Type) {
        self.title = @"置顶推广";
        self.tableView.tableHeaderView = [self newTopView:@"置顶岗位排名在首页，曝光效果翻倍，快来试试吧！"];
    }else if (self.serviceType == Appreciation_push_Type){
        self.title = @"推送推广";
        self.tableView.tableHeaderView = [self newTopView:@"精准推送岗位信息给城市中的兼客，招聘效率提升2倍"];
    }else if (self.serviceType == Appreciation_Refresh_Type){
        self.title = @"刷新推广";
        self.tableView.tableHeaderView = [self newTopView:@"刷新岗位，排名靠前，时间显示最新，效果提高3.5倍"];
    }
    self.refreshType = RefreshTypeHeader;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:nib(@"JKAppreciteCell") forCellReuseIdentifier:@"JKAppreciteCell"];
    
    [self initWithNoDataViewWithStr:@"数据加载失败，请下拉重试~" onView:self.tableView];
    self.viewWithNoData.y += 50;
    [self getData:YES];
}

- (UIView *)newTopView:(NSString *)title{
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    topView.backgroundColor = MKCOLOR_RGBA(0, 118, 255, 0.03);
    UILabel *label = [UILabel labelWithText:title textColor:[UIColor XSJColor_tBlue] fontSize:15.0f];
    label.numberOfLines = 0;
    [topView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(topView).offset(16);
        make.right.equalTo(topView).offset(-16);
        make.top.equalTo(topView).offset(14);
        make.bottom.equalTo(topView).offset(-14);
    }];
    
    topView.height = [label contentSizeWithWidth:SCREEN_WIDTH - 32].height + 28;
    [topView addBorderInDirection:BorderDirectionTypeBottom borderWidth:0.7 borderColor:MKCOLOR_RGBA(0, 118, 255, 0.48) isConstraint:NO];
    return topView;
}

- (void)getData:(BOOL)isShowLoding{
    WEAKSELF
    [[XSJRequestHelper sharedInstance] queryJobVasListLoading:isShowLoding block:^(ResponseInfo *response) {
        [weakSelf.tableView.header endRefreshing];
        if (response) {
            weakSelf.viewWithNoData.hidden = YES;
            NSArray *result = nil;
            switch (weakSelf.serviceType) {
                case Appreciation_stick_Type:
                    result = [JobVasModel objectArrayWithKeyValuesArray:[response.content objectForKey:@"job_top_vas_list"]];
                    [result setValue:@(Appreciation_stick_Type) forKey:@"serviceType"];
                    break;
                case Appreciation_push_Type:
                    result = [JobVasModel objectArrayWithKeyValuesArray:[response.content objectForKey:@"job_push_vas_list"]];
                    [result setValue:@(Appreciation_push_Type) forKey:@"serviceType"];
                    break;
                case Appreciation_Refresh_Type:
                    result = [JobVasModel objectArrayWithKeyValuesArray:[response.content objectForKey:@"job_refresh_vas_list"]];
                    [result setValue:@(Appreciation_Refresh_Type) forKey:@"serviceType"];
                    break;
                default:
                    break;
            }
            weakSelf.selectedModel = result.firstObject;
            weakSelf.selectedModel.selected = YES;
            weakSelf.dataSource = [result mutableCopy];
            [weakSelf.tableView reloadData];
        }else{
            self.viewWithNoData.hidden = NO;
        }
    }];
}

- (void)headerRefresh{
    [self getData:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource ? self.dataSource.count : 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JKAppreciteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JKAppreciteCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - uitableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0f;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (self.serviceType) {
        case Appreciation_stick_Type:
            return @"置顶时长";
        case Appreciation_Refresh_Type:
            return @"刷新单价";
        case Appreciation_push_Type:
            return @"推送人数";
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(JKAppreciteCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    JobVasModel *model = [self.dataSource objectAtIndex:indexPath.row];
    [cell setData:model];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *result = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected == YES"]];
        
    [result setValue:[[NSNumber alloc] initWithBool:NO] forKey:@"selected"];
    self.selectedModel = [self.dataSource objectAtIndex:indexPath.row];
    self.selectedModel.selected = YES;
    [self.tableView reloadData];
}

#pragma mark - 重写方法

- (void)clickOnview:(UIView *)bottomView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (!self.selectedModel.selected) {
        [UIHelper toast:@"未选择服务套餐"];
        return;
    }
    
    if (self.serviceType == Appreciation_stick_Type) {
        [[UserData sharedInstance] setIsUpdateWithEPHome:YES];  //置顶付费时要刷新首页
    }
    
    WEAKSELF
    [[XSJRequestHelper sharedInstance] entRechargeJobVas:self.jobId totalAmount:self.selectedModel.rechargePrice orderType:@(self.serviceType) oderId:self.selectedModel.id block:^(ResponseInfo *result) {
        if (result) {
            PaySelect_VC *viewCtrl = [[PaySelect_VC alloc] init];
            viewCtrl.fromType = PaySelectFromType_JobVasOrder;
            viewCtrl.job_vas_order_id = [result.content objectForKey:@"job_vas_order_id"];
            viewCtrl.needPayMoney = weakSelf.selectedModel.rechargePrice.intValue;
            [weakSelf.navigationController pushViewController:viewCtrl animated:YES];
        }
    }];
}

#pragma mark  - 其他

- (void)backAction{
    [self.navigationController popToViewController:self.popToVC animated:YES];
}

- (void)dealloc{
    ELog(@"%@消失了", [self class]);
    [WDNotificationCenter removeObserver:self];
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
