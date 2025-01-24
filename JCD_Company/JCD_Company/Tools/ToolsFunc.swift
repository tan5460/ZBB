//
//  ToolsFunc.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/25.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto
import ObjectMapper
import Alamofire

class GlobalNotificationer: HoNotificationer {
    enum HoNotification: String {
        case order // 个人订单刷新
        case user  // 用户更新
        case record// 交易记录
        case purchaseRefresh // 采购订单刷新
        case isContains // 包含在购物车
        case sureOrder // 确定订单
        case yysSureOrderRefresh //合伙人确认订单后移除
    }
}

struct ToolsFunc {
    
    ///多种颜色字符
    static func getMixtureAttributString(_ attributedList: Array<MixtureAttr>) -> NSMutableAttributedString {
        
        let attr = NSMutableAttributedString(string: "")
        
        for mixtureAttr in attributedList {
            
            let attrSearchString = NSAttributedString(string: mixtureAttr.string, attributes: [ NSAttributedString.Key.foregroundColor: mixtureAttr.color, NSAttributedString.Key.font: mixtureAttr.font])
            attr.append(attrSearchString)
        }
        return attr
    }
    
    static func showLoginVC() {
        
        //清除设备id
//        let urlStr = APIURL.logout
//        var parameters: Parameters = [:]
//        parameters["userId"] = UserData1.shared.tokenModel?.userId
//        YZBSign.shared.request(urlStr, method: .delete, parameters: parameters, success: { (response) in
//            
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
//            if errorCode == "0" {
//                
//            }
//            
//        }) { (error) in
//            
//        }
        
        //退出登录未读数归零、清掉用户本地数据、聊天退出登录
        UserDefaults.standard.set(0, forKey: "unreadCount")
        
        AppUtils.cleanUserData()
        YZBChatRequest.shared.logout(errorBlock: { (error) in})
        
//        if let window = UIApplication.shared.keyWindow {
//            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
//                let oldState: Bool = UIView.areAnimationsEnabled
//                UIView.setAnimationsEnabled(false)
//                window.rootViewController = BaseNavigationController(rootViewController: LoginVC())
//                UIView.setAnimationsEnabled(oldState)
//            })
//        }
        NSObject().getCurrentVC().navigationController?.pushViewController(ZBBLoginViewController())
    }
    
    static func logout() {
        clearData()
        NSObject().getCurrentVC().navigationController?.popToRootViewController(animated: false)
        let vc = UIApplication.shared.keyWindow?.rootViewController as! MainViewController
        vc.selectedIndex = 0
    }
    
    static func clearData() {
        //退出登录未读数归零、清掉用户本地数据、聊天退出登录
        UserDefaults.standard.set(0, forKey: "unreadCount")
        UserData1.shared.tokenModel = nil
        UserData1.shared.isNew = false
        UserData1.shared.isHaveMyList = false
        AppUtils.cleanUserData()
        YZBChatRequest.shared.logout(errorBlock: { (error) in})
    }
}

//MARK: - 延展

extension UIImage {
    
