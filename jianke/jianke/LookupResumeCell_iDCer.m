//
//  LookupResumeCell_iDCer.m
//  jianke
//
//  Created by yanqb on 2017/5/23.
//  Copyright © 2017年 xianshijian. All rights reserved.
//

#import "LookupResumeCell_iDCer.h"
#import "WDConst.h"

@interface LookupResumeCell_iDCer ()

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *labStart;


@end

@implementation LookupResumeCell_iDCer

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(JKModel *)model{
    if (model.id_card_verify_status.integerValue == 1) {
        self.labStart.text = @"未认证";
    }else if (model.id_card_verify_status.integerValue == 2){
        self.labStart.text = @"认证中";
    }else if (model.id_card_verify_status.integerValue == 3){
        self.labStart.text = @"已认证";
    }else{
        self.labStart.text = @"";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
