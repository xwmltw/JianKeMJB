//
//  LookupEPInfo_VC.m
//  jianke
//
//  Created by xiaomk on 15/9/30.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "LookupEPInfo_VC.h"
#import "WDConst.h"
#import "EditEmployerInfo_VC.h"
#import "EPCertification_VC.h"
#import "IdentityCardAuth_VC.h"
#import "JobCount_VC.h"
#import "JobComplaint_VC.h"
#import "WDChatView_VC.h"


@interface LookupEPInfo_VC ()<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray* _cellReusedIdArray;
    EPModel* _EpModel; /*!< 雇主模型 */
    NSInteger _numberOfCell;
    
    CGFloat _introCellHeight;
}

@property (weak, nonatomic) IBOutlet UIButton *btnHead;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *jobCountBtn;
@property (weak, nonatomic) IBOutlet UIButton *complaintBtn;
@property (weak, nonatomic) IBOutlet UILabel *dealTime;
@property (nonatomic, strong) UIWebView *phoneWebView;

@end

@implementation LookupEPInfo_VC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [UIHelper setToCircle:self.btnHead];

    self.jobCountBtn.layer.cornerRadius = 15;
    self.complaintBtn.layer.cornerRadius = 15;
    if (!self.isLookOther) {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info_ep_edit"] style:UIBarButtonItemStyleDone target:self action:@selector(editResume:)];
        self.navigationController.navigationBar.barTintColor = [UIColor XSJColor_blackBase];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editResume)];
    } else {
        
        UIBarButtonItem *phoneBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"card_icon_phone"] style:UIBarButtonItemStyleDone target:self action:@selector(phoneClick)];
        UIBarButtonItem *chatBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"card_icon_msg"] style:UIBarButtonItemStyleDone target:self action:@selector(chatClick)];
        self.navigationItem.rightBarButtonItems = @[phoneBtn, chatBtn];
    }
    
//    _cellReusedIdArray = [[NSMutableArray alloc] initWithObjects:@"name",@"EPName",@"email", nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];

}

- (void)getData{
    if (self.lookOther){
        ELog(@"=====lookOther");
        if (self.isFromGroupMembers && self.accountId) {
            WEAKSELF
            [[UserData sharedInstance] getEPModelWithEpAccount:self.accountId block:^(EPModel* model) {
                _EpModel = model;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf updateUIWithData];
                });
            }];
        }else if (self.enterpriseId.length > 0){
            WEAKSELF
            [[UserData sharedInstance] getEPModelWithEpid:self.enterpriseId block:^(EPModel* model) {
                _EpModel = model;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf updateUIWithData];
                });
            }];
        }
    }else{
        WEAKSELF
        [[UserData sharedInstance]getEPModelWithBlock:^(EPModel* model) {
            _EpModel = model;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateUIWithData];
            });
        }];
    }
}