    /// 绘制圆角图片
    func setImageRadius(radius: CGFloat) -> UIImage? {
        
        let imgSize = self.size
        let imgBounds = CGRect(x: 0, y: 0, width: imgSize.width, height: imgSize.height)
        
        //开启图文上下层
        UIGraphicsBeginImageContextWithOptions(imgSize, false, 1)
        
        let bezierPath = UIBezierPath.init(roundedRect: imgBounds, cornerRadius: radius)
        bezierPath.addClip()
        self.draw(in: imgBounds)
        
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    /// 颜色的渐变图片，默认方向从左到右
    /// - parameter colors: 颜色的数组
    /// - parameter gradientDirection: 渐变的方向 0:从上到下 1:从左到右 2:左上到右下 3:右上到左下
    /// - parameter radius: 圆角
    class func gradualImageFromColors(colors : [UIColor], ByGradientDirection gradientDirection:Int = 1, ByGradientSize gradientSize: CGSize = CGSize(width: 100, height: 40), ByCornerRadius radius:CGFloat = 0) -> UIImage? {
        
        let screenScale = UIScreen.main.scale
        
        var newImgWidth = gradientSize.width
        var newImgHeight = gradientSize.height
        
        if screenScale == 2 {
            newImgWidth = gradientSize.width*2
            newImgHeight = gradientSize.height*2
        }else if screenScale == 3 {
            newImgWidth = gradientSize.width*3
            newImgHeight = gradientSize.height*3
        }
        
        //生成对应倍数图，不会变模糊
        let newSize = CGSize(width: newImgWidth, height: newImgHeight)
        let colorCGs = colors.map{$0.cgColor}
        
        //开启图文上下层
        UIGraphicsBeginImageContext(newSize)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        let colorSpace =  CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient.init(colorsSpace: colorSpace, colors: colorCGs as CFArray , locations: nil)
        var start = CGPoint.zero
        var end = CGPoint.zero
        switch gradientDirection {
        case 0:
            start = CGPoint(x: 0.0, y: 0.0)
            end = CGPoint(x: 0.0, y: newSize.height)
        case 1:
            start = CGPoint(x: 0.0, y: 0.0)
            end = CGPoint(x: newSize.width, y: 0.0)
        case 2:
            start = CGPoint(x: 0.0, y: 0.0)
            end = CGPoint(x: newSize.width, y: newSize.height)
        case 3:
            start = CGPoint(x: newSize.width, y: 0.0)
            end = CGPoint(x: 0.0, y: newSize.height)
        default:
            break
        }
        context?.drawLinearGradient(gradient!, start: start, end: end, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        
        var image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        
        if radius > 0 {
            
            var newRedius = radius
            
            if screenScale == 2 {
                newRedius = radius*2
            }else if screenScale == 3 {
                newRedius = radius*3
            }
            
            image = image?.setImageRadius(radius: newRedius)
        }
        return image
    }
    
    /// 图片压缩
    func resizeImage(valueMax: CGFloat = 310) -> UIImage? {
        
        //prepare constants
        let width = self.size.width
        let height = self.size.height
        let scale = width/height
        
        var sizeChange = CGSize()
        
        if width <= valueMax && height <= valueMax{ //a，图片宽或者高均小于或等于1280时图片尺寸保持不变，不改变图片大小
            return self
        }
        else {
            if scale <= 2 && scale >= 1 {   //b,宽或者高大于1280，但是图片宽度高度比小于或等于2，则将图片宽或者高取大的等比压缩至1280
                let changedWidth:CGFloat = valueMax
                let changedheight:CGFloat = changedWidth / scale
                sizeChange = CGSize(width: NSInteger(changedWidth), height: NSInteger(changedheight))
                
            }else if scale >= 0.5 && scale <= 1 {
                
                let changedheight:CGFloat = valueMax
                let changedWidth:CGFloat = changedheight * scale
                sizeChange = CGSize(width: NSInteger(changedWidth), height: NSInteger(changedheight))
                
            }else if width > valueMax && height > valueMax {    //宽以及高均大于1280，但是图片宽高比大于2时，则宽或者高取小的等比压缩至1280
                
                if scale > 2 {  //高的值比较小
                    
                    let changedheight:CGFloat = valueMax
                    let changedWidth:CGFloat = changedheight * scale
                    sizeChange = CGSize(width: NSInteger(changedWidth), height: NSInteger(changedheight))
                    
                }else if scale < 0.5{   //宽的值比较小
                    
                    let changedWidth:CGFloat = valueMax
                    let changedheight:CGFloat = changedWidth / scale
                    sizeChange = CGSize(width: NSInteger(changedWidth), height: NSInteger(changedheight))
                    
                }
            }else { //d, 宽或者高，只有一个大于1280，并且宽高比超过2，不改变图片大小
                return self
            }
        }
        
        UIGraphicsBeginImageContext(sizeChange)
        
        //draw resized image on Context
        self.draw(in: CGRect(x: 0, y: 0, width: sizeChange.width, height: sizeChange.height))
        
        //create UIImage
        let resizedImg = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImg
    }
}

extension UIColor {
    
    /// 返回格式化颜色,传入颜色值如红色就传入:0xff0000
    class func colorFromRGB(rgbValue: Int, alpha: CGFloat=1) -> UIColor {
        
        return UIColor(red: (CGFloat((rgbValue & 0xFF0000) >> 16))/255.0, green: (CGFloat((rgbValue & 0xFF00) >> 8))/255.0, blue: (CGFloat(rgbValue & 0xFF))/255.0, alpha: alpha);
    }
    
    /// 颜色到图片
    func image(size: CGSize = CGSize(width: 36, height: 36), radius: CGFloat = 0) -> UIImage? {
        
        let screenScale = UIScreen.main.scale
        
        var newImgWidth = size.width
        var newImgHeight = size.height
        
        if screenScale == 2 {
            newImgWidth = size.width*2
            newImgHeight = size.height*2
        }else if screenScale == 3 {
            newImgWidth = size.width*3
            newImgHeight = size.height*3
        }
        
        let rect = CGRect(x: 0, y: 0, width: newImgWidth, height: newImgHeight)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(self.cgColor)
        context!.fill(rect)
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if radius > 0 {
            var newRedius = radius
            
            if screenScale == 2 {
                newRedius = radius*2
            }else if screenScale == 3 {
                newRedius = radius*3
            }
            
            image = image?.setImageRadius(radius: newRedius)
        }
        return image
    }
}

extension Double {
    
    /// 四舍五入取整
    func notRoundingNumber() -> NSNumber {
        
        //四舍五入
        let roundingBehavior = NSDecimalNumberHandler(roundingMode: .plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let ouncesDecimal: NSDecimalNumber = NSDecimalNumber(string: "\(self)")
        let roundedOunces: NSDecimalNumber = ouncesDecimal.rounding(accordingToBehavior: roundingBehavior)
        
        return roundedOunces
    }
    
    /// 把 price 数字精确到小数点后第 position 位，不足 position 位补 0，然后四舍五入(注：position = -1 四舍五入后个位数为0)
    func notRoundingString(afterPoint position: Int, qian: Bool = true) -> String {
        
        //四舍五入
        let roundingBehavior = NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(position), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let ouncesDecimal: NSDecimalNumber = NSDecimalNumber(string: "\(self)")
        let roundedOunces: NSDecimalNumber = ouncesDecimal.rounding(accordingToBehavior: roundingBehavior)
        
        //生成需要精确的小数点格式，
        //比如精确到小数点第3位，格式为“0.000”；精确到小数点第4位，格式为“0.0000”；
        var formatterString : String = "0."
        if position > 0 {
            for _ in 0 ..< position {
                formatterString.append("0")
            }
        }else {
            formatterString = "0"
        }
        let formatter : NumberFormatter = NumberFormatter()
        //设置生成好的格式，NSNumberFormatter 对象会按精确度自动四舍五入
        formatter.positiveFormat = formatterString
        //然后把这个number 对象格式化成我们需要的格式，
        var roundingStr = formatter.string(from: roundedOunces) ?? "0"
        
        if roundingStr.range(of: ".") != nil {
            
            let sub1 = String(roundingStr.suffix(1))
            if sub1 == "0" {
                roundingStr = String(roundingStr.prefix(roundingStr.count-1))
                let sub2 = String(roundingStr.suffix(1))
                if sub2 == "0" {
                    roundingStr = String(roundingStr.prefix(roundingStr.count-2))
                }
            }
        }
        
        if qian {
            return roundingStr.addMicrometerLevel()
        }
        
        return roundingStr
    }
    
}


struct MixtureAttr {
    var string: String = ""
    var color: UIColor = PublicColor.commonTextColor
    var font: UIFont = UIFont.systemFont(ofSize: 14)
}

extension String {

    // MARK : 校验手机号码
    func isTelNumber()->Bool
        
    {
        
        let mobile = "^1((3[0-9]|4[57]|5[0-35-9]|7[0678]|8[0-9])\\d{8}$)"
        
        let  CM = "(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
        
        let  CU = "(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
        
        let  CT = "(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
        
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        
        let regextestcm = NSPredicate(format: "SELF MATCHES %@",CM )
        
        let regextestcu = NSPredicate(format: "SELF MATCHES %@" ,CU)
        
        let regextestct = NSPredicate(format: "SELF MATCHES %@" ,CT)
        
        if ((regextestmobile.evaluate(with: self) == true)
            
            || (regextestcm.evaluate(with: self)  == true)
            
            || (regextestct.evaluate(with: self) == true)
            
            || (regextestcu.evaluate(with: self) == true))
            
        {
            
            return true
            
        }
            
        else
            
        {
            
            return false
            
        }
        
    }
    
    
    // MARK : 添加千分位的函数实现
    func addMicrometerLevel() -> String {
        // 判断传入参数是否有值
        if self.length != 0 {
            /**
             创建两个变量
             integerPart : 传入参数的整数部分
             decimalPart : 传入参数的小数部分
             */
            var integerPart:String?
            var decimalPart = String.init()
            
            // 先将传入的参数整体赋值给整数部分
            integerPart =  self
            // 然后再判断是否含有小数点(分割出整数和小数部分)
            if self.contains(".") {
                let segmentationArray = self.components(separatedBy: ".")
                integerPart = segmentationArray.first
                decimalPart = segmentationArray.last!
            }
            
            /**
             创建临时存放余数的可变数组
             */
            let remainderMutableArray = NSMutableArray.init(capacity: 0)
            // 创建一个临时存储商的变量
            var discussValue:Int32 = 0
            
            /**
             对传入参数的整数部分进行千分拆分
             */
            
         
            repeat {
                let tempValue = integerPart! as NSString
                // 获取余数
                var remainderValue = 0
                
                if tempValue.intValue >= 1000{

                    // 获取商

                    discussValue = tempValue.intValue / 1000

                    // 获取余数

                    remainderValue = Int(tempValue.intValue % 1000)

                    // 将余数一字符串的形式添加到可变数组里面

                    var remainderStr = String.init(format:"%d", remainderValue)

                    if remainderStr.count == 1 {

                        remainderStr = "00" + remainderStr

                    }else if remainderStr.count == 2 {

                        remainderStr = "0" + remainderStr

                    }

                    remainderMutableArray.insert(remainderStr, at:0)

                    // 将商重新复制

                    integerPart = String.init(format:"%d", discussValue)

                }else{

                    // 获取余数

                    remainderValue = Int(tempValue.intValue%1000)

                    // 将余数一字符串的形式添加到可变数组里面

                    let remainderStr = String.init(format:"%d", remainderValue)

                    remainderMutableArray.insert(remainderStr, at:0)

                    // 将商重新复制

                    integerPart = String.init(format:"%d", discussValue)

                    break

                }
            } while discussValue>0
            
            // 创建一个临时存储余数数组里的对象拼接起来的对象
            var tempString = String.init()
            
            // 根据传入参数的小数部分是否存在，是拼接“.” 还是不拼接""
            let lastKey = (decimalPart.length == 0 ? "":".")
            /**
             获取余数组里的余数
             */
            for i in 0..<remainderMutableArray.count {
                // 判断余数数组是否遍历到最后一位
                let  param = (i != remainderMutableArray.count-1 ?",":lastKey)
                tempString = tempString + String.init(format: "%@%@", remainderMutableArray[i] as! String,param)
            }
            //  清楚一些数据
            integerPart = nil
            remainderMutableArray.removeAllObjects()
            // 最后返回整数和小数的合并
         
            return tempString as String + decimalPart
        }
        return self
    }
    
    
    /// 移除字符串中的表情符号，返回一个新的字符串
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case
            0x00A0...0x00AF,
            0x2030...0x204F,
            0x2120...0x213F,
            0x2190...0x21AF,
            0x2310...0x329F,
            0x1F000...0x1F9CF:
                return true
            default:
                continue
            }
        }
        return false
    }
    
