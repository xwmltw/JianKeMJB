//
//  BDManagerTableView.h
//  jianke
//
//  Created by xiaomk on 16/6/27.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDConst.h"

@interface BDManagerTableView : NSObject

@property (nonatomic, weak) UIViewController *owner;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) BOOL isFromHome;
@property (nonatomic, assign) ManagerType managerType; /*!< ManagerTypeEP | ManagerTypeBD */

- (void)getLastData;

@end
