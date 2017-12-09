//
//  EmployExaList.m
//  jianke
//
//  Created by xiaomk on 16/7/21.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "EmployExaList.h"
#import "ApplyJobModel.h"
#import "LookupResume_VC.h"
#import "ClockRecordManager_VC.h"
#import "GroupMessageController.h"
#import "MKMessageComposeHelper.h"
#import "EmployListCell.h"
#import "DateSelectView.h"


#import "PersonnelManagerCell.h"
#import "PayExactWageManager_VC.h"
#import "PayWage_VC.h"
#import "MakeCheck_VC.h"


@interface EmployExaList ()<UITableViewDelegate, UITableViewDataSource, EmployListCellDelegate>{
    NSArray* _botBtnArray;  /*!< 底部按钮列表 */
    
    NSArray *_nameFirstLetterArray;
    NSArray *_allSortJK;
}
@property (nonatomic, strong) UIView *botView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *jkModelArray;
@property (nonatomic, strong) ApplyJobModel *ajModel;

@property (nonatomic, copy) NSString *accountStr;  /*!< 群发消息 */


//@property (nonatomic, strong) DLAVAlertView *dateAlertView;
@property (nonatomic, weak) DateSelectView *dateSelectView;

@end

@implementation EmployExaList

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _jkModelArray = [[NSMutableArray alloc] init];

    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor XSJColor_grayTinge];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];

    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getDatasList)];
    
    self.botView = [[UIView alloc] init];
    self.botView.backgroundColor = MKCOLOR_RGBA(250, 250, 250, 1);
    [self.view addSubview:self.botView];
    
    [self.botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.bottom.equalTo(self.botView.mas_top);
    }];
    
    [self initWithNoDataViewWithStr:@"没有已录用的兼客" onView:self.tableView];
    [self setupBottomToolBar];
    

}

- (void)getData{
    [self.tableView.header beginRefreshing];
}

- (void)setupBottomToolBar{
    //消息群发
    UIButton *btn3 = [self setupBottomBtnWithImg:@"v3_jkgl_qftz"];
    btn3.tag = 103;
    //签到管理
    UIButton *btn5 = [self setupBottomBtnWithImg:@"v3_mgr_qdgl"];
    btn5.tag = 105;
    //批量支付
    UIButton *btn6 = [self setupBottomBtnWithImg:@"v3_mgr_plzf"];
    btn6.tag = 106;
    
    _botBtnArray = @[btn3, btn5, btn6];

    [self layoutBottomBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    lineView.backgroundColor  = [UIColor XSJColor_grayLine];
    [self.botView addSubview:lineView];
}

- (UIButton *)setupBottomBtnWithImg:(NSString *)imgName{
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnBottomOnclick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)layoutBottomBtn{
    NSInteger count = _botBtnArray.count;
    
    CGFloat BtnW = SCREEN_WIDTH / count;
    for (NSInteger i = 0; i < count; i++) {
        UIButton *btn = _botBtnArray[i];
        [self.botView addSubview:btn];
        
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.botView);
            make.width.mas_equalTo(BtnW);
            make.left.mas_equalTo(BtnW * i);
        }];
    }
}



#pragma mark - ***** 获取数据 ******
- (void)getDatasList{
    WEAKSELF
    [[UserData sharedInstance] entQueryApplyJobListWithJobId:self.jobId listType:@(2) queryParam:nil block:^(ResponseInfo* response) {
        [weakSelf.tableView.header endRefreshing];
        
        if (response && response.success) {
            weakSelf.viewWithNoNetwork.hidden = YES;
            
            weakSelf.ajModel = [ApplyJobModel objectWithKeyValues:response.content];
            NSArray* array = [JKModel objectArrayWithKeyValuesArray:response.content[@"apply_job_resume_list"]];
            [_jkModelArray removeAllObjects];
            [_jkModelArray addObjectsFromArray:array];
            
            if (_jkModelArray.count <= 0 ) {
                weakSelf.viewWithNoData.hidden = NO;
            }else{
                weakSelf.viewWithNoData.hidden = YES;
            }
            [weakSelf initTableViewData];
        }else{
            weakSelf.viewWithNoNetwork.hidden = NO;
        }
    }];
}

/* 拼音分组 */
- (void)initTableViewData{
    NSArray* array = [MKCommonHelper getNoRepeatSortLetterArray:_jkModelArray letterKey:@"name_first_letter"];
    _nameFirstLetterArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:array]];
    
    NSMutableArray *sortJk = [NSMutableArray array];
    for (NSString* letter in _nameFirstLetterArray) {
        NSArray* tempArray = [_jkModelArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name_first_letter like[cd] %@", letter]];
        [sortJk addObject:tempArray];
    }
    
    _allSortJK = [[NSArray alloc] initWithArray:sortJk];
    [self.tableView reloadData];
}


#pragma mark - ***** UITableView delegate ******
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    PersonnelManagerCell *cell = [PersonnelManagerCell cellWithTableView:tableView];
//    cell.isShowInCheckInMgr = YES;
//    if (indexPath.section >= _allSortJK.count || indexPath.row >= [_allSortJK[indexPath.section] count]) {
//        return cell;
//    }
//    JKModel* jkmodel =_allSortJK[indexPath.section][indexPath.row];
//    [cell refreshWithData:jkmodel];
//    return cell;
    
    EmployListCell *cell = [EmployListCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.isAccurateJob = self.isAccurateJob;
    
    if (_allSortJK.count <= indexPath.section || [_allSortJK[indexPath.section] count] <= indexPath.row) {
        return cell;
    }
    
    JKModel *jkmodel = _allSortJK[indexPath.section][indexPath.row];
    [cell refreshWithData:jkmodel andIndexPath:indexPath];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JKModel* jkModel =_allSortJK[indexPath.section][indexPath.row];
    // 跳转
    LookupResume_VC *vc = [[LookupResume_VC alloc]init];
    vc.resumeId = jkModel.resume_id;
    vc.jobId = [NSNumber numberWithInt:self.jobId.intValue];
    vc.isLookOther = YES;
    vc.otherJkModel = jkModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    JKModel* jkmodel =_allSortJK[indexPath.section][indexPath.row];
    return jkmodel.cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_allSortJK[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _allSortJK.count > 0 ? _allSortJK.count : 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView*)tableView{
    //    NSMutableArray* array = [[NSMutableArray alloc] initWithArray:_nameFirstLetterArray];
    //    [array addObject:@"#"];
    return _nameFirstLetterArray;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = [UIColor XSJColor_grayTinge];
    [view setBorderWidth:0.5 andColor:[UIColor XSJColor_grayLine]];
    
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

#pragma mark - employList delegate
- (void)elCell_updateCellIndex:(NSIndexPath*)indexPath withModel:(JKModel *)model{
    [self.tableView reloadData];
}

- (void)elCell_moreEventWithIndex:(NSIndexPath *)indexPath withModel:(JKModel *)jkModel{
    [MKActionSheet sheetWithTitle:nil buttonTitleArray:@[@"电话联系兼客",@"调整上岗日期"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            if ([[UserData sharedInstance] getLoginType].integerValue == 1 && [[UserData sharedInstance] getEpModelFromHave].identity_mark.integerValue == 2) {
                [[XSJRequestHelper sharedInstance] callFreePhoneWithCalled:jkModel.contact.phone_num block:nil];
            }else{
                [[MKOpenUrlHelper sharedInstance] callWithPhone:jkModel.contact.phone_num];
            }            
        }else if (buttonIndex == 1){
            [self adjustWorkDateWithJkModel:jkModel];
        }
    }];
}

- (void)adjustWorkDateWithJkModel:(JKModel *)jkModel{
    WEAKSELF
    [[UserData sharedInstance] queryJobCanApplyDateWithJobId:@(self.jobId.integerValue) resumeId:jkModel.resume_id block:^(ResponseInfo *response) {
        
        // 可报名日期
        NSArray *tmpArray = response.content[@"job_can_apply_date"];
        
        NSMutableArray *canSelDateArray = [NSMutableArray array];
        for (NSString *str in tmpArray) {
            [canSelDateArray addObject:[NSDate dateWithTimeIntervalSince1970:str.longLongValue * 0.001]];
        }
        
        // 已报名日期
        NSArray *tmpNumArray = [self sortForWorkDateArray:jkModel.stu_work_time];
        NSMutableArray *applyDateArray = [NSMutableArray array];
        for (NSNumber *num in tmpNumArray) {
            [applyDateArray addObject:[NSDate dateWithTimeIntervalSince1970:num.longLongValue]];
        }
        
        // 日期控件
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 300)];
        DateSelectView *dateSelectView = [[DateSelectView alloc] initWithFrame:CGRectMake(0, 0, 260, 260)];
        weakSelf.dateSelectView = dateSelectView;
        dateSelectView.type = DateViewTypeAdjust;
        [containerView addSubview:dateSelectView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, 260, 240, 0.7)];
        lineView.backgroundColor = [UIColor XSJColor_grayLine];
        [containerView addSubview:lineView];
        
        UILabel *adjustLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 260, 260, 40)];
        adjustLabel.numberOfLines = 0;
        adjustLabel.textColor = MKCOLOR_RGB(136, 136, 136);
        adjustLabel.font = [UIFont systemFontOfSize:12];
        adjustLabel.text = @"通过点击，增加或减少上岗日期";
        [containerView addSubview:adjustLabel];
        
        weakSelf.dateSelectView.canSelDateArray = canSelDateArray;
        weakSelf.dateSelectView.datesApply = applyDateArray;
        weakSelf.dateSelectView.didClickBlock = ^(id obj){
            
            NSString *addDateStr = @"";
            for (NSDate *date in dateSelectView.datesAdd) {
                addDateStr = [NSString stringWithFormat:@"%@%ld、", addDateStr, (long)date.day];
            }
            
            NSString *reduceDateStr = @"";
            for (NSDate *date in dateSelectView.datesReduce) {
                reduceDateStr = [NSString stringWithFormat:@"%@%ld、", reduceDateStr, (long)date.day];
            }
            
            NSString *adjustDateStr = @"";
            if (reduceDateStr.length > 0) {
                adjustDateStr = [NSString stringWithFormat:@"减少了%@号; ", reduceDateStr];
            }
            
            if (addDateStr.length > 0) {
                adjustDateStr = [NSString stringWithFormat:@"%@增加了%@号", adjustDateStr, addDateStr];
            }
            
            if (adjustDateStr.length > 0) {
                adjustDateStr = [adjustDateStr stringByReplacingOccurrencesOfString:@"、号" withString:@"号"];
            }
            
            if (adjustDateStr.length < 1) {
                adjustDateStr = @"通过点击，增加或减少上岗日期";
            }
            
            adjustLabel.text = adjustDateStr;
        };
        
        
        [XSJUIHelper showConfirmWithView:containerView msg:nil title:@"调整日期" cancelBtnTitle:@"取消" okBtnTitle:@"确定" completion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                
                NSMutableArray *applyDateArrayNew = [NSMutableArray arrayWithArray:applyDateArray];
                // 加上新增的
                [applyDateArrayNew addObjectsFromArray:dateSelectView.datesAdd];
                // 减去取消的
                NSMutableArray *delDateArray = [NSMutableArray array];
                for (NSDate *date in dateSelectView.datesReduce) {
                    for (NSDate *applyDate in applyDateArrayNew) {
                        if ([date isSameDay:applyDate]) {
                            [delDateArray addObject:applyDate];
                        }
                    }
                }
                
                for (NSDate *delDate in delDateArray) {
                    [applyDateArrayNew removeObject:delDate];
                }
                
                // 转换成字符串数组
                NSMutableArray *applyDateStrArrayNew = [NSMutableArray array];
                for (NSDate *date in applyDateArrayNew) {
                    NSString *dateStr = [NSString stringWithFormat:@"%.0f", date.timeIntervalSince1970 * 1000];
                    [applyDateStrArrayNew addObject:dateStr];
                }
                
                // 调整发送请求
                [[UserData sharedInstance] entChangeStuOnBoardDateWithApplyJobId:jkModel.apply_job_id dayArray:applyDateStrArrayNew block:^(ResponseInfo *response) {
                    [UserData delayTask:0.3 onTimeEnd:^{
                        [UIHelper toast:@"调整成功"];
                    }];
                    
                    // 修改日期呈现
                    NSMutableArray *applyDateStrArray = [NSMutableArray array];
                    for (NSString *str in applyDateStrArrayNew) {
                        NSNumber *sortNum = @(str.longLongValue * 0.001);
                        [applyDateStrArray addObject:sortNum];
                    }
                    
                    jkModel.stu_work_time = applyDateStrArray;
                    [weakSelf getDatasList];
                }];
            }
        }];
    }];
}

/** 报名日期排序 */
- (NSArray *)sortForWorkDateArray:(NSArray *)array{
    NSArray *tmpWorkTime = [array sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        if (obj1.longLongValue < obj2.longLongValue) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    return tmpWorkTime;
}

#pragma mark - ***** 按钮事件 ******
- (void)btnBottomOnclick:(UIButton *)sender{
    if (sender.tag == 103){   //消息群发
        [self sendGroupMsg];
    }else if (sender.tag == 105){   //签到管理
        ClockRecordManager_VC *viewCtrl = [[ClockRecordManager_VC alloc] init];
        viewCtrl.jobId = _jobId;
        [self.navigationController pushViewController:viewCtrl animated:YES];
    }else if (sender.tag == 106){   //批量支付
        if ([self.delegate respondsToSelector:@selector(elm_changeToPayVC)]) {
            [self.delegate elm_changeToPayVC];
        }
    }
}

/** 消息群发 */
- (void)sendGroupMsg{
    if (_jkModelArray.count) {
        WEAKSELF
        [MKActionSheet sheetWithTitle:nil buttonTitleArray:@[@"消息铃铛群发",@"手机短信群发"] block:^(MKActionSheet *actionSheet, NSInteger buttonIndex) {
            if (buttonIndex == 0) {
                
                NSMutableArray *accountIDarray = [NSMutableArray array];
                [_jkModelArray enumerateObjectsUsingBlock:^(JKModel *jkModel, NSUInteger idx, BOOL *stop) {
                    [accountIDarray addObject:jkModel.account_id.description];
                    _accountStr = [accountIDarray componentsJoinedByString:@","];
                }];
                
                GroupMessageController *vc = [[GroupMessageController alloc] init];
                vc.jobId = weakSelf.jobId;
                vc.account_id = _accountStr;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }else if (buttonIndex == 1){
                [weakSelf sendPhoneMessage];
            }
        }];
    } else {
        [UIHelper toast:@"当前没有需要发送消息的兼客"];
    }
}

- (void)sendPhoneMessage{
    [[MKMessageComposeHelper sharedInstance] showWithRecipientArray:[_jkModelArray valueForKeyPath:@"contact.phone_num"] onViewController:self block:nil];
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
