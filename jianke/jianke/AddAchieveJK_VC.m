//
//  AddAchieveJK_VC.m
//  jianke
//
//  Created by xiaomk on 16/4/26.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "AddAchieveJK_VC.h"
#import "WDConst.h"
#import "JKModel.h"
#import "AddAchieveJKCell.h"
#import "MKCommonHelper.h"

@interface AddAchieveJK_VC ()<MKBaseTableViewCellDelegate>{
    NSArray* _nameFirstLetterArray;
    NSArray* _allSortJK;

}

@end

@implementation AddAchieveJK_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"添加接收人";
    [self setUISingleTableView];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initWithNoDataViewWithStr:@"暂无可选的接收人" onView:self.tableView];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemOnclick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    
    
    UIView* headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    headView.backgroundColor = [UIColor whiteColor];
    
    UIButton* btnAllSelect = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 40, 40)];
    [btnAllSelect setImage:[UIImage imageNamed:@"v230_check box"] forState:UIControlStateNormal];
    [btnAllSelect setImage:[UIImage imageNamed:@"v230_select"] forState:UIControlStateSelected];
    [btnAllSelect addTarget:self action:@selector(btnAllSelectOnclick:) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btnAllSelect];
    
    UILabel* labTitle = [[UILabel alloc] initWithFrame:CGRectMake(56, 4, 200, 32)];
    labTitle.text = @"全选";
    labTitle.textColor = [UIColor blackColor];
    labTitle.font = HHFontSys(kFontSize_3);
    [headView addSubview:labTitle];
    self.tableView.tableHeaderView = headView;
    
    [self loadDataSource];
}

- (void)loadDataSource{
    QueryConfirmModel* model = [[QueryConfirmModel alloc] init];
    model.job_id = self.job_id;
    model.list_type = @(1);
    NSString* content = [model getContent];
    
    WEAKSELF
    RequestInfo *request = [[RequestInfo alloc] initWithService:@"shijianke_queryConfirmToWorkStuList" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
        if (response && [response success]) {
            NSArray* array = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];
            if (array && array.count > 0) {
                weakSelf.datasArray = [NSMutableArray arrayWithArray:array];
                [weakSelf initTableViewData];
                weakSelf.viewWithNoData.hidden = YES;
            }else{
//                [UIHelper toast:@"暂无可添加的兼客"];
//                [weakSelf.navigationController popViewControllerAnimated:YES];
                weakSelf.viewWithNoData.hidden = NO;
            }
            weakSelf.viewWithNoNetwork.hidden = YES;
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
       
    }];
}

- (void)initTableViewData{
    NSArray* array = [MKCommonHelper getNoRepeatSortLetterArray:self.datasArray letterKey:@"name_first_letter"];
    _nameFirstLetterArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:array]];

    NSMutableArray *sortJk = [NSMutableArray array];
    for (NSString* letter in _nameFirstLetterArray) {
        NSArray* tempArray = [self.datasArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name_first_letter like[cd] %@", letter]];
        [sortJk addObject:tempArray];
    }
    _allSortJK = [[NSArray alloc] initWithArray:sortJk];
    [self setSendCount];
    [self.tableView reloadData];

}

- (void)cell_eventWithIndexPath:(NSIndexPath *)indexPath{
    [self setSendCount];
    [self.tableView reloadData];
}

- (void)setSendCount{
    NSInteger allCount = 0;
    NSInteger selectCount = 0;
    for (NSArray* ary in _allSortJK) {
        for (JKModel* model in ary) {
            allCount += 1;
            if (model.isSelect) {
                selectCount += 1;
            }
        }
    }
    self.title = [NSString stringWithFormat:@"添加接收人(%ld/%ld)",(long)allCount,(long)selectCount];
}

- (void)btnAllSelectOnclick:(UIButton*)sender{
    sender.selected = !sender.selected;
    
    for (NSArray* ary in _allSortJK) {
        for (JKModel* model in ary) {
            model.isSelect = sender.selected;
        }
    }
    [self setSendCount];
    [self.tableView reloadData];
}

- (void)rightItemOnclick:(UIBarButtonItem*)sender{

    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    for (NSArray* ary in _allSortJK) {
        for (JKModel* model in ary) {
            if (model.isSelect) {
                [array addObject:model.apply_job_id.stringValue];
            }
        }
    }
    
    if (array.count == 0) {
        [UIHelper toast:@"请选择需要发送的兼客"];
        return;
    }
    
    NSString* idAryStr = [array componentsJoinedByString:@","];
    NSString* content = [NSString stringWithFormat:@"apply_job_id_list:[%@]",idAryStr];
    
    WEAKSELF
    RequestInfo* request = [[RequestInfo alloc] initWithService:@"shijianke_entSendConfirmWork" andContent:content];
    [request sendRequestWithResponseBlock:^(ResponseInfo* response) {
        if (response && response) {
            [UIHelper toast:@"提交成功"];
            if (weakSelf.block) {
                weakSelf.block(YES);
            }
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}

#pragma mark - ***** UITableView delegate ******
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"cell";
    AddAchieveJKCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [AddAchieveJKCell new];
        cell.delegate = self;
    }
    JKModel* jkmodel =_allSortJK[indexPath.section][indexPath.row];
    [cell refreshWithData:jkmodel andIndexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_allSortJK[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allSortJK.count > 0 ? _allSortJK.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView{
    //    NSMutableArray* array = [[NSMutableArray alloc] initWithArray:_nameFirstLetterArray];
    //    [array addObject:@"#"];
    return _nameFirstLetterArray;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = [UIColor XSJColor_grayTinge];
    
    UILabel* labTitle = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 100, 20)];
    labTitle.textColor = MKCOLOR_RGB(128, 128, 128);
    labTitle.font = [UIFont systemFontOfSize:14];
    labTitle.text = _nameFirstLetterArray[section];
    [view addSubview:labTitle];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
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


@implementation QueryConfirmModel
@end