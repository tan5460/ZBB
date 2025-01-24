//
//  appDefine.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/23.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import SnapKit

var IS_iPad: Bool {
    get {
       return UIDevice.current.userInterfaceIdiom == .pad
    }
}

var isSHAccountUserId: Bool {
    get {
        var isSH = false
        
        if UserData1.shared.tokenModel?.userId == "83b715805fcd434f826ad3a31be8fd11" || UserData1.shared.tokenModel?.userId == "977497a7672ed50e903de5f4fecc38d9" {
            isSH = true
        }
        return isSH
    }
}

var LetterPrefixArray = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

struct PublicSize{
    
    static var RateWidth:CGFloat = PublicSize.screenWidth/375.0         //屏幕宽比
    static var RateHeight:CGFloat = PublicSize.screenHeight/667.0       //屏幕高比
    static var PadRateWidth:CGFloat = PublicSize.screenWidth/768.0      //pad屏幕宽比
    static var PadRateHeight:CGFloat = PublicSize.screenHeight/1024.0   //pad屏幕高比
    /// 屏幕宽度
    static let kScreenWidth = UIScreen.main.bounds.size.width
    /// 屏幕高度
    static let kScreenHeight = UIScreen.main.bounds.size.height
    static let kScalWidth = (PublicSize.kScreenWidth / 375) /// 宽度比
    static let kScalHeight = (PublicSize.kScreenHeight / 667) /// 高度比
    
    /// 状态栏
    static let kStatusBarHeight = UIApplication.shared.statusBarFrame.height
    
    /// navigationBar高度
    static let kNavBarHeight = 44.0+UIApplication.shared.statusBarFrame.height
    
    /// tabbar高度
    static let kTabBarHeight = CGFloat(isX ? 83.0 : 49.0)
    static let kBottomOffset = CGFloat(isX ? 34.0 : 0.0)
    static let isX: Bool = UIScreen.main.bounds.height >= 812
    static let isIphoneX = UIScreen.main.nativeBounds.size.height-2436 == 0
    static let isSmallIphone = UIScreen.main.bounds.size.height == 480
    static var screenWidth: CGFloat {
        get {
            return UIScreen.main.bounds.width
        }
    }
    static var screenHeight: CGFloat {
        get {
            return UIScreen.main.bounds.height
        }
    }
    static var screenFrame: CGRect {
        get {
            return UIScreen.main.bounds
        }
    }
    
}

//共用颜色
struct PublicColor{
    /// 333333
    static var c333 = UIColor.colorFromRGB(rgbValue: 0x333333)
    /// 666666
    static var c666 = UIColor.colorFromRGB(rgbValue: 0x666666)
    /// 999999
    static var c999 = UIColor.colorFromRGB(rgbValue: 0x999999)
    
    // -- 颜色
    ///用于特别强调和突出文字，文字选中、可点击状态 #23AC38
    static var emphasizeTextColor = UIColor.colorFromRGB(rgbValue: 0x27A27D)
    ///价格颜色#FF3029
    static var priceTextColor = UIColor.colorFromRGB(rgbValue: 0xFF3029)
    
    ///新版用于特别强调的颜色 #FF5700
    static var emphasizeColor = UIColor.colorFromRGB(rgbValue: 0xFF5700)
    
    ///按钮高亮颜色 #E5E5E5
    static var buttonHightColor = UIColor.colorFromRGB(rgbValue: 0xE5E5E5)
    
    ///未读消息颜色 #FF332A
    static var unreadMsgColor = UIColor.colorFromRGB(rgbValue: 0xFC3D3D)
    
    ///用于普通级文字信息，标题文字，导航栏icon #1F1F1F
    static var commonTextColor = UIColor.colorFromRGB(rgbValue: 0x1F1F1F)
    
    ///用于次要文字信息，弹窗内容，文本框内默认状态文字颜色 #666666
    static var minorTextColor = UIColor.colorFromRGB(rgbValue: 0x666666)
    