    /// 多种颜色字符串
    static func getMixtureAttributString(_ attributedList: Array<MixtureAttr>) -> NSMutableAttributedString {
        
        let attr = NSMutableAttributedString(string: "")
        
        for mixtureAttr in attributedList {
            
            let attrSearchString = NSAttributedString(string: mixtureAttr.string, attributes: [ NSAttributedString.Key.foregroundColor: mixtureAttr.color, NSAttributedString.Key.font: mixtureAttr.font])
            attr.append(attrSearchString)
        }
        return attr
    }
    
    /// json转字典
    func jsonToDic() -> [String: Any] {
        
        var dic: [String: Any] = [:]
        
        if let jsonData = self.data(using: .utf8) {
            
            let jsonDic = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
            if let dict = jsonDic as? [String: Any] {
                dic = dict
            }
        }
        
        return dic
    }
    
    /// 修改行距
    func changeLineSpaceForLabel(lineSpacing: CGFloat = 3) -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString.init(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSMakeRange(0, self.count))
        
        return attributedString
    }
    
    /// 增加删除线
    func addUnderline() -> NSMutableAttributedString {
        
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.baselineOffset, value: 0, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.lightGray, range: NSRange(location: 0, length: attributeString.length))
        
        return attributeString
    }
    
    /// 移除删除线
    func removeUnderline() -> NSMutableAttributedString {
        
        let attributeString = NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.baselineOffset, value: 0, range: NSMakeRange(0, attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
        return attributeString

    }
    
    /// 计算文本的宽高
    func getLabHeigh(font: UIFont, width: CGFloat) -> CGSize {
        
        let statusLabelText: NSString = self as NSString
        
        let size = CGSize(width: width, height: 900)
        
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key: AnyObject], context:nil).size
        
        return strSize
        
    }
    
    ///计算文本的宽
    func getLabWidth(font: UIFont) -> CGFloat {
        
        let statusLabelText: NSString = self as NSString
        
        let size = CGSize(width: 900, height: 100)
        
        let dic = NSDictionary(object: font, forKey: NSAttributedString.Key.font as NSCopying)
        
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedString.Key: AnyObject], context:nil).size
        
        return strSize.width
    }
    
    /// HTML富文本反转义
    func htmlToString() -> String {
        
        var htmlStr = ""
        do {
            htmlStr = try NSAttributedString(data: self.data(using: String.Encoding.utf8, allowLossyConversion: true)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
        }catch {
            AppLog(error)
        }
        return htmlStr
    }
    
    /// Range转换为NSRange
    func nsRange(from range: Range<String.Index>) -> NSRange {
        
        let from = range.lowerBound.samePosition(in: utf16)
        let to = range.upperBound.samePosition(in: utf16)
        return NSRange(location: utf16.distance(from: utf16.startIndex, to: from!), length: utf16.distance(from: from!, to: to!))
    }
    
    /// Range转换为NSRange
    func rangef(from nsRange: NSRange) -> Range<String.Index>? {
        
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    /// md5加密
    func md5String() -> String {
        
        let cStr = self.cString(using: String.Encoding.utf8)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        
        CC_MD5(cStr!, (CC_LONG)(strlen(cStr!)), buffer)
        
        let md5String = NSMutableString()
        for i in 0 ..< 16{
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        
        return md5String as String
    }
    
    /// 取出两个指定字符串中间的内容并组成数组
    func componentsSeparated(fromString: String, toString: String) -> Array<String>? {
        
        if fromString.count <= 0 || toString.count <= 0 {
            return nil
        }
        
        var subStringsArray: Array<String> = []
        var tempString = self
        var range = tempString.range(of: fromString)
        
        while range != nil {
            tempString = String(tempString.suffix(from: (range?.upperBound)!))
            range = tempString.range(of: toString)
            
            if range != nil {
                let subStr = String(tempString.prefix(upTo: (range?.lowerBound)!))
                subStringsArray.append(subStr)
                range = tempString.range(of: fromString)
            }
        }
        
        if subStringsArray.count > 0 {
            return subStringsArray
        }
        return nil
    }
    
    /// 字符串转数组  可以选择清除空白字符串
    func strToArr(by: String, clearEmpty: Bool=false) -> [String] {
        
        var strArr:[String]=[]
        if self.range(of: by) != nil {
            strArr = self.components(separatedBy: by)
        }
        if strArr.count==0 && self.count>0 {
            strArr=[self]
        }
        
        var relArr:[String]=[]
        for i in strArr{
            let str:String=i
            if(clearEmpty){
                if(str.count>0){
                    relArr.append(str)
                }
            }else{
                relArr.append(str)
            }
        }
        
        return relArr
    }
    
    /// 根据出生日期计算年龄的方法
    func caculateAge(format: String="yyyy-MM-dd HH:mm:ss") -> Int {
        
        var iAge = 999
        
        //格式化日期
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = format
        
        if let birthDayDate = dFormatter.date(from: self) {
            
            // 获取出生 年月日
            let birthdayDate = NSCalendar.current.dateComponents([.year,.month,.day], from: birthDayDate)
            let brithDateYear = birthdayDate.year ?? 0
            let brithDateDay = birthdayDate.day ?? 0
            let brithDateMonth = birthdayDate.month ?? 0
            
            // 获取系统当前 年月日
            let currentDate = NSCalendar.current.dateComponents([.year,.month,.day], from: Date())
            let currentDateYear = currentDate.year ?? 0
            let currentDateDay = currentDate.day ?? 0
            let currentDateMonth = currentDate.month ?? 0
            
            // 计算年龄
            iAge = currentDateYear - brithDateYear - 1
            
            if currentDateMonth > brithDateMonth || (currentDateMonth == brithDateMonth && currentDateDay >= brithDateDay) {
                
                iAge += 1
            }
        }
        
        return iAge
    }
    
    /// 时间戳转时间
    func timeStampToDateStr(format: String="yyyy-MM-dd HH:mm:ss") -> String {
        
        var dateStr = ""
        
        let timeStamp: TimeInterval = NSString(string: self).doubleValue
        let date = Date(timeIntervalSince1970: timeStamp)
        
        let dFmatter = DateFormatter()
        dFmatter.locale = Locale(identifier: "zh_CN")
        dFmatter.dateFormat = format
        dateStr = dFmatter.string(from: date)
        
        return dateStr
    }
    
    /// 时间转时间
    func stringToDateStr(format: String="yyyy-MM-dd HH:mm:ss", formatOut: String="yyyy-MM-dd HH:mm:ss") -> String {
        
        var dateStr = ""
        
        let dFmatter = DateFormatter()
        dFmatter.dateFormat = format
        
        let dFmatterOut = DateFormatter()
        dFmatterOut.dateFormat = formatOut
        
        if let date = dFmatter.date(from: self) {
            dateStr = dFmatterOut.string(from: date)
        }
        
        return dateStr
    }
    
    /// 时间转时间戳
    func stringToTimeStamp(format: String="yyyy-MM-dd HH:mm:ss") -> TimeInterval {
        
        var timeStamp: TimeInterval = 0
        
        let dFmatter = DateFormatter()
        dFmatter.dateFormat = format
        
        if let date = dFmatter.date(from: self) {
            timeStamp = date.timeIntervalSince1970
        }
        
        return timeStamp
    }
}

extension Date {
    
    func dateToString(format: String="yyyy-MM-dd HH:mm:ss") -> String {
        
        var dateStr = ""
        
        let fmatter = DateFormatter()
        fmatter.dateFormat = format
        dateStr = fmatter.string(from: self)
        
        return dateStr
    }
    
    func dateToWeekday(_ showToday: Bool = true) -> String {
        
        var weekday = ""
        
        // 指定日历的算法
        let calendar = NSCalendar.init(calendarIdentifier: .gregorian)
        let comps = calendar?.components(.weekday, from: self)
        
        // 1 是周日，2是周一 3.以此类推
        if let weekValue = comps?.weekday {
            
            switch weekValue {
            case 1:
                weekday = "周日"
            case 2:
                weekday = "周一"
            case 3:
                weekday = "周二"
            case 4:
                weekday = "周三"
            case 5:
                weekday = "周四"
            case 6:
                weekday = "周五"
            case 7:
                weekday = "周六"
            default:
                break
            }
        }
        
        if showToday {
            
            let isToday = calendar?.isDateInToday(self)
            
            if isToday == true {
                weekday = "今日"
            }
        }
        
        return weekday
    }
    
    func onTheSameDay(dateStr: String, format: String="yyyy-MM-dd HH:mm:ss") -> Bool {
        
        let dFmatter = DateFormatter()
        dFmatter.dateFormat = format
        
        if let date = dFmatter.date(from: dateStr) {
            
            let calendar = Calendar.current
            let comp1 = calendar.dateComponents([.year,.month,.day], from: self)
            let comp2 = calendar.dateComponents([.year,.month,.day], from: date)
            
            if comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day {
                return true
            }
        }
        return false
    }
    
    func daysAddToDate(days: TimeInterval) -> Date {
        
        let newDate = Date.init(timeInterval: days*24*60*60, since: self)
        return newDate
    }
}

extension UIButton {
    
    /// 设置按钮图片的位置 实现button的文字图片上下或者左右排列
    /// - parameter imagePosition: .top:图片在上 .left:图片在左 .bottom:图片在下 .right:图片在z右
    /// - parameter additionalSpacing: 图片与文字的间隙
    public func set(image anImage: UIImage?, title: String, imagePosition: UIView.ContentMode, additionalSpacing: CGFloat, state: UIControl.State){
        
        self.imageView?.contentMode = .center
        self.setImage(anImage, for: state)
        
        positionLabelRespectToImage(title: title, position: imagePosition, spacing: additionalSpacing)
        
        self.titleLabel?.contentMode = .center
        self.setTitle(title, for: state)
    }
    
    /// 设置按钮图片的偏移量
    /// - parameter titlePosition: .top:图片在上 .left:图片在左 .bottom:图片在下 .right:图片在z右
    /// - parameter additionalSpacing: 图片与文字的间隙
    private func positionLabelRespectToImage(title: String, position: UIView.ContentMode, spacing: CGFloat) {
        
        let imageSize = self.imageRect(forContentRect:self.frame)
        let titleFont = self.titleLabel?.font!
        let titleSize = title.size(withAttributes:[NSAttributedString.Key.font: titleFont!])
        
        let imgSizeWidth = imageSize.width
        let imgSizeHeight = imageSize.height
        
        var titSizeWidth = titleSize.width
        if position == .left || position == .right {
            
            if titSizeWidth + imgSizeWidth >= self.frame.size.width {
                titSizeWidth = self.frame.size.width - imgSizeWidth - spacing
            }
        }
        let titSizeHeight = titleSize.height
        
        var titleInsets: UIEdgeInsets
        var imageInsets: UIEdgeInsets
        
        switch (position){
        case .top:
            titleInsets = UIEdgeInsets(top: 0,left: -(imgSizeWidth), bottom: -imgSizeHeight-spacing/2, right: 0)
            imageInsets = UIEdgeInsets(top: -titSizeHeight-spacing/2, left: 0, bottom: 0, right: -titSizeWidth)
            
        case .bottom:
            titleInsets = UIEdgeInsets(top: -imgSizeHeight-spacing/2,left: -imgSizeWidth, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -titSizeHeight-spacing/2, right: -titSizeWidth)
            
        case .left:
            titleInsets = UIEdgeInsets(top: 0,left: spacing/2, bottom: 0, right: -spacing/2)
            imageInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
            
        case .right:
            titleInsets = UIEdgeInsets(top: 0, left: -imgSizeWidth-spacing/2, bottom: 0, right: imgSizeWidth+spacing/2)
            imageInsets = UIEdgeInsets(top: 0, left: titSizeWidth+spacing/2, bottom: 0, right: -titSizeWidth-spacing/2)
            
        default:
            titleInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        self.titleEdgeInsets = titleInsets
        self.imageEdgeInsets = imageInsets
    }
    
    /// titleLabel 宽度
    func titleWidth() -> CGFloat {
        let btnTitle = titleLabel?.text
        return btnTitle!.getLabWidth(font: titleLabel!.font)
    }
}

extension UIViewController {
    
    /// 获取当前控制器
    class func getCurrentVC() -> UIViewController? {
        
        var result: UIViewController?
        var rootVC = UIApplication.shared.keyWindow?.rootViewController
        
        repeat {
            
            if rootVC is UINavigationController {
                
                let navi = rootVC as! UINavigationController
                let vc = navi.visibleViewController
                result = vc
                rootVC = vc?.presentedViewController
            }
            else if rootVC is UITabBarController {
                
                let tab = rootVC as! UITabBarController
                result = tab
                rootVC = tab.selectedViewController
            }
            else {
                
                result = rootVC
                rootVC = nil
            }
            
        } while (rootVC != nil)
        
        return result
    }
}

extension UISearchBar {
    
    var textField: UITextField? {
        get {
            return self.value(forKey: "searchField") as? UITextField
        }
    }
}

extension UIView {
    
    /// 创建无数据视图
    func prepareNoDate(view noDataView: UIView, title: String = "暂无数据") {
        
        noDataView.isHidden = true
        self.addSubview(noDataView)
        
        noDataView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(200)
        }
        
        let imgView : UIImageView = UIImageView()
        imgView.tag = 1000
        imgView.image = UIImage(named: "icon_empty")
        imgView.contentMode = .scaleAspectFit
        noDataView.addSubview(imgView)
        
        imgView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
            make.width.height.equalTo(158)
        }
        
        let noDataLabel = UILabel()
        noDataLabel.tag = 1001
        noDataLabel.font = UIFont.systemFont(ofSize: 15)
        noDataLabel.textColor = UIColor.darkGray
        noDataLabel.text = title
        noDataView.addSubview(noDataLabel)
        
        noDataLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imgView.snp.bottom).offset(20)
        }
    }
    
    /// 取得视图所在的控制器
    public func viewController() -> UIViewController? {
        
        var nextResponder: UIResponder? = self
        
        repeat {
            nextResponder = nextResponder?.next
            
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            
        } while nextResponder != nil
        
        return nil
    }
    
    /// 视图设置阴影
    public func layerShadow(color:UIColor = .black,
                            offsetSize:CGSize = CGSize(width: 0, height: 0),
                            opacity:Float = 0.06,
                            radius:CGFloat = 3.0) {
        
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offsetSize
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    /**
     *  设置部分圆角(相对布局)
     *  @param corners 需要设置为圆角的角 UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerAllCorners
     *  @param radii   需要设置的圆角大小 例如 CGSizeMake(20.0f, 20.0f)
     *  @param rect    需要设置的圆角view的rect
     */
    public func addRoundedCorners(corners: UIRectCorner, radii: CGSize, rect: CGRect) {
        
        // 画圆角和阴影
        let rounded = UIBezierPath.init(roundedRect: rect, byRoundingCorners: corners, cornerRadii: radii)
        
        let shape = CAShapeLayer()
        shape.path = rounded.cgPath
        self.layer.mask = shape
    }
    
    /**
     *  添加虚线
     *  @param direction    设置方向 1：横向 2：竖向
     *  @param pattern  第一个是 线条长度   第二个是间距
     */
    func addDottedToLayer(color: UIColor, width: CGFloat, direction: Int = 1, pattern: [NSNumber] = [2, 2]) {
        
        let border = CAShapeLayer()
        //  线条颜色
        border.strokeColor = color.cgColor
        border.fillColor = nil
        
        let pat = UIBezierPath()
        pat.move(to: CGPoint.zero)
        
        if direction == 1 {
            pat.addLine(to: CGPoint(x: width, y: 0))
        }else{
            pat.addLine(to: CGPoint(x: 0, y: width))
        }
        
        border.path = pat.cgPath
        border.frame = self.bounds
        
        // 不要设太大 不然看不出效果
        border.lineWidth = 0.5
        border.lineCap = .butt
        border.lineDashPattern = pattern
        self.layer.addSublayer(border)
    }
}

