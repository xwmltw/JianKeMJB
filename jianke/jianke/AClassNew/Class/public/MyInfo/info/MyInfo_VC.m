//
//  MyInfo_VC.m
//  jianke
//
//  Created by xiaomk on 16/6/7.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "MyInfo_VC.h"
#import "XSJConst.h"
#import "MyInfoCell_0.h"
#import "MyInfoCell_1.h"

#import "SettingController.h"

#import "MoneyBag_VC.h"
#import "WebView_VC.h"
#import "InterestJob_VC.h"

#import "LookupResume_VC.h"

#import "BDCheckManager_VC.h"
#import "BdOrderController.h"
#import "TalentPoolController.h"

#import "EditEmployerInfo_VC.h"

#import "AccountMoneyModel.h"
#import "Login_VC.h"
#import "IdentityCardAuth_VC.h"
#import "CityTool.h"
#import "XSJUserInfoData.h"
#import "NetworkTest_VC.h"
#import "SocialActivist_VC.h"
#import "ZPSalary_VC.h"
#import "JobCollection_VC.h"
#import "NewSocialActivist_VC.h"
#import "EpProfile_VC.h"


@interface MyInfo_VC ()<UITableViewDelegate, UITableViewDataSource>{
    JKModel *_jkInfo;
    EPModel *_epInfo;
    NSInteger _loginType;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datasArray;
@end

@implementation MyInfo_VC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateUserModel];
}

- (void)viewDidLoad {
    self.isRootVC = YES;
    [super viewDidLoad];

    self.title = @"我";
    //登录成功通知
    [WDNotificationCenter addObserver:self selector:@selector(loginSuccessNotifi) name:WDNotifi_LoginSuccess object:nil];
    [WDNotificationCenter addObserver:self selector:@selector(updateMoneyBagRedPoint) name:IMPushWalletNotification object:nil];
    [WDNotificationCenter addObserver:self selector:@selector(showBaozhaoCheckRedPoint) name:IMNotification_BDSendBillForPayToEP object:nil];

    _loginType = [[UserData sharedInstance] getLoginType].integerValue;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.datasArray = [[NSMutableArray alloc] init];
    [self loadDatas];
    
    WEAKSELF
    CityModel *ctModel = [[UserData sharedInstance] city];
    [CityTool getCityModelWithCityId:ctModel.id block:^(CityModel* obj) {
        if (obj) {
            [[UserData sharedInstance] setCity:obj];
            [weakSelf loadDatas];
            [weakSelf initUserInfo];
        }
    }];
}