    ///用于提示性文字，未编辑状态时的文字颜色 #999999
    static var placeholderTextColor = UIColor.colorFromRGB(rgbValue: 0x999999)
    
    ///用于导航栏底部的分割线颜色，部分按钮描边色 #DADADA
    static var navigationLineColor = UIColor.colorFromRGB(rgbValue: 0xDADADA)
    
    ///用于分割线颜色，以及框的描边，按钮点击色 #E5E5E5
    static var partingLineColor = UIColor.colorFromRGB(rgbValue: 0xE5E5E5)
    
    ///用于内容区域的背景底色 #F8F8F8
    static var backgroundViewColor = UIColor.colorFromRGB(rgbValue: 0xF8F8F8)
    
    ///用于网页进度条颜色 #FB6F31
    static var progressColor = UIColor.colorFromRGB(rgbValue: 0xFB6F31)
    
    ///订单状态标签（橙色） #FE954F
    static var orangeLabelColor = UIColor.colorFromRGB(rgbValue: 0xFE954F)
    
    ///订单状态标签（绿色） #33D088
    static var greenLabelColor = UIColor.colorFromRGB(rgbValue: 0x33D088)
    
    ///订单状态标签（红色） FF6B6B
    static var redLabelColor = UIColor.colorFromRGB(rgbValue: 0xFF6B6B)
    
    ///银行卡背景（黄色） FFAD42
    static var bankYellowColor = UIColor.colorFromRGB(rgbValue: 0xFFAD42)
    
    ///银行卡背景（蓝色） 658AFC
    static var bankBlueColor = UIColor.colorFromRGB(rgbValue: 0x658AFC)
    
    ///银行卡背景（紫色） B26FFE
    static var bankPurpleColor = UIColor.colorFromRGB(rgbValue: 0xB26FFE)
    
    ///黑蓝色，聊天订单色 #404244
    static var blackBlueTextColor = UIColor.colorFromRGB(rgbValue: 0x404244)
    
    // -- 颜色图片
    // #FFA101
    static var yColorImage = UIImage.gradualImageFromColors(colors: [UIColor.colorFromRGB(rgbValue: 0xFFA101),UIColor.colorFromRGB(rgbValue: 0xFFBA00)])
    
    ///渐变按钮背景颜色图片 #78D73A → #00E468
    static var gradualColorImage = UIImage.gradualImageFromColors(colors: [UIColor.colorFromRGB(rgbValue: 0x1DC597),UIColor.colorFromRGB(rgbValue: 0x61D9B9)])
    
    ///渐变按钮高亮背景颜色图片 #78D73A → #00E468
    static var gradualHightColorImage = UIImage.gradualImageFromColors(colors: [UIColor.colorFromRGB(rgbValue: 0x1DC597),UIColor.colorFromRGB(rgbValue: 0x61D9B9)])
    
    ///立即购买渐变按钮背景颜色图片 #FFC000 → #FF9600
    static var gradualColorImage_buyBtn = UIImage.gradualImageFromColors(colors: [UIColor.colorFromRGB(rgbValue: 0xFFC000),UIColor.colorFromRGB(rgbValue: 0xFF9600)])
    
    ///立即购买渐变按钮高亮背景颜色图片 #FFC000 → #FF9600
    static var gradualHightColorImage_buyBtn = UIImage.gradualImageFromColors(colors: [UIColor.colorFromRGB(rgbValue: 0xFFC000),UIColor.colorFromRGB(rgbValue: 0xFF9600)])
    
    ///按钮背景颜色图片 #FFFFFF
    static var buttonColorImage = UIColor.colorFromRGB(rgbValue: 0xFFFFFF).image()
    
    ///按钮高亮背景颜色图片 #E5E5E5
    static var buttonHightColorImage = UIColor.colorFromRGB(rgbValue: 0xE5E5E5).image()
}

