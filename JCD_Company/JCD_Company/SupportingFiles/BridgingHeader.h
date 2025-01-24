//
//  BridgingHeader.h
//  YZB_Company
//
//  Created by TanHao on 2017/7/22.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

#ifndef BridgingHeader_h
#define BridgingHeader_h

@import Alamofire;
@import PopupDialog;
@import Then;
@import Stevia;
//MD5加密
#import <CommonCrypto/CommonDigest.h>
//判断手机格式
#import "Utils_objectC.h"

//删除字典中 null值
#import "DeleteEmpty.h"
// 支付宝授权登录
#import "APAuthInfo.h"
#import "APRSASigner.h"
//tableview索引
#import "UITableView+SCIndexView.h"

//计算网络图片宽高
#import "XHWebImageAutoSize.h"

//选择图片
#import "TZImagePickerController/TZImagePickerController.h"

//高德地图
#import <AMapLocationKit/AMapLocationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

#import <Pingpp.h>
#import <AlipaySDK/AlipaySDK.h>
// 微信SDK
#import "WXApi.h"

// 杉德支付相关
#import <PayFramework/PayFramework.h>
#import "UPPaymentControl.h"

// QQSDK

//#import <TencentOpenAPI/TencentOAuth.h>
//#import <TencentOpenAPI/QQApiinterface.h>
//#import <TencentOpenAPI/QQApiInterfaceObject.h>
//#import <TencentOpenAPI/TencentOAuthObject.h>
//#import <TencentOpenAPI/sdkdef.h>
// 新浪SDK
#import "WeiboSDK.h"
//友盟
//#import <UMShare/UMShare.h>
#import <UMCommonLog/UMCommonLogHeaders.h>
//#import <UShareUI/UShareUI.h>
#import <UMCommon/UMCommon.h>
#import <MBProgressHUD/MBProgressHUD.h>
//极光
#import <JMessage/JMessage.h>
// 引入 JPush 功能所需头文件
#import "JPUSHService.h"
// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

//富文本
#import "BSText.h"

#endif /* BridgingHeader_h */
