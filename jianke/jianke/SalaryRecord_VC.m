//
//  SalaryRecord_VC.m
//  jianke
//
//  Created by fire on 16/8/19.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "SalaryRecord_VC.h"
#import "MoneyBagCell.h"
#import "MoneyDetailModel.h"
#import "PayDetail_VC.h"

@interface SalaryRecord_VC ()

@property (nonatomic, strong) QueryParamModel *queryParam;

@end

@implementation SalaryRecord_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发放记录";
    self.queryParam = [[QueryParamModel alloc] init];
    [self initUIWithType:DisplayTypeOnlyTableView];
    [self initWithNoDataViewWithStr:@"无发放记录" onView:self.view];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.refreshType = RefreshTypeAll;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView.header beginRefreshing];
}

#pragma mark - 网络请求

- (void)headerRefresh{
    self.queryParam.page_num = @1;
    WEAKSELF
    [[XSJRequestHelper sharedInstance] queryAccDetail:self.queryParam withJobId:self.jobId block:^(ResponseInfo *response) {
        if (response && response.success) {
            NSArray *array = [MoneyDetailModel objectArrayWithKeyValuesArray:[response.content objectForKey:@"detail_list"]];
            if (array.count) {
                weakSelf.viewWithNoData.hidden = YES;
                weakSelf.dataSource = [array mutableCopy];
                weakSelf.queryParam.page_num = @(weakSelf.queryParam.page_num.integerValue + 1);
                [weakSelf.tableView reloadData];
            }else{
                weakSelf.viewWithNoData.hidden = NO;
            }
        }
        [weakSelf.tableView.header endRefreshing];
    }];
}

- (void)footerRefresh{
    WEAKSELF
    [[XSJRequestHelper sharedInstance] queryAccDetail:self.queryParam withJobId:self.jobId block:^(ResponseInfo *response) {
        if (response && response.success) {
            NSArray *array = [MoneyDetailModel objectArrayWithKeyValuesArray:[response.content objectForKey:@"detail_list"]];
            if (array && array.count) {
                [weakSelf.dataSource addObjectsFromArray:array];
                weakSelf.queryParam.page_num = @(weakSelf.queryParam.page_num.integerValue +1);
                [weakSelf.tableView reloadData];
            }
        }
        [weakSelf.tableView.footer endRefreshing];
    }];
}

#pragma mark - uitableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource ? self.dataSource.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MoneyBagCell *cell = [MoneyBagCell cellWithTableView:tableView];
    MoneyDetailModel *mdModel = [self.dataSource objectAtIndex:indexPath.row];
    [cell refreshWithData:mdModel];
    return cell;
}

#pragma mark - uitableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MoneyDetailModel *mdModel = [self.dataSource objectAtIndex:indexPath.row];
    PayDetail_VC *viewCtrl = [[PayDetail_VC alloc] init];
    viewCtrl.detail_list_id = mdModel.account_money_detail_list_id;
    viewCtrl.money_detail_title = mdModel.money_detail_title;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 75;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
