//
//  ExactPayOnlineCell.m
//  jianke
//
//  Created by 时现 on 15/11/23.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "ExactPayOnlineCell.h"
#import "JKModel.h"
#import "UIImageView+WebCache.h"
#import "DateHelper.h"
#import "UIHelper.h"
#import "DateTools.h"
#import "PaySalaryModel.h"
#import "DateSelectView.h"
#import "WDConst.h"
//#import "ResumeListModel.h"

//#define WIDTH  30
//#define HIGHT  30

@interface ExactPayOnlineCell(){
    NSIndexPath* _indexPath;
    
    NSInteger _days;    /*!< 总天数 */
    NSArray* _epcArray; /*!< 方块数据数组 */
    
    double _salaryNum;  /*!< 需支付的薪资 */
    
//    NSInteger _rectMaxCount;
//    CGFloat _rectSideLeng;
//    CGFloat _rectEdges;
}

@property (weak, nonatomic) IBOutlet UIButton *selectBtn;       //选择btn
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;    //头像
@property (weak, nonatomic) IBOutlet UIImageView *sexImage;     //性别
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;        //姓名
@property (weak, nonatomic) IBOutlet UILabel *labAddStatus;
@property (weak, nonatomic) IBOutlet UITextField *tfSalaryNum;  //修改薪水textfield
@property (weak, nonatomic) IBOutlet UILabel *unPunckNum;       //漏签次数 日期
@property (weak, nonatomic) IBOutlet UILabel *labPayDatail;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exactPayViewHeight;    /*!< 小方块区域view的高度 */
@property (weak, nonatomic) IBOutlet UIButton *exactBtn;        /*!< 点击弹出日历按钮 */
@property (weak, nonatomic) IBOutlet UIView *exactPayView;      /*!< 小方块区域的view */

//@property (nonatomic, strong) NSMutableArray *pictureArray;     /*!< 小方块数组 */

//@property (nonatomic, strong) UIImageView *exactImgV;
//显示下方框数组
@property (nonatomic, strong) NSMutableArray *picMoneyArr;
@property (nonatomic, strong) NSMutableArray *picRedArr;
@property (nonatomic, strong) NSMutableArray *picGreenArr;
@property (nonatomic, strong) NSMutableArray *defaultSelectDateArray;

@property (nonatomic, strong) NSMutableArray *defaultSelectNumArray;

@property (nonatomic, copy) NSString *preparePay;//准备支付
@property (nonatomic, copy) NSString *alreadyPay;//已经支付

@property (nonatomic, strong) NSMutableArray *pitchArray;
@property (nonatomic, strong) NSNumber *onBoardStatus;//是否未到岗

@property (nonatomic, strong) ResumeListModel *rlModel;

@end
@implementation ExactPayOnlineCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"ExactPayOnlineCell";
    ExactPayOnlineCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"ExactPayOnlineCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        [cell.labAddStatus setBorderWidth:1 andColor:[UIColor XSJColor_grayLine]];
        [cell.labAddStatus setCorner];
        cell.labAddStatus.hidden = YES;
        [cell.iconImage setCorner];

    }
    return cell;
}

