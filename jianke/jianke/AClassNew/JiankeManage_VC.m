//
//  JiankeManage_VC.m
//  jianke
//
//  Created by xiaomk on 16/6/29.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JiankeManage_VC.h"
#import "PersonnelManager_VC.h"
#import "EmployList_TV.h"
#import "EmployExaManager_VC.h"
#import "PayWage_VC.h"
#import "PayExactWageManager_VC.h"
#import "EPActionSheetItem.h"
#import "JobModel.h"
#import "ShareToGroupController.h"
#import "QrCodeViewController.h"
#import "CityTool.h"
#import "MakeCheck_VC.h"

@interface JiankeManage_VC()<PersonnelManagerDelegate,EmployListDelegate,EmployExaManagerDelegate>{

}

@end

@implementation JiankeManage_VC



- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"兼客管理";
    
    NSArray *titleArray = [[NSArray alloc] initWithObjects:@"人员管理",@"考勤管理",@"发放工资", nil];

    [self initUIWithTitleArray:titleArray];
    
    PersonnelManager_VC *pmVC = [[PersonnelManager_VC alloc] init];
    pmVC.jobId = self.jobId;
    pmVC.managerType = self.managerType;
    pmVC.isAccurateJob = self.isAccurateJob;
    pmVC.delegate = self;
    [self.vcArray addObject:pmVC];

    if (self.isAccurateJob.integerValue == 1) {     //精确岗位
        EmployExaManager_VC *emVC = [[EmployExaManager_VC alloc] init];
        emVC.jobId = self.jobId;
        emVC.managerType = self.managerType;
        emVC.isAccurateJob = self.isAccurateJob;
        emVC.jobModel = self.jobModel;
        emVC.delegate = self;
        [self.vcArray addObject:emVC];
        
    }else{      //松散岗位
        EmployList_TV *elVC = [[EmployList_TV alloc] init];
        elVC.jobId = self.jobId;
        elVC.managerType = self.managerType;
        elVC.isAccurateJob = self.isAccurateJob;
        elVC.delegate = self;
        [self.vcArray addObject:elVC];
    }

    
    if (self.managerType == ManagerTypeEP) {
        if (self.isAccurateJob.integerValue == 1) {
            PayExactWageManager_VC *payVc = [[PayExactWageManager_VC alloc] init];
            payVc.isMutiVC = YES;
            payVc.jobId = self.jobId;
            payVc.isAccurateJob = self.isAccurateJob;
            payVc.jobModel = self.jobModel;
            [self.vcArray addObject:payVc];
        }else{
            PayWage_VC *payVc = [[PayWage_VC alloc] init];
            payVc.jobId = self.jobId;
            [self.vcArray addObject:payVc];
        }
    }else{
        MakeCheck_VC *mcVc = [[MakeCheck_VC alloc] init];
        mcVc.jobId = self.jobId;
        mcVc.jobModel =  self.jobModel;
        [self.vcArray addObject:mcVc];
    }
    
    [self initVcArrayOverAndShowFirstVCWithIndex:0];
    
    if (!self.isClose) {
        UIButton *btnEvent = [UIButton buttonWithType:UIButtonTypeCustom];
        btnEvent.frame = CGRectMake(0, 0, 44, 44);
        [btnEvent setImage:[UIImage imageNamed:@"v3_mgr_add"] forState:UIControlStateNormal];
        [btnEvent addTarget:self action:@selector(btnEventOnClick:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:btnEvent];
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

/** 返回  判断 发放工资 是否有 添加 发放对象 */
- (void)backToLastView{
    UIViewController *vc = [self.vcArray objectAtIndex:2];
    
    if ([vc respondsToSelector:@selector(getIsHaveAddPayJianke)]) {
        if ([vc performSelector:@selector(getIsHaveAddPayJianke) withObject:nil]) {
            [UIHelper showConfirmMsg:@"添加人员的工资还未发放，离开页面将导致添加列表失去，请及时发放工资." title:nil cancelButton:@"留在该页面" okButton:@"果断离开" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            return;
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)scrollViewDidEventWithScroll:(UIScrollView *)scrollView{
    if (self.slideVCType == MKSlideVCType_scrollView) {
        NSInteger currentIndex = [self getCurrentSelectBtnIndex];
        if (currentIndex > 0 && currentIndex < self.vcArray.count) {
            UIViewController *vc = [self.vcArray objectAtIndex:currentIndex];
            
            if ([vc respondsToSelector:@selector(getDataWhenShow)]) {
                [vc performSelector:@selector(getDataWhenShow) withObject:nil];
            }
            
//            if (_isChangeToPayDate && _changToPayDateIndex >= 0) {
//                _isChangeToPayDate = NO;
//                if ([vc respondsToSelector:@selector(getDataShowChangeToPayWithIndex:)]) {
//                    [vc performSelector:@selector(getDataShowChangeToPayWithIndex:) withObject:@(_changToPayDateIndex)];
//                }
//            }else{
//                
//            }
        }
    }
}

#pragma mark - ***** PersonnelManagerDelegate ******
- (void)pmd_setOtherVcRefreshStatus{
    for (UIViewController *vc in self.vcArray) {
        if ([vc respondsToSelector:@selector(setNeedRefresh)]) {
            [vc performSelector:@selector(setNeedRefresh) withObject:nil];
        }
    }
}

#pragma mark - ***** PersonnelManagerDelegate ******
- (void)pmd_setTitle:(NSString *)title withIndex:(NSInteger)titleIndex{
    [self setBtnTitle:title withIndex:titleIndex];
}

#pragma mark - ***** EmployListDelegate ******
- (void)eld_setSelectVcWithIndex:(NSInteger)index{
    [self setSelectVcWithIndex:index];
}

#pragma mark - ***** EmployExaManagerDelegate ******
- (void)changeSelectVcWithIndex:(NSInteger)vcIndex showDetailIndex:(NSInteger)detailIndex{
    [self setSelectVcWithIndex:vcIndex];
}


#pragma mark - ***** more button ******
- (void)btnEventOnClick:(UIButton *)sender{
    
    EPActionSheetItem *qrCodeItem = [[EPActionSheetItem alloc] initWithImgName:@"v260_code" title:@"二维码" arg:nil];
    EPActionSheetItem *reflushItem = [[EPActionSheetItem alloc] initWithImgName:@"v260_ep_share" title:@"分享" arg:nil];
    EPActionSheetItem *shareItem = [[EPActionSheetItem alloc] initWithImgName:@"v260_ep_update" title:@"刷新" arg:nil];
    EPActionSheetItem *closeItem = [[EPActionSheetItem alloc] initWithImgName:@"v260_ep_close" title:@"结束招聘" arg:nil];
    
    MKActionSheet *sheet = [[MKActionSheet alloc] initWithTitle:nil objArray:@[qrCodeItem,reflushItem,shareItem,closeItem] titleKey:@"title"];
    [sheet setImageKey:@"imgName" imageValueType:MKActionSheetButtonImageValueType_name];
    sheet.needCancelButton = NO;
    WEAKSELF
    [sheet showWithBlock:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
        switch (buttonIndex) {
            case 0: // 二维码
            {
                [weakSelf qrBtnClick];
            }
                break;
            case 1: // 分享
            {
                [weakSelf btnShareClick];
            }
                break;
            case 2: // 刷新
            {
                [weakSelf btnRefreshJobOnClick];
            }
                break;
            case 3: // 结束招聘
            {
                [weakSelf btnOverJobOnClick];
            }
                break;
            default:
                break;
        }

    }];
}

/** 二维码 */
- (void)qrBtnClick{
    WEAKSELF
    [[UserData sharedInstance] entRefreshJobQrCodeWithJobId:self.jobModel.job_id.stringValue block:^(ResponseInfo *response) {
        if (response.success) {
            
            NSString *qrCode = response.content[@"qr_code"];
            NSString *expireTime = response.content[@"expire_time"];
            
            QrCodeViewController *vc = [[QrCodeViewController alloc] init];
            vc.qrCode = qrCode;
            vc.expireTime = @(expireTime.longLongValue);
            vc.jobId = weakSelf.jobModel.job_id.stringValue;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    }];
}

/** 分享 */
- (void)btnShareClick{
    WEAKSELF
    [ShareHelper jobShareWithVc:self info:self.jobModel.share_info_not_sms block:^(NSNumber *obj) {
        switch (obj.integerValue) {
            case ShareTypeInvitePerson: // 分享到人才库
            {
                [[UserData sharedInstance] entShareJobToTalentPoolWithJobId:weakSelf.jobModel.job_id.description];
            }
                break;
            case ShareTypeIMGroup: // 分享到IM群组
            {
                ShareToGroupController *vc = [[ShareToGroupController alloc] init];
                vc.jobModel = weakSelf.jobModel;
                vc.isBackToRootView = YES;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }
        
    }];
}

/** 刷新 */
- (void)btnRefreshJobOnClick{
    NSString* content = [NSString stringWithFormat:@"job_id:%@", self.jobId];
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_updateParttimeJobRanking" andContent:content];
    request.isShowLoading = YES;
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            [UIHelper toast:@"刷新成功"];
        }
    }];
}

/** 结束招聘 */
- (void)btnOverJobOnClick{
    [TalkingData trackEvent:@"正在招人_结束岗位"];
    if (self.jobModel.status.intValue == 2) {
        WEAKSELF
        [UIHelper showConfirmMsg:@"确定结束?" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weakSelf closeJob:weakSelf.jobModel.job_id];
            }
        }];
    }
}
/** 关闭岗位 **/
- (void)closeJob:(NSNumber *)jobId{
    NSString* content = [NSString stringWithFormat:@"job_id:%@", jobId];
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_closeJob" andContent:content];
    request.isShowLoading = YES;
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            [UIHelper toast:@"关闭成功"];
            [UserData sharedInstance].isUpdateWithEPHome = YES;
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
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
