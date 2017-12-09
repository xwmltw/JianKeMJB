//
//  InvitingForJobCell.m
//  jianke
//
//  Created by xiaomk on 15/9/15.
//  Copyright (c) 2015年 xianshijian. All rights reserved.
//

#import "InvitingForJobCell.h"
#import "JobModel.h"
#import "UIHelper.h"
#import "WDConst.h"
#import "ApplyJobResumeModel.h"

@interface InvitingForJobCell() <UIScrollViewDelegate>
{
    NSMutableArray *_applyJKArray;
    BOOL _isShowBtnView;
    JobModel* _jobModel;
    NSArray* _dataArray;
    NSInteger _nowSelect;   //首页显示的 当前天 如果没有当前天 就显示下一天
    int _todayNum;    //精确的 是否是当天 ，否则为 -1；
    CGFloat _pageWidth;
    NSMutableArray* _labArray;
}

//@property (weak, nonatomic) IBOutlet UIButton *bgBtn; /*!< 背景按钮 */

@property (weak, nonatomic) IBOutlet UIImageView *imgQiang;
@property (weak, nonatomic) IBOutlet UIImageView *imgTuo;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutImgTuoLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutTitleLeft;
@property (weak, nonatomic) IBOutlet UILabel *labTitle;


@property (weak, nonatomic) IBOutlet UIView *viewMid;
@property (weak, nonatomic) IBOutlet UILabel *labAddress;   /*!< 地址 */
@property (weak, nonatomic) IBOutlet UILabel *labDate;      /*!< 时间 */

//@property (weak, nonatomic) IBOutlet UIButton *btnBot;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_1;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_2;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_3;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_4;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_5;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_6;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_7;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_8;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_9;
@property (weak, nonatomic) IBOutlet UIButton *btnApplyHead_10;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *headArray;
@property (weak, nonatomic) IBOutlet UILabel *hireNumLab;
@property (weak, nonatomic) IBOutlet UIImageView *spamLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spamLeftConstraint;
@property (weak, nonatomic) IBOutlet UIButton *moreActionBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutSalRightConstraint;


//@property (weak, nonatomic) IBOutlet UIButton *btnApplyList;
@property (weak, nonatomic) IBOutlet UIView *viewCheckIng;
@property (weak, nonatomic) IBOutlet UILabel *labApplyNum;
//@property (weak, nonatomic) IBOutlet UIImageView *imgRedPoint;
- (IBAction)btnShowSheet:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *salaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *unitLab;

@end
@implementation InvitingForJobCell


+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"InvitingForJobCell";
    InvitingForJobCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"InvitingForJobCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}



