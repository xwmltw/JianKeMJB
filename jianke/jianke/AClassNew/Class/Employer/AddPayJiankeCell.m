//
//  AddPayJiankeCell.m
//  jianke
//
//  Created by xiaomk on 16/7/11.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "AddPayJiankeCell.h"
#import "XSJConst.h"

@interface AddPayJiankeCell(){
    
}



@end

@implementation AddPayJiankeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"AddPayJiankeCell";
    AddPayJiankeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"AddPayJiankeCell" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        [cell.imgHead setCorner];
        
    }
    return cell;
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
