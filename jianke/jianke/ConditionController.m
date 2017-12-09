//
//  ConditionController.m
//  jianke
//
//  Created by fire on 15/11/18.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "ConditionController.h"
#import "ConditionCell.h"
#import "ConditionCellModel.h"
#import "ConditionSheet.h"
#import "PostJobCellModel.h"
#import "JobModel.h"
#import "DateTools.h"


@interface ConditionController ()

//@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *cellArray;

@property (nonatomic, strong) ConditionSheet *sexSheet; /*!< 性别 */
@property (nonatomic, strong) ConditionSheet *ageSheet; /*!< 年龄 */
@property (nonatomic, strong) ConditionSheet *heightSheet; /*!< 身高 */
@property (nonatomic, strong) ConditionSheet *lestDaySheet; /*!< 最少上岗天数 */

@end

@implementation ConditionController

- (ConditionSheet *)sexSheet{
    if (!_sexSheet) {
        NSNumber *sex = self.jobModel.sex;
        ConditionSheetItem *other = [[ConditionSheetItem alloc] initWithTitle:@"不限" selected:(sex ? NO : YES) enable:YES arg:nil];
        ConditionSheetItem *man = [[ConditionSheetItem alloc] initWithTitle:@"男" selected:(sex && sex.integerValue == 1 ? YES : NO) enable:YES arg:@(1)];
        ConditionSheetItem *women = [[ConditionSheetItem alloc] initWithTitle:@"女" selected:(sex && sex.integerValue == 0 ? YES : NO) enable:YES arg:@(0)];
        
        WEAKSELF
        _sexSheet = [[ConditionSheet alloc] initWithItems:@[other, man, women] complentBlock:^(NSInteger index, NSNumber *arg) {
            weakSelf.jobModel.sex = arg;
            [weakSelf.tableView reloadData];
        }];
    }
    return _sexSheet;
}

- (ConditionSheet *)ageSheet{
    if (!_ageSheet) {
        NSNumber *age = self.jobModel.age;
        ConditionSheetItem *other = [[ConditionSheetItem alloc] initWithTitle:@"不限" selected:(age ? NO : YES) enable:YES arg:nil];
        ConditionSheetItem *age18 = [[ConditionSheetItem alloc] initWithTitle:@"18周岁以上" selected:(age && age.integerValue == 1 ? YES : NO) enable:YES arg:@(1)];
        ConditionSheetItem *age18To25 = [[ConditionSheetItem alloc] initWithTitle:@"18-25周岁" selected:(age && age.integerValue == 2 ? YES : NO) enable:YES arg:@(2)];
        ConditionSheetItem *age25 = [[ConditionSheetItem alloc] initWithTitle:@"25周岁以上" selected:(age && age.integerValue == 3 ? YES : NO) enable:YES arg:@(3)];
        
        WEAKSELF
        _ageSheet = [[ConditionSheet alloc] initWithItems:@[other, age18, age18To25, age25] complentBlock:^(NSInteger index, NSNumber *arg) {
            weakSelf.jobModel.age = arg;
            [weakSelf.tableView reloadData];
        }];
    }
    return _ageSheet;
}


- (ConditionSheet *)heightSheet{
    if (!_heightSheet) {
        NSNumber *height = self.jobModel.height;
        ConditionSheetItem *other = [[ConditionSheetItem alloc] initWithTitle:@"不限" selected:(height ? NO : YES) enable:YES arg:nil];
        ConditionSheetItem *height160 = [[ConditionSheetItem alloc] initWithTitle:@"160cm以上" selected:(height && height.integerValue == 1 ? YES : NO) enable:YES arg:@(1)];
        ConditionSheetItem *height165 = [[ConditionSheetItem alloc] initWithTitle:@"165cm以上" selected:(height && height.integerValue == 2 ? YES : NO) enable:YES arg:@(2)];
        ConditionSheetItem *height168 = [[ConditionSheetItem alloc] initWithTitle:@"168cm以上" selected:(height && height.integerValue == 3 ? YES : NO) enable:YES arg:@(3)];
        ConditionSheetItem *height170 = [[ConditionSheetItem alloc] initWithTitle:@"170cm以上" selected:(height && height.integerValue == 4 ? YES : NO) enable:YES arg:@(4)];
        ConditionSheetItem *height175 = [[ConditionSheetItem alloc] initWithTitle:@"175cm以上" selected:(height && height.integerValue == 5 ? YES : NO) enable:YES arg:@(5)];
        ConditionSheetItem *height180 = [[ConditionSheetItem alloc] initWithTitle:@"180cm以上" selected:(height && height.integerValue == 6 ? YES : NO) enable:YES arg:@(6)];
        
        WEAKSELF
        _heightSheet = [[ConditionSheet alloc] initWithItems:@[other, height160, height165, height168, height170, height175, height180] complentBlock:^(NSInteger index, NSNumber *arg) {
            weakSelf.jobModel.height = arg;
            [weakSelf.tableView reloadData];
        }];
    }
    return _heightSheet;
}

