//
//  HistoryPostJob_VC.m
//  jianke
//
//  Created by xiaomk on 16/8/23.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "HistoryPostJob_VC.h"
#import "JobExpressCell.h"
#import "JobModel.h"

@interface HistoryPostJob_VC ()<UITableViewDelegate, UITableViewDataSource>{
    BOOL _isGetMore;
    QueryParamModel* _queryParam;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayData;

@end

@implementation HistoryPostJob_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"历史岗位模板";
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    NSString *noDataStr;
    if (self.postJobType == PostJobType_common) {
        noDataStr = @"您还没有发布过普通岗位哦";
    }else if (self.postJobType == PostJobType_bd){
        noDataStr = @"您还没有发布过包招岗位哦";
    }else if (self.postJobType == PostJobType_fast){
        noDataStr = @"您还没有发布过快招岗位哦";
    }
    [self initWithNoDataViewWithStr:noDataStr onView:self.tableView];
    
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getLastData)];
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMoreData)];

    self.arrayData = [[NSMutableArray alloc] init];
    [self getLastData];
}

- (void)getLastData{
    _isGetMore = NO;
    [self getData];
}

- (void)getMoreData{
    _isGetMore = YES;
    [self getData];
}


- (void)getData{
    GetEnterpriscJobModel *reqModel = [[GetEnterpriscJobModel alloc] init];
    reqModel.query_type = @(6);
    if (self.postJobType == PostJobType_common) {
        reqModel.job_type = @(1);
    }else if (self.postJobType == PostJobType_bd){
        reqModel.job_type = @(3);
    }else if (self.postJobType == PostJobType_fast){
        reqModel.job_type = @(4);
    }
    if (_isGetMore && _queryParam) {
        reqModel.query_param = _queryParam;
    }else{
        reqModel.query_param = [[QueryParamModel alloc] initWithPageSize:@(30) pageNum:@(1)];
    }
    
    NSString* content = [reqModel getContent];
    
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_getEnterpriseSelfJobList_v2" andContent:content];
    request.isShowLoading = YES;
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        [weakSelf.tableView.header endRefreshing];
        weakSelf.viewWithNoData.hidden = YES;
        weakSelf.viewWithNoNetwork.hidden = YES;
        
        if (response && [response success]) {
            _queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
            if (_queryParam) {
                _queryParam.page_num = @(_queryParam.page_num.integerValue + 1);
            }
            
            if (!_isGetMore) {
                [weakSelf.arrayData removeAllObjects];
            }
            
            NSArray *tempArray = [JobModel objectArrayWithKeyValuesArray:response.content[@"job_list"]];
        
            if (tempArray && tempArray.count) {
                [weakSelf.arrayData addObjectsFromArray:tempArray];
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.footer endRefreshing];

            }else{
                [weakSelf.tableView reloadData];
                weakSelf.tableView.footer.state = MJRefreshStateNoMoreData;
            }
            
            if (weakSelf.arrayData.count == 0) {
                //无数据
                weakSelf.viewWithNoData.hidden = NO;
            }
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
            [weakSelf.tableView.footer endRefreshing];
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JobExpressCell* cell = [JobExpressCell cellWithTableView:tableView];
    
    if (self.arrayData.count <= indexPath.row) {
        return cell;
    }
    
    JobModel* model = self.arrayData[indexPath.row];
    [cell refreshWithData:model];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v210_pressed_background"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JobModel* model = self.arrayData[indexPath.row];
    if (model) {
        MKBlockExec(self.block, model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayData.count ? self.arrayData.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 94;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
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
