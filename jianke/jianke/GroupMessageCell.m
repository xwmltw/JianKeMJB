//
//  GroupMessageCell.m
//  jianke
//
//  Created by fire on 15/12/9.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import "GroupMessageCell.h"
#import "GroupMessageModel.h"
#import "DateHelper.h"

@interface GroupMessageCell ()

@property (weak, nonatomic) IBOutlet UILabel *receiverLabel; /*!< 消息接受者 */

@property (weak, nonatomic) IBOutlet UILabel *messageContentLabel; /*!< 消息内容 */

@property (weak, nonatomic) IBOutlet UILabel *postTimeLabel; /*!< 发布时间 */

@end

@implementation GroupMessageCell

- (void)setModel:(GroupMessageModel *)model
{
    _model = model;

    self.receiverLabel.text = model.receiver;
    self.messageContentLabel.text = model.postContent;
    self.postTimeLabel.text = [DateHelper getDateWithNumber:model.postTime];
}

@end
