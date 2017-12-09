//
//  BdOrderController.m
//  jianke
//
//  Created by fire on 15/12/10.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "BdOrderController.h"
#import "BDManagerTableView.h"
#import "XSJConst.h"

@interface BdOrderController ()

@property (nonatomic, strong) BDManagerTableView *bdTableView;

@end

@implementation BdOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"包招管理";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor XSJColor_grayDeep];
    [self.view addSubview:tableView];
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    BDManagerTableView *bdTableView = [[BDManagerTableView alloc] init];
    bdTableView.tableView = tableView;
    bdTableView.owner = self;
    bdTableView.managerType = ManagerTypeBD;
    self.bdTableView = bdTableView;
    
    [bdTableView getLastData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
