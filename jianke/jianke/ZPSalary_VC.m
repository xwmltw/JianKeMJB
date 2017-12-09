//
//  ZPSalary_VC.m
//  jianke
//
//  Created by xuzhi on 16/7/20.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ZPSalary_VC.h"
#import "ZPSalaryCell.h"
#import "Masonry.h"
#import "UILabel+MKExtension.h"
#import "PaySelect_VC.h"
#import "ZPDetailList_VC.h"
#import "MoneyBagPasswordManager.h"
#import "QueryAccountMoneyModel.h"

@interface ZPSalary_VC () <UIAlertViewDelegate,UITextFieldDelegate> {
    QueryParamModel *_queryParam;
}
@property (weak,nonatomic) UILabel *salaLabel;
@property (strong,nonatomic) UILabel *subSalaLabel; //冻结余额
//@property (weak , nonatomic) UITextField *pwd;
@end

@implementation ZPSalary_VC



- (void)viewDidLoad{
    [super viewDidLoad];
    self.btntitles = @[@"转入"];
    [self initUIWithType:DisplayTypeTableViewAndBottom];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self setData];
    [self newrightItem];
    self.tableView.tableHeaderView = [self newTopView];
    
    
    WEAKSELF
    [self setBtnEventBlock:^(UIButton *button){
        PaySelect_VC* viewCtrl = [[PaySelect_VC alloc] init];
        viewCtrl.fromType = PaySelectFromType_inviteBalance;
        [weakSelf.navigationController pushViewController:viewCtrl animated:YES];
    }];
    
    [[MoneyBagPasswordManager sharedInstance] setPasswordSuccess:NO block:^(MoneyBagInfoModel* model) {
        if (!model) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView.header beginRefreshing];
}

- (void)setData{
    self.title = @"招聘余额";
    _queryParam = [[QueryParamModel alloc] init];
    self.refreshType = RefreshTypeAll;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)newrightItem{
    UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"v3_public_info_whith"] style:UIBarButtonItemStyleDone target:self action:@selector(infoClick)];
    self.navigationItem.rightBarButtonItem = infoBtn;
}

- (UIView *)newTopView{
    UIView *topView = [[UIView alloc] init];
    topView.height = 226.0f;
    topView.backgroundColor = [UIColor colorWithRed:255/255.0 green:142/255.0 blue:15/255.0 alpha:1];
    UILabel *titleLabel = [UILabel labelWithText:@"招聘余额 (元)" textColor:[UIColor whiteColor] fontSize:16.0f];
    UILabel *salaLabel = [UILabel labelWithText:@"0.00" textColor:[UIColor whiteColor] fontSize:60.0f];
    self.salaLabel = salaLabel;
    UILabel *subTitleLabel = [UILabel labelWithText:@"冻结款 (元)" textColor:[UIColor whiteColor] fontSize:13.0f];
    UILabel *subSalaLabel = [UILabel labelWithText:@"0.00" textColor:[UIColor whiteColor] fontSize:30.0f];
    self.subSalaLabel = subSalaLabel;
    
    [topView addSubview:titleLabel];
    [topView addSubview:salaLabel];
    [topView addSubview:subTitleLabel];
    [topView addSubview:subSalaLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView).offset(24);
        make.centerX.equalTo(topView);
        make.width.greaterThanOrEqualTo(@10);
        make.height.equalTo(@22);
    }];
    [salaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(6);
        make.centerX.equalTo(topView);
        make.width.greaterThanOrEqualTo(@10);
        make.height.equalTo(@79);
    }];
    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(salaLabel.mas_bottom).offset(16);
        make.centerX.equalTo(topView);
        make.width.greaterThanOrEqualTo(@10);
        make.height.equalTo(@18);
    }];
    [subSalaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(salaLabel.mas_bottom).offset(37);
        make.centerX.equalTo(topView);
        make.width.greaterThanOrEqualTo(@10);
        make.height.equalTo(@42);
    }];

    return topView;
}

#pragma mark - uitableview datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ZPSalaryCell *cell = [ZPSalaryCell cellWithTableView:tableView];
    AcctVirtualModel *model = self.dataSource[indexPath.row];
    cell.avModel = model;
    return cell;
}

#pragma mark - uitableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 85.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    AcctVirtualModel *model = self.dataSource[indexPath.row];
    if (model.virtual_money_detail_type.integerValue == 3) {
        ZPDetailList_VC *viewCtrl = [[ZPDetailList_VC alloc] init];
        viewCtrl.detailListId = model.detail_list_id;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }
}

#pragma mark - 网络请求

- (void)getNewData{
    _queryParam.page_num = @1;
    WEAKSELF
    [[XSJRequestHelper sharedInstance] queryAcctVirtualDetailList:_queryParam block:^(AcctVirtualResponseModel *result) {
        [weakSelf.tableView.header endRefreshing];
        if (result && result.detail_list.count) {
            [weakSelf handelData:result];
            weakSelf.dataSource = [result.detail_list mutableCopy];
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)getMoreData{
    if (_queryParam.page_num.integerValue == 1) {
        _queryParam.page_num = @(_queryParam.page_num.integerValue+1);
    }
    WEAKSELF
        [[XSJRequestHelper sharedInstance] queryAcctVirtualDetailList:_queryParam block:^(AcctVirtualResponseModel *result) {
            [weakSelf.tableView.footer endRefreshing];
            if (result && result.detail_list.count) {
                _queryParam.page_num = @(_queryParam.page_num.integerValue+1);
                [weakSelf handelData:result];
                [weakSelf.dataSource addObjectsFromArray:result.detail_list];
                [weakSelf.tableView reloadData];
            }
        }];
}

- (void)headerRefresh{
    [self getNewData];
}

- (void)footerRefresh{
    [self getMoreData];
}

#pragma mark - 其他

- (void)handelData:(AcctVirtualResponseModel *)result{
    self.salaLabel.text = [NSString stringWithFormat:@"%.2f",(result.recruitment_amount.integerValue/100.00)];
    self.subSalaLabel.text = [NSString stringWithFormat:@"%.2f",(result.recruitment_frozen_amount.integerValue/100.00)];
}

- (void)infoClick{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"招聘余额简介" message:@"招聘余额用于存放兼客合伙人预付的招聘佣金，合伙人每发一个岗位，系统会将该岗位的预计佣金冻结，待岗位到期后2天内解冻返还剩余的金额" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)backToLastView{
    if (self.isFromPay) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
