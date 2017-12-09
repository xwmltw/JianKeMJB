//
//  PersonnelManagerCell.m
//  jianke
//
//  Created by xiaomk on 16/7/4.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "PersonnelManagerCell.h"
#import "XSJConst.h"
#import "JKModel.h"

@interface PersonnelManagerCell(){
    JKModel* _jkModel;
}

@end

@implementation PersonnelManagerCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"PersonnelManagerCell";
    PersonnelManagerCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"PersonnelManagerCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor whiteColor];
        [cell.labAddTag setBorderWidth:1 andColor:[UIColor XSJColor_grayLine]];
        [cell.labAddTag setCorner];
        [cell.imgHead setCorner];

    }
    return cell;
}

- (void)refreshWithData:(JKModel*)jkmodel{
    if (jkmodel) {
        _jkModel = jkmodel;
        
        self.btnPhone.hidden = YES; //无用的

        
        [self.imgHead sd_setImageWithURL:[NSURL URLWithString:jkmodel.user_profile_url] placeholderImage:[UIHelper getDefaultHead]];
        
        //性别
        self.imgSex.image = jkmodel.sex.integerValue == 1 ?  [UIImage imageNamed:@"main_sex_male"] : [UIImage imageNamed:@"main_sex_female"];
        //名字
        self.labName.text = jkmodel.true_name;
        self.labAddTag.hidden = NO;
        switch (jkmodel.apply_job_source.integerValue) {
            case 1:
                self.labAddTag.text = @"平台报名";
                self.labAddTag.hidden = YES;
                break;
            case 2:
                self.labAddTag.text = @"人员补录";
                break;
            case 3:
                self.labAddTag.text = @"人员推广";
                break;
            default:
                break;
        }
        //时间
        if (jkmodel.stu_work_time_type.integerValue == 2) { // 默认
            NSString *startDate = [DateHelper getDateWithNumber:jkmodel.stu_work_time.firstObject];
            NSString *endDate = [DateHelper getDateWithNumber:jkmodel.stu_work_time.lastObject];
            self.labDate.text = [NSString stringWithFormat:@"%@ 至 %@", startDate, endDate];
        } else { // 兼客选择
            self.labDate.text = [DateHelper dateRangeStrWithSecondNumArray:jkmodel.stu_work_time];
        }
        
        jkmodel.cellHeight = 64;
        CGSize labDateSize = [self.labDate contentSizeWithWidth:SCREEN_WIDTH-72];
        if (labDateSize.height > 18) {
            jkmodel.cellHeight = 64-17+labDateSize.height;
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
