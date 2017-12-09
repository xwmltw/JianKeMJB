//
//  BuyInsuranceCell.m
//  jianke
//
//  Created by 时现 on 15/12/9.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "BuyInsuranceCell.h"
#import "JKModel.h"
#import "UIImageView+WebCache.h"
#import "UIHelper.h"
#import "BuyInsuranceModel.h"
#import "DateHelper.h"
#import "WDConst.h"
#import "DateTools.h"
#import "DateSelectView.h"

#define WIDTH  30
#define HIGHT  30

@interface BuyInsuranceCell(){
    JKModel *_jkModel;
    ResumeLModel *_rlModel;
    NSIndexPath* _indexPath;

    NSInteger _days;
    BuyInsuranceModel *_biModel;
    double _salaryNum;
    BOOL _isSelectBtn;
//    ResumeLModel *_rlModel;

}
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;//选择btn
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;//头像
@property (weak, nonatomic) IBOutlet UIImageView *imgSex;//性别
@property (weak, nonatomic) IBOutlet UILabel *labName;//姓名
@property (weak, nonatomic) IBOutlet UILabel *labBoardDate;//上岗日期
@property (weak, nonatomic) IBOutlet UILabel *labSalary;//保险金额
@property (weak, nonatomic) IBOutlet UIView *cubeView;//小方块view
@property (weak, nonatomic) IBOutlet UIButton *cubeViewOnClick;//小方块上的button
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutCubeView;//小方块view的height

@property (nonatomic,strong) NSMutableArray *pinkPicArray;//放鸽子array
@property (nonatomic,strong)NSMutableArray *greenPicArray;//报名array
@property (nonatomic,strong) NSMutableArray *payedArray;//盾牌方块
@property (nonatomic, strong) NSMutableArray *pictureArray;//小方块数组
@property (nonatomic, strong) NSMutableArray *defaultSelectDateArray;//打勾的☑️
@property (nonatomic, copy) NSString *preparePay;//准备支付


@end
@implementation BuyInsuranceCell



+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"BuyInsuranceCell" bundle:nil];
    }
    BuyInsuranceCell* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (instancetype)init{
    _salaryNum = -1;
    _isSelectBtn = NO;
    return self;
}

-(void)refreshWithData:(ResumeLModel *)model andIndexPath:(NSIndexPath *)indexPath{
    if (model) {
        self.imgHead.layer.cornerRadius = 2;
        self.imgHead.clipsToBounds = YES;
        
        _jkModel = model.resume_info;
        _rlModel = model;
        _indexPath = indexPath;
        //姓名性别头像
        _days = _rlModel.exapcArray.count;
        if (_rlModel.isSelect) {
            self.btnSelect.selected = YES;
            _isSelectBtn = YES;
        }
        self.labName.text = _jkModel.true_name;
        if (_jkModel.sex.intValue == 0) {
            [self.imgSex setImage:[UIImage imageNamed:@"v230_female"]];
        }else{
            [self.imgSex setImage:[UIImage imageNamed:@"v230_male"]];
        }
        [self.imgHead sd_setImageWithURL:[NSURL URLWithString:_jkModel.user_profile_url]placeholderImage:[UIHelper getDefaultHeadRect]];
        //时间
        self.labBoardDate.text = [DateHelper dateRangeStrWithMicroSecondNumArray:_jkModel.stu_work_time];

        [self drawLittleRect];
        
    }
    if (_rlModel.nowPay != 0) {
        self.labSalary.text = [NSString stringWithFormat:@"%.2f", (long)_rlModel.nowPay * 0.01];
    }else{
//        self.labSalary.text = [NSString stringWithFormat:@"%.2f",self.insurancePrice.intValue * 0.01];
        self.labSalary.text = @"0";
    }
}
//画方块
-(void)drawLittleRect{
    //显示方块
    if (!self.pictureArray || self.pictureArray.count == 0) {
        self.pictureArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 30; i++) {
            UIImageView* exactImgV = [[UIImageView alloc]init];
            [self.pictureArray addObject:exactImgV];
        }
    }
    int lineNum = 0;//行数
    int showNum = (SCREEN_WIDTH - 33 - 12 - 8)/30;
    for (int i = 0; i < _days; i++) {
        if (i >= self.pictureArray.count) {
            break;
        }
        UIImageView* exactImgV = [self.pictureArray objectAtIndex:i];
        exactImgV.backgroundColor = [UIColor clearColor];
        lineNum = i/showNum;
        int d = fmod(i, showNum);
        exactImgV.frame = CGRectMake(8 + WIDTH * d, HIGHT * lineNum + 8, 22, 22);
        ExaBuyCellModel *epcModel = [_rlModel.exapcArray objectAtIndex:i];
        
        if (epcModel.buyStatus == 0){
            //1：不可购买，2，已购买, 3，可购买
            [exactImgV setImage:[UIImage imageNamed:@"v230_grid"]];
            
        }else if (epcModel.buyStatus == 1) {
        [exactImgV setImage:[UIImage imageNamed:@"v230_unfinished"]];

        }else if (epcModel.buyStatus == 2){
        [exactImgV setImage:[UIImage imageNamed:@"v240_checkbox"]];

        }else if (epcModel.buyStatus == 3){
            [exactImgV setImage:[UIImage imageNamed:@"v230_paybox"]];
        }else if (epcModel.buyStatus == 4){
            [exactImgV setImage:[UIImage imageNamed:@"v230_pay"]];
        }
        [self.cubeView addSubview:exactImgV];
    }
    CGRect cellFrame = self.frame;
    cellFrame.size.width = SCREEN_WIDTH;
    cellFrame.size.height = 110 + lineNum*30;
    self.frame = cellFrame;
    self.layoutCubeView.constant = 8 + 30*(lineNum+1);
 
}

