//
//  ChoosePostJobType_VC.m
//  jianke
//
//  Created by xiaomk on 16/4/18.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "ChoosePostJobType_VC.h"
#import "PostJob_VC.h"
#import "WebView_VC.h"

@interface ChoosePostJobType_VC (){
    
}

@end

@implementation ChoosePostJobType_VC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"发布岗位";
    [self setUISingleTableView];
    self.tableView.backgroundColor = [UIColor XSJColor_grayTinge];
    
    [self loadDataSource];
}

- (void)loadDataSource{
    JobTypeModel* model1 = [[JobTypeModel alloc] init];
    model1.title = @"新建普通岗位";
    model1.detail = @"简单方便，海量兼客来报名。";
    model1.imgName = @"jobPost_putong";
    
    JobTypeModel* model2 = [[JobTypeModel alloc] init];

    model2.title = @"包招服务商";
    model2.detail = @"专业人员代您招聘和管理。";
    model2.imgName = @"jobPost_baozhao";
    [self.datasArray addObject:model1];
    [self.datasArray addObject:model2];
    
    [self.tableView reloadData];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString* cellIdentifier = @"cell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    JobTypeModel* model = [self.datasArray objectAtIndex:indexPath.row];
    cell.textLabel.text = model.title;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    cell.textLabel.textColor = [UIColor XSJColor_base];
    cell.detailTextLabel.text = model.detail;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
    cell.detailTextLabel.textColor = [UIColor XSJColor_tGray];
    cell.imageView.image = [UIImage imageNamed:model.imgName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [TalkingData trackEvent:@"选择新建岗位类型页面_新建普通岗位"];
        PostJob_VC* vc = [[PostJob_VC alloc] init];
        vc.postJobType = PostJobType_common;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1){
        [TalkingData trackEvent:@"选择新建岗位类型页面_新建包招岗位"];
        
        WebView_VC *viewCtrl = [[WebView_VC alloc] init];
        viewCtrl.url = [NSString stringWithFormat:@"%@%@", URL_HttpServer, KUrl_BDService];
        [self.navigationController pushViewController:viewCtrl animated:YES];
        ELog(@"进入包招服务商web");
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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



@implementation JobTypeModel
@end