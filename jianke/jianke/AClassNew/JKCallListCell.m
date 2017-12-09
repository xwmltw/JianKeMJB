//
//  JKCallListCell.m
//  jianke
//
//  Created by fire on 16/9/7.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JKCallListCell.h"
#import "WDConst.h"
#import "JKModel.h"

@interface JKCallListCell (){
    JKModel *_JKModel;
}

@property (nonatomic, copy) MKBlock block;
@property (weak, nonatomic) IBOutlet UIImageView *profileImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *dateLab;

- (IBAction)makeCallAction:(id)sender;

@end

@implementation JKCallListCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setData:(JKModel *)model callBack:(MKBlock)block{
    self.block = block;
    _JKModel = model;
    [self.profileImg sd_setImageWithURL:[NSURL URLWithString:model.user_profile_url] placeholderImage:[UIHelper getDefaultHead]];
    self.nameLab.text = model.true_name;
    self.dateLab.text = [DateHelper getDateFromTimeNumber:model.contact_time withFormat:@"M-d HH:mm"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)makeCallAction:(id)sender {
    MKBlockExec(self.block, nil);
}
@end
