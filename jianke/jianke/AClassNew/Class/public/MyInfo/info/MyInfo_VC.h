//
//  MyInfo_VC.h
//  jianke
//
//  Created by xiaomk on 16/6/7.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "WDViewControllerBase.h"

typedef NS_ENUM(NSInteger, MyInfoCellType) {
//    jk
    JKMyInfoCellType_login         = 1,
    
    JKMyInfoCellType_moneyBag,
    JKMyInfoCellType_personalService,
    JKMyInfoCellType_advanceSalary,
    JKMyInfoCellType_socialActivist,
    
    JKMyInfoCellType_jobCollect,
    JKMyInfoCellType_interestJob,
//    JKMyInfoCellType_appRecommend,

    JKMyInfoCellType_switchToEP,
    
//    ep
    EPMyInfoCellType_login,
    EPMyInfoCellType_moneyBag,
    EPMyInfoCellType_inviteBalance,
    EPMyInfoCellType_partner,
    EPMyInfoCellType_baozhaoMgr,
    EPMyInfoCellType_baozhaoCheck,
    
    EPMyInfoCellType_jiankeLib,
    EPMyInfoCellType_zongbao,
    EPMyInfoCellType_contactMgr,
    EPMyInfoCellType_switchToJK,

//    public
    MyInfoCellType_shareJK,
    MyInfoCellType_guide,
    MyInfoCellType_setting,
    
    MyInfoCellType_debugVC
};

@interface MyInfo_VC : WDViewControllerBase

@end