- (void)refreshWithData:(ResumeListModel *)model andIndexPath:(NSIndexPath *)indexPath{
    _salaryNum = 0;
//    _rectMaxCount = 30;
//    _rectSideLeng = 30; //22+8
//    _rectEdges = 8;
    
    if (model) {
        _rlModel = model;
        _indexPath = indexPath;
        
        JKModel *jkModel = model.resume_info;
        
        _epcArray = _rlModel.exaPayArray;
        _days = _epcArray.count;
        _salaryNum = _rlModel.nowPaySalary*0.01;
        
        self.selectBtn.selected = _rlModel.isSelect;
        //头像
        [self.iconImage sd_setImageWithURL:[NSURL URLWithString:jkModel.user_profile_url] placeholderImage:[UIHelper getDefaultHeadRect]];
        
        //sex
        if (jkModel.sex.intValue == 0) {
            [self.sexImage setImage:[UIImage imageNamed:@"v230_female"]];
        }else{
            [self.sexImage setImage:[UIImage imageNamed:@"v230_male"]];
        }
        //姓名
        self.nameLabel.text = jkModel.true_name;
        
        // 人员补录 
        if (jkModel.apply_job_type.integerValue > 1 || jkModel.isFromPayAdd) {
            self.labAddStatus.hidden = NO;
        }else{
            self.labAddStatus.hidden = YES;
        }
        
        
        if (_rlModel.isFromSingleDay) {
            self.unPunckNum.text = [NSString stringWithFormat:@"漏签%@次",_rlModel.stu_unPunck_num];
        }else{        //时间
            self.unPunckNum.text = [DateHelper dateRangeStrWithMicroSecondNumArray:jkModel.stu_work_time];
            self.unPunckNum.font = [UIFont fontWithName:kFont_RSR size:13];
        }
        
        //薪水
        self.tfSalaryNum.text = [[NSString stringWithFormat:@"%.2f",_salaryNum] stringByReplacingOccurrencesOfString:@".00" withString:@""];

        _rlModel.cellHeight = 68;

        if (_rlModel.isFromSingleDay || jkModel.isFromPayAdd) {
            self.exactPayView.hidden = YES;
        }else{
            self.exactPayView.hidden = NO;
            //显示方块
//            if (!self.pictureArray) {
//                self.pictureArray = [[NSMutableArray alloc] init];
//                for (int i = 0; i < _rectMaxCount; i++) {
//                    UIImageView* exactImgV = [[UIImageView alloc]init];
//                    [self.pictureArray addObject:exactImgV];
//                }
//            }
//            int lineNum = 0;//行数
//            int showNum = (SCREEN_WIDTH-28 - _rectEdges)/_rectSideLeng; //每行显示个数
            
//            _days = _days < _rectMaxCount ? _days : _rectMaxCount;
//            for (int i = 0; i < _days; i++) {
//                UIImageView* exactImgV = [self.pictureArray objectAtIndex:i];
//                exactImgV.image = nil;
//                exactImgV.backgroundColor = [UIColor clearColor];
//                
//                lineNum = i/showNum;
//                int d = fmod(i, showNum);
//                exactImgV.frame = CGRectMake(_rectEdges + _rectSideLeng * d, _rectSideLeng * lineNum + _rectEdges, _rectSideLeng-_rectEdges, _rectSideLeng-_rectEdges);
//                
//                ExaPayCellModel* epcModel = [_epcArray objectAtIndex:i];
//                if (epcModel.dayStatus == 0) {
//                    [exactImgV setImage:[UIImage imageNamed:@"v230_grid"]];
//                }else if (epcModel.dayStatus == 1){
//                    [exactImgV setImage:[UIImage imageNamed:@"v230_paybox"]];
//                }else if (epcModel.dayStatus == 2){
//                    [exactImgV setImage:[UIImage imageNamed:@"v230_pay"]];
//                }else if (epcModel.dayStatus == 3){
//                    [exactImgV setImage:[UIImage imageNamed:@"v230_payedaa"]];
//                }else if (epcModel.dayStatus == 4){
//                    [exactImgV setImage:[UIImage imageNamed:@"v230_unfinished"]];
//                }
//                [self.exactPayView addSubview:exactImgV];
//                
//                _rlModel.onBoardDate = nil;
//                _rlModel.onBoardDate = [[NSMutableArray alloc] init];
//                for (ExaPayCellModel *model in _epcArray) {
//                    if (model.dayStatus == 2) {
//                        [_rlModel.onBoardDate addObject:[NSString stringWithFormat:@"%lld",model.timeStamp]];
//                    }
//                }
//            }

            self.picMoneyArr = [[NSMutableArray alloc] init];
            self.picRedArr = [[NSMutableArray alloc] init];
            self.picGreenArr = [[NSMutableArray alloc] init];
            self.defaultSelectDateArray = [[NSMutableArray alloc] init];
            for (ExaPayCellModel* model in _epcArray) {
                NSDate * date = [NSDate dateWithTimeIntervalSince1970:model.timeStamp/1000];
                switch (model.dayStatus) {
                    case 1:{
                        [self.picGreenArr addObject:date];
                    }
                        break;
                    case 2:{
                        [self.picGreenArr addObject:date];
                        [self.defaultSelectDateArray addObject:date];
                        [_rlModel.onBoardDate addObject:date];
                    }
                        break;
                    case 3:{
                        [self.picGreenArr addObject:date];
                        [self.picMoneyArr addObject:date];
                    }
                        break;
                    case 4:{
                        [self.picGreenArr addObject:date];
                        [self.picRedArr addObject:date];
                    }
                        break;
                    default:
                        break;
                }
            }

            self.picMoneyArr = [[NSMutableArray alloc] init];
            self.picRedArr = [[NSMutableArray alloc] init];
            self.picGreenArr = [[NSMutableArray alloc] init];
            self.defaultSelectDateArray = [[NSMutableArray alloc] init];
            for (ExaPayCellModel* model in _epcArray) {
                NSDate * date = [NSDate dateWithTimeIntervalSince1970:model.timeStamp/1000];
                switch (model.dayStatus) {
                    case 1:{
                        [self.picGreenArr addObject:date];
                    }
                        break;
                    case 2:{
                        [self.picGreenArr addObject:date];
                        [self.defaultSelectDateArray addObject:date];
                        [_rlModel.onBoardDate addObject:date];
                    }
                        break;
                    case 3:{
                        [self.picGreenArr addObject:date];
                        [self.picMoneyArr addObject:date];
                    }
                        break;
                    case 4:{
                        [self.picGreenArr addObject:date];
                        [self.picRedArr addObject:date];
                    }
                        break;
                    default:
                        break;
                }
            }

            self.labPayDatail.text = [NSString stringWithFormat:@"已支付%lu天，待支付%lu天",(unsigned long)self.picMoneyArr.count, (unsigned long)self.defaultSelectDateArray.count];
            // 计算日期label高度
            CGSize labTimeSize = [self.unPunckNum contentSizeWithWidth:SCREEN_WIDTH-104];
            
            if (labTimeSize.height > 18) {
                _rlModel.cellHeight = _rlModel.cellHeight-18 + labTimeSize.height;
            }
            
            if (_rlModel.isSelect) {    //选中
                self.exactPayView.hidden = NO;
                
                _rlModel.cellHeight = _rlModel.cellHeight + 44;
            }else{  // 未选中
                self.exactPayView.hidden = YES;
            }
        }
    }
}

