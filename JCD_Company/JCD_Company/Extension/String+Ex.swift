//
//  String+Ex.swift
//  YS_HelloRead
//
//  Created by Cloud on 2018/12/24.
//  Copyright © 2018 chaoyun. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import UIKit

extension String {
    
    /// 版本大小比较
    /// - Parameter newVersion: 新版本号
    /// - Parameter oldVersion: 旧版本号
    static func compareVersion(newVersion: String, oldVersion: String) -> Bool {
        if newVersion.isEmpty && oldVersion.isEmpty || newVersion == oldVersion {
            return false
        }
        if  newVersion.isEmpty && !oldVersion.isEmpty {
            return false
        }
        if !newVersion.isEmpty && oldVersion.isEmpty {
            return true
        }
        let newVersionArr = newVersion.components(separatedBy: ".")
        let oldVersionArr = oldVersion.components(separatedBy: ".")
        let smallCount = (newVersionArr.count > oldVersionArr.count) ? oldVersionArr.count : newVersionArr.count
        for index in 0..<smallCount {
            let value1 = Int(newVersionArr[index])
            let value2 = Int(oldVersionArr[index])
            if value1! > value2! {
                return true
                
            } else if value1! < value2! {
                return false
            }
        }
        if newVersionArr.count > oldVersionArr.count {
            return true
        } else if newVersionArr.count < oldVersionArr.count {
            return false
        } else {
            return false
        }
    }
    
    /// 从String中截取出参数
    var urlParameters: [String: AnyObject]? {
        // 截取是否有参数
        guard let urlComponents = NSURLComponents(string: self), let queryItems = urlComponents.queryItems else {
            return nil
        }
        // 参数字典
        var parameters = [String: AnyObject]()
        
        // 遍历参数
        queryItems.forEach({ (item) in
            
            // 判断参数是否是数组
            if let existValue = parameters[item.name], let value = item.value {
                // 已存在的值，生成数组
                if var existValue = existValue as? [AnyObject] {
                    
                    existValue.append(value as AnyObject)
                } else {
                    parameters[item.name] = [existValue, value] as AnyObject
                }
                
            } else {
                
                parameters[item.name] = item.value as AnyObject
            }
        })
        
        return parameters
    }
    
