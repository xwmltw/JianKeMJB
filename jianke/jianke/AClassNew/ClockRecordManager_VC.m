//
//  ClockRecordManager_VC.m
//  jianke
//
//  Created by fire on 16/7/8.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ClockRecordManager_VC.h"
#import "UIButton+Extension.h"
#import "Masonry.h"
#import "ClockRecordCell.h"
#import "XSJRequestHelper.h"
#import "UIColor+Extension.h"
#import "MJRefresh.h"
#import "UIView+MKException.h"
#import "ReportRecord_VC.h"
#import "ParamModel.h"
#import "MKAlertView.h"

@interface ClockRecordManager_VC () <UITableViewDataSource,UITableViewDelegate,ClockRecordCellDelegate> {
    NSMutableArray *_dataArr;   // 保存_first数组和_historiy数组
    NSMutableArray *_firstArr;  //正常打卡记录数组
    NSMutableArray *_historicArr;    //历史打卡记录数组
    NSInteger _currentPage; //当前页码
    EntQueryPunch *_punch;
    BOOL _isFromClosePunch;    //是否是结束签到    
}
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIButton *recordBtn;    //点名记录按钮
@property (nonatomic, strong) UIView *footerView;

@end

@implementation ClockRecordManager_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self newData];
    self.footerView = [self newTableFooterView];
    [self newTabeleView];
    [self newBottomView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView.header beginRefreshing];
}

- (void)newData{
    self.title = @"签到管理";
    _currentPage = 1;
    QueryParamModel *param = [[QueryParamModel alloc] init];
    param.page_num = @1;
    param.page_size = @30;
    _punch = [[EntQueryPunch alloc] initWithJob:_jobId andListType:@1 andParam:param];
    
    _firstArr =[NSMutableArray array];
    _historicArr = [NSMutableArray array];
    _dataArr  = [NSMutableArray arrayWithObjects:_firstArr,_historicArr, nil];
}

#pragma mark - 控件

- (void)newTabeleView{
    UITableView *tableView = [UIHelper createTableViewWithStyle:UITableViewStyleGrouped delegate:self onView:self.view];
    tableView.rowHeight = 74;
    tableView.estimatedRowHeight = 74;
    tableView.backgroundColor = [UIColor whiteColor];
    self.tableView = tableView;
    [self.tableView registerNib:[UINib nibWithNibName:@"ClockRecordCell" bundle:nil] forCellReuseIdentifier:@"ClockRecordCell"];
    [self initWithNoDataViewWithStr:@"发起一次点名\n监督兼客认真完成工作" onView:self.tableView];
    WEAKSELF
    tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf requestForPunch:2];
    }];
    tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf requestForPunch:1];
    }];
}

- (void)newBottomView{
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UIButton *button = [UIButton creatBottomButtonWithTitle:@"发起点名" addTarget:self action:@selector(addAction:)];
    [bottomView addSubview:button];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(bottomView.mas_top);
    }];
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(60);
    }];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView).offset(16);
        make.right.equalTo(bottomView).offset(-16);
        make.bottom.equalTo(bottomView).offset(-8);
        make.top.equalTo(bottomView).offset(8);
    }];
    [bottomView addBorderInDirection:BorderDirectionTypeTop borderWidth:0.7 borderColor:[UIColor XSJColor_tGrayTinge] isConstraint:YES];
}

//免去复用footerview的麻烦
- (UIView *)newTableFooterView{
    UIView *view = [[UIView alloc] init];
    UIButton *button = [UIButton buttonWithTitle:[NSString stringWithFormat:@"点名记录(%ld)",(unsigned long)_historicArr.count] bgColor:[UIColor XSJColor_tGrayMiddle] image:@"v3_public_history_white" target:self sector:@selector(punchAction)];
    [button setCornerValue:2.0f];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor XSJColor_tGrayTinge] forState:UIControlStateDisabled];
    [button setImage:[UIImage imageNamed:@"v3_public_history"] forState:UIControlStateDisabled];
    self.recordBtn = button;
    [view addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY);
        make.width.greaterThanOrEqualTo(@120);
        make.height.equalTo(@30);
    }];
    return view;
}

#pragma mark - uitableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = [_dataArr objectAtIndex:section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ClockRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClockRecordCell" forIndexPath:indexPath];
    PunchResponseModel *prModel = nil;
    switch (indexPath.section) {
        case 0:
            prModel = [_firstArr objectAtIndex:indexPath.row];
            break;
        case 1:
            prModel = [_historicArr objectAtIndex:indexPath.row];
            break;
    }
    cell.delegate = self;
    [cell setData:prModel];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1 && (_firstArr.count !=0 || _historicArr.count != 0)) {
        return self.footerView;
    }
    return nil;
}

