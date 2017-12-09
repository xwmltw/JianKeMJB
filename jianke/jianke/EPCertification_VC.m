//
//  EPCertification_VC.m
//  jianke
//
//  Created by xiaomk on 15/10/4.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "EPCertification_VC.h"
#import "UserData.h"
#import "UIButton+WebCache.h"
#import "WebView_VC.h"
#import "UIView+WebCacheOperation.h"
#import "UIPlaceHolderTextView.h"

@interface EPCertification_VC ()<UIActionSheetDelegate>{
    NSString* _headImgUrl;
}
@property (nonatomic, strong) EPModel* epModel;
@property (weak, nonatomic) IBOutlet UITextField *labEPName;
@property (weak, nonatomic) IBOutlet UITextField *labEPIdentifier;
@property (weak, nonatomic) IBOutlet UILabel *labEpPhotoText;
@property (weak, nonatomic) IBOutlet UIButton *btnChoosePhoto;
@property (weak, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (weak, nonatomic) IBOutlet UIButton *readedEpPromise;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveAndChange;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightForEPpicture;

@end

@implementation EPCertification_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"企业认证";
    self.heightForEPpicture.constant = (SCREEN_WIDTH - 32) * 284/694;
    [self getLatestVerifyInfo];
}

- (void)updateData{
    if (self.epModel.enterprise_name) {
        self.labEPName.text = self.epModel.enterprise_name;
    }
    self.readedEpPromise.selected = YES;
    if (self.epModel.regist_num && self.epModel.regist_num.integerValue) {
        self.labEPIdentifier.text = [NSString stringWithFormat:@"%ld",(long)self.epModel.regist_num.integerValue];
    }
    if (self.epModel.business_licence_url) {
        [self.imgPhoto sd_setImageWithURL:[NSURL URLWithString:self.epModel.business_licence_url]];
    }
    if (self.epModel.business_licence_url) {
        [self.btnSaveAndChange setTitle:@"重新提交" forState:UIControlStateNormal];
    }else{
        [self.btnSaveAndChange setTitle:@"保存" forState:UIControlStateNormal];
    }
}

/** 限制营业执照号码长度 */
- (IBAction)epRigsterNum:(UITextField *)sender {
    [TalkingData trackEvent:@"企业认证_营业执照号"];
    if (sender.text.length > 26) {
        sender.text = [sender.text substringToIndex:26];
    }
}

/** 限制公司名长度 */
- (IBAction)epName:(UITextField *)sender {
    [TalkingData trackEvent:@"企业认证_企业名称"];
    if (sender.text.length > 30) {
        sender.text = [sender.text substringToIndex:30];
    }
}

/** 提交图片 */
- (IBAction)btnSendPhotoOnclick:(UIButton *)sender {
    [self.view endEditing:YES];
    [self postImage];
}

- (void)postImage{
    [TalkingData trackEvent:@"企业认证_上传营业执照"];
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"请选择图片来源" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照上传",@"从相册上传", nil];
    menu.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
}

/** ActionSheet选择相应事件 */
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    //按了取消
    if (buttonIndex == 2) {
        return;
    }
    WEAKSELF
  [UIDeviceHardware getCameraAuthorization:^(id obj) {
        UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypeCamera;
        if(buttonIndex == 0){
            type = UIImagePickerControllerSourceTypeCamera;
        }else if(buttonIndex == 1){
            type = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [[UIPickerHelper sharedInstance] presentImagePickerOnVC:weakSelf sourceType:type finish:^(NSDictionary *info) {
            UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
            UIImage *newImg = image;
            [weakSelf performSelector:@selector(selectPic:) withObject:newImg afterDelay:0.1];
        }];
    }];
}

/** 设置营业执照照显示 */
- (void)selectPic:(UIImage*)image
{
    self.imgPhoto.image = image;
    
    RequestInfo* info = [[RequestInfo alloc] init];
    [info uploadImage:image andBlock:^(NSString* imageUrl) {
        _headImgUrl = imageUrl;
    }];
}
#pragma mark - 其他方法

//保存
- (IBAction)btnSaveOnclick:(UIButton *)sender {
    
    if ([self.labEPName.text isEqualToString:@""] ) {
        [UIHelper toast:@"名称不能为空"];
        return;
    }
    
    if (self.labEPName.text.length < 2 || self.labEPName.text.length > 30) {
        [UIHelper toast:@"名称长度只能在2-30个汉字或字母"];
        return;
    }
    
    if (self.labEPIdentifier.text.length < 2 || self.labEPIdentifier.text.length > 30) {
        [UIHelper toast:@"请输入有效的营业执照号码"];
        return;
    }
    
    if (self.imgPhoto == nil) {
        [UIHelper toast:@"请上传营业执照照图片!"];
        
        return;
    }
    
    if (!self.readedEpPromise.selected) {
        [UIHelper toast:@"请阅读并确认同意雇主认证承诺书的内容!"];
        return;
    }
    if (self.epModel.job_ing_count.intValue > 0) {
        
        DLAVAlertView *alert = [[DLAVAlertView alloc]initWithTitle:@"提醒" message:@"尚有岗位处于招聘状态，无法重新提交" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
            
            if (buttonIndex == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }];
    }else{
        [self sendMsg];
    }
    
    
}

/**
 * 网络请求
 */

- (void)getLatestVerifyInfo{
    WEAKSELF
    [[XSJRequestHelper sharedInstance] getLatestVerifyInfo:^(ResponseInfo *result) {
        weakSelf.epModel = [EPModel objectWithKeyValues:[result.content objectForKey:@"account_info"]];
        if (weakSelf.epModel.verifiy_status.integerValue > 1) {
            EPModel *tmpModel = [EPModel objectWithKeyValues:[result.content objectForKey:@"last_business_licence_verify_info"]];
            weakSelf.epModel.enterprise_name = tmpModel.enterprise_name;
            weakSelf.epModel.regist_num = tmpModel.regist_num;
            weakSelf.epModel.business_licence_url = tmpModel.business_licence_url;
        }
        [weakSelf updateData];
    }];
}

- (void)sendMsg {
    [TalkingData trackEvent:@"雇主个人中心_企业认证确定"];
    NSString* content = [NSString stringWithFormat:@"enterprise_name:\"%@\",regist_num:\"%@\",business_licence_url:\"%@\"",self.labEPName.text, self.labEPIdentifier.text,_headImgUrl];
    
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_entLicenseInfoVerify" andContent:content];
    request.isShowLoading = YES;
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            [UIHelper toast:@"提交成功！"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [UIHelper toast:@"提交失败，请重新提交！"];
        }
    }];
}

- (IBAction)resignRreponse:(UIView *)sender {
    [self.labEPIdentifier resignFirstResponder];
    [self.labEPName resignFirstResponder];
}



/** 打勾 */
- (IBAction)checkRead:(UIButton *)sender {
    
    sender.selected = !sender.selected;
}


/** 查看认证承诺书 */
- (IBAction)readEntPromise:(UIButton *)sender {
    WebView_VC* vc = [[WebView_VC alloc] init];
    vc.url = [NSString stringWithFormat:@"%@%@", URL_HttpServer, kUrl_entPromise];
    vc.title = @"雇主认证承诺书";
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