    func urlEncoding() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.init(charactersIn: "`#%^{}\"[]|\\<> ").inverted)!
    }
    
    static func getCacheSize() -> String {
        // 取出cache文件夹目录
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        // 取出文件夹下所有文件数组
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        //快速枚举出所有文件名 计算文件大小
        var size = 0
        for file in fileArr! {
            // 把文件名拼接到路径中
            let path = cachePath! + ("/\(file)")
            // 取出文件属性
            if let floder = try? FileManager.default.attributesOfItem(atPath: path) {
                for (key, fileSize) in floder where key == FileAttributeKey.size {
                    // 累加文件大小
                    size += (fileSize as AnyObject).integerValue
                }
            }
            // 用元组取出文件大小属性
            
        }
        let totalCache = Double(size) / 1024.00 / 1024.00
        return String(format: "%.2f", totalCache)
    }
    
    static func clearCache() {
        // 取出cache文件夹目录
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let fileArr = FileManager.default.subpaths(atPath: cachePath!)
        
        // 遍历删除
        
        for file in fileArr! {
            
            let path = (cachePath! as NSString).appending("/\(file)")
            if FileManager.default.fileExists(atPath: path) {
                
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                }
            }
            
        }
        //return getCacheSize()
    }
    
    static func dateString(date: String) -> String {
        var timeStamp = date
        if date.count == 13 {
            timeStamp = String(date.prefix(10))
        }
        //转换为时间
        let timeInterval: TimeInterval = TimeInterval(timeStamp)!
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //自定义日期格式
        let time = dateformatter.string(from: date as Date)
        return time
    }
    
    static func dayDateString(date: String) -> String {
        var timeStamp = date
        if date.count == 13 {
            timeStamp = String(date.prefix(10))
        }
        //转换为时间
        let timeInterval: TimeInterval = TimeInterval(timeStamp)!
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd" //自定义日期格式
        let time = dateformatter.string(from: date as Date)
        return time
    }
    
    // 根据后台时间字符串转换成几天前或者年月日
    func conversionAbsoluteDate() -> String {
        let dfmatter = DateFormatter()
        //yyyy-MM-dd HH:mm:ss
        dfmatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        guard  let date = dfmatter.date(from: self) else {
            return self
        }
        
        //        //获取当前的时间戳
        //        let currentTime = Date().timeIntervalSince1970
        //        //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
        //        let timeStamp: TimeInterval = date.timeIntervalSince1970
        //        //时间差
        //        let reduceTime: TimeInterval = currentTime - timeStamp
        
        if date.year ==  Date().year {
            if date.month == Date().month {
                switch Date().day-date.day {
                case 0:
                    return String(format: "%02d:%02d", arguments: [date.hour, date.minute])
                case 1:
                    return String(format: "昨天 %02d:%02d", arguments: [date.hour, date.minute])
                case 2:
                    return String(format: "前天 %02d:%02d", arguments: [date.hour, date.minute])
                default:
                    print("date:\(date.day)-Date()\(Date().day) = \(date.day-Date().day)")
                    return String(format: "%02d-%02d", arguments: [date.month, date.day])
                }
            } else {
                return String(format: "%02d-%02d", arguments: [date.month, date.day])
            }
        } else {
            return String(format: "%04d-%02d-%02d", arguments: [date.year, date.month, date.day])
        }
    }
    
    // MARK: - 根据后台时间戳返回几分钟前，几小时前，几天前
    func conversionDateToChinese() -> String {
        let dfmatter = DateFormatter()
        //yyyy-MM-dd HH:mm:ss
        dfmatter.dateFormat="yyyy-MM-dd HH:mm:ss"
        guard  let date = dfmatter.date(from: self) else {
            return self
        }
        //获取当前的时间戳
        let currentTime = Date().timeIntervalSince1970
        //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
        let timeStamp: TimeInterval = date.timeIntervalSince1970
        //时间差
        let reduceTime: TimeInterval = currentTime - timeStamp
        //时间差小于60秒
        if reduceTime < 60 {
            return "刚刚"
        }
        //时间差大于一分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins)分钟前"
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours)小时前"
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days)天前"
        }
        let mothe = Int(reduceTime / 3600 / 24 / 30)
        if mothe < 12 {
            return "\(mothe)个月前"
        }
        let year = Int(mothe/12)
        return "\(year)年前"
    }
    
    // MARK: - 根据传入的图片地址字符串获取url
    func getUrlWithImageStr() -> URL? {
        if !self.isEmpty, let url = URL.init(string: APIURL.ossPicUrl+self) {
            return url
        } else {
            return nil
        }
    }
    
    /// Json String 转数组
    func getArrayByJsonString() -> Array<Any> {
        let jsonData: Data = self.data(using: .utf8)!
        let arr = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if arr != nil {
            return arr as! Array<Any>
        }
        return Array<Any>()
    }
    
    func dateStringEx() -> String {
        var timeStamp = String()
        if self.count == 13 {
            timeStamp = String(self.prefix(10))
        }
        //转换为时间
        let timeInterval: TimeInterval = TimeInterval(timeStamp)!
        let date = NSDate(timeIntervalSince1970: timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss" //自定义日期格式
        let time = dateformatter.string(from: date as Date)
        return time
    }
    /// 秒数转化为时间字符串
    static func secondsToTimeString(seconds: Int) -> String {
        //天数计算
        let days = (seconds/1000)/(24*3600);
        
        //小时计算
        let hours = (seconds/1000)%(24*3600)/3600;
        
        //分钟计算
        let minutes = (seconds/1000)%3600/60;
        
        //秒计算
        let second = (seconds/1000)%60;
        
        let timeString  = String(format: "%lu天 %02lu:%02lu:%02lu", days, hours, minutes, second)
        return timeString
    }
    /// 天数计算
    static func secondsToDay(seconds: Int) -> String {
        let days: Int = (seconds/1000)/(24*3600)
        return "\(days)"
    }
    
    /// 小时计算
    static func secondsToHour(seconds: Int) -> String {
        let hours: Int = (seconds/1000)%(24*3600)/3600;
        if hours > 9 {
            return "\(hours)"
        } else {
            return "0\(hours)"
        }
    }
    
    /// 分钟计算
    static func secondsToMinutes(seconds: Int) -> String {
        let minutes: Int = (seconds/1000)%3600/60;
        if minutes > 9 {
            return "\(minutes)"
        } else {
            return "0\(minutes)"
        }
    }
    
    /// 秒数转化为时间字符串
    static func secondsToSecond(seconds: Int) -> String {
        let second = (seconds/1000)%60;
        if second > 9 {
            return "\(second)"
        } else {
            return "0\(second)"
        }
    }
    /*
     常用的一些正则表达式：
     非中文：[^\\u4E00-\\u9FA5]
     非英文：[^A-Za-z]
     非数字：[^0-9]
     非中文或英文：[^A-Za-z\\u4E00-\\u9FA5]
     非英文或数字：[^A-Za-z0-9]
     非因为或数字或下划线：[^A-Za-z0-9_]
     */
    func isPhoneNumber() -> Bool {
        if self.count == 0 {
            return false
        }
        let pattern2 = "^1[0-9]{10}$"
        if NSPredicate(format: "SELF MATCHES %@", pattern2).evaluate(with: self) {
            return true
        }
        return false
    }
    
    
    func base64String() -> String {
        let utf8EncodeData = self.data(using: String.Encoding.utf8, allowLossyConversion: true)
        if utf8EncodeData == nil {
            return self
        }
        // 将NSData进行Base64编码
        let base64String = utf8EncodeData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: UInt(0)))
        return base64String!
    }
    
    func getStringWithBase64() -> String {
        // 将base64字符串转换成NSData
        let base64Data = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: 0))
        if base64Data == nil {
            return self
        }
        // 对NSData数据进行UTF8解码
        let stringWithDecode = NSString(data: base64Data! as Data, encoding: String.Encoding.utf8.rawValue)
        return stringWithDecode! as String
    }
    
    /// 字典转 Json Sting
    static func getJsonStringByDictionary(dictionary: [String: Any]) -> String {
        if !JSONSerialization.isValidJSONObject(dictionary) {
            debugPrint("无法解析出JsonString")
            return ""
        }
        if let data: Data = try? JSONSerialization.data(withJSONObject: dictionary, options: []), let jsonString = String.init(data: data, encoding: .utf8) {
            return jsonString
        }
        return ""  
    }
    
    func stringValueDic(_ str:String) -> [String: Any]? {
        let data = str.data(using:String.Encoding.utf8)
        if let dict = try? JSONSerialization.jsonObject(with: data!,options: JSONSerialization.ReadingOptions.mutableContainers)as? [String: Any] {
            return dict
        }
        return nil
    }
    
    static func getDictionaryFromJSONString(jsonString:String) -> NSDictionary{
        let jsonData:Data = jsonString.data(using: .utf8)!
        let dict = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
        if dict != nil {
            return dict as! NSDictionary
        }
        return NSDictionary()
    }
    
    
    /// 根据字符串计算高度尺寸，width 默认是最大数
    func size(font: UIFont, width: CGFloat = CGFloat.greatestFiniteMagnitude, paragraphStyle: NSParagraphStyle = NSParagraphStyle.default) -> CGSize {
        var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        let rect = self.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                     attributes: attributes,
                                     context: nil)
        return rect.size
    }
    
    /// 根据字符串计算宽度尺寸
    func getSizeWithHeight(font: UIFont, height: CGFloat = CGFloat.greatestFiniteMagnitude, paragraphStyle: NSParagraphStyle = NSParagraphStyle.default) -> CGSize {
        var attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font]
        attributes[NSAttributedString.Key.paragraphStyle] = paragraphStyle
        let rect = self.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height),
                                     options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                     attributes: attributes,
                                     context: nil)
        return rect.size
    }
    
    func transformToPinYin() -> String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        let s = string.replacingOccurrences(of: " ", with: "")
        return s
    }
    
    func isContainSpecialCharacters() -> Bool {
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        if self.rangeOfCharacter(from: characterset.inverted) != nil {
            print("string contains special characters")
            return true
        }
        return false
    }
    
    func textShow(){
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.windows.first?.rootViewController?.view ?? UIView(), animated: true)
        hud.mode = MBProgressHUDMode.text
        hud.bezelView.style = .solidColor;
        //设置等待框背景色为黑色
        hud.bezelView.backgroundColor = .black;
        hud.removeFromSuperViewOnHide = true;
        hud.customView?.backgroundColor(.black)
        hud.animationType = .zoomIn
        hud.minShowTime = 1.5
        hud.contentColor = .white
        hud.label.text(self)
        //hud.detailsLabel.text("这是详细信息内容，会很长很长呢")
        hud.hide(animated: true, afterDelay: 1) //延迟隐藏
        
    }
    
    func textShowLoading() -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.windows.first?.rootViewController?.view ?? UIView(), animated: true)
        hud.mode = MBProgressHUDMode.indeterminate
        hud.bezelView.style = .solidColor;
        //设置等待框背景色为黑色
        hud.bezelView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.490822988)
        ;
        hud.removeFromSuperViewOnHide = true;
        hud.customView?.backgroundColor(.black)
        hud.animationType = .zoomIn
        hud.minShowTime = 1.5
        hud.contentColor = .white
        hud.label.text(self)
        //hud.detailsLabel.text("这是详细信息内容，会很长很长呢")
        return hud
    }
    
    static func attributedString(strs: [String], colors: [UIColor], fonts: [UIFont]) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString.init()
        if !(strs.count == colors.count && strs.count == fonts.count) {
            return attributedString
        }
        strs.enumerated().forEach { (item) in
            let index = item.offset
            let str = item.element
            let color = colors[index]
            let font = fonts[index]
            attributedString.append(NSAttributedString.init(string: str, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color]))
        }
        return attributedString
    }
}
// MARK: - 属性字符串
extension NSAttributedString {
    func reset(line spacing: (CGFloat) -> CGFloat) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: self)
        enumerateAttributes(
            in: NSRange(location: 0, length: length),
            options: .longestEffectiveRangeNotRequired
        ) { (attributes, range, stop) in
            var temp = attributes
            if let paragraph = attributes[.paragraphStyle] as? NSMutableParagraphStyle {
                paragraph.lineSpacing = spacing(paragraph.lineSpacing)
                temp[.paragraphStyle] = paragraph
            }
            string.setAttributes(temp, range: range)
        }
        return string
    }
    
    
}


