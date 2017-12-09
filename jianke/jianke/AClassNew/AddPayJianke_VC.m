//
//  AddPayJianke_VC.m
//  jianke
//
//  Created by xiaomk on 16/7/11.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "AddPayJianke_VC.h"
#import "ManualAddPerson_VC.h"
#import "XSJConst.h"
#import "AddPayJiankeCell.h"
#import "ManualAddPerson_VC.h"

@interface AddPayJianke_VC ()<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *_datasArray;
    
    NSMutableArray *_addJiankeArray;

}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIButton *btnAddJk;

@end

@implementation AddPayJianke_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加发放对象";
    
    _datasArray = [[NSMutableArray alloc] init];
    _addJiankeArray = [[NSMutableArray alloc] init];
    [self setupUI];
    [self getData];
}

- (void)setupUI{
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor XSJColor_grayDeep];
    [topView setBorder];
    [self.view addSubview:topView];
    
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.mas_equalTo(96);
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    [btn setTitle:@"手动添加其他兼客" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor XSJColor_tBlackTinge] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.backgroundColor = [UIColor whiteColor];
    [btn setBorderWidth:0.5 andColor:[UIColor XSJColor_grayLine]];
    [btn addTarget:self action:@selector(btnAddOtherJkOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:btn];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(topView);
        make.top.equalTo(topView).offset(12);
        make.height.mas_equalTo(44);
    }];
    
    UILabel *labTitle = [[UILabel alloc] init];
    labTitle.text = @"兼客列表";
    labTitle.font = [UIFont systemFontOfSize:14];
    labTitle.textColor = [UIColor XSJColor_tGray];
    labTitle.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:labTitle];
    
    [labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(topView);
        make.top.equalTo(btn.mas_bottom);
        make.bottom.equalTo(topView.mas_bottom);
    }];
    
    
    UIView *botView = [[UIView alloc] init];
    botView.backgroundColor = [UIColor XSJColor_grayTinge];
    [botView setBorder];
    [self.view addSubview:botView];
    
    [botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(68);
    }];
    
    UIButton *btnAddJK = [UIButton creatBottomButtonWithTitle:@"确认添加" addTarget:self action:@selector(btnAddJKOnclick:)];
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
        make.left.right.equalTo(self.view);
        make.top.equalTo(topView.mas_bottom);
        make.bottom.equalTo(botView.mas_top);
    }];
    
    [self initWithNoDataViewWithStr:@"暂无可添加兼客，可手动添加其他兼客" onView:self.tableView];
}

- (void)getData{
    GetQueryApplyJobModel *model = [[GetQueryApplyJobModel alloc] init];
    model.job_id = self.jobId;
    model.on_board_date = @(self.on_board_date.integerValue);
    NSString *content = [model getContent];
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc] initWithService:@"shijianke_entQueryCanChangeOnBoardDateStuList" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            NSArray *array = [JKModel objectArrayWithKeyValuesArray:response.content[@"resume_list"]];
            [array enumerateObjectsUsingBlock:^(JKModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.account_id = obj.stu_account_id;
            }];
            [_datasArray removeAllObjects];
            [_datasArray addObjectsFromArray:array];
            [weakSelf initTableViewData];
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
    }];
}

- (void)initTableViewData{
    if (_addJiankeArray.count > 0) {
        NSMutableArray *tempAry = [[NSMutableArray alloc] init];
        for (JKModel *addModel in _addJiankeArray) {
            BOOL isHave = NO;
            for (JKModel *jkModel in _datasArray) {
                if ([addModel.telphone isEqualToString:jkModel.telphone]) {
                    isHave = YES;
                    break;
                }
            }
            if (!isHave) {
                [tempAry addObject:addModel];
            }
        }
        [_datasArray addObjectsFromArray:tempAry];
    }
    
    if (_datasArray.count > 0) {
        self.viewWithNoData.hidden = YES;
    }else{
        self.viewWithNoData.hidden = NO;
    }
    
    [self.tableView reloadData];
    [self updateBtnAddJkTitle];
}

#pragma mark - ***** UITableView Delegate ******
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
    return 0.1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
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

- (void)updateBtnAddJkTitle{
    NSInteger count = 0;
    for (JKModel *model in _datasArray) {
        if (model.isSelect) {
            count++;
        }
    }
    if (count > 0) {
        [self.btnAddJk setTitle:[NSString stringWithFormat:@"确认添加(%ld人)",(long)count] forState:UIControlStateNormal];
        self.btnAddJk.enabled = YES;
    }else{
        [self.btnAddJk setTitle:@"确认添加" forState:UIControlStateNormal];
        self.btnAddJk.enabled = NO;
    }
}


/** 手动添加其他兼客 */
- (void)btnAddOtherJkOnclick:(UIButton *)sender{
    ManualAddPerson_VC *vc = [[ManualAddPerson_VC alloc] init];
    vc.title = @"添加发放对象";
    vc.isFromPayView = YES;
    vc.job_id = self.jobId;
    WEAKSELF
    vc.block = ^(NSArray *array){
        if (array && array.count > 0) {
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            for (JKModel *addModel in array) {
                BOOL isHave = NO;
                for (JKModel *jkModel in _addJiankeArray) {
                    if ([addModel.telphone isEqualToString:jkModel.telphone]) {
                        isHave = YES;
                        break;
                    }
                }
                if (!isHave) {
                    [tempArray addObject:addModel];
                }
            }
            [_addJiankeArray addObjectsFromArray:tempArray];
            [weakSelf initTableViewData];
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

/** 确认添加 */
- (void)btnAddJKOnclick:(UIButton *)sende{
    NSMutableArray *retArrya = [[NSMutableArray alloc] init];
    for (JKModel *jkModel in _datasArray) {
        if (jkModel.isSelect) {
            jkModel.isFromPayAdd = YES;
            if (jkModel.true_name.length > 0 && (!jkModel.name_first_letter || jkModel.name_first_letter.length == 0)) {
                jkModel.name_first_letter = [MKCommonHelper getChineseNameFirstPinyinWithName:jkModel.true_name];
                unichar c = [jkModel.name_first_letter characterAtIndex:0];
                if((c < 'A'|| c > 'Z') && (c < 'a'|| c > 'z')){
                    jkModel.name_first_letter = @"#";
                }
            }
            [retArrya addObject:jkModel];
        }
    }
    if (retArrya.count > 0) {
        [UIHelper toast:[NSString stringWithFormat:@"已成功添加%lu人",(unsigned long)retArrya.count]];
        MKBlockExec(self.block, retArrya);
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [UIHelper toast:@"未选择添加的兼客"];
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
