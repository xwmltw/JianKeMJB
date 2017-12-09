//
//  BuyInsuranceCell_2.h
//  jianke
//
//  Created by 时现 on 16/1/13.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyInsuranceModel.h"
@protocol InsuranceDelegate_2 <NSObject>

//- (void)elCell_changeData_2WithModel:(ResumeLModel *)model andIndexPath:(NSIndexPath*)indexPath;

- (void)allMoneyWithSelect_2;

@end
@interface BuyInsuranceCell_2 : UITableViewCell


@property (nonatomic, retain) id <InsuranceDelegate_2> delegate;
@property (nonatomic,strong) NSNumber *insurancePrice;

+ (instancetype)new;
- (void)refreshWithData:(ResumeLModel  *)model andIndexPath:(NSIndexPath*)indexPath;;

@end