extension String {
    //MARK: - 验证是否是纯数字
        func isNumber() -> Bool {
            let pattern = "^[0-9]+$"
            if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
                return true
            }
            return false
        }

        

        // 验证是不是字母
        func isLetter() -> Bool {
            let pattern = "^^[A-Za-z0-9]+$"

            if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
                return true

            }

            return false

        }

        

        //MARK: - 验证是否是6位纯数字

        func isNumberSix() -> Bool {
            let pattern = "^\\d{6}$"

            if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
                return true

            }

    //        let a = "aaaa"

    //        a.trimOptional()

            return false

        }

        //MARK: - 验证是否是是有效提现金额

        func verifyNumberTwo() -> Bool {
            let pattern = "^\\d+(\\.\\d{1,2})?$"

            if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
                return true

            }

            return false

        }





    //检测银行卡

        func verifyBankCard() -> Bool {
            let pattern = "^([0-9]{16}|[0-9]{19}|[0-9]{17}|[0-9]{18}|[0-9]{20}|[0-9]{21})$"

            let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)

            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) {
                return true

            }

            return false

        }

        //检测姓名

        func verifyUserName() -> Bool {
            let pattern = "(^[\u{4e00}-\u{9fa5}]{2,12}$)|(^[A-Za-z0-9_-]{4,12}$)"
            let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)

            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) {
                return true

            }

            return false

        }

        //MARK: - 验证身份证

        func verifyId() -> Bool {
            let pattern = "(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)"

            let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)

            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) {
                return true

            }

            return false

        }

        //MARK:处理手机号

        func phoneNoAddAsterisk() -> String {
            return (self as NSString).replacingCharacters(in: NSMakeRange(3,4), with: "****")

        }

        

        //MARK:处理手机号

        func phoneNoHide() -> String {
            return (self as NSString).replacingCharacters(in: NSMakeRange(2,7), with: "*******")

        }

        //MARK:处理银行卡号(隐藏几位)

        func bankCardAddAsterisk() -> String {
            if self.count  == 0 {
                return self

            }
            return (self as NSString).replacingCharacters(in: NSMakeRange(4,10), with: "***********")

        }

        //MARK:获取字符串个数(去空格)

//        func trim() -> String {
//            return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//
//        }

        // 检测密码

        func isPassword() -> Bool {
            let pattern = "^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{6,18}$"//"^[@A-Za-z0-9!#\\$%\\^&*\\.~_]{6,20}$"

            let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)

            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) {
                return true

            }
            return false

        }
}
