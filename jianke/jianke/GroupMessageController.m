//
//  GroupMessageController.m
//  jianke
//
//  Created by fire on 15/12/9.
//  Copyright © 2015年 xianshijian. All rights reserved.
//  群发消息

#import "GroupMessageController.h"
#import "MJRefresh.h"
#import "DataBaseTool.h"
#import "UIPlaceHolderTextView.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "GroupMessageCell.h"
#import "Masonry.h"
#import "DateHelper.h"
#import "GroupMessageModel.h"

@interface GroupMessageController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *messageArray;

@property (nonatomic, weak) UIPlaceHolderTextView *textView;

@property (nonatomic, weak) UIView *footerView;

@property (nonatomic, assign) NSInteger index;

@end

@implementation GroupMessageController

- (void)loadView{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = scrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群发消息";
    self.index = 0;
    [self setupTableView];
    [self setupUI];
    [self.tableView.header beginRefreshing];
}

- (void)setupTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height-64-50) style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.allowsSelection = NO;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    [tableView registerNib:[UINib nibWithNibName:@"GroupMessageCell" bundle:nil] forCellReuseIdentifier:@"GroupMessageCell"];
//    tableView.contentInset = UIEdgeInsetsMake(0, 0, 114, 0);
    
    tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getData)];
    tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMore)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [tableView addGestureRecognizer:tap];
}

- (void)setupUI{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,  self.view.frame.size.height-64-50, SCREEN_WIDTH, 50)];
    [footerView setBorderWidth:1 andColor:MKCOLOR_RGB(228, 228, 228)];
    footerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:footerView];
    self.footerView = footerView;
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:@"v231_send"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"v231_send_p"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(postMessage) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:btn];
    
    UIPlaceHolderTextView *textView = [[UIPlaceHolderTextView alloc] init];
    
    if (self.receiveDate) {
        textView.placeholder = [NSString stringWithFormat:@"发送给 %@ 号上岗的兼客:", [DateHelper getDateWithNumber:@(self.receiveDate.longLongValue * 0.001)]];
    } else if (self.isSendApplyYet) {
        textView.placeholder = @"发送给已报名的兼客:";
    }else{
        textView.placeholder = @"发送给已录用的兼客:";
    }
    
    textView.maxLength = 300;
    textView.placeholderColor = MKCOLOR_RGB(180, 180, 185);
    textView.font = [UIFont systemFontOfSize:15];
    [footerView addSubview:textView];
    self.textView = textView;
    
//    WEAKSELF
//    textView.block = ^(NSString *text){
//      
//        CGFloat textViewH = weakSelf.textView.contentSize.height;
//        if (textViewH != textView.height) {
//         
//            [weakSelf.textView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(textViewH);
//            }];
//            
//            [weakSelf.footerView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(textViewH + 20);
//            }];
//        }
//    };
    
//    [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(50);
//        make.left.mas_equalTo(0);
//        make.right.mas_equalTo(0);
//        make.bottom.mas_equalTo(0);
//    }];
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(50);
        make.bottom.right.mas_equalTo(0);
    }];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(42);
        make.left.mas_equalTo(16);
        make.right.equalTo(btn.mas_left);
        make.centerY.equalTo(footerView);
    }];
}


- (void)tap{
    [self.textView resignFirstResponder];
}

/** 获取最新消息 */
- (void)getData{
    self.index = 0;
    self.messageArray = [DataBaseTool groupMessagesWithJobId:self.jobId withIndex:self.index];
    [self.tableView reloadData];
    [self.tableView.header endRefreshing];
}

/** 获取更多消息 */
- (void)getMore{
    self.index += 10;
    NSMutableArray *moreArray = [DataBaseTool groupMessagesWithJobId:self.jobId withIndex:self.index];
    if (moreArray && moreArray.count) {
 
        [self.messageArray addObjectsFromArray:moreArray];
        [self.tableView reloadData];
    }
    [self.tableView.footer endRefreshing];
}

/** 保存消息 */
- (void)saveMessageWithSendGroupMsgModel:(SendGroupMsgPM *)sendModel{
    GroupMessageModel *model = [[GroupMessageModel alloc] init];
    model.jobId = @(self.jobId.integerValue);
    model.postTime = @([NSDate date].timeIntervalSince1970);
    model.postContent = sendModel.notice_content;
    
    if (self.receiveDate) {
        NSString *dateStr = [DateHelper getDateAndWeekWithDate:[NSDate dateWithTimeIntervalSince1970:self.receiveDate.longLongValue * 0.001]];
        model.receiver = [NSString stringWithFormat:@"发送给: %@ 上岗的兼客", dateStr];
    } else if (self.isSendApplyYet) {
        model.receiver = [NSString stringWithFormat:@"发送给: 已报名的兼客"];
    } else {
        model.receiver = [NSString stringWithFormat:@"发送给: 已录用的兼客"];
    }
    
    
    [DataBaseTool saveGroupMessage:model];
    self.textView.text = @"";
    [self.textView resignFirstResponder];
    [self.messageArray insertObject:model atIndex:0];
    [self.tableView reloadData];
}

/** 发布消息 */
- (void)postMessage{
    if (self.textView.text.length > 0) {
        
        if (!self.account_id || self.account_id.length == 0) {
            [UIHelper toast:@"没有可以发送消息的兼客"];
            return;
        }
        
        SendGroupMsgPM *model = [[SendGroupMsgPM alloc]init];
        model.account_idlist = self.account_id;
        model.notice_channel = @1;
        model.notice_content = self.textView.text;
        model.notice_parttime_id = self.jobId;
        
        NSString* content = [model getContent];
        
        RequestInfo *request = [[RequestInfo alloc]initWithService:@"shijianke_entNoticeToStu" andContent:content];
        request.isShowLoading = YES;
        
        WEAKSELF
        [request sendRequestWithResponseBlock:^(ResponseInfo *response) {
            if (!response) {
                [UIHelper toast:@"发送失败"];
            }
            if (response && [response success]) {
                [UIHelper toast:@"发送成功"];
                [weakSelf saveMessageWithSendGroupMsgModel:model];
            }
            
        }];
    }else{
        [UIHelper toast:@"请输入通知信息"];
    }
}


#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.messageArray) {
        return self.messageArray.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView fd_heightForCellWithIdentifier:@"GroupMessageCell" configuration:^(GroupMessageCell *cell) {
        cell.model = self.messageArray[indexPath.row];
    }];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GroupMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GroupMessageCell" forIndexPath:indexPath];
    cell.model = self.messageArray[indexPath.row];
    return cell;
}


AddTableViewLineAdjust

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