- (ConditionSheet *)lestDaySheet{
    if (!_lestDaySheet) {
        // 判断工作天数
        // 设置是否可以选中
        
        NSDate *startDate = self.startDate;
        NSDate *endDate = self.endDate;
        NSInteger days = [startDate daysEarlierThan:endDate] + 1;
        
        NSNumber *apply_job_date = self.jobModel.apply_job_date;
        ConditionSheetItem *other = [[ConditionSheetItem alloc] initWithTitle:@"不限" selected:(apply_job_date ? NO : YES) enable:YES arg:nil];
        ConditionSheetItem *day2 = [[ConditionSheetItem alloc] initWithTitle:@"2天以上" selected:(apply_job_date && apply_job_date.integerValue == 2 ? YES : NO) enable:(days >= 2 ? YES : NO) arg:@(2)];
        ConditionSheetItem *day3 = [[ConditionSheetItem alloc] initWithTitle:@"3天以上" selected:(apply_job_date && apply_job_date.integerValue == 3 ? YES : NO) enable:(days >= 3 ? YES : NO) arg:@(3)];
        ConditionSheetItem *day5 = [[ConditionSheetItem alloc] initWithTitle:@"5天以上" selected:(apply_job_date && apply_job_date.integerValue == 5 ? YES : NO) enable:(days >= 5 ? YES : NO) arg:@(5)];
        ConditionSheetItem *dayAll = [[ConditionSheetItem alloc] initWithTitle:@"全部到岗" selected:(apply_job_date && apply_job_date.integerValue == 0 ? YES : NO) enable:YES arg:@(0)];
        
        WEAKSELF
        _lestDaySheet = [[ConditionSheet alloc] initWithItems:@[other, day2, day3, day5, dayAll] complentBlock:^(NSInteger index, NSNumber *arg) {
            weakSelf.jobModel.apply_job_date = arg;
            [weakSelf.tableView reloadData];
        }];
    }
    return _lestDaySheet;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"限制条件";
    
    self.tableViewStyle = UITableViewStyleGrouped;
    [self setUIHaveBottomView];
    
//    // tableView
//    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
//    tableView.delegate = self;
//    tableView.dataSource = self;
//    [self.view addSubview:tableView];
//    self.tableView = tableView;
    [self.tableView registerNib:[UINib nibWithNibName:@"ConditionCell" bundle:nil] forCellReuseIdentifier:@"ConditionCell"];
    self.tableView.rowHeight = 44;
    [self setData];
}

