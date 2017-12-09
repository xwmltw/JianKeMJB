//
//  EditEmployerInfo_VC.m
//  jianke
//
//  Created by xiaomk on 16/3/2.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "EditEmployerInfo_VC.h"
#import "WDConst.h"
#import "MKCommonHelper.h"
#import "EditEPInfoCell.h"
#import "IdentityCardAuth_VC.h"
#import "EPCertification_VC.h"
#import "UIPlaceHolderTextView.h"
#import "EditEPInfoDetailCell.h"


@interface EditEmployerInfo_VC ()<UIActionSheetDelegate,UINavigationBarDelegate,EditEPInfoCellDelegate>{
    NSString* _headImgUrl;

}
@property (nonatomic, strong) UIButton *btnHead;
@property (nonatomic, strong) UITextView* tvEditEPInfo;

@end

@implementation EditEmployerInfo_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"编辑雇主信息";
    self.btntitles = @[@"保存"];
    [self initUIWithType:DisplayTypeTableViewAndTopBottom];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view exchangeSubviewAtIndex:0 withSubviewAtIndex:2];
    
    //header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 140)];
    headerView.backgroundColor = [UIColor XSJColor_blackBase];
    UIButton* btnHead = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-60)/2, 40, 60, 60)];
    [btnHead addTarget:self action:@selector(btnHeadOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [btnHead sd_setBackgroundImageWithURL:[NSURL URLWithString:self.epModel.profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
    [btnHead setToCircle];
    [headerView addSubview:btnHead];
    self.btnHead = btnHead;
    self.topView.height = 140;
    [self.topView addSubview:headerView];
    
}

#pragma mark - UITableView delegate
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        EditEPInfoCell* cell = [EditEPInfoCell cellWithTableView:tableView];
        cell.delegate = self;
        [cell setData:_epModel atIndexPath:indexPath];
        return cell;

    }else if (indexPath.section == 1){
        static NSString* editIdentifie = @"editCell";
        EditEPInfoDetailCell* cell = [tableView dequeueReusableCellWithIdentifier:editIdentifie];
        if (!cell) {
            cell = [EditEPInfoDetailCell new];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        self.tvEditEPInfo = cell.tfEPDetail;
        cell.tfEPDetail.placeholder = @"详细填写企业简介";
        cell.tfEPDetail.font = [UIFont systemFontOfSize:16];
        cell.tfEPDetail.scrollEnabled = YES;
        cell.tfEPDetail.text = self.epModel.desc.length > 0 ? self.epModel.desc : @"";
        cell.tfEPDetail.placeholderColor = MKCOLOR_RGB(180, 180, 185);
        return cell;
    }
    return nil;
}



- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.size.width, 32)];
    view.backgroundColor = [UIColor XSJColor_grayTinge];
    UILabel* labTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 200, 32)];
    labTitle.textColor = MKCOLOR_RGB(128, 128, 128);
    labTitle.font = [UIFont systemFontOfSize:16];
    [view addSubview:labTitle];
    
    if (section == 1){
        labTitle.text = @"公司简介";
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 32;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 48;
    }else if (indexPath.section == 1){
        return 140;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }else if (section == 1){
        return 1;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

#pragma mark - uiscrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    ELog(@"%f",scrollView.contentOffset.y);
    CGFloat cy = scrollView.contentOffset.y;
    if (cy <= 0) {
        cy = cy * (-1);
        self.topView.transform = CGAffineTransformMakeScale(1 + cy/70, 1+ cy/70);
    }else if(!CGAffineTransformIsIdentity(self.topView.transform)){
        self.topView.transform = CGAffineTransformIdentity;
    }
    ELog(@"--%f",self.topView.height);
}

#pragma mark - 按钮事件

//个人完成认证不能修改
- (void)alertNameMsg {
//    UIButton *btn = [[UIButton alloc]init];
//    btn.frame = self.tfTureName.bounds;
//    [self.tfTureName addSubview:btn];
//    [btn addTarget:self action:@selector(nameAlreadyAuthing) forControlEvents:UIControlEventTouchUpInside];
//    self.tfTureName.textColor = [UIColor grayColor];
}

//完成认证提示消息
-(void)nameAlreadyAuthing {
    if (self.epModel.id_card_verify_status.intValue == 2 ) {
        [UIHelper toast:@"正在认证中..."];
    } else if (self.epModel.id_card_verify_status.intValue == 3) {
        [UIHelper toast:@"已完成认证不能修改"];
    }
}

////企业完成认证不能修改
//- (void)alertEpNameMsg {
//    UIButton *btn = [[UIButton alloc]init];
//    btn.frame = self.tfEPName.bounds;
//    [self.tfEPName addSubview:btn];
//    [btn addTarget:self action:@selector(epAlreadyAuthing) forControlEvents:UIControlEventTouchUpInside];
//    self.tfEPName.textColor = [UIColor grayColor];
//}

////完成认证提示消息
//-(void)epAlreadyAuthing {
//    if (self.epModel.verifiy_status.intValue == 2 ) {
//        [UIHelper toast:@"正在认证中..."];
//    } else if (self.epModel.verifiy_status.intValue == 3 ) {
//        [UIHelper toast:@"已完成认证不能修改"];
//    }
//}

- (void)pushAction:(EditEpCellType)type{
    if (type == EditEpCellType_Name) {
        [self btnAuthUserNameOnclick];
    }else if (type == EditEpCellType_Enterprase){
        [self btnEPAuthOnclick];
    }
}


//实名认证
- (void)btnAuthUserNameOnclick{
    IdentityCardAuth_VC* vc = [[IdentityCardAuth_VC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

//企业认证
- (void)btnEPAuthOnclick{
    EPCertification_VC* vc = [UIHelper getVCFromStoryboard:@"EP" identify:@"sid_epCertification"];
    [self.navigationController pushViewController:vc animated:YES];
}

//保存按钮
- (void)clickOnview:(UIView *)bottomView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [TalkingData trackEvent:@"雇主信息_编辑保存"];
    if (self.epModel.true_name.length == 0 || self.epModel.true_name.length > 10) {
        [UIHelper toast:@"请输入正确姓名"];
        return;
    }
    if (self.epModel.enterprise_name.length < 2 || self.epModel.enterprise_name.length > 30) {
        [UIHelper toast:@"请输入正确公司名字"];
        return;
    }
    if (self.epModel.email.length > 0) {
        if (![MKCommonHelper validateEmail:self.epModel.email]) {
            [UIHelper toast:@"邮箱格式有误，请输入有效果的邮箱"];
            return;
        }
    }
    [self sendMsg];
}

- (void)sendMsg {
    PostEPInfo *model = [[PostEPInfo alloc]init];
    model.true_name = self.epModel.true_name;
    model.enterprise_name = self.epModel.enterprise_name;
    if (self.epModel.email.length > 0) {
        model.email = self.epModel.email;
    }
    if (_headImgUrl.length > 0) {
        model.profile_url = _headImgUrl;
    }
    model.desc = self.tvEditEPInfo.text;
    
    ELog(@"========_headImgUrl%@",_headImgUrl);
    NSString* content = [model getContent];
    
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_postEnterpriseBasicInfo_V1" andContent:content];
    request.isShowLoading = YES;
    WEAKSELF
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            [UIHelper toast:@"保存信息成功！"];
            [weakSelf updateResume];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

/** 更新雇主简历 */
- (void)updateResume{
    [[UserData sharedInstance] getEPModelWithBlock:^(EPModel *model) {
        [WDNotificationCenter postNotificationName:WDNotifi_updateEPResume object:self];
    }];
}

//返回提示
-(void)backToLastView{
    [self.view endEditing:YES];
    WEAKSELF
    [UIHelper showConfirmMsg:@"您还未保存，确定要退出吗？" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            return;
        }else{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - 修改头像
- (void)btnHeadOnclick:(UIButton *)sender {
    UIActionSheet* menu = [[UIActionSheet alloc] initWithTitle:@"请选择图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照上传",@"从相册上传", nil];
    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {
        return;
    }
    WEAKSELF
    [UIDeviceHardware getCameraAuthorization:^(id obj) {
        UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypeCamera;
        if (buttonIndex == 0) {
            type = UIImagePickerControllerSourceTypeCamera;
        }else if (buttonIndex == 1){
            type = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [[UIPickerHelper sharedInstance] presentImagePickerOnVC:weakSelf sourceType:type finish:^(NSDictionary *info) {
            UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
            UIImage* newImage = image;
            NSString* uploadImageName = [NSString stringWithFormat:@"%@%@",@"shijiankehead_postEditEpInfoHead",@".jpg"];
            [weakSelf saveImage:newImage withName:uploadImageName];
            [weakSelf performSelector:@selector(selectPic:) withObject:newImage afterDelay:0.1];
        }];
    }];
}

- (void)selectPic:(UIImage*)image{
    [self.btnHead setBackgroundImage:image forState:UIControlStateNormal];
    [self.btnHead setBackgroundImage:image forState:UIControlStateHighlighted];
    
    RequestInfo* info = [[RequestInfo alloc] init];
    [info uploadImage:image andBlock:^(NSString* imageUrl) {
        _headImgUrl = imageUrl;
    }];
}

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    newSize.height = image.size.height*(newSize.width/image.size.width);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)saveImage:(UIImage*)tempImage withName:(NSString*)imageName{
    NSData* imageData = UIImagePNGRepresentation(tempImage);
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    imageName = fullPathToFile;
    __unused NSArray* nameAry = [imageName componentsSeparatedByString:@"/"];
    ELog(@"===new fullPathToFile===%@",fullPathToFile);
    ELog(@"===new FileName===%@",[nameAry objectAtIndex:[nameAry count]-1]);

    [imageData writeToFile:fullPathToFile atomically:NO];
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
