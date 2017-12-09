//
//  ManualAddPerson_VC.m
//  jianke
//
//  Created by fire on 16/7/5.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ManualAddPerson_VC.h"
#import "UserData.h"
#import "JKModel.h"
#import "UIView+MKException.h"
#import "UIButton+Extension.h"
#import "ManualAddPayCell.h"
#import "MKCommonHelper.h"

@interface ManualAddPerson_VC () <UITableViewDataSource,UITableViewDelegate,ManualAddCellDelegate>{
    BOOL _isLastItem;    //是否只剩下最后一条目
}

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong)NSMutableArray *dataArr;
@property (nonatomic, weak) UIButton *submitBtn;
@property (nonatomic, weak) UIView *botView;

@end

@implementation ManualAddPerson_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.title = @"手动补录";
    self.dataArr = [NSMutableArray array];
    [self addData];
    [self newBottomBtn];
    [self newTableView];
}

- (void)newBottomBtn{
    
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor XSJColor_grayTinge];
    [bottomView setBorderWidth:0.5 andColor:[UIColor XSJColor_grayLine]];
    [self.view addSubview:bottomView];
    self.botView = bottomView;
    
    UIButton *button = [UIButton buttonWithTitle:@"添加补录人员" bgColor:[UIColor whiteColor] image:nil target:self sector:@selector(btnAddJkOnclick)];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor XSJColor_tBlackTinge] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setBorderWidth:0.5 andColor:[UIColor XSJColor_grayLine]];
    [bottomView addSubview:button];
    
    UIButton *button2 = [UIButton buttonWithTitle:[NSString stringWithFormat:@"确认添加(%lu人)",(unsigned long)_dataArr.count] bgColor:[UIColor XSJColor_base] image:nil  target:self sector:@selector(submitAction:)];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button2.titleLabel.font = [UIFont systemFontOfSize:17];
    [button2 setCornerValue:2];
    self.submitBtn = button2;
    [bottomView addSubview:button2];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(button.mas_top).offset(-12);
    }];
    
    [button2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bottomView.mas_left).offset(16);
        make.right.equalTo(bottomView.mas_right).offset(-16);
        make.bottom.equalTo(bottomView.mas_bottom).offset(-12);
        make.height.mas_equalTo(44);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(bottomView);
        make.bottom.equalTo(button2.mas_top).offset(-12);
        make.height.mas_equalTo(44);
    }];
}

#pragma mark - ***** 初始化控件 ******
- (void)newTableView{
    
    UITableView *tableView  =  [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor XSJColor_grayDeep];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    tableView.delegate  =  self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (self.isFromPayView) {
        tableView.estimatedRowHeight = 230;
    }else{
        tableView.estimatedRowHeight = 186;
    }
    
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.botView.mas_top);
    }];
    
    //设置tableheaderview
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    label.backgroundColor = [UIColor whiteColor];
    [label setTextColor:[UIColor XSJColor_tGrayDeep]];
    label.shadowOffset = CGSizeMake(0, 1);
    label.font = [UIFont systemFontOfSize:14.0f];
    if (self.isFromPayView) {
        label.text = @"  添加前请验证手机号，确保工资能够到账";
    }else{
        label.text = @"  添加前请验证手机号以免添加错误";
    }
    self.tableView.tableHeaderView = label;
}



#pragma mark - ***** UITableview delegate ******
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JKModel *jkModel = [_dataArr objectAtIndex:indexPath.row];
    ManualAddPayCell *cell = [ManualAddPayCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.isFromPayView = self.isFromPayView;
    [cell setJkModel:jkModel withIndexPath:indexPath isLastItem:_isLastItem];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_dataArr.count == 1) {
        if (self.isFromPayView) {
            return 186;
        }else{
            return 142;
        }
    }
    if (self.isFromPayView) {
        return 230;
    }else{
        return 186;
    }
    
}

#pragma mark - *****  ManualAddCell delegate ******
- (void)deleteCellForIndexPath:(NSIndexPath *)indexPath{
    [_dataArr removeObjectAtIndex:indexPath.row];
    _isLastItem = _dataArr.count > 1 ? NO : YES;
    if (_isLastItem) {
        [_tableView reloadData];
    }else{
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self updateSubmitBtn];
}