- (IBAction)exactBtnOnClick:(UIButton *)sender {
    //岗位的总时间
    NSDate * startDate = [NSDate dateWithTimeIntervalSince1970:[_rlModel.job_start_time longLongValue]/1000];
    NSDate * endDate = [NSDate dateWithTimeIntervalSince1970:[_rlModel.job_end_time longLongValue]/1000];
    // 弹窗
    DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"请选择支付日期" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 300)];
    
    //日历下方的label
    UILabel *allSalaryLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 270, 200, 20)];
    allSalaryLabel.font = [UIFont systemFontOfSize:12];
    [containerView addSubview:allSalaryLabel];
    
    // 日期控件
    DateSelectView *dateView = [[DateSelectView alloc] initWithFrame:CGRectMake(0, 0, 260, 260)];
    dateView.type = DateViewTypePay;
    [containerView addSubview:dateView];
    alertView.contentView = containerView;
    
    self.picMoneyArr = [[NSMutableArray alloc] init];
    self.picRedArr = [[NSMutableArray alloc] init];
    self.picGreenArr = [[NSMutableArray alloc] init];
    self.defaultSelectDateArray = [[NSMutableArray alloc] init];
    for (ExaPayCellModel* model in _epcArray) {
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:model.timeStamp/1000];
        switch (model.dayStatus) {
            case 1:{
                [self.picGreenArr addObject:date];
            }
                break;
            case 2:{
                [self.picGreenArr addObject:date];
                [self.defaultSelectDateArray addObject:date];
                [_rlModel.onBoardDate addObject:date];
            }
                break;
            case 3:{
                [self.picGreenArr addObject:date];
                [self.picMoneyArr addObject:date];
            }
                break;
            case 4:{
                [self.picGreenArr addObject:date];
                [self.picRedArr addObject:date];
            }
                break;
            default:
                break;
        }
    }
    
    //预设
    NSInteger daySalary = _rlModel.job_day_salary.integerValue;
    self.preparePay = [NSString stringWithFormat:@"￥%.2f", self.defaultSelectDateArray.count * daySalary * 0.01];
    self.alreadyPay = [NSString stringWithFormat:@"￥%.2f", _rlModel.ent_pay_salary.integerValue  * 0.01];
    allSalaryLabel.attributedText = [self allSalaryAttributedTextWithPreparePayStr:self.preparePay alreadyPayStr:self.alreadyPay];
    
    dateView.datesPay = self.picMoneyArr;
    
    dateView.datesAbsent = self.picRedArr;
    dateView.datesComplete = self.picGreenArr;
    dateView.datesSelected = self.defaultSelectDateArray;
    dateView.startDate = startDate;
    dateView.endDate = endDate;
    __weak typeof(DateSelectView *) weakDateView = dateView;
    WEAKSELF
    dateView.didClickBlock = ^(id obj){
        NSInteger days = weakDateView.datesSelected.count;
        weakSelf.preparePay = [NSString stringWithFormat:@"￥%.2f", days * (weakSelf.rlModel.job_day_salary.integerValue)  * 0.01];
        allSalaryLabel.attributedText = [weakSelf allSalaryAttributedTextWithPreparePayStr:weakSelf.preparePay alreadyPayStr:weakSelf.alreadyPay];
        
        weakSelf.rlModel.onBoardDate = weakDateView.datesSelected;
    };
    [alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            // 修改小方块颜色
            for (ExaPayCellModel* model in _epcArray) {
                if (model.dayStatus == 2) {
                    model.dayStatus = 1;
                }
            }
            for (NSDate *date in weakDateView.datesSelected) {
                long long dateNum = date.timeIntervalSince1970*1000;
                for (ExaPayCellModel* model in _epcArray) {
                    if (model.timeStamp == dateNum){
                        model.dayStatus = 2;
                    }
                }
            }
            // 修改预付的薪资显示
            _rlModel.exaPayArray = _epcArray;
            _salaryNum = weakDateView.datesSelected.count * weakSelf.rlModel.job_day_salary.integerValue*0.01;
            [weakSelf changeMoneyIsReflushCell:YES];
        }
    }];
}


