//
//  AddAchieveJKCell.m
//  jianke
//
//  Created by xiaomk on 16/4/27.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "AddAchieveJKCell.h"
#import "JKModel.h"
#import "WDConst.h"

@interface AddAchieveJKCell(){
    JKModel* _jkModel;
}
@property (weak, nonatomic) IBOutlet UIButton *btnSelect;
@property (weak, nonatomic) IBOutlet UIImageView *imgHead;
@property (weak, nonatomic) IBOutlet UILabel *labName;

@end

@implementation AddAchieveJKCell


+ (instancetype)new{
    static UINib* _nib;
    if (_nib == nil) {
        _nib = [UINib nibWithNibName:@"AddAchieveJKCell" bundle:nil];
    }
    AddAchieveJKCell* cell;
    if (_nib) {
        cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)refreshWithData:(JKModel*)model andIndexPath:(NSIndexPath *)indexPath{
    [super refreshWithData:model andIndexPath:indexPath];
    if (model) {
        _jkModel = model;
        self.indexPath = indexPath;
        
        [self.btnSelect addTarget:self action:@selector(btnSelectOnclick:) forControlEvents:UIControlEventTouchUpInside];
        self.btnSelect.selected = model.isSelect;
        [self.imgHead sd_setImageWithURL:[NSURL URLWithString:model.profile_url] placeholderImage:[UIHelper getDefaultHead]];
        self.labName.text = model.true_name;
    }
}

- (void)btnSelectOnclick:(UIButton*)sender{
    sender.selected = !sender.selected;
    _jkModel.isSelect = sender.selected;
    [self.delegate cell_eventWithIndexPath:self.indexPath];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
