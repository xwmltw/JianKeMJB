//
//  HelpCenterSearch_VC.m
//  jianke
//
//  Created by xiaomk on 16/2/18.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "HelpCenterSearch_VC.h"
#import "WDConst.h"
#import "ImDataManager.h"
#import "KefuChatView_VC.h"

@interface HelpCenterSearch_VC ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
    NSMutableArray* _datasArray;
}

@property (nonatomic, strong) UITextField* tfSearch;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) UIView* noResultView;
@property (nonatomic, strong) UILabel* labNoResultContent;

@end

@implementation HelpCenterSearch_VC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor XSJColor_grayDeep];
    
//    CGRect navBgFrame = self.navTitleBgView.frame;
//    navBgFrame.size.width = SCREEN_WIDTH;
//    self.navTitleBgView.frame = navBgFrame;
    
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(4, 0, 30, 28)];
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v250_icon_search"]];
    imageView.frame = CGRectMake(4, 4, 20, 20);
    [view addSubview:imageView];
    
    self.tfSearch = [[UITextField alloc] initWithFrame:CGRectMake(58, 8, SCREEN_WIDTH-58-16, 28)];
    self.tfSearch.returnKeyType = UIReturnKeySearch;
    self.tfSearch.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.tfSearch.delegate = self;
    self.tfSearch.font = [UIFont systemFontOfSize:14];
    self.tfSearch.placeholder = @"输入关键字";
    self.tfSearch.textColor = [UIColor blackColor];
    self.tfSearch.tintColor = [UIColor blueColor];
    self.tfSearch.backgroundColor = MKCOLOR_RGB(172, 219, 224);
    self.tfSearch.leftView = view;
    self.tfSearch.leftViewMode = UITextFieldViewModeAlways;
    [self.tfSearch addTarget:self action:@selector(searchChange:) forControlEvents:UIControlEventEditingChanged];
    [UIHelper setCorner:self.tfSearch];
//    [self.navTitleBgView addSubview:self.tfSearch];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor =[UIColor XSJColor_grayDeep];
    self.tableView.hidden = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    WEAKSELF
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
    
    self.noResultView = [[UIView alloc] init];
    [self.view addSubview:self.noResultView];
    
    UIImageView* imgIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v260_no_resourse"]];
    [self.noResultView addSubview:imgIcon];
    
    UILabel* labContent = [[UILabel alloc] init];
//    labContent.text = @"抱歉，未搜索到与[%@]相关的帮助内容。您可以移步至消息铃铛中咨询客服。";
    labContent.numberOfLines = 0;
    labContent.textColor = [UIColor XSJColor_tGray];
    labContent.font = [UIFont systemFontOfSize:18];
    [self.noResultView addSubview:labContent];
    self.labNoResultContent = labContent;
    
    UIButton* btnToKefu = [[UIButton alloc] init];
//    [btnToKefu setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [btnToKefu setTitle:@"去咨询" forState:UIControlStateNormal];
    [btnToKefu setTitleColor:[UIColor XSJColor_base] forState:UIControlStateNormal];
    [btnToKefu setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [btnToKefu addTarget:self action:@selector(btnToKefuOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.noResultView addSubview:btnToKefu];
    [UIHelper setCorner:btnToKefu];
    [UIHelper setBorderWidth:1 andColor:[UIColor XSJColor_base] withView:btnToKefu];
    
    UILabel* labKufuQQ = [[UILabel alloc] init];
    labKufuQQ.text = [NSString stringWithFormat:@"客服QQ：%@",kKefuQQ];
    labKufuQQ.textColor = [UIColor XSJColor_tGray];
    labKufuQQ.font = [UIFont systemFontOfSize:18];
    [self.noResultView addSubview:labKufuQQ];
    
    [self.noResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    [imgIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.noResultView.mas_centerX);
        make.top.equalTo(weakSelf.noResultView.mas_top).offset(32);
    }];
    [labContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.noResultView.mas_left).offset(24);
        make.right.equalTo(weakSelf.noResultView.mas_right).offset(-24);
        make.top.equalTo(imgIcon.mas_bottom).offset(16);
    }];
    
    [btnToKefu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.noResultView.mas_centerX);
        make.top.equalTo(labContent.mas_bottom).offset(8);
        make.width.mas_equalTo(@100);
        make.height.mas_equalTo(@40);
    }];
    
    [labKufuQQ mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(labContent);
        make.right.equalTo(labContent);
        make.top.equalTo(btnToKefu.mas_bottom).offset(8);
    }];
}

- (void)btnToKefuOnclick:(UIButton*)sender{
    KefuChatView_VC *chatViewController = [ImDataManager getKeFuChatVC];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)setLabContentWith:(NSString*)searchStr{
    self.labNoResultContent.text = [NSString stringWithFormat:@"抱歉，未搜索到与 [%@] 相关的帮助内容。您可以移步至消息铃铛中咨询客服。",searchStr];
}

#pragma mark - tableView delegate
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* cellIdentifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v210_pressed_background"]];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = MKCOLOR_RGB(89, 89, 89);
    }
    cell.textLabel.text = @"xxxx";
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datasArray.count ? _datasArray.count : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)searchChange:(UITextField*)textField{
    [self setLabContentWith:textField.text];
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
