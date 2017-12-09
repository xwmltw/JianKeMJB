//
//  TalentPoolController.m
//  jianke
//
//  Created by fire on 15/10/22.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "TalentPoolController.h"
#import "MJRefresh.h"
#import "ParamModel.h"
#import "UserData.h"
#import "UIHelper.h"
#import "TalentModel.h"
#import "TalentCell.h"
#import "LookupResume_VC.h"


@interface TalentPoolController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) MJRefreshBackFooter *normalReflushFooter;
@property (nonatomic, strong) MJRefreshBackFooter *delReflushFooter;

//@property (nonatomic, strong) UIView *noDataView;
//@property (nonatomic, strong) UIView *noSignalView;

@property (nonatomic, strong) NSMutableArray *talentPoolArray;
@property (nonatomic, strong) NSMutableArray *delTalentPoolArray;
@property (nonatomic, strong) QueryParamModel *queryParam;
@property (nonatomic, strong) QueryParamModel *delQueryParam;

@property (nonatomic, strong) NSNumber *talentPoolCount;
@property (nonatomic, strong) NSNumber *delTalentPoolCount;

@property (nonatomic, weak) UIButton *footerBtn;
@property (nonatomic, strong) UIView *footer;
@property (nonatomic, strong) UIView *delTalentViewHeader;
@property (nonatomic, weak) UIButton *headerBtn;

@end

@implementation TalentPoolController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"人才库";
    
    // tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    [self.view addSubview:tableView];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 64;
    self.tableView = tableView;
    [self.tableView registerNib:[UINib nibWithNibName:@"TalentCell" bundle:nil] forCellReuseIdentifier:@"TalentCell"];
    
    WEAKSELF
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(weakSelf.view);
    }];
    
    [self setupUI];
    
    // 设置刷新
    [self setupReflush];
    
    // 获取数据
    [self.tableView.header beginRefreshing];
    
    // 注册通知
    [WDNotificationCenter addObserver:self selector:@selector(delTalentPool:) name:DelTalentPoolNotification object:nil];
    [WDNotificationCenter addObserver:self selector:@selector(recoverTalentPool:) name:RecoverTalentPoolNotification object:nil];
}

/** 初始化UI */
- (void)setupUI{
    // 添加导航栏按钮
    UIBarButtonItem *infoBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"v3_public_info_whith"] style:UIBarButtonItemStyleDone target:self action:@selector(infoClick)];
    self.navigationItem.rightBarButtonItem = infoBtn;
    
    [self initWithNoDataViewWithStr:@"您当前还没有人才信息" onView:self.tableView];

    // tableFooter
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    footer.backgroundColor = [UIColor clearColor];
    self.footer = footer;
    
    UIButton *footerBtn = [[UIButton alloc] init];
    footerBtn.height = 28;
    footerBtn.width = 90;
    footerBtn.center = footer.center;
    
    [footerBtn setBackgroundImage:[UIImage imageNamed:@"v210_delete_background"] forState:UIControlStateNormal];
    [footerBtn setBackgroundImage:[UIImage imageNamed:@"v210_delete_background_pressed"] forState:UIControlStateHighlighted];
    footerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [footerBtn addTarget:self action:@selector(footerBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [footer addSubview:footerBtn];
    self.footerBtn = footerBtn;
}


- (void)updateUI{
    // 设置未删除数量
    if (self.delTalentPoolCount) {
        self.title = [NSString stringWithFormat:@"人才库 (%ld)", (long)self.talentPoolCount.integerValue];
    }
    
    // 有无数据
    if (!self.talentPoolCount.integerValue && !self.delTalentPoolCount.integerValue) {
        self.viewWithNoData.hidden = NO;
    } else {
        self.viewWithNoData.hidden = YES;
    }
    
    // 被删数
    if (self.delTalentPoolCount) {
        [self.footerBtn setTitle:[NSString stringWithFormat:@"已删除 (%ld)", (long)self.delTalentPoolCount.integerValue] forState:UIControlStateNormal];
        [self.headerBtn setTitle:[NSString stringWithFormat:@"已删除 (%ld)", (long)self.delTalentPoolCount.integerValue] forState:UIControlStateNormal];
        
        if (self.delTalentPoolCount.integerValue && self.footerBtn.enabled) {
            self.tableView.tableFooterView = self.footer;
        } else {
            self.tableView.tableFooterView = nil;
        }
    }
    [self.tableView reloadData];
}


/** 设置上下拉刷新 */
- (void)setupReflush{
    // 刷新控件
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)];
    
    self.normalReflushFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(moreData)];
    self.delReflushFooter = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(moreDelData)];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger numberOfSections = 0;
    
    if (self.talentPoolArray && self.talentPoolArray.count) {
        numberOfSections = 1;
    }
    if (self.delTalentPoolArray && self.delTalentPoolArray.count) {
        numberOfSections = 2;
    }
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger numberOfRows = 0;
    
    if (section == 0) {
        numberOfRows = self.talentPoolArray.count;
    }
    if (section == 1) {
        numberOfRows = self.delTalentPoolArray.count;
    }
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TalentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TalentCell"];
    TalentModel *talentModel = nil;
    if (indexPath.section == 0) {
        talentModel = self.talentPoolArray[indexPath.row];
    }
    if (indexPath.section == 1) {
        talentModel = self.delTalentPoolArray[indexPath.row];
    }
    
    cell.talentModel = talentModel;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DLog(@"跳转到兼客简历");
    
    TalentModel *talentModel = nil;
    
    if (indexPath.section == 0) {
        talentModel = self.talentPoolArray[indexPath.row];
    }
    if (indexPath.section == 1) {
        talentModel = self.delTalentPoolArray[indexPath.row];
    }
    LookupResume_VC *vc = [[LookupResume_VC alloc] init];
    vc.resumeId = @(talentModel.resume_id.longLongValue);
    vc.isLookOther = YES;

    [self.navigationController pushViewController:vc animated:YES];
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {

        if (!self.delTalentViewHeader) {
            
            UIView *delTalentViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 40)];
            delTalentViewHeader.backgroundColor = [UIColor whiteColor];
            self.delTalentViewHeader = delTalentViewHeader;
            
            UIButton *headerBtn = [[UIButton alloc] init];
            headerBtn.height = 28;
            headerBtn.width = 90;
            headerBtn.center = delTalentViewHeader.center;
            [headerBtn setBackgroundImage:[UIImage imageNamed:@"v210_rectangle"] forState:UIControlStateNormal];
            [headerBtn setTitle:[NSString stringWithFormat:@"已删除 (%@)", self.delTalentPoolCount.description] forState:UIControlStateNormal];
            [headerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            headerBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            headerBtn.userInteractionEnabled = NO;
            [delTalentViewHeader addSubview:headerBtn];
            self.headerBtn = headerBtn;
            
        }
        
        return self.delTalentViewHeader;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 40;
    }
    return 0.1;
}

