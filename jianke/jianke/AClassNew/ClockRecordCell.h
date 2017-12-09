//
//  ClockRecordCell.h
//  jianke
//
//  Created by fire on 16/7/8.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

@class PunchResponseModel;
@protocol ClockRecordCellDelegate <NSObject>

- (void)closePunch:(NSString *)punchId andPunchResponseModel:(PunchResponseModel *)punchModel;

@end

@class PunchResponseModel;
#import <UIKit/UIKit.h>

@interface ClockRecordCell : UITableViewCell

@property (nonatomic, weak) id<ClockRecordCellDelegate> delegate;
- (void)setData:(PunchResponseModel *)prModel;

@end
