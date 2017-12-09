//
//  EPMainTableView.h
//  jianke
//
//  Created by xiaomk on 15/11/19.
//  Copyright © 2015年 xianshijian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDConst.h"
#import "RequestParamWrapper.h"

@interface EPMainTableView : NSObject

@property (nonatomic, weak) UIViewController *owner;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, assign) ManagerType managerType; /*!< ManagerTypeEP | ManagerTypeBD */

@property (nonatomic, assign) BOOL isFromHome;

- (void)getLastData;

@end

