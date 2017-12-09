//
//  LinkAddCell.m
//  jianke
//
//  Created by xuzhi on 16/7/6.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "LinkAddCell.h"
#import "UIColor+Extension.h"
#import "ParamModel.h"
#import "UILabel+MKExtension.h"
#import "XSJConst.h"

@interface LinkAddCell()

@property (weak, nonatomic) IBOutlet UILabel *jobLabel;
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;


- (IBAction)copyAction:(id)sender;

@end

@implementation LinkAddCell

- (void)awakeFromNib{
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor XSJColor_grayTinge];
    self.boardView.backgroundColor = [UIColor XSJColor_grayDeep];
    [self.boardView setCornerValue:3];
}

- (void)setMakeupInfo:(MakeupInfo *)makeupInfo{
    
    self.jobLabel.text = makeupInfo.makeup_info;
    self.linkLabel.text = makeupInfo.qr_code;
    self.qrImageView.image = makeupInfo.qr_image;
    
    //cell高度计算
    CGFloat jLableHeight = [self.jobLabel contentSizeWithWidth:SCREEN_WIDTH-68].height;
    CGFloat lLableHeight = [self.linkLabel contentSizeWithWidth:SCREEN_WIDTH-172].height;
    CGFloat tLabelHeight = [self.tipLabel contentSizeWithWidth:SCREEN_WIDTH-32].height;
    makeupInfo.cellHeight = 550 -16-18-16+jLableHeight+lLableHeight+tLabelHeight;
}

- (IBAction)copyAction:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.linkLabel.text;
    [UIHelper toast:@"已复制到剪贴板"];
}


@end