- (IBAction)CubeOnClick:(UIButton *)sender {
    
    DLog(@"弹出日历");
    
    //岗位的总时间
    NSDate * startDate = [NSDate dateWithTimeIntervalSince1970:[_rlModel.job_start_time longLongValue]/1000];
    NSDate * endDate = [NSDate dateWithTimeIntervalSince1970:[_rlModel.job_end_time longLongValue]/1000];
    
    DLAVAlertView *alertView = [[DLAVAlertView alloc] initWithTitle:@"请选择支付日期" message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    //日历下方的label
    UILabel *allSalaryLabel = [[UILabel alloc]initWithFrame:CGRectMake(8, 270, 200, 20)];
    allSalaryLabel.font = [UIFont systemFontOfSize:12];
    [containerView addSubview:allSalaryLabel];
    // 日期控件
    DateSelectView *dateView = [[DateSelectView alloc] initWithFrame:CGRectMake(0, 0, 300, 260)];
    dateView.type = DateViewTypeInsurance;
    [containerView addSubview:dateView];
    alertView.contentView = containerView;
    
    self.payedArray = [[NSMutableArray alloc] init];
    self.pinkPicArray = [[NSMutableArray alloc] init];
    self.greenPicArray = [[NSMutableArray alloc] init];
    self.defaultSelectDateArray = [[NSMutableArray alloc]init];
    for (ExaBuyCellModel* model in _rlModel.exapcArray) {
        NSDate * date = [NSDate dateWithTimeIntervalSince1970:model.timeStamp/1000];
        switch (model.buyStatus) {//1：不可购买，2，已购买, 3，可购买
            case 1:
            {
                [self.pinkPicArray addObject:date];
                [self.greenPicArray addObject:date];
                DLog(@">>>>>>>>>>>pinkPicArray%lu",(unsigned long)self.pinkPicArray.count);

            }
                break;
            case 2://
            {
                [self.payedArray addObject:date];
                [self.greenPicArray addObject:date];
            }
                break;
            case 3:
            {
                [self.greenPicArray addObject:date];
                
            }break;
            case 4:
            {
                [self.defaultSelectDateArray addObject:date];
                [self.greenPicArray addObject:date];
                DLog(@">>>>>>>>>>>>>defaultSelectDateArray%lu",(unsigned long)self.defaultSelectDateArray.count);
            } break;
            default:
                break;
        }
    }
    
    if (_rlModel.nowPay != 0) {
        self.preparePay = [NSString stringWithFormat:@"￥%.2f",_rlModel.nowPay *0.01];
    }else{
        self.preparePay = @"0";
    }
    allSalaryLabel.attributedText  = [self allSalaryAttributedTextWithPreparePayStr:self.preparePay];
    dateView.datesPay = self.payedArray;
    dateView.datesAbsent = self.pinkPicArray;
    dateView.datesComplete = self.greenPicArray;
    dateView.datesSelected = self.defaultSelectDateArray;
    dateView.startDate = startDate;
    dateView.endDate = endDate;
    __weak typeof(DateSelectView *) weakDateView = dateView;
    WEAKSELF
    dateView.didClickBlock = ^(id obj){
        NSInteger days = weakDateView.datesSelected.count;
        //日历上label
        weakSelf.preparePay = [NSString stringWithFormat:@"￥%.2f", days * (_rlModel.insurance_unit_price.intValue)  * 0.01];

        allSalaryLabel.attributedText = [weakSelf allSalaryAttributedTextWithPreparePayStr:weakSelf.preparePay];
        
        _rlModel.onBoardDate = weakDateView.datesSelected;

    };
    [alertView showWithCompletion:^(DLAVAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            
            if (_rlModel.onBoardDate.count > 0) {
                _rlModel.isHasDate = YES;
            }else{
                _rlModel.isHasDate = NO;
            }
            
            _rlModel.nowPay = weakDateView.datesSelected.count * _rlModel.insurance_unit_price.integerValue;
            
            for (ExaBuyCellModel *ebcModel in _rlModel.exapcArray) {
                
                if (ebcModel.buyStatus == 4) {
                    ebcModel.buyStatus = 3;
                }
                
                for (NSDate *date in _rlModel.onBoardDate) {
                    if (ebcModel.timeStamp == date.timeIntervalSince1970*1000) {
                        ebcModel.buyStatus = 4;
                    }

                }
            }
            [_delegate allMoneyWithSelect];

            [weakSelf reflushCell];
        }
    }];
}

- (void)reflushCell{
    
    [_delegate elCell_changeDataWithModel:_rlModel andIndexPath:_indexPath];
}

- (IBAction)btnSelect:(UIButton *)sender {
    _isSelectBtn = !_isSelectBtn;
    sender.selected = _isSelectBtn;
    
    _rlModel.isSelect = _isSelectBtn;
    [_delegate allMoneyWithSelect];
}

- (NSMutableAttributedString *)allSalaryAttributedTextWithPreparePayStr:(NSString *)preparePayStr
{
    
    NSMutableAttributedString *aStrM = [[NSMutableAttributedString alloc] initWithString:@"预计支付 "];
    NSMutableAttributedString *bStrM = [[NSMutableAttributedString alloc] initWithString:@" 元"];
    
    if (preparePayStr.length > 0) {
        preparePayStr = [preparePayStr stringByReplacingOccurrencesOfString:@".00" withString:@""];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[NSForegroundColorAttributeName] = [UIColor redColor];
        NSMutableAttributedString *preparePay = [[NSMutableAttributedString alloc] initWithString:preparePayStr attributes:dic];
        [aStrM appendAttributedString:preparePay];
    }
   
    [aStrM appendAttributedString:bStrM];



    
    return aStrM;
}



@end
