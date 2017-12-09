//
//  JKCallList_VC.m
//  jianke
//
//  Created by fire on 16/9/7.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JKCallList_VC.h"
#import "JKCallListCell.h"

@interface JKCallList_VC ()

@property (nonatomic, strong) QueryParamModel *queryParam;

@end

@implementation JKCallList_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"咨询的兼客";
    self.queryParam = [[QueryParamModel alloc] init];
    [self initUIWithType:DisplayTypeOnlyTableView];
    self.refreshType = RefreshTypeAll;
    self.tableView.estimatedRowHeight = 71.0f;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:nib(@"JKCallListCell") forCellReuseIdentifier:@"JKCallListCell"];
    
    [self initWithNoDataViewWithStr:@"暂无咨询的兼客" onView:self.view];
    [self.tableView.header beginRefreshing];
}

#pragma mark - 重写方法

- (void)headerRefresh{
    self.queryParam.page_num = @1;
    WEAKSELF
    [[XSJRequestHelper sharedInstance] queryContactApplyJobResumeList:self.queryParam jobId:self.jobId block:^(ResponseInfo *response) {
        [weakSelf.tableView.header endRefreshing];
        if (response && response.success) {
            NSArray *JKlist = [JKModel objectArrayWithKeyValuesArray:[response.content objectForKey:@"contact_apply_job_resume_list"]];
            weakSelf.dataSource = [JKlist mutableCopy];
            [weakSelf.tableView reloadData];
            weakSelf.viewWithNoNetwork.hidden = YES;
            self.viewWithNoData.hidden = JKlist.count > 0;
            weakSelf.queryParam.page_num = @(weakSelf.queryParam.page_num.integerValue + 1);
        }else{
            weakSelf.viewWithNoData.hidden = YES;
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
    }];
}

- (void)footerRefresh{
    WEAKSELF
    [[XSJRequestHelper sharedInstance] queryContactApplyJobResumeList:self.queryParam jobId:self.jobId block:^(ResponseInfo *response) {
        [weakSelf.tableView.footer endRefreshing];
        if (response && response.success) {
            NSArray *JKlist = [JKModel objectArrayWithKeyValuesArray:[response.content objectForKey:@"contact_apply_job_resume_list"]];
            if (JKlist.count > 0) {
                [weakSelf.dataSource addObjectsFromArray:JKlist];
                [weakSelf.tableView reloadData];
                weakSelf.queryParam.page_num = @(weakSelf.queryParam.page_num.integerValue + 1);
            }
        }
    }];
}

#pragma mark - uiatbleview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource ? self.dataSource.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JKCallListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JKCallListCell" forIndexPath:indexPath];
    JKModel *model = [self.dataSource objectAtIndex:indexPath.row];
    WEAKSELF
    [cell setData:model callBack:^(id result) {
        [weakSelf makeCallWithPhone:model.stu_telephone.description];
    }];
    return cell;
}

#pragma mark - uitableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 71.0f;
}

- (void)makeCallWithPhone:(NSString *)phone{
    [[MKOpenUrlHelper sharedInstance] callWithPhone:phone];
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
