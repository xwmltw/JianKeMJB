//
//  LinkAddPerson_VC.m
//  jianke
//
//  Created by fire on 16/7/5.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "LinkAddPerson_VC.h"
#import "Masonry.h"
#import "LinkAddCell.h"
#import "UserData.h"
#import "MKCommonHelper.h"

@interface LinkAddPerson_VC () <UITableViewDataSource,UITableViewDelegate>{
    MakeupInfo *_makeupInfo;
    NSTimer *_timer;    //计时器
    CGFloat _brightness;    //屏幕亮度
    
}

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation LinkAddPerson_VC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _brightness = [UIScreen mainScreen].brightness;
    [UIScreen mainScreen].brightness = 0.9;
}

- (void)viewWillDisappear:(BOOL)animated{
    [_timer invalidate];
    [UIScreen mainScreen].brightness = _brightness;
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"链接补录";
    [self newSubviews];
    
    _makeupInfo = [[MakeupInfo alloc] init];
    [self beginRequest];
}

#pragma - 初始化subviews
- (void)newSubviews{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerNib:[UINib nibWithNibName:@"LinkAddCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"LinkAddCell"];
    [self.view addSubview:tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}



#pragma mark - 网络请求
- (void)beginRequest{

    WEAKSELF
    [[UserData sharedInstance] creatMakeupUrlWithJobId:_jobId block:^(ResponseInfo *response) {
        if (response.success) {
            _makeupInfo = [MakeupInfo objectWithKeyValues:response.content];
            [weakSelf createQrImage];
            [weakSelf.tableView reloadData];
            [weakSelf nextRefresh:([_makeupInfo.expire_time doubleValue]/1000.0)];
        }
    }];
    
}

- (void)nextRefresh:(NSTimeInterval)interval{
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(beginRequest) userInfo:nil repeats:NO];
}

#pragma mark - uitableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LinkAddCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkAddCell" forIndexPath:indexPath];
    [cell setMakeupInfo:_makeupInfo];
    return cell;
    
}

#pragma mark - uitableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _makeupInfo.cellHeight;
}

#pragma - 生成二维码
- (void)createQrImage{
    UIImage *qrImage = [MKCommonHelper createQrImageWithUrl:_makeupInfo.qr_code withImgWidth:180];
    _makeupInfo.qr_image = qrImage;
}

- (void)dealloc{
    _timer = nil;
}
@end
