//
//  AreaSelectView.m
//  jianke
//
//  Created by fire on 16/8/16.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "AreaSelectView.h"
#import "WDConst.h"

@interface AreaSelectView () <UITextFieldDelegate>

@property (nonatomic, weak) UITextField *utf;

@end

@implementation AreaSelectView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

+ (instancetype)showOnView:(UIView *)view{
    AreaSelectView *areaView = [[AreaSelectView alloc] initWithFrame:view.bounds];
    areaView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
    [view addSubview:areaView];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.type = kCATransitionFade;
    [view.layer addAnimation:transition forKey:@"animationKey"];
    return areaView;
}

- (void)initUI{
    
    //遮挡
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    bgView.backgroundColor = [UIColor XSJColor_blackBase];
    [self addSubview:bgView];
    
    //搜索
    UITextField *utf = [[UITextField alloc] init];
    self.utf = utf;
    utf.delegate = self;
    utf.placeholder = @"搜索地点";
    utf.backgroundColor = [UIColor whiteColor];
    [utf addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventEditingChanged];
    [utf becomeFirstResponder];
    [self addSubview:utf];
    
    //取消按钮
    UIButton *button = [UIButton buttonWithTitle:@"取消" bgColor:nil image:nil target:self sector:@selector(cancelAction:)];
    button.frame = CGRectMake(0, 0, 60, 40);
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.utf.rightViewMode = UITextFieldViewModeAlways;
    self.utf.rightView = button;
    self.utf.leftViewMode = UITextFieldViewModeAlways;
    self.utf.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"v250_icon_search"]];
    
    //tableview
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.tag = 101;
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.hidden = YES;
    self.tableView = tableView;
    [self addSubview:tableView];
    
    [self makeConstraint];
    [self.utf addBorderInDirection:BorderDirectionTypeBottom borderWidth:0.7 borderColor:[UIColor XSJColor_tGrayTinge] isConstraint:YES];
}

- (void)makeConstraint{
    [self.utf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.left.right.equalTo(self);
        make.height.equalTo(@40);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.utf.mas_bottom);
        make.left.bottom.right.equalTo(self);
    }];
}

- (void)editAction:(UITextField *)utf{
    if ([self.delegate respondsToSelector:@selector(areaSelectView:searchAction:)]) {
        [self.delegate areaSelectView:self searchAction:utf];
    }
}

- (void)cancelAction:(UIButton *)sender{
    if ([self.delegate respondsToSelector:@selector(areaSelectView:)]) {
        [self.delegate areaSelectView:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.delegate areaSelectView:self];
}

@end