- (void)loadDatas{
    [self.datasArray removeAllObjects];
    CityModel *cityModel = [[UserData sharedInstance] city];

    if (_loginType == WDLoginType_JianKe) {
        NSMutableArray *ary1 = [[NSMutableArray alloc] init];
        [ary1 addObject:@(JKMyInfoCellType_login)];
        
        NSMutableArray *ary2 = [[NSMutableArray alloc] init];
        [ary2 addObject:@(JKMyInfoCellType_moneyBag)];
        [ary2 addObject:@(JKMyInfoCellType_personalService)];
        [ary2 addObject:@(JKMyInfoCellType_advanceSalary)];
        
        if (cityModel.socialActivistPortal.integerValue == 1) {
            [ary2 addObject:@(JKMyInfoCellType_socialActivist)];
        }
        
        NSMutableArray *ary3 = [[NSMutableArray alloc] init];
        [ary3 addObject:@(JKMyInfoCellType_jobCollect)];
        [ary3 addObject:@(JKMyInfoCellType_interestJob)];
//        [ary3 addObject:@(JKMyInfoCellType_appRecommend)];
        [ary3 addObject:@(MyInfoCellType_shareJK)];
        [ary3 addObject:@(MyInfoCellType_guide)];
        [ary3 addObject:@(MyInfoCellType_setting)];
        
        NSMutableArray *ary4 = [[NSMutableArray alloc] init];
        [ary4 addObject:@(JKMyInfoCellType_switchToEP)];
#ifdef DEBUG
        [ary4 addObject:@(MyInfoCellType_debugVC)];
#endif
        [self.datasArray addObject:ary1];
        [self.datasArray addObject:ary2];
        [self.datasArray addObject:ary3];
        [self.datasArray addObject:ary4];
        
    }else if (_loginType == WDLoginType_Employer){
        [TalkingData trackEvent:@"雇主_个人中心页面"];
        NSMutableArray *ary1 = [[NSMutableArray alloc] init];
        [ary1 addObject:@(EPMyInfoCellType_login)];
        
        NSMutableArray *ary2 = [[NSMutableArray alloc] init];
        [ary2 addObject:@(EPMyInfoCellType_moneyBag)];
        
        if ([[UserData sharedInstance] isLogin] && _epInfo.identity_mark.integerValue == 2) {
            [ary2 addObject:@(EPMyInfoCellType_inviteBalance)];     //招聘余额
        }
        
        NSMutableArray *ary3 = [[NSMutableArray alloc] init];
        if (cityModel.enablePartnerService.integerValue == 1){
//            [ary3 addObject:@(EPMyInfoCellType_partner)];
        }
//        if (_epInfo && _epInfo.is_bd_bind_account.integerValue == 1) { //是bd
//            [ary3 addObject:@(EPMyInfoCellType_baozhaoMgr)]; //包招管理
//        }
//        [ary3 addObject:@(EPMyInfoCellType_baozhaoCheck)]; //包招账单

//        NSMutableArray *ary4 = [[NSMutableArray alloc] init];
        [ary3 addObject:@(EPMyInfoCellType_jiankeLib)];
        [ary3 addObject:@(EPMyInfoCellType_zongbao)];
      
        NSMutableArray *ary5 = [[NSMutableArray alloc] init];
        CityModel* city = [[UserData sharedInstance] city];
        if (city && city.contactQQ.integerValue > 10000) {
            [ary5 addObject:@(EPMyInfoCellType_contactMgr)];
        }
        
        [ary5 addObject:@(MyInfoCellType_shareJK)];
        [ary5 addObject:@(MyInfoCellType_guide)];
        [ary5 addObject:@(MyInfoCellType_setting)];
        
        NSMutableArray *ary6 = [[NSMutableArray alloc] init];
        [ary6 addObject:@(EPMyInfoCellType_switchToJK)];
#ifdef DEBUG
        [ary6 addObject:@(MyInfoCellType_debugVC)];
#endif
        [self.datasArray addObject:ary1];
        [self.datasArray addObject:ary2];
        [self.datasArray addObject:ary3];
//        [self.datasArray addObject:ary4];
        [self.datasArray addObject:ary5];
        [self.datasArray addObject:ary6];
    }
    MKDispatch_main_async_safe(^{
        [self.tableView reloadData];
    });
}

- (void)initUserInfo{
    if ([[UserData sharedInstance] isLogin]) {
        if (_loginType == WDLoginType_JianKe) {
            _jkInfo = [[UserData sharedInstance] getJkModelFromHave];
            if (_jkInfo) {
                [self loadDatas];
            }else{
                [self updateUserModel];
            }
        }else if (_loginType == WDLoginType_Employer){
            _epInfo = [[UserData sharedInstance] getEpModelFromHave];
            if (_epInfo) {
                [self loadDatas];
            }else{
                [self updateUserModel];
            }
        }
    }
}

- (void)updateUserModel{
    if ([[UserData sharedInstance] isLogin]) {
        WEAKSELF
        [[UserData sharedInstance] getJKModelWithBlock:^(JKModel* obj) {
            _jkInfo = obj;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf loadDatas];
            });
        }];
    }
}

#pragma mark - ***** 通知处理 ******
- (void)loginSuccessNotifi{
    [self updateUserModel];
}

- (void)updateMoneyBagRedPoint{
    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.tableView reloadData];
        [self updateUserModel];
    });
}

- (void)showBaozhaoCheckRedPoint{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_epInfo && _epInfo.is_bd_bind_account.integerValue == 1) {
            return;
        }
        [self.tableView reloadData];
    });
}

