//
//  PreviewJob_VC.m
//  jianke
//
//  Created by xuzhi on 16/9/25.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "PreviewJob_VC.h"
#import "JianKeAppreciation_VC.h"

@interface PreviewJob_VC ()

@end

@implementation PreviewJob_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"效果预览";
    [self setupView];
}

- (void)setupView{
    self.view.backgroundColor = MKCOLOR_RGB(250, 250, 250);
    
    UIImageView *imgView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v3_job_stick_preview"]];
    imgView.x = 16;
    imgView.y = 20;
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGFloat width = SCREEN_WIDTH - 32;
    CGFloat cilps = (width - imgView.width) / imgView.width;
    
    imgView.width = width;
    imgView.height += imgView.height * cilps;
    
    UIButton *button = [UIButton buttonWithTitle:@"置顶推广" bgColor:[UIColor XSJColor_base] image:nil target:self sector:@selector(pushStick)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setCornerValue:2.0f];
    button.frame = CGRectMake(16, CGRectGetMaxY(imgView.frame) + 20, SCREEN_WIDTH - 32, 44);
    
    [self.view addSubview:imgView];
    [self.view addSubview:button];
    
}

- (void)pushStick{
    JianKeAppreciation_VC *viewCtrl = [[JianKeAppreciation_VC alloc] init];
    viewCtrl.serviceType = Appreciation_stick_Type;
    viewCtrl.jobId = self.jobId;
    viewCtrl.popToVC = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController pushViewController:viewCtrl animated:YES];
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