- (void)updateUIWithData{
    ELog(@"=====updateUIWithData");
    [self.btnHead sd_setBackgroundImageWithURL:[NSURL URLWithString:_EpModel.profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
    [self.btnHead sd_setBackgroundImageWithURL:[NSURL URLWithString:_EpModel.profile_url] forState:UIControlStateDisabled placeholderImage:[UIHelper getDefaultHeadRect]];
    self.btnHead.enabled = NO;
    
    NSString *strJobCount = _EpModel.job_ing_count ? [NSString stringWithFormat:@"%@",_EpModel.job_ing_count] : @"0";
    NSString *strComplaint = _EpModel.complaint_bystu_count ? [NSString stringWithFormat:@"%@",_EpModel.complaint_bystu_count] : @"0";
    [self.jobCountBtn setTitle:[NSString stringWithFormat:@" %@ 个岗位",strJobCount] forState:UIControlStateNormal];
    [self.complaintBtn setTitle:[NSString stringWithFormat:@" %@ 次被投诉",strComplaint] forState:UIControlStateNormal];
    
    if (_EpModel.deal_resume_used_time_avg_desc.length > 0) {
        if ([_EpModel.deal_resume_used_time_avg_desc isEqualToString:@"无"]) {
            self.dealTime.text = @"简历处理用时: 无";
        }else{
            self.dealTime.text = [NSString stringWithFormat:@"简历处理用时: %@",_EpModel.deal_resume_used_time_avg_desc];
        }
    }else{
        self.dealTime.text = @"简历处理用时: 无";
    }
    
    
    
    
    _cellReusedIdArray = [[NSMutableArray alloc] init];
    [_cellReusedIdArray addObject:@"name"];
    _numberOfCell = 1;
    
    if (_EpModel.enterprise_name.length > 0) {
        if (!self.isLookOther || _EpModel.verifiy_status.intValue >= 2) {    //看自己   //看别人 并已经认证
            _numberOfCell++;
            [_cellReusedIdArray addObject:@"EPName"];
        }
    }
    
    if (_EpModel.email.length > 0) {
        _numberOfCell++;
        [_cellReusedIdArray  addObject:@"email"];
    }

    if (_EpModel.enterprise_name.length > 0) {
//        if (_EpModel.verifiy_status.intValue > 1) {
            _numberOfCell++;
            [_cellReusedIdArray addObject:@"intro"];
//        }
    }
    
    [self.tableView reloadData];
}

//个人认证
- (IBAction)btnAuthTureName:(UIButton *)sender {
    [TalkingData trackEvent:@"雇主_个人中心_实名认证"];
    IdentityCardAuth_VC* vc = [[IdentityCardAuth_VC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//企业认证
- (IBAction)btnEpAuth:(UIButton *)sender {
    [TalkingData trackEvent:@"雇主信息_编辑_企业认证"];
    EPCertification_VC *vc=[UIHelper getVCFromStoryboard:@"EP" identify:@"sid_epCertification"];
//    vc.epModel = _EpModel;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - UITableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:_cellReusedIdArray[indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel* labTitle = (UILabel*)[cell viewWithTag:101];
    //姓名
    if ([_cellReusedIdArray[indexPath.row] isEqualToString:@"name"]) {
        UIButton* btnUserAuth = (UIButton*)[cell viewWithTag:102];
//        cell.imageView.image = [UIImage imageNamed:@"v240_account-box"];

        labTitle.text = _EpModel.true_name ? _EpModel.true_name : @"";
        if (self.isLookOther) {
            if (_EpModel.id_card_verify_status.intValue == 3){
                [btnUserAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_yes"] forState:UIControlStateNormal];
                [btnUserAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_yes"] forState:UIControlStateDisabled];
                btnUserAuth.enabled = NO;
                btnUserAuth.hidden = NO;
//                cell.imageView.image = [UIImage imageNamed:@"v240_account-box"];
            }else{
                btnUserAuth.hidden = YES;
            }
        }else{
            btnUserAuth.hidden = NO;
            if (_EpModel.id_card_verify_status.intValue == 1) {
                [btnUserAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_no"] forState:UIControlStateNormal];
                btnUserAuth.enabled = YES;
            }else if (_EpModel.id_card_verify_status.intValue == 2){
                [btnUserAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ing"] forState:UIControlStateNormal];
                [btnUserAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ing"] forState:UIControlStateDisabled];
                btnUserAuth.enabled = NO;
            }else if (_EpModel.id_card_verify_status.intValue == 3){
                [btnUserAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_yes"] forState:UIControlStateNormal];
                [btnUserAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_yes"] forState:UIControlStateDisabled];
                btnUserAuth.enabled = NO;
            }
        }
        //企业名称
    }else if ([_cellReusedIdArray[indexPath.row] isEqualToString:@"EPName"]){
        UIButton* btnEpAuth = (UIButton*)[cell viewWithTag:102];
//        cell.imageView.image = [UIImage imageNamed:@"info_ep_gongsi"];
        labTitle.text = _EpModel.enterprise_name ? _EpModel.enterprise_name : @"";
        if (self.isLookOther) {  //别人查看雇主信息
            if (_EpModel.verifiy_status.intValue == 1) {
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_no"] forState:UIControlStateNormal];
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_no"] forState:UIControlStateDisabled];
                btnEpAuth.enabled = NO;
                btnEpAuth.hidden = YES;
            } else if (_EpModel.verifiy_status.intValue == 2) {
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ing"] forState:UIControlStateNormal];
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ing"] forState:UIControlStateDisabled];
                btnEpAuth.enabled = NO;
                btnEpAuth.hidden = NO;
            } else if (_EpModel.verifiy_status.intValue == 3){
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ep_0"] forState:UIControlStateNormal];
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ep_0"] forState:UIControlStateDisabled];
                btnEpAuth.enabled = NO;
                btnEpAuth.hidden = NO;
            }else{
                btnEpAuth.hidden = YES;
            }
        }else{ //自己看雇主信息
            labTitle.text = _EpModel.enterprise_name ? _EpModel.enterprise_name : @"";
//            cell.imageView.image = [UIImage imageNamed:@"info_ep_gongsi"];
            btnEpAuth.hidden = NO;
            //NSNumber *verifiy_status; /*!< 认证状态, 1未认证, 2正在认证、3认证通过 */
            if (_EpModel.verifiy_status.intValue == 1) {
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_no"] forState:UIControlStateNormal];
                btnEpAuth.enabled = YES;
            }else if (_EpModel.verifiy_status.intValue == 2){
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ing"] forState:UIControlStateNormal];
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ing"] forState:UIControlStateDisabled];
                btnEpAuth.enabled = NO;
            }else if (_EpModel.verifiy_status.intValue == 3){
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ep_0"] forState:UIControlStateNormal];
                [btnEpAuth setBackgroundImage:[UIImage imageNamed:@"info_auth_ep_0"] forState:UIControlStateDisabled];
                btnEpAuth.enabled = NO;
            }
        }
        
        //邮箱
    }else if ([_cellReusedIdArray[indexPath.row] isEqualToString:@"email"]){
        if (_EpModel.email > 0) {
            labTitle.text = _EpModel.email;
        }
    }else if ([_cellReusedIdArray[indexPath.row] isEqualToString:@"intro"]){
        UIView* iconView = (UIView*)[cell viewWithTag:101];
        UILabel* labCompany = (UILabel*)[cell viewWithTag:102];
        UILabel* labIntro = (UILabel*)[cell viewWithTag:103];

        [UIHelper setCorner:iconView withValue:1];
        labCompany.text = _EpModel.enterprise_name ? _EpModel.enterprise_name : @"";
        labIntro.text = _EpModel.desc;
        
        CGSize labSize = [UIHelper getSizeWithString:labIntro.text width:SCREEN_WIDTH-20-16 font:[UIFont systemFontOfSize:14]];
        _introCellHeight = labSize.height + 12+20+12+17+4+12;
        return cell;

    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_cellReusedIdArray[indexPath.row] isEqualToString:@"intro"]) {
        return _introCellHeight;
    }else if ([_cellReusedIdArray[indexPath.row] isEqualToString:@"email"]){
        return 56;
    }
    return 44;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _numberOfCell;
}

#pragma mark - 按钮事件
//编辑雇主信息
- (void)editResume{
    [TalkingData trackEvent:@"雇主信息_编辑"];
    EditEmployerInfo_VC* vc = [[EditEmployerInfo_VC alloc] init];
    vc.epModel = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:_EpModel]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)jobCountBtn:(UIButton *)sender {
    //岗位
    JobCount_VC *vc = [[JobCount_VC alloc]init];
    vc.enterprise_id = _EpModel.enterprise_id;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)complaintCount:(UIButton *)sender {
    //举报
    JobComplaint_VC *vc = [[JobComplaint_VC alloc]init];
    vc.entID = _EpModel.enterprise_id;
    [self.navigationController pushViewController:vc animated:YES];
}

/** 打电话 */
- (void)phoneClick{
    if (!self.phoneWebView) {
        self.phoneWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [self.phoneWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", _EpModel.telphone]]]];
}

/** IM聊天 */
- (void)chatClick{
    NSString* content = [NSString stringWithFormat:@"\"accountId\":\"%@\"", _EpModel.account_id];
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_im_getUserPublicInfo" andContent:content];
    request.isShowLoading = NO;
    [request sendRequestToImServer:^(ResponseInfo* response) {
        if (response && [response success]) {
            int type = [[UserData sharedInstance] getLoginType].integerValue == WDLoginType_JianKe ? WDLoginType_Employer : WDLoginType_JianKe;
            [WDChatView_VC openPrivateChatOn:self accountId:_EpModel.account_id.description withType:type jobTitle:nil jobId:nil];
        }else {
            [UIHelper toast:@"对不起,该用户未开通IM功能"];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