//根据电话 请求数据
- (void)queryAccountInfo:(NSString *)param withIndexPath:(NSIndexPath *)indexPath{
    int count = 0;
    for (JKModel *model in _dataArr) {
        if ([param isEqualToString:model.telphone]) {
            count += 1;
            if (count > 1) {
                JKModel *model = [_dataArr objectAtIndex:indexPath.row];
                model.telphone = @"";
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [UIHelper toast:@"手机号码已存在，请重新输入"];
                return;
            }
        }
    }
    
    WEAKSELF
    [[UserData sharedInstance] queryAccountInfo:param block:^(JKModel *jkModel) {
        if (jkModel) {
            JKModel *model = [_dataArr objectAtIndex:indexPath.row];
            model.sex = jkModel.sex ? jkModel.sex : @1;
            model.true_name = jkModel.true_name;
            UITableViewCell *cell = [weakSelf.tableView cellForRowAtIndexPath:indexPath];
            if ([cell respondsToSelector:@selector(updateCell:)]) {
                [cell performSelector:@selector(updateCell:) withObject:model];
            }
        }
    }];
}

#pragma mark - 其他自定义方法
- (void)addData{
    JKModel *jkModel = [[JKModel alloc] init];
    jkModel.sex = @1;
    jkModel.isFromPayAdd = self.isFromPayView;
    jkModel.isSelect = YES;
    [_dataArr addObject:jkModel];
    _isLastItem = _dataArr.count > 1 ? NO : YES;
}

- (void)btnAddJkOnclick{
    JKModel *jkModel = [_dataArr lastObject];
    if (![self dataIsOK:jkModel]) {
        return;
    }
    [self addData];
    [_tableView reloadData];

    [UserData delayTask:0.2 onTimeEnd:^{
        if (self.tableView.contentSize.height - self.tableView.bounds.size.height > 0) {
            [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height) animated:YES];
        }
    }];
   
    [self updateSubmitBtn];
    
}


- (void)submitAction:(UIButton *)button{
    for (JKModel *jkModel in _dataArr) {
        if (![self dataIsOK:jkModel]) {
            return;
        }
        jkModel.true_name = jkModel.input_name;
        if (jkModel.profile_url && jkModel.profile_url.length == 0) {
            jkModel.profile_url = nil;
        }
        if (jkModel.true_name.length > 0) {
            jkModel.name_first_letter = [MKCommonHelper getChineseNameFirstPinyinWithName:jkModel.input_name];
            unichar c = [jkModel.name_first_letter characterAtIndex:0];
            if((c < 'A'|| c > 'Z') && (c < 'a'|| c > 'z')){
                jkModel.name_first_letter = @"#";
            }
        }
    }
    

    if (self.isFromPayView) {
        [UIHelper toast:[NSString stringWithFormat:@"已成功添加%lu人",(unsigned long)_dataArr.count]];
        MKBlockExec(self.block,_dataArr);
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        WEAKSELF
        [[UserData sharedInstance] entMakeupStuBySelfWithJobId:_job_id resumeList:_dataArr block:^(id result) {
            [UIHelper toast:[NSString stringWithFormat:@"已成功添加%lu人",(unsigned long)_dataArr.count]];
            MKBlockExec(weakSelf.block,_dataArr);
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (BOOL)dataIsOK:(JKModel *)jkModel{
    if (jkModel.telphone.length != 11) {
        [UIHelper toast:@"请输入有效的手机号码"];
        return NO;
    }else if (!jkModel.input_name || jkModel.input_name.length < 2 || jkModel.input_name.length > 12){
        [UIHelper toast:@"请输入2-12位字符的兼客名称"];
        return NO;
    }else if (!jkModel.sex){
        [UIHelper toast:@"请选择兼客性别"];
        return NO;
    }
    
    if (self.isFromPayView) {
        if (!jkModel.salary_num ) {
            [UIHelper toast:@"请输入代发工资金额"];
            return NO;
        }else if (jkModel.salary_num.integerValue <= 0){
            [UIHelper toast:@"代发工资金额不能小于等于0"];
            return NO;
        }
    }
    return YES;
}

- (void)updateSubmitBtn{
    [_submitBtn setTitle:[NSString stringWithFormat:@"确认添加(%ld人)",(unsigned long)_dataArr.count] forState:UIControlStateNormal];
}

@end
