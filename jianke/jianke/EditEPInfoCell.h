//
//  EditEPInfoCell.h
//  jianke
//
//  Created by xiaomk on 16/3/2.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

@class EPModel;

typedef NS_ENUM(NSInteger, EditEpCellType){
    EditEpCellType_Name = 100,
    EditEpCellType_Enterprase,
    EditEpCellType_Email
};

@protocol EditEPInfoCellDelegate <NSObject>

- (void)pushAction:(EditEpCellType)type;

@end

#import <UIKit/UIKit.h>

@interface EditEPInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgIcom;
@property (weak, nonatomic) IBOutlet UITextField *tfText;
@property (weak, nonatomic) IBOutlet UIButton *btnAuth;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutBtnNextWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutBtnAutoWidth;

@property(nonatomic, weak) id<EditEPInfoCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableview;
- (void)setData:(EPModel *)epModel atIndexPath:(NSIndexPath *)indexPath;

@end