- (void)refreshWithData:(JobModel*)model{
    if (model) {
        _jobModel = model;
        _isShowBtnView = YES;
        if (model.status.integerValue == 2) {
            self.moreActionBtn.hidden = NO;
            self.layoutSalRightConstraint.constant = 40;
        }else{
            self.moreActionBtn.hidden = YES;
            self.layoutSalRightConstraint.constant = 16;
        }
        
        //抢单 标记
        
        if (model.source.integerValue == 1) {
            self.imgTuo.hidden = YES;
            self.imgQiang.hidden = YES;
            self.spamLab.hidden = NO;
            self.spamLeftConstraint.constant = 12;
            self.layoutTitleLeft.constant = 32;
        }else{
            self.spamLab.hidden = YES;
            if (self.managerType == ManagerTypeEP) { // 雇主视角
                if (model.job_type.integerValue == 2 && model.enable_recruitment_service.integerValue == 1) { // 抢 & 托
                    self.imgQiang.hidden = NO;
                    self.imgTuo.hidden = NO;
                    
                    self.layoutImgTuoLeft.constant = 32;
                    self.layoutTitleLeft.constant = 52;
                    
                } else if (model.job_type.integerValue == 2 && model.enable_recruitment_service.integerValue != 1) { // 抢
                    self.imgQiang.hidden = NO;
                    self.imgTuo.hidden = YES;
                    self.layoutTitleLeft.constant = 32;
                    
                } else if (model.job_type.integerValue != 2 && model.enable_recruitment_service.integerValue == 1) { // 托
                    self.imgQiang.hidden = YES;
                    self.imgTuo.hidden = NO;
                    self.layoutImgTuoLeft.constant = 12;
                    self.layoutTitleLeft.constant = 32;
                    
                } else { // 都不显示
                    self.imgQiang.hidden = YES;
                    self.imgTuo.hidden = YES;
                    self.layoutTitleLeft.constant = 12;
                }
            } else if (self.managerType == ManagerTypeBD) { // BD视角
                self.imgTuo.hidden = YES;
                if (model.job_type.integerValue == 2) { //抢
                    self.imgQiang.hidden = NO;
                    self.layoutTitleLeft.constant = 32;
                } else {
                    self.imgQiang.hidden = YES;
                    self.layoutTitleLeft.constant = 12;
                }
            }
        }
        
        
        //标题
        self.labTitle.text = model.job_title;
        
        //薪水
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%.2f", model.salary.value.floatValue] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20], NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:87/255.0 blue:34/255.0 alpha:1]}];
        [attStr appendAttributedString:[[NSAttributedString alloc] initWithString:[model.salary getTypeDesc] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
        self.salaryLabel.attributedText = attStr;
        self.unitLab.text = [model.salary getTypeDesc];
        //人数
        self.hireNumLab.text = [NSString stringWithFormat:@"招聘人数：%@人", model.recruitment_num];
        
        //时间
        NSString* dateStr = [NSString stringWithFormat:@"工作日期：%@", [[model.dead_time_start_end_str stringByReplacingOccurrencesOfString:@"." withString:@"/"] stringByReplacingOccurrencesOfString:@"-" withString:@"至"]];
        self.labDate.text = dateStr;
        self.labDate.font = [UIFont fontWithName:kFont_RSR size:13];
        //地址
        self.labAddress.text = [NSString stringWithFormat:@"集合地点：%@", model.working_place];
        
        
        self.btnApplyHead_1.hidden = YES;
        self.btnApplyHead_2.hidden = YES;
        self.btnApplyHead_3.hidden = YES;
        self.btnApplyHead_4.hidden = YES;
        self.btnApplyHead_5.hidden = YES;
        self.btnApplyHead_6.hidden = YES;
        self.btnApplyHead_7.hidden = YES;
        self.btnApplyHead_8.hidden = YES;
        self.btnApplyHead_9.hidden = YES;
        self.btnApplyHead_10.hidden = YES;
        
        self.labApplyNum.hidden = YES;

        if (model.status.intValue == 1) {
            ELog(@"待审核");
            self.viewCheckIng.hidden = NO;
        }else if (model.status.intValue == 2) {
            self.viewCheckIng.hidden = YES;
            self.labApplyNum.hidden = NO;
//            self.btnApplyList.hidden = NO;
            
            
            _applyJKArray = [[NSMutableArray alloc] init];
            NSInteger showHeadNum = (int)((SCREEN_WIDTH-(110+16+16))/30);
            NSInteger maxNum = showHeadNum > 10 ? 10 : showHeadNum;
            if (model.source.integerValue == 1) {
                if (model.apply_job_contact_resumes && model.apply_job_contact_resumes.count){    //采集岗位电话咨询JK列表
                    for (NSDictionary* data in model.apply_job_contact_resumes){
                        ApplyJobResumeModel* model = [ApplyJobResumeModel objectWithKeyValues:data];
                        [_applyJKArray addObject:model];
                    }
                    showHeadNum = (model.apply_job_contact_resumes.count < maxNum) ? model.apply_job_contact_resumes.count : maxNum ;
                }                
            }else{
                if (model.apply_job_resumes && model.apply_job_resumes.count > 0){  //非采集岗位报名JK简历列表
                    for (NSDictionary* data in model.apply_job_resumes){
                        ApplyJobResumeModel* model = [ApplyJobResumeModel objectWithKeyValues:data];
                        [_applyJKArray addObject:model];
                    }
                    showHeadNum = (model.apply_job_resumes.count < maxNum) ? model.apply_job_resumes.count : maxNum ;
                }
            }
            
            if (_applyJKArray && _applyJKArray.count) {

                for (int i = 0; i < showHeadNum; i++) {
                    ApplyJobResumeModel* applyModel = [_applyJKArray objectAtIndex:i];
                    switch (i) {
                        case 0:
                            self.btnApplyHead_1.hidden = NO;
                            [self.btnApplyHead_1 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                            
                        case 1:
                            self.btnApplyHead_2.hidden = NO;
                            [self.btnApplyHead_2 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                        case 2:
                            self.btnApplyHead_3.hidden = NO;
                            [self.btnApplyHead_3 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                        case 3:
                            self.btnApplyHead_4.hidden = NO;
                            [self.btnApplyHead_4 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                        case 4:
                            self.btnApplyHead_5.hidden = NO;
                            [self.btnApplyHead_5 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                            
                        case 5:
                            self.btnApplyHead_6.hidden = NO;
                            [self.btnApplyHead_6 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                            
                        case 6:
                            self.btnApplyHead_7.hidden = NO;
                            [self.btnApplyHead_7 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                            
                        case 7:
                            self.btnApplyHead_8.hidden = NO;
                            [self.btnApplyHead_8 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                        case 8:
                            self.btnApplyHead_9.hidden = NO;
                            [self.btnApplyHead_9 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                        case 9:
                            self.btnApplyHead_10.hidden = NO;
                            [self.btnApplyHead_10 sd_setBackgroundImageWithURL:[NSURL URLWithString:applyModel.user_profile_url] forState:UIControlStateNormal placeholderImage:[UIHelper getDefaultHeadRect]];
                            break;
                        default:
                            break;
                    }
                }
            }
            NSString* applyNumStr = nil;
            if (model.source.integerValue == 1) {
                applyNumStr = [NSString stringWithFormat:@"%@人咨询",model.contact_apply_num];
            }else{
                applyNumStr = [NSString stringWithFormat:@"%@份简历待处理",model.undeal_apply_num];
            }
            self.labApplyNum.text = applyNumStr;
            self.labApplyNum.hidden = NO;
//            self.imgRedPoint.hidden = !(model.undeal_apply_num.integerValue > 0);

        }
    }
}

#pragma mark - 按钮事件
////点击cell头部  走这里  点击按钮
//- (IBAction)bgBtnOnClick:(UIButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(cell_didSelectRowAtIndex:)]) {
//        [self.delegate cell_didSelectRowAtIndex:_jobModel];
//    }
//}

///** 点击底部 */
//- (IBAction)btnBotOnclick:(UIButton *)sender {
//    if ([self.delegate respondsToSelector:@selector(cell_btnBotOnClick:)]) {
//        [self.delegate cell_btnBotOnClick:_jobModel];
//    }
//}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//更多操作
- (IBAction)btnShowSheet:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cell_btnBotOnClick:)]) {
        [self.delegate cell_btnBotOnClick:_jobModel];
    }
}
@end