/// 针对MAAnnotationView的扩展
extension MAAnnotationView {
    
    /// 根据heading信息旋转大头针视图
    ///
    /// - Parameter heading: 方向信息
    func rotateWithHeading(heading: CLHeading) {
        
        //将设备的方向角度换算成弧度
        let headings = Double.pi * heading.magneticHeading / 180.0
        //创建不断旋转CALayer的transform属性的动画
        let rotateAnimation = CABasicAnimation(keyPath: "transform")
        //动画起始值
        let formValue = self.layer.transform
        rotateAnimation.fromValue = NSValue(caTransform3D: formValue)
        //绕Z轴旋转heading弧度的变换矩阵
        let toValue = CATransform3DMakeRotation(CGFloat(headings), 0, 0, 1)
        //设置动画结束值
        rotateAnimation.toValue = NSValue(caTransform3D: toValue)
        rotateAnimation.duration = 0.2
        rotateAnimation.isRemovedOnCompletion = true
        //设置动画结束后layer的变换矩阵
        self.layer.transform = toValue
        
        //添加动画
        self.layer.add(rotateAnimation, forKey: nil)
        
    }
}

extension PopupDialog {
    
    @objc public convenience init(title: String?, message: String? = nil) {
        
        // Create and configure the standard popup dialog view
        let viewController = PopupDialogDefaultViewController()
        viewController.titleText   = title
        viewController.messageText = message
        
        // Call designated initializer
        self.init(viewController: viewController,
                  buttonAlignment: .horizontal,
                  tapGestureDismissal: false,
                  panGestureDismissal: false)
    }
}

