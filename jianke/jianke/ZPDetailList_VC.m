//
//  DetailList_VC.m
//  jianke
//
//  Created by xuzhi on 16/7/25.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ZPDetailList_VC.h"
#import "ZPDetaiListCell.h"
#import "PayDetailModel.h"
#import "UILabel+MKExtension.h"
#import "MJRefresh.h"

@interface ZPDetailList_VC () <UITableViewDataSource,UITableViewDelegate> {
    QueryParamModel *_queryParam;
    DetailItmeParam *_param;
}

@property (weak , nonatomic) UITableView *tableView;
@property (strong , nonatomic) NSMutableArray *dataSource;

@end

@implementation ZPDetailList_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setData];
    [self newTableView];
    [self.tableView.header beginRefreshing];
}

- (void)setData{
    self.title = @"佣金明细";
    self.dataSource = [NSMutableArray array];
    _param = [[DetailItmeParam alloc] init];
    _param.query_param = [[QueryParamModel alloc] init];
    _param.detail_list_id = self.detailListId;
}

- (void)newTableView{
    self.tableView = [UIHelper createTableViewWithStyle:UITableViewStylePlain delegate:self onView:self.view];
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self headerRefresh];
    }];
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self footerRefresh];
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    self.tableView.estimatedRowHeight = 63.0f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 网络请求

- (void)headerRefresh{
    _queryParam.page_num = @1;
    WEAKSELF
    [[XSJRequestHelper sharedInstance] queryAcctVirtualDetailItem:_param block:^(NSArray *result) {
        [weakSelf.tableView.header endRefreshing];
        if (result && result.count) {
            weakSelf.dataSource = [result mutableCopy];
            [weakSelf.tableView reloadData];
        }
    }];

}

- (void)footerRefresh{
    if (_queryParam.page_num.integerValue == 1) {
        _queryParam.page_num = @(_queryParam.page_num.integerValue+1);
    }
    WEAKSELF
    [[XSJRequestHelper sharedInstance] queryAcctVirtualDetailItem:_param block:^(NSArray *result) {
        [weakSelf.tableView.footer endRefreshing];
        if (result && result.count) {
            _queryParam.page_num = @(_queryParam.page_num.integerValue+1);
            [weakSelf.dataSource addObjectsFromArray:result];
            [weakSelf.tableView reloadData];
        }
    }];
}

#pragma mark - uitableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource ? self.dataSource.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZPDetaiListCell *cell = [ZPDetaiListCell cellWithTableView:tableView];
    PayDetailModel *model = [self.dataSource objectAtIndex:indexPath.row];
    cell.pdModel = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 63.0f;
}

@end
