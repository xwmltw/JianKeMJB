//
//  JiankeScheduling_VC.m
//  jianke
//
//  Created by xiaomk on 16/7/20.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JiankeScheduling_VC.h"
#import "XSJConst.h"
#import "AddPayJiankeCell.h"

@interface JiankeScheduling_VC ()<UITableViewDataSource, UITableViewDelegate>{
    NSMutableArray *_datasArray;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIButton *btnAddJk;
@end

@implementation JiankeScheduling_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"兼客列表";
    
    UIView *botView = [[UIView alloc] init];
    botView.backgroundColor = [UIColor XSJColor_grayTinge];
    [botView setBorder];
    [self.view addSubview:botView];
    
    [botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(68);
    }];
    
    UIButton *btnAddJK = [UIButton creatBottomButtonWithTitle:@"确认选择" addTarget:self action:@selector(btnAddJKOnclick:)];
    btnAddJK.titleLabel.font = [UIFont systemFontOfSize:17];
    [botView addSubview:btnAddJK];
    self.btnAddJk = btnAddJK;
    
    [btnAddJK mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(botView).offset(16);
        make.right.equalTo(botView).offset(-16);
        make.top.equalTo(botView).offset(12);
        make.bottom.equalTo(botView).offset(-12);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.bottom.equalTo(botView.mas_top);
    }];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    headView.backgroundColor = [UIColor whiteColor];
    
    UILabel *labTitle = [[UILabel alloc] init];
    labTitle.text = @"请选择需要调整排班的兼客";
    labTitle.font = [UIFont systemFontOfSize:14];
    labTitle.textColor = [UIColor XSJColor_tGrayDeep];
    [headView addSubview:labTitle];
    [labTitle addBorderInDirection:BorderDirectionTypeBottom borderWidth:0.7 borderColor:[UIColor XSJColor_tGrayTinge] isConstraint:NO];
    
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headView.mas_left).offset(12);
        make.right.equalTo(headView.mas_right).offset(-12);
        make.centerY.equalTo(headView);
    }];
    
    self.tableView.tableHeaderView = headView;
    
    
    [self initWithNoDataViewWithStr:@"暂无可选兼客" onView:self.tableView];
    _datasArray = [[NSMutableArray alloc] init];
    [self getData];
}

- (void)getData{
    GetQueryApplyJobModel *model = [[GetQueryApplyJobModel alloc] init];
    model.job_id = self.jobId;
    model.on_board_date = self.on_board_date;
    NSString *content = [model getContent];
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc] initWithService:@"shijianke_entQueryCanChangeOnBoardDateStuList" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            NSArray *array = [JKModel objectArrayWithKeyValuesArray:response.content[@"resume_list"]];
            if (array.count > 0) {
                weakSelf.viewWithNoData.hidden = YES;
                [array enumerateObjectsUsingBlock:^(JKModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    obj.account_id = obj.stu_account_id;
                }];
                [_datasArray removeAllObjects];
                [_datasArray addObjectsFromArray:array];
                [weakSelf.tableView reloadData];
            }else{
                weakSelf.viewWithNoData.hidden = NO;
            }
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
    }];
}



#pragma mark - ***** UITableView delegate ******
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddPayJiankeCell *cell = [AddPayJiankeCell cellWithTableView:tableView];
    [cell.btnSelect addTarget:self action:@selector(btnSelectOnclick:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnSelect.tag = indexPath.row;
    
    JKModel *model = [_datasArray objectAtIndex:indexPath.row];
    cell.btnSelect.selected = model.isSelect;
    [cell.imgHead sd_setImageWithURL:[NSURL URLWithString:model.user_profile_url] placeholderImage:[UIHelper getDefaultHeadRect]];
    
    if (model.sex.intValue == 0) {
        [cell.imgSex setImage:[UIImage imageNamed:@"v230_female"]];
    }else{
        [cell.imgSex setImage:[UIImage imageNamed:@"v230_male"]];
    }
    
    cell.labName.text = model.true_name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JKModel *model = [_datasArray objectAtIndex:indexPath.row];
    model.isSelect = !model.isSelect;
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self updateBtnAddJkTitle];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datasArray.count > 0 ? _datasArray.count : 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 12;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0, 52, 0, 0)];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsMake(0, 52, 0, 0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 52, 0, 0)];
    }
}

#pragma mark - ***** 按钮事件 ******


- (void)btnSelectOnclick:(UIButton *)sender{
    sender.selected = !sender.selected;
    JKModel *model = [_datasArray objectAtIndex:sender.tag];
    model.isSelect = sender.selected;
    [self updateBtnAddJkTitle];
}

- (void)btnAddJKOnclick:(UIButton *)sende{
    NSMutableArray *addArray = [[NSMutableArray alloc] init];

    for (JKModel *jkModel in _datasArray) {
        if (jkModel.isSelect) {
            [addArray addObject:jkModel.apply_job_id];
        }
    }
    if (addArray.count > 0) {
        EntChangeOnBoardDateStuPM *model = [[EntChangeOnBoardDateStuPM alloc] init];
        model.job_id = self.jobId;
        model.on_board_date = self.on_board_date;
        model.apply_job_id_list = addArray;

        NSString *content = [model getContent];
        
        WEAKSELF
        RequestInfo *request = [[RequestInfo alloc] initWithService:@"shijianke_entChangeOnBoardDateStu" andContent:content];
        [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
            if (response.success) {
                [UIHelper toast:[NSString stringWithFormat:@"已成功添加%lu人",(unsigned long)addArray.count]];
                MKBlockExec(weakSelf.block, addArray)
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        }];
    }else{
        [UIHelper toast:@"未选择添加的兼客"];
    }
}

- (void)updateBtnAddJkTitle{
    NSInteger count = 0;
    for (JKModel *model in _datasArray) {
        if (model.isSelect) {
            count++;
        }
    }
    if (count > 0) {
        [self.btnAddJk setTitle:[NSString stringWithFormat:@"确认选择(%ld人)",(long)count] forState:UIControlStateNormal];
    }else{
        [self.btnAddJk setTitle:@"确认选择" forState:UIControlStateNormal];
    }
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
