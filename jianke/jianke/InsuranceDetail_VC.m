//
//  InsuranceDetail_VC.m
//  jianke
//
//  Created by 时现 on 15/12/7.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "InsuranceDetail_VC.h"
#import "InsuranceDetailCell.h"
#import "WDConst.h"
#import "UserData.h"
#import "InsuranceDetailModel.h"
#import "BuyInsurance_VC.h"

@interface InsuranceDetail_VC ()<UITableViewDataSource,UITableViewDelegate>
{
    InsuranceDetailModel *_idModel;
}
@property (nonatomic, strong) QueryParamModel *queryParam;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayData; /*!< 一维InsuranceDetailModel数组 */
@property (nonatomic, strong) NSMutableArray *insuranceArray; /*!< 二维InsuranceDetailModel数组 */

@property (nonatomic, copy) NSString *timeStr;//header标题

@end

@implementation InsuranceDetail_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"投保详情";
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    self.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView.header beginRefreshing];
    [self getLastData];
}


- (void)getLastData{
    self.queryParam = [[QueryParamModel alloc] init];
    self.queryParam.page_num = @(1);
    self.queryParam.page_size = @(30);
    self.queryParam.timestamp = @((long)([[NSDate date] timeIntervalSince1970] * 1000));
    
    NSString *content = [NSString stringWithFormat:@"%@,account_money_detail_list_id:\"%@\"",[self.queryParam getContent],self.account_money_detail_list_id];
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_queryInsurancePolicyDetail" andContent:content];
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && response.success) {
            NSArray *array = [InsuranceDetailModel objectArrayWithKeyValuesArray:response.content[@"stu_list"]];
            weakSelf.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
            weakSelf.arrayData = [NSMutableArray arrayWithArray:array];
            if (weakSelf.arrayData.count) {
                weakSelf.tableView.footer.hidden = NO;
                [weakSelf sortOriArray];
                [weakSelf.tableView reloadData];
            }else{
                weakSelf.tableView.footer.hidden = YES;
            }
        }
        [weakSelf.tableView.header endRefreshing];
    }];

}

-(void)sortOriArray
{
    NSArray *insuranceTimeArray = [self.arrayData valueForKeyPath:@"insurance_time"];
    
    //去重
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSNumber * insuranceTime in insuranceTimeArray) {
        [dic setObject:insuranceTime forKey:insuranceTime];
    }
    insuranceTimeArray = [dic allKeys];
    
//    排序
    insuranceTimeArray = [insuranceTimeArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber * obj1, NSNumber * obj2) {
        if (obj1.longLongValue < obj2.longLongValue) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }];
    
    
    //创建二维数组
    
    self.insuranceArray = [NSMutableArray array];
    for (NSNumber *insuraceTime in insuranceTimeArray) {
        
        NSArray *tmpArray = [self.arrayData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"insurance_time.longValue == %ld",insuraceTime.longValue]];
        
        
        if (tmpArray && tmpArray.count) {
            [self.insuranceArray addObject:tmpArray];
        }
    }

}
-(void)getMoreData
{
    self.queryParam.page_num = @(self.queryParam.page_num.integerValue + 1);
    self.queryParam.timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
    
    NSString *content = [NSString stringWithFormat:@"%@,account_money_detail_list_id:\"%@\"",[self.queryParam getContent],self.account_money_detail_list_id];
    RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_queryInsurancePolicyDetail" andContent:content];
    
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        
        if (response && response.success) {

            NSArray *newArray = [InsuranceDetailModel objectArrayWithKeyValuesArray:response.content[@"stu_list"]];
            
            if (!newArray || !newArray.count) {
                
                self.tableView.footer.hidden = YES;
                [self.tableView.footer endRefreshing];
                return;
            }
            
            [self.arrayData addObjectsFromArray:newArray];
            [self sortOriArray];
            self.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
            [self.tableView reloadData];

        }
        [self.tableView.footer endRefreshing];
        
    }];

    
    
}
#pragma mark - UItableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InsuranceDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InsuranceDetailCell"];
    
    if (cell == nil) {
        cell = [InsuranceDetailCell new];
    }
    _idModel = self.insuranceArray[indexPath.section][indexPath.row];
    [cell refreshWithData:_idModel];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.insuranceArray) {
        return [self.insuranceArray[section] count];
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.insuranceArray) {
        return self.insuranceArray.count;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    InsuranceDetailModel *model = [self.insuranceArray[section] firstObject];
    NSString *timeStr = [DateHelper jobBillTimeStrWithNum:model.insurance_time];
    
    UIView *sectionHeadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    sectionHeadView.backgroundColor = MKCOLOR_RGB(240, 240, 240);
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = MKCOLOR_RGB(200, 200, 200);
    label.textColor = [UIColor whiteColor];
    label.text = timeStr;
    label.font = [UIFont systemFontOfSize:13];
    label.layer.cornerRadius = 2;
    label.clipsToBounds = YES;
    [sectionHeadView addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@(21));
        make.centerX.equalTo(sectionHeadView);
        make.centerY.equalTo(sectionHeadView);
    }];
    
    return sectionHeadView;
}
-(void)backToLastView
{
    if (self.isFromMoneyBag) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        BuyInsurance_VC *vc = [UIHelper getVCFromStoryboard:@"EP" identify:@"sid_BuyInsurance_VC"];
        UIViewController *target = nil;
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[vc class]]) {
                target = controller;
            }
        }
        if (target) {
            [self.navigationController popToViewController:target animated:YES];
        }
    }
}
@end