#pragma mark - 服务器交互
/** 获取人才库数据 */
- (void)getData{
    self.queryParam = [[QueryParamModel alloc] init];
    self.queryParam.page_num = @(1);
    self.queryParam.page_size = @(30);
    self.queryParam.timestamp = @((long)([[NSDate date] timeIntervalSince1970] * 1000));
    NSString *content = [NSString stringWithFormat:@"talent_pool_status:1, %@", [self.queryParam getContent]];
    
    WEAKSELF
    [[UserData sharedInstance] entQueryTalentPoolWithContent:content block:^(ResponseInfo *response) {
        if (!response) {
            weakSelf.talentPoolArray = nil;
            weakSelf.delTalentPoolArray = nil;
            weakSelf.viewWithNoNetwork.hidden = NO;
            weakSelf.viewWithNoData.hidden = YES;
            [weakSelf.tableView.header endRefreshing];
            [weakSelf.tableView reloadData];
            weakSelf.tableView.tableFooterView = nil;
            return;
        }
        
        weakSelf.viewWithNoNetwork.hidden = YES;
        if (response && response.success) {
            weakSelf.talentPoolArray = [NSMutableArray arrayWithArray:[TalentModel objectArrayWithKeyValuesArray:response.content[@"list"]]];
            weakSelf.talentPoolCount = response.content[@"normal_count"];
            weakSelf.delTalentPoolCount = response.content[@"deleted_count"];
            weakSelf.delTalentPoolArray = nil;
            weakSelf.footerBtn.enabled = YES;
            [weakSelf updateUI];
            weakSelf.tableView.footer = weakSelf.normalReflushFooter;
            weakSelf.tableView.footer.hidden = NO;
        }
        [weakSelf.tableView.header endRefreshing];
    }];
}

/** 获取被删除的人才库数据 */
- (void)getDelData{
    self.delQueryParam = [[QueryParamModel alloc] init];
    self.delQueryParam.page_num = @(1);
    self.delQueryParam.page_size = @(30);
    self.delQueryParam.timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
    NSString *content = [NSString stringWithFormat:@"talent_pool_status:2, %@", [self.delQueryParam getContent]];
    WEAKSELF
    [[UserData sharedInstance] entQueryTalentPoolWithContent:content block:^(ResponseInfo *response) {
        if (response && response.success) {
            weakSelf.delTalentPoolArray = [NSMutableArray arrayWithArray:[TalentModel objectArrayWithKeyValuesArray:response.content[@"list"]]];
            [weakSelf updateUI];
            weakSelf.tableView.footer = weakSelf.delReflushFooter;
            weakSelf.tableView.footer.hidden = NO;
        }
    }];
}


