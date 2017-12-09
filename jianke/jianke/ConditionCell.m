//
//  ConditionCell.m
//  jianke
//
//  Created by fire on 15/11/18.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "ConditionCell.h"

@interface ConditionCell()

@property (weak, nonatomic) IBOutlet UIImageView *indecatorImgView;

@property (nonatomic, copy) MKBlock btnBlock;

@end


@implementation ConditionCell

- (void)setModel:(ConditionCellModel *)model
{
    _model = model;
    
    self.titleLabel.text = model.title;
    
    self.switchBtn.selected = model.isSwitchOn;
    
    self.btnBlock = model.btnBlock;
    
    if (model.cellType == ConditionCellTypeSwitch) {
        self.switchBtn.hidden = NO;
        self.indecatorImgView.hidden = YES;
        
    } else {
        self.switchBtn.hidden = YES;
        self.indecatorImgView.hidden = NO;
    }
}


- (IBAction)switchBtnClick:(UIButton *)sender
{
    sender.selected = !sender.selected;
    self.model.switchOn = sender.selected;
    
    if (self.btnBlock) {
        self.btnBlock(sender);
    }
}


@end