#pragma mark - ***** UITableView delegate ******
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyInfoCellType type = [self.datasArray[indexPath.section][indexPath.row] integerValue];
    switch (type) {
        case JKMyInfoCellType_login:
        case EPMyInfoCellType_login:{

            MyInfoCell_0 *cell = [MyInfoCell_0 cellWithTableView:tableView];
            cell.vipImg.hidden = YES;
            [cell.btnHead setToCircle];
            cell.btnHead.userInteractionEnabled = NO;
            
            [cell.btnLogin addTarget:self action:@selector(btnLoginOnclicked:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnRegister addTarget:self action:@selector(btnRegister:) forControlEvents:UIControlEventTouchUpInside];
            [cell.btnAuth addTarget:self action:@selector(btnAuthOnclick:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.btnRegister setCorner];
            
            if ([[UserData sharedInstance] isLogin]) {
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;

                cell.btnAuth.hidden = NO;
                cell.labName.hidden = NO;
                cell.btnLogin.hidden = YES;
                cell.btnRegister.hidden = YES;
                NSString *nameStr;
                NSString *profileUrlStr;
                int verifyStatus;
                if (type == JKMyInfoCellType_login) {
                    nameStr = _jkInfo.true_name;
                    profileUrlStr = _jkInfo.profile_url;
                    verifyStatus = _jkInfo.id_card_verify_status.intValue;
                }else if (type == EPMyInfoCellType_login){
                    nameStr = _epInfo.true_name;
                    profileUrlStr = _epInfo.profile_url;
                    verifyStatus = _epInfo.id_card_verify_status.intValue;
                    cell.vipImg.hidden = YES;
                }
                cell.labName.text = nameStr;
                [cell.btnHead sd_setBackgroundImageWithURL:[NSURL URLWithString:profileUrlStr] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHead]];
                switch (verifyStatus) {
                    case 1:{
                        [cell.btnAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_no"] forState:UIControlStateNormal];
                    }
                        break;
                    case 2:
                        [cell.btnAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ing"] forState:UIControlStateNormal];
                        cell.btnAuth.userInteractionEnabled = NO;
                        break;
                    case 3:
                        [cell.btnAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_yes"] forState:UIControlStateNormal];
                        cell.btnAuth.userInteractionEnabled = NO;
                        break;
                    case 4:
                        [cell.btnAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_no"] forState:UIControlStateNormal];
                        break;
                    default:
                        break;
                }
                
            }else{
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.btnAuth.hidden = YES;
                cell.labName.hidden = YES;
                
                cell.btnLogin.hidden = NO;
                cell.btnRegister.hidden = NO;
            }
            return cell;
        }
        case JKMyInfoCellType_moneyBag:
        case EPMyInfoCellType_moneyBag:{
            MyInfoCell_1 *cell = [MyInfoCell_1 cellWithTableView:tableView];
            [cell.labAdvanceMoney setCorner];
            [cell.labRedPoint setToCircle];
            cell.labRedPoint.hidden = YES;
            cell.labAdvanceMoney.hidden = YES;
            cell.labMoney.text = @"0";
            
            if ([[UserData sharedInstance] isLogin]) {
                cell.labRedPoint.hidden = ![XSJUserInfoData sharedInstance].isShowMoneyBadRedPoint;

                if (_loginType == WDLoginType_Employer && _epInfo) {
                    NSString* moneyStr = [NSString stringWithFormat:@"%0.2f", _epInfo.acct_amount.floatValue*0.01];
                    cell.labMoney.text = moneyStr;
                    
                    if (_epInfo.advance_amount && _epInfo.advance_amount.integerValue > 0) {
                        cell.labAdvanceMoney.hidden = NO;
                        cell.labAdvanceMoney.text = [NSString stringWithFormat:@" 预付款: %0.2f ",_epInfo.advance_amount.floatValue*0.01];
                    }
                    
                }else if (_loginType == WDLoginType_JianKe && _jkInfo){
                    NSString* moneyStr = [NSString stringWithFormat:@"%0.2f", _jkInfo.acct_amount.floatValue*0.01];
                    cell.labMoney.text = moneyStr;
                }

            }
            return cell;
        }
        case JKMyInfoCellType_advanceSalary:
        case JKMyInfoCellType_socialActivist:
        case JKMyInfoCellType_jobCollect:
        case JKMyInfoCellType_interestJob:
//        case JKMyInfoCellType_appRecommend:
        case JKMyInfoCellType_switchToEP:
        case MyInfoCellType_shareJK:
        case MyInfoCellType_guide:
        case MyInfoCellType_setting:
        case EPMyInfoCellType_inviteBalance:
        case EPMyInfoCellType_partner:
//        case EPMyInfoCellType_baozhaoMgr:
//        case EPMyInfoCellType_baozhaoCheck:
        case EPMyInfoCellType_jiankeLib:
        case EPMyInfoCellType_zongbao:
        case EPMyInfoCellType_contactMgr:
        case EPMyInfoCellType_switchToJK:
        case JKMyInfoCellType_personalService:
        {
            static NSString *cellIdentifier = @"JKMyInfocell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                cell.textLabel.font = [UIFont systemFontOfSize:15];
                cell.textLabel.textColor = [UIColor XSJColor_tBlackTinge];
                
                UIImageView *leftImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info_icon_push_2"]];
                leftImg.tag = 200;
                [cell addSubview:leftImg];
                [leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(cell);
                    make.right.equalTo(cell).offset(-16);
                }];
                
                UILabel *redPoint = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-16-8, 10, 8, 8)];
                redPoint.tag = 300;
                redPoint.backgroundColor = [UIColor redColor];
                [redPoint setToCircle];
                [cell addSubview:redPoint];
            }
            UILabel *redPoint = (UILabel*)[cell viewWithTag:300];
            redPoint.hidden = YES;
            
            NSString *imgName;
            NSString *labTitle;
            switch (type) {
                case JKMyInfoCellType_advanceSalary:{
                    imgName = @"v3_myinfo_jk_advance";
                    labTitle = @"预支工资";
                    break;
                }
                case JKMyInfoCellType_socialActivist:{
                    imgName = @"v3_myinfo_king";
                    labTitle = @"我是人脉王";
                }
                    break;
                case JKMyInfoCellType_jobCollect:{
                    imgName = @"v3_myinfo_collect";
                    labTitle = @"岗位收藏";
                }
                    break;
                case JKMyInfoCellType_interestJob:{
                    imgName = @"v3_myinfo_jk_favorate";
                    labTitle = @"兼职意向";
                    break;
                }
//                case JKMyInfoCellType_appRecommend:{
//                    imgName = @"v3_myinfo_jk_recommend";
//                    labTitle = @"应用推荐";
//                    break;
//                }
                case MyInfoCellType_shareJK:{
                    imgName = @"v3_myinfo_jk_share";
                    labTitle = @"分享兼客";
                    break;
                }
                case MyInfoCellType_guide:{
                    imgName = @"v3_myinfo_guide";
                    labTitle = @"使用引导";
                    break;
                }
                case MyInfoCellType_setting:{
                    imgName = @"v3_myinfo_setting";
                    labTitle = @"设置";
                    break;
                }
                case JKMyInfoCellType_switchToEP:{
                    imgName = @"v3_myinfo_jk_switch";
                    labTitle = @"切换为雇主";
                    break;
                }
                    //ep
                case EPMyInfoCellType_inviteBalance:{
                    imgName = @"v3_set_zpye";
                    labTitle = @"招聘余额";
                    break;
                }
                case EPMyInfoCellType_partner:{
                    imgName = @"v3_set_partner";
                    labTitle = @"兼客合伙人";
                    break;
                }
//                case EPMyInfoCellType_baozhaoMgr:{
//                    imgName = @"v3_myinfo_ep_baozhao_mgr";
//                    labTitle = @"包招管理";
//                }
//                    break;
//                case EPMyInfoCellType_baozhaoCheck:{
//                    imgName = @"v3_myinfo_ep_baozhao";
//                    labTitle = @"包招账单";
//                    redPoint.hidden = ![XSJUserInfoData sharedInstance].isShowEpBaozhaoCheckRedPoint;
//                }
//                    break;
                case EPMyInfoCellType_jiankeLib:{
                    imgName = @"v3_myinfo_ep_ability";
                    labTitle = @"人才库";
                }
                    break;
                case EPMyInfoCellType_zongbao:{
                    imgName = @"v3_myinfo_ep_zhongbao";
                    labTitle = @"兼客众包";
                }
                    break;
                case EPMyInfoCellType_contactMgr:{
                    imgName = @"v3_myinfo_ep_content_mgr";
                    labTitle = @"联系运营经理";
                }
                    break;
                case EPMyInfoCellType_switchToJK:{
                    imgName = @"v3_myinfo_ep_switch";
                    labTitle = @"切换为兼客";
                }
                    break;
                case JKMyInfoCellType_personalService:{
                    imgName = @"v3_myinfo_jk_personal_service";
                    labTitle = @"个人服务";
                }
                default:
                    break;
            }
            
            cell.imageView.image = [UIImage imageNamed:imgName];
            cell.textLabel.text = labTitle;
            return cell;

        }
        case MyInfoCellType_debugVC:{
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"debugCell"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"debugCell"];
                cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v210_pressed_background"]];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; //显示最右边的箭头
                [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
                cell.textLabel.textColor = [UIColor XSJColor_tBlackTinge];
            }
            cell.textLabel.text = @"网络调试界面";
            return cell;
        }
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MyInfoCellType type = [self.datasArray[indexPath.section][indexPath.row] integerValue];
    switch (type) {
        case JKMyInfoCellType_login:{
            if ([[UserData sharedInstance] isLogin]) {
                LookupResume_VC *vc = [[LookupResume_VC alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case EPMyInfoCellType_login:{
            if ([[UserData sharedInstance] isLogin]) {
                EpProfile_VC *vc = [[EpProfile_VC alloc] init];
                vc.epModel = [[UserData sharedInstance] getEpModelFromHave];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case JKMyInfoCellType_moneyBag:    //钱袋子
        case EPMyInfoCellType_moneyBag:{
            WEAKSELF
            [[UserData sharedInstance] userIsLogin:^(id obj) {
                if (obj) {
                    MoneyBag_VC* vc = [UIHelper getVCFromStoryboard:@"JK" identify:@"sid_moneybag"];
                    vc.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
          
            }];
        }
            break;
        case EPMyInfoCellType_inviteBalance:{    //招聘余额
            ELog(@"进入招聘余额页面");
            WEAKSELF
            [[UserData sharedInstance] userIsLogin:^(id obj) {
                if (obj) {
                    ZPSalary_VC *viewCtrl = [[ZPSalary_VC alloc] init];
                    viewCtrl.hidesBottomBarWhenPushed = YES;
                    viewCtrl.accountId = _epInfo.account_id;
                    [weakSelf.navigationController pushViewController:viewCtrl animated:YES];
                }
                
            }];
        }
            break;
        case EPMyInfoCellType_partner:{         //兼客合伙人
            WebView_VC *vc = [[WebView_VC alloc] init];
            vc.url = [NSString stringWithFormat:@"%@%@", URL_HttpServer,kUrl_applyForPartner];;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case JKMyInfoCellType_personalService:{
            ELog(@"进入个人服务");
            WEAKSELF
            [[UserData sharedInstance] userIsLogin:^(id obj) {
                if (obj) {
                    [[XSJRequestHelper sharedInstance] getClientGlobalInfoWithBlock:^(ClientGlobalInfoRM *globalModel) {
                        if (globalModel && globalModel.service_personal_url) {
                            WebView_VC *vc = [[WebView_VC alloc] init];
                            vc.url = globalModel.service_personal_url;
                            vc.hidesBottomBarWhenPushed = YES;
                            [weakSelf.navigationController pushViewController:vc animated:YES];
                        }
                    }];
                }
            }];

        }
            break;
        case JKMyInfoCellType_advanceSalary:{   //预付工资
            WEAKSELF
            [[UserData sharedInstance] userIsLogin:^(id obj) {
                if (obj) {
                    [[XSJRequestHelper sharedInstance] getClientGlobalInfoWithBlock:^(ClientGlobalInfoRM *globalModel) {
                        if (globalModel && globalModel.borrowday_advance_salary_url) {
                            WebView_VC *vc = [[WebView_VC alloc] init];
                            NSString *urlStr;
                            NSRange range = [globalModel.borrowday_advance_salary_url rangeOfString:@"?"];
                            if (range.location == NSNotFound){
                                urlStr = [NSString stringWithFormat:@"%@?loginCode=%@",globalModel.borrowday_advance_salary_url,[[XSJUserInfoData sharedInstance] getUserInfo].userPhone];
                            }else{
                                urlStr = [NSString stringWithFormat:@"%@&loginCode=%@",globalModel.borrowday_advance_salary_url,[[XSJUserInfoData sharedInstance] getUserInfo].userPhone];
                            };
                            vc.url = urlStr;
                            vc.hidesBottomBarWhenPushed = YES;
                            [weakSelf.navigationController pushViewController:vc animated:YES];
                        }
                    }];
                }
            }];
        }
            break;
        case JKMyInfoCellType_socialActivist:{
            WEAKSELF
            [[UserData sharedInstance] userIsLogin:^(id obj) {
                NewSocialActivist_VC *viewCtrl = [[NewSocialActivist_VC alloc] init];
                viewCtrl.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:viewCtrl animated:YES];
            }];
            
        }
            break;
        case JKMyInfoCellType_jobCollect:{  //岗位收藏
            WEAKSELF
            [[UserData sharedInstance] userIsLogin:^(id obj) {
                if (obj) {
                    JobCollection_VC *viewCtrl = [[JobCollection_VC alloc] init];
                    viewCtrl.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:viewCtrl animated:YES];
                }
            }];
        }
            break;
        case JKMyInfoCellType_interestJob:{
            WEAKSELF
            [[UserData sharedInstance] userIsLogin:^(id obj) {
                if (obj) {
                    InterestJob_VC *vc = [[InterestJob_VC alloc] init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            }];
        }
            break;
//        case JKMyInfoCellType_appRecommend:{    //应用推荐 & 发现
//            [TalkingData trackEvent:@"兼客首页_发现"];
//            WebView_VC* vc = [[WebView_VC alloc] init];
//            vc.url = [NSString stringWithFormat:@"%@%@",URL_ZhaiTaskHttp ,kUrl_zaiFind];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
        case MyInfoCellType_shareJK:{        //分享
            [TalkingData trackEvent:@"雇主_个人中心_分享兼客"];
            WEAKSELF
            [[XSJRequestHelper sharedInstance] getClientGlobalInfoWithBlock:^(ClientGlobalInfoRM* globaModel) {
                if (globaModel.share_info.share_info) {
                    ShareInfoModel *shareInfo = globaModel.share_info.share_info;
                    [ShareHelper platFormShareWithVc:weakSelf info:shareInfo block:nil];
                }else{
                    [UIHelper toast:@"获取分享信息失败"];
                }
            }];
        }
            break;
        case MyInfoCellType_guide:{
            [TalkingData trackEvent:@"雇主_个人中心_使用引导"];
            NSString *urlStr;
            if (_loginType == WDLoginType_Employer) { // 雇主
                urlStr = kUrl_epHelper;
            } else { // 兼客
                urlStr = kUrl_jkHelper;
            }
            WebView_VC* vc = [[WebView_VC alloc] init];
            vc.url = [NSString stringWithFormat:@"%@%@", URL_HttpServer, urlStr];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case MyInfoCellType_setting:{
            SettingController *vc = [[SettingController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case JKMyInfoCellType_switchToEP:{
            [XSJUIHelper switchRequestIsToEP:YES];
        }
            break;
            //ep
//        case EPMyInfoCellType_baozhaoMgr:{
//            WEAKSELF
//            [[UserData sharedInstance] userIsLogin:^(id obj) {
//                if (obj) {
//                    BdOrderController *vc = [[BdOrderController alloc] init];
//                    vc.hidesBottomBarWhenPushed = YES;
//                    [weakSelf.navigationController pushViewController:vc animated:YES];
//                }
//            }];
//        }
//            break;
//        case EPMyInfoCellType_baozhaoCheck:{
//            [TalkingData trackEvent:@"雇主_个人中心_包招账单"];
//            WEAKSELF
//            [[UserData sharedInstance] userIsLogin:^(id obj) {
//                if (obj) {
//                    BDCheckManager_VC* vc = [[BDCheckManager_VC alloc] init];
//                    vc.hidesBottomBarWhenPushed = YES;
//                    [weakSelf.navigationController pushViewController:vc animated:YES];
//                }
//            }];
//        }
//            break;
        case EPMyInfoCellType_jiankeLib:{
            [TalkingData trackEvent:@"雇主_个人中心_人才库"];
            WEAKSELF
            [[UserData sharedInstance] userIsLogin:^(id obj) {
                if (obj) {
                    TalentPoolController *vc = [[TalentPoolController alloc] init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [weakSelf.navigationController pushViewController:vc animated:YES];
                }
            }];
        }
            break;
        case EPMyInfoCellType_zongbao:{
            [TalkingData trackEvent:@"雇主_个人中心_兼客众包"];
            WebView_VC* vc = [[WebView_VC alloc] init];
            vc.url = [NSString stringWithFormat:@"%@%@",URL_HttpServer, kUrl_zhaiTaskIntroduce];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case EPMyInfoCellType_contactMgr:{
            [TalkingData trackEvent:@"雇主_个人中心_联系运营经理"];
            CityModel* city = [[UserData sharedInstance] city];
            [MKOpenUrlHelper openQQWithNumber:city.contactQQ onViewController:self block:^(BOOL bRet) {
                [UIHelper toast:@"你没有安装QQ"];
            }];
        }
            break;
        case EPMyInfoCellType_switchToJK:{
            [TalkingData trackEvent:@"雇主_个人中心_切换为兼客"];
            [XSJUIHelper switchRequestIsToEP:NO];
        }
            break;
        case MyInfoCellType_debugVC:{
            NetworkTest_VC *vc = [[NetworkTest_VC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyInfoCellType type = [self.datasArray[indexPath.section][indexPath.row] integerValue];
    switch (type) {
        case JKMyInfoCellType_login:
        case EPMyInfoCellType_login:
            return 92;
        case JKMyInfoCellType_moneyBag:
            return 48;
        case EPMyInfoCellType_moneyBag:
            if (_epInfo && _epInfo.advance_amount.integerValue > 0) {
                return 72;
            }else{
                return 48;
            }
        default:
            break;
    }
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[self.datasArray objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.datasArray.count ? self.datasArray.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 12;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == self.datasArray.count - 1) {
        return 32;
    }
    return 1;
}


#pragma mark - ***** 按钮事件 ******
- (void)btnLoginOnclicked:(UIButton *)sender{

    Login_VC* loginVC = [UIHelper getVCFromStoryboard:@"Main" identify:@"sid_main_login"];
    MainNavigation_VC* vc = [[MainNavigation_VC alloc] initWithRootViewController:loginVC];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)btnRegister:(UIButton *)sender{    
    Login_VC *loginVC = [UIHelper getVCFromStoryboard:@"Main" identify:@"sid_main_login"];
    loginVC.isToRegister = YES;
    MainNavigation_VC* vc = [[MainNavigation_VC alloc] initWithRootViewController:loginVC];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)btnAuthOnclick:(UIButton *)sender{
    IdentityCardAuth_VC *vc = [[IdentityCardAuth_VC alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
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