/** 获取更多人才库数据 */
- (void)moreData{
    self.queryParam.page_num = @(self.queryParam.page_num.integerValue + 1);
    self.queryParam.timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
    
    NSString *content = [NSString stringWithFormat:@"talent_pool_status:1, %@", [self.queryParam getContent]];
    
    WEAKSELF
    [[UserData sharedInstance] entQueryTalentPoolWithContent:content block:^(ResponseInfo *response) {
        if (response && response.success) {
            NSArray *newArray = [TalentModel objectArrayWithKeyValuesArray:response.content[@"list"]];
            if (!newArray || !newArray.count) {
                weakSelf.tableView.footer.hidden = YES;
                [weakSelf.tableView.footer endRefreshing];
                return;
            }
            
            [weakSelf.talentPoolArray addObjectsFromArray:newArray];
            weakSelf.queryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
            [weakSelf.tableView reloadData];
        }
        [weakSelf.tableView.footer endRefreshing];
    }];
}

/** 获取更多被删除的人才库数据 */
- (void)moreDelData{
    self.delQueryParam.page_num = @(self.delQueryParam.page_num.integerValue + 1);
    self.delQueryParam.timestamp = @([[NSDate date] timeIntervalSince1970] * 1000);
    
    NSString *content = [NSString stringWithFormat:@"talent_pool_status:2, %@", [self.delQueryParam getContent]];
    
    WEAKSELF
    [[UserData sharedInstance] entQueryTalentPoolWithContent:content block:^(ResponseInfo *response) {
        if (response && response.success) {
            NSArray *newArray = [TalentModel objectArrayWithKeyValuesArray:response.content[@"list"]];
            if (!newArray || !newArray.count) {
                weakSelf.tableView.footer.hidden = YES;
                [weakSelf.tableView.footer endRefreshing];
                return;
            }
            [weakSelf.delTalentPoolArray addObjectsFromArray:newArray];
            weakSelf.delQueryParam = [QueryParamModel objectWithKeyValues:response.content[@"query_param"]];
            [weakSelf.tableView reloadData];
        }
        [weakSelf.tableView.footer endRefreshing];
    }];
}


#pragma mark - 按钮点击
- (void)infoClick{
    [TalkingData trackEvent:@"人才库_简介"];
    [UIHelper showMsg:@"您录用并确认完工的兼客都会被添加进来。点击【删除】对兼客做进一步筛选，被删除的兼客可以在页面末尾被找回。" andTitle:@"人才库简介"];
}

- (void)footerBtnClick{
    self.footerBtn.enabled = NO;
    [self getDelData];
}


#pragma mark - 通知
/** 删除 */
- (void)delTalentPool:(NSNotification *)notification{
    TalentModel *talentModel = notification.userInfo[DelTalentPoolInfo];
    
    WEAKSELF
    [[UserData sharedInstance] changeTalentResumeStatusWithTalentPoolId:talentModel.talent_pool_id talentPoolState:@(2) block:^(ResponseInfo *response) {
       
        if (response.success) {
            
            talentModel.talent_pool_status = @(2);
            [weakSelf.delTalentPoolArray addObject:talentModel];
            [weakSelf.talentPoolArray removeObject:talentModel];
            
            weakSelf.talentPoolCount = @(weakSelf.talentPoolCount.integerValue - 1);
            weakSelf.delTalentPoolCount = @(weakSelf.delTalentPoolCount.integerValue + 1);
            
            if (weakSelf.footerBtn.enabled) {
                weakSelf.tableView.tableFooterView = weakSelf.footer;
            }
            
            [weakSelf.tableView reloadData];
            [weakSelf updateCount];
        }
    }];
}

/** 恢复 */
- (void)recoverTalentPool:(NSNotification *)notification{
    TalentModel *talentModel = notification.userInfo[RecoverTalentPoolInfo];
    
    WEAKSELF
    [[UserData sharedInstance] changeTalentResumeStatusWithTalentPoolId:talentModel.talent_pool_id talentPoolState:@(1) block:^(ResponseInfo *response) {
        if (response.success) {
            talentModel.talent_pool_status = @(1);
            [weakSelf.talentPoolArray addObject:talentModel];
            [weakSelf.delTalentPoolArray removeObject:talentModel];
            
            weakSelf.talentPoolCount = @(weakSelf.talentPoolCount.integerValue + 1);
            weakSelf.delTalentPoolCount = @(weakSelf.delTalentPoolCount.integerValue - 1);
            
            [weakSelf.tableView reloadData];
            [weakSelf updateCount];
        }
    }];
}

/** 更新人数 */
- (void)updateCount{
    self.title = [NSString stringWithFormat:@"人才库 (%@)", self.talentPoolCount];
    
    [self.footerBtn setTitle:[NSString stringWithFormat:@"已删除 (%@)", self.delTalentPoolCount] forState:UIControlStateNormal];
    [self.headerBtn setTitle:[NSString stringWithFormat:@"已删除 (%@)", self.delTalentPoolCount] forState:UIControlStateNormal];
}


- (void)dealloc{
    DLog(@"TalentPoolController dealloc");
}

@end
