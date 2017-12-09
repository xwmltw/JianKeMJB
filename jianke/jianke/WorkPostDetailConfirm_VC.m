//
//  WorkPostDetailConfirm_VC.m
//  jianke
//
//  Created by xiaomk on 16/4/26.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WorkPostDetailConfirm_VC.h"
#import "AddAchieveJK_VC.h"
#import "JKModel.h"
#import "WPDetailConfirmNoCell.h"
#import "WPDetailConfirmYesCell.h"

@interface WorkPostDetailConfirm_VC ()

@end

@implementation WorkPostDetailConfirm_VC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUISingleTableView];
    [self setIsNeedHeadRefresh:YES];
    [self initWithNoDataViewWithStr:@"暂无上岗信息" onView:self.tableView];
    [self loadDataSource];
}

- (void)loadDataSource{
    QueryConfirmModel* model = [[QueryConfirmModel alloc] init];
    model.job_id = self.jobId;
    if (self.type == WorkPostDetailCellType_NO) {
        model.list_type = @(2);
    }else if (self.type == WorkPostDetailCellType_YES){
        model.list_type = @(3);
    }
    NSString* content = [model getContent];
    
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc] initWithService:@"shijianke_queryConfirmToWorkStuList" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            NSArray* array = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];
            if (array && array.count >  0) {
                weakSelf.datasArray = [NSMutableArray arrayWithArray:array];
                weakSelf.viewWithNoData.hidden = YES;
            }else{
                weakSelf.viewWithNoData.hidden = NO;
            }
            [weakSelf.tableView reloadData];
            weakSelf.viewWithNoNetwork.hidden = YES;
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
        [weakSelf.tableView.header endRefreshing];
        [weakSelf.tableView.footer endRefreshing];
    }];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.type == WorkPostDetailCellType_NO) {
        static NSString* cellIdentifier = @"cellPost";
        WPDetailConfirmNoCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [WPDetailConfirmNoCell new];
        }
        JKModel* model = [self.datasArray objectAtIndex:indexPath.row];
        [cell refreshWithData:model andIndexPath:indexPath];
        return cell;
    }else if (self.type == WorkPostDetailCellType_YES){
        static NSString* cellIdentifier = @"cellPost";
        WPDetailConfirmYesCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [WPDetailConfirmYesCell new];
        }
        JKModel* model = [self.datasArray objectAtIndex:indexPath.row];
        [cell refreshWithData:model andIndexPath:indexPath];
        return cell;
    }
    return nil;
   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
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
