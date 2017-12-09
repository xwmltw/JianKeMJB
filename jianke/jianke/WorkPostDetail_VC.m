//
//  WorkPostDetail_VC.m
//  jianke
//
//  Created by xiaomk on 16/4/26.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WorkPostDetail_VC.h"
#import "WorkPostDetailConfirm_VC.h"
#import "AddAchieveJK_VC.h"

@interface WorkPostDetail_VC ()

@property (nonatomic, strong) WorkPostDetailConfirm_VC* leftVC;
@property (nonatomic, strong) WorkPostDetailConfirm_VC* rightVC;
@end

@implementation WorkPostDetail_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"上岗详情";
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:@"添加接收人" style:UIBarButtonItemStyleDone target:self action:@selector(btnAddOclick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    [self initTopWithLeftTitle:@"未确认" rightTitle:@"已确认"];
    
    WorkPostDetailConfirm_VC* leftVC = [[WorkPostDetailConfirm_VC alloc] init];
    leftVC.type = WorkPostDetailCellType_NO;
    leftVC.jobId = self.jobId;
    [self addChildViewController:leftVC];
    [self setLView:leftVC.view];
    self.leftVC = leftVC;
    
    WorkPostDetailConfirm_VC* rightVC = [[WorkPostDetailConfirm_VC alloc] init];
    rightVC.type = WorkPostDetailCellType_YES;
    rightVC.jobId = self.jobId;
    [self addChildViewController:rightVC];
    [self setRView:rightVC.view];
    self.rightVC = rightVC;
    
}

- (void)btnAddOclick:(UIBarButtonItem*)sender{
    AddAchieveJK_VC* vc = [[AddAchieveJK_VC alloc] init];
    vc.job_id = self.jobId;
    WEAKSELF
    vc.block = ^(BOOL bRet){
        [weakSelf.leftVC loadDataSource];
        [weakSelf.rightVC loadDataSource];
    };
    [self.navigationController pushViewController:vc animated:YES];
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
