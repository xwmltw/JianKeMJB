//
//  BuyInsuranceCell.h
//  jianke
//
//  Created by 时现 on 15/12/9.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyInsuranceModel.h"
#import "JKModel.h"
@protocol InsuranceDelegate <NSObject>

- (void)elCell_changeDataWithModel:(ResumeLModel *)model andIndexPath:(NSIndexPath*)indexPath;
- (void)allMoneyWithSelect;

@end



@interface BuyInsuranceCell : UITableViewCell

@property (nonatomic, weak) id <InsuranceDelegate> delegate;
@property (nonatomic,strong) NSNumber *insurancePrice;



+ (instancetype)new;

- (void)refreshWithData:(ResumeLModel  *)model andIndexPath:(NSIndexPath*)indexPath;

@end