- (NSMutableAttributedString *)allSalaryAttributedTextWithPreparePayStr:(NSString *)preparePayStr alreadyPayStr:(NSString *)alreadyPayStr{
    preparePayStr = [self.preparePay stringByReplacingOccurrencesOfString:@".00" withString:@""];
    alreadyPayStr = [self.alreadyPay stringByReplacingOccurrencesOfString:@".00" withString:@""];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSForegroundColorAttributeName] = [UIColor redColor];
    NSMutableAttributedString *preparePay = [[NSMutableAttributedString alloc] initWithString:preparePayStr attributes:dic];
    
    NSMutableAttributedString *aStrM = [[NSMutableAttributedString alloc] initWithString:@"预计支付 "];
    [aStrM appendAttributedString:preparePay];
    [aStrM appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@", 已支付 "]];
    [aStrM appendAttributedString:[[NSMutableAttributedString alloc] initWithString:alreadyPayStr]];
    
    return aStrM;
}


#pragma mark - ***** 按钮事件 ******
- (IBAction)salaryEidtChange:(UITextField *)sender {
    NSRange range = [sender.text rangeOfString:@"."];
    if (range.length != 0) { // 有小数点
        if (sender.text.length > 9) {
            sender.text = [sender.text substringToIndex:9];
        }
    } else { // 没有小数点
        if (sender.text.length > 6) {
            sender.text = [sender.text substringToIndex:6];
        }
    }
    
    _salaryNum = [self.tfSalaryNum.text doubleValue];
    if (!_salaryNum) {
        _salaryNum = 0;
    }
    [self changeMoneyIsReflushCell:NO];
}
- (IBAction)salaryEndEditing:(UITextField *)sender {
    [sender resignFirstResponder];
    _salaryNum = [self.tfSalaryNum.text doubleValue];
    if (!_salaryNum) {
        _salaryNum = 0;
    }
    [self changeMoneyIsReflushCell:YES];
}

- (void)changeMoneyIsReflushCell:(BOOL)isReflush{
    _rlModel.nowPaySalary = _salaryNum * 100;
    self.selectBtn.selected = _rlModel.nowPaySalary != 0;
    _rlModel.isSelect = self.selectBtn.selected;
    
    if ([self.delegate respondsToSelector:@selector(psCell_allMoneyWithSelect)]) {
        [self.delegate psCell_allMoneyWithSelect];
    }
    if (isReflush) {
        [self reflushCell];
    }
}

- (IBAction)btnSelectOnClick:(UIButton *)sender {    
//    if (!_rlModel.isSelect && _salaryNum == 0) {
//        [UIHelper toast:@"金额为0，不能选择"];
//        return;
//    }
    sender.selected = !sender.selected;
    _rlModel.isSelect = sender.selected;

    if ([self.delegate respondsToSelector:@selector(psCell_allMoneyWithSelect)]) {
        [self.delegate psCell_allMoneyWithSelect];
    }
    [self reflushCell];
}

- (void)reflushCell{
    if ([self.delegate respondsToSelector:@selector(psCell_updateCellIndex:withModel:)]) {
        [self.delegate psCell_updateCellIndex:_indexPath withModel:_rlModel];
    }
}



@end