- (void)setData{
    self.cellArray = [NSMutableArray array];
    
    NSMutableArray *section0 = [NSMutableArray array];
    WEAKSELF
    [section0 addObject:[ConditionCellModel cellModelWithTitle:@"性别" type:ConditionCellTypeIndecator swichState:NO btnBlock:nil]];
    [section0 addObject:[ConditionCellModel cellModelWithTitle:@"年龄" type:ConditionCellTypeIndecator swichState:NO btnBlock:nil]];
    [section0 addObject:[ConditionCellModel cellModelWithTitle:@"身高" type:ConditionCellTypeIndecator swichState:NO btnBlock:nil]];
    [section0 addObject:[ConditionCellModel cellModelWithTitle:@"实名认证" type:ConditionCellTypeSwitch swichState:weakSelf.jobModel.rel_name_verify ? YES : NO btnBlock:^(UIButton *switchBtn) {
        weakSelf.jobModel.rel_name_verify = switchBtn.selected ? @(1) : nil;
    }]];
    
    [section0 addObject:[ConditionCellModel cellModelWithTitle:@"有生活照" type:ConditionCellTypeSwitch swichState:weakSelf.jobModel.life_photo ? YES : NO btnBlock:^(UIButton *switchBtn) {
        weakSelf.jobModel.life_photo = switchBtn.selected ? @(1) : nil;
    }]];
    
    [section0 addObject:[ConditionCellModel cellModelWithTitle:@"最少上岗天数" type:ConditionCellTypeIndecator swichState:NO btnBlock:nil]];
    
    NSMutableArray *section1 = [NSMutableArray array];
    [section1 addObject:[ConditionCellModel cellModelWithTitle:@"有健康证" type:ConditionCellTypeSwitch swichState:weakSelf.jobModel.health_cer ? YES : NO btnBlock:^(UIButton *switchBtn) {
        weakSelf.jobModel.health_cer = switchBtn.selected ? @(1) : nil;
        
    }]];
    
    [section1 addObject:[ConditionCellModel cellModelWithTitle:@"有学生证" type:ConditionCellTypeSwitch swichState:weakSelf.jobModel.stu_id_card ? YES : NO btnBlock:^(UIButton *switchBtn) {
        weakSelf.jobModel.stu_id_card = switchBtn.selected ? @(1) : nil;
    }]];
    [self.cellArray addObject:section0];
    [self.cellArray addObject:section1];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.cellArray[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.cellArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ConditionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConditionCell" forIndexPath:indexPath];
    ConditionCellModel *model = self.cellArray[indexPath.section][indexPath.row];
    
    cell.model = model;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: // 性别
            {
                NSNumber *arg = self.jobModel.sex;
                if (arg && arg.integerValue == 1) {
                    cell.titleLabel.text = @"男";
                }
                if (arg && arg.integerValue == 0) {
                    cell.titleLabel.text = @"女";
                }
            }
                break;
            case 1:
            {
                NSNumber *arg = self.jobModel.age;
                if (arg && arg.integerValue == 1) {
                    cell.titleLabel.text = @"18周岁以上";
                }
                if (arg && arg.integerValue == 2) {
                    cell.titleLabel.text = @"18-25周岁";
                }
                if (arg && arg.integerValue == 3) {
                    
                    cell.titleLabel.text = @"25周岁以上";
                }
            }
                break;
            case 2:
            {
                NSNumber *arg = self.jobModel.height;
                if (arg && arg.integerValue == 1) {
                    cell.titleLabel.text = @"160cm以上";
                }
                if (arg && arg.integerValue == 2) {
                    cell.titleLabel.text = @"165cm以上";
                }
                if (arg && arg.integerValue == 3) {
                    cell.titleLabel.text = @"168cm以上";
                }
                if (arg && arg.integerValue == 4) {
                    cell.titleLabel.text = @"170cm以上";
                }
                if (arg && arg.integerValue == 5) {
                    cell.titleLabel.text = @"175cm以上";
                }
                if (arg && arg.integerValue == 6) {
                    cell.titleLabel.text = @"180cm以上";
                }
            }
                break;
            case 3:
            {
                cell.switchBtn.selected = (self.jobModel.rel_name_verify && self.jobModel.rel_name_verify.integerValue == 1);
            }
                break;
            case 4:
            {
                cell.switchBtn.selected = (self.jobModel.life_photo && self.jobModel.life_photo.integerValue == 1);
            }
                break;
            case 5:
            {
                NSNumber *arg = self.jobModel.apply_job_date;
                if (arg && arg.integerValue == 2) {
                    cell.titleLabel.text = @"2天以上";
                }
                if (arg && arg.integerValue == 3) {
                    cell.titleLabel.text = @"3天以上";
                }
                if (arg && arg.integerValue == 5) {
                    cell.titleLabel.text = @"5天以上";
                }
                if (arg && arg.integerValue == 0) {
                    cell.titleLabel.text = @"全部到岗";
                }
            }
                break;
            default:
                break;
        }
    }
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                cell.switchBtn.selected = (self.jobModel.health_cer && self.jobModel.health_cer.integerValue == 1);
            }
                break;
            case 1:
            {
                cell.switchBtn.selected = (self.jobModel.stu_id_card && self.jobModel.stu_id_card.integerValue == 1);
            }
                break;
            default:
                break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 10;
    }
    return 33;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 33)];
        headerView.backgroundColor = MKCOLOR_RGB(239, 239, 244);
        
        UILabel *sectionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 7, SCREEN_WIDTH - 16, 20)];
        sectionTitleLabel.font = [UIFont systemFontOfSize:14];
        sectionTitleLabel.text = @"证件";
        sectionTitleLabel.textColor = MKCOLOR_RGB(89, 89, 89);
        [headerView addSubview:sectionTitleLabel];
        
        return headerView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    // 覆盖父类方法,不能删
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: // 性别
            {
                [self.sexSheet show];
            }
                break;
            case 1: // 年龄
            {
                [self.ageSheet show];
            }
                break;
            case 2: // 身高
            {
                [self.heightSheet show];
            }
                break;
            case 3: // 实名认证
            case 4: // 有生活照
                break;
            case 5: // 最少上岗天数
            {
                // 判断是否已经选择了日期
                if (!self.startDate || !self.endDate) {
                    [UIHelper showConfirmMsg:@"请先选择兼职日期才能限制最少上岗天数哦~" title:@"提示" cancelButton:@"知道了" completion:nil];
                } else {
                    [self.lestDaySheet show];
                }
            }
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: // 有健康证
                break;
            case 1: // 有学生证
                break;
        }
    }
}

- (void)btnBottomOnclick:(UIButton*)sender{
    MKBlockExec(self.block, self.jobModel);
    [self.navigationController popViewControllerAnimated:YES];
}

@end