//MARK: - 类

import PopupDialog
public final class AlertButton: PopupDialogButton {
    
    override public func setupView() {
        defaultTitleColor = PublicColor.emphasizeTextColor
        super.setupView()
    }
}

//MARK: - 延时调用，重复调用取消上次任务

class ActionIntervalGuard: NSObject {
    
    private var action: (()->Void)?
    private var timer: Timer?
    
    func perform(interval: TimeInterval, action: @escaping () -> Void) {
        
        self.action = action
        if let old = self.timer {
            old.invalidate()
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(task), userInfo: nil, repeats: false)
    }
    
    @objc func task() {
        
        self.timer?.invalidate()
        self.timer = nil
        self.action?()
    }
}


//MARK: - 自定义模型类型转换

class StringTransform: TransformType {
    
    public typealias Object = String
    public typealias JSON = Int32
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        
        guard let value = value as? JSON else {
            return nil
        }
        return Object(value)
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        
        guard let value = value else { return nil }
        return JSON(value)
    }
}

class IntTransform: TransformType {
    
    public typealias Object = Int
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        
        guard let value = value as? JSON else {
            return nil
        }
        return Object(value)
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        
        guard let value = value else { return nil }
        return JSON(value)
    }
}

class CGFloatTransform: TransformType {
    
    public typealias Object = CGFloat
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        
        guard let value = value as? JSON else {
            return nil
        }
        return Object(Double(value) ?? 0)
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        
        guard let value = value else { return nil }
        return JSON(format: "%.f", value)
    }
}

class DoubleTransform: TransformType {
    
    public typealias Object = Double
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Object? {
        
        guard let value = value as? JSON else {
            return nil
        }
        return Object(value)
    }
    
    open func transformToJSON(_ value: Object?) -> JSON? {
        
        guard let value = value else { return nil }
        return JSON(value)
    }
}

//MARK: - 拨打电话

func AppCallWith(phone: String) {
    
    let phoneStr = String.init(format: "tel:%@", phone)
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(URL.init(string: phoneStr)!, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(URL(string: phoneStr)!)
    }
}

//MARK: - 调试模式下打印

func AppLog<T>(_ message: T, fileName: String = #file, methodName: String = #function, lineNumber: Int = #line)
{
    #if DEBUG
    // 要把路径最后的字符串截取出来
    let fName = ((fileName as NSString).pathComponents.last!)
    print("\(fName).\(methodName)[\(lineNumber)]: \(message)")
    #endif
}