#pragma mark - uitableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ReportRecord_VC *viewCtrl = [[ReportRecord_VC alloc] init];
    PunchResponseModel *prModel = nil;
    switch (indexPath.section) {
        case 0:
            prModel = [_firstArr objectAtIndex:indexPath.row];
            break;
        case 1:
            prModel = [_historicArr objectAtIndex:indexPath.row];
            break;
    }
    viewCtrl.punch_the_clock_request_id = prModel.punch_the_clock_request_id;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return 10.0f;
    }
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40.0f;
    }
    return 0.01f;
}

#pragma mark - 网络请求

//请求打卡签到列表
- (void)requestForPunch:(NSInteger)status{
    _punch.list_type = [NSNumber numberWithInteger:status];
    //1 表示正常打卡数据 2表示历史打卡数据
    WEAKSELF
    if (status == 1) {
        [weakSelf beginNormalRequest];
    }else if (status == 2){
        [weakSelf beginHistoricRequest];
    }
}

- (void)beginNormalRequest{
    _punch.query_param.page_num = @1;
    [[XSJRequestHelper sharedInstance] entQueryPunchRequestList:_punch block:^(PunchClockModel *result) {
        if (result) {
            [self handelNormalRequest:result];
        }else{
            [self.tableView.header endRefreshing];
        }

    }];
}

- (void)beginHistoricRequest{
    _punch.query_param.page_num = [NSNumber numberWithInteger:(_currentPage)];  //设置下一页
    [[XSJRequestHelper sharedInstance] entQueryPunchRequestList:_punch block:^(PunchClockModel *result) {
        if (result) {
            [self handelHistoryRequest:result];
            [self updateBtnStatus:NO];
            [self judgeNoData];
        }else{
            [self.tableView.footer endRefreshing];
        }
    }];
}

//处理正常打卡记录
- (void)handelNormalRequest:(PunchClockModel *)result{
    [self.tableView.header endRefreshing];
    [_firstArr removeAllObjects];
    [_firstArr addObjectsFromArray:result.punch_request_list];
    [self.recordBtn setTitle:[NSString stringWithFormat:@"点名记录(%ld)",(long)[result.punch_request_list_history_count integerValue]] forState:UIControlStateNormal];
    if (result.punch_request_list.count == 0 || _isFromClosePunch) {    //正常打卡无数据或结束签到
        _currentPage = 1;
        [_historicArr removeAllObjects];
        [self requestForPunch:2];
    }else{
        [self.tableView reloadData];
        [self judgeNoData];
    }
}

//处理历史打卡记录
- (void)handelHistoryRequest:(PunchClockModel *)result{
    
    if (!result.punch_request_list.count) {
        [self.tableView reloadData];
        [self.tableView.footer noticeNoMoreData];
        return;
    }
    
    [self.tableView.footer endRefreshing];
    _currentPage++;
    [_historicArr addObjectsFromArray:result.punch_request_list];
    [self.recordBtn setTitle:[NSString stringWithFormat:@"点名记录(%ld)",(long)[result.punch_request_list_history_count integerValue]] forState:UIControlStateNormal];
    [self.tableView reloadData];
}


//发起签到
- (void)beginPunch{
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970]*1000;
    WEAKSELF
    [[XSJRequestHelper sharedInstance] entIssuePunchRequest:_punch.job_id clockTime:[NSString stringWithFormat:@"%f",seconds] block:^(id result) {
        [weakSelf.tableView.header beginRefreshing];
    }];
}

#pragma mark - ClockRecordCellDelegate

//关闭打卡
- (void)closePunch:(NSString *)punchId andPunchResponseModel:(PunchResponseModel *)punchModel{
    WEAKSELF
    [[XSJRequestHelper sharedInstance] entClosePunchRequest:punchId block:^(id result) {
        punchModel.request_status = @2;
        _isFromClosePunch = YES;
        [weakSelf.tableView.header beginRefreshing];
    }];
}

#pragma mark - 事件响应

- (void)addAction:(UIButton *)button{
    WEAKSELF
    [MKAlertView alertWithTitle:@"只有当天需要上岗的兼客才会收到点名消息，一天可以发起六次点名。" message:nil cancelButtonTitle:@"取消" confirmButtonTitle:@"确定" completion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [weakSelf beginPunch];
        }
    }];
}

- (void)punchAction{
    [self.tableView.footer beginRefreshing];
}

- (void)updateBtnStatus:(BOOL)enable{
    [self.recordBtn setEnabled:enable];
    self.recordBtn.backgroundColor = enable ? [UIColor XSJColor_tGrayMiddle] : [UIColor clearColor] ;
}

- (void)judgeNoData{
    if (!_firstArr.count && !_historicArr.count) {
        self.viewWithNoData.hidden = NO;
    }else{
        self.viewWithNoData.hidden = YES;
    }
}

@end
