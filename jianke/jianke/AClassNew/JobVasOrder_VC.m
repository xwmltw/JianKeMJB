//
//  JobVasOrder_VC.m
//  jianke
//
//  Created by fire on 16/9/24.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JobVasOrder_VC.h"
#import "JianKeAppreciation_VC.h"
#import "JobVasOrderCell.h"

@interface JobVasOrder_VC () <JobVasOrderCellDelegate>

@property (nonatomic, strong) JobVasResponse *model;
@property (nonatomic, strong) NSMutableDictionary<NSNumber * , NSNumber *> *cellHeightDic;   /*!< cell高度 */

@end

@implementation JobVasOrder_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"付费推广";
    self.tableViewStyle = UITableViewStyleGrouped;
    [self initUIWithType:DisplayTypeOnlyTableView];
    [self.tableView registerNib:nib(@"JobVasOrderCell") forCellReuseIdentifier:@"aJobVasOrderCell"];
    
    self.cellHeightDic = [NSMutableDictionary dictionary];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)getData{
    WEAKSELF
    [[XSJRequestHelper sharedInstance] queryJobVasInfo:self.jobId block:^(ResponseInfo *result) {
        if (result) {
            weakSelf.model = [JobVasResponse objectWithKeyValues:result.content];
            [weakSelf loadUIData];
        }
    }];
}

- (void)loadUIData{
    if (self.dataSource.count == 0) {
        [self.dataSource addObject:@(Appreciation_stick_Type)];
        [self.dataSource addObject:@(Appreciation_Refresh_Type)];
        [self.dataSource addObject:@(Appreciation_push_Type)];
    }
//    [self.dataSource removeAllObjects];

    [self.tableView reloadData];
}

#pragma mark - uitableview datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource ? self.dataSource.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JobVasOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"aJobVasOrderCell" forIndexPath:indexPath];
    AppreciationType type = ((NSNumber *)[self.dataSource objectAtIndex:indexPath.section]).integerValue;
    cell.delegate = self;
    [cell setData:self.model andType:type cellDic:self.cellHeightDic];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [self.cellHeightDic objectForKey:[self.dataSource objectAtIndex:indexPath.section]].floatValue;
    return height;
}

#pragma mark - JobVasOrderCell delegate

- (void)jobVasOrderCell:(JobVasOrderCell *)cell actionType:(NSInteger)type{
    JianKeAppreciation_VC *viewCtrl = [[JianKeAppreciation_VC alloc] init];
    viewCtrl.serviceType = type;
    viewCtrl.jobId = self.jobId;
    viewCtrl.popToVC = self;
    [self.navigationController pushViewController:viewCtrl animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 21.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01f;
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
