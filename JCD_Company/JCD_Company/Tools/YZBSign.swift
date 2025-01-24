//
//  Alamofire+YZBSign.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/1/17.
//  Copyright © 2018年 WZKJ. All rights reserved.
//  signKey yzp
//  passwordKey yzbpasswordyzb


import Foundation
import Alamofire
import PopupDialog
import ObjectMapper
import SwiftyJSON

class YZBSign {
    
    ///单例模式
    static let shared = YZBSign()
    private init(){}
    
    let signKey = "c25a1809b3399650ed4699691b4ab714"
    let passwordKey = "f218b81c0528bf69781ff8a7d6729171"
    
    
    //MARK: - 网络请求
    
    //@discardableResult 表示取消不使用返回值的警告
    /// 自定义签名请求
    @discardableResult func request(
        _ url: URLConvertible,
        method: HTTPMethod = .get,
        parameters: Parameters = Parameters(),
        encoding: ParameterEncoding = URLEncoding.default,
        headers: HTTPHeaders? = nil,
        success: @escaping (_ response : [String : AnyObject])->(),
        failure: @escaping (_ error : Error)->()) -> DataRequest {
        
        var header = HTTPHeaders()
        header = headers ?? HTTPHeaders()
        header["Content-type"] = "application/x-www-form-urlencoded"
        header["accessToken"] = UserData1.shared.tokenModel?.accessToken
        header["userId"] = UserData1.shared.tokenModel?.userId
        header["appVersion"] =  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        debugPrint("accessToken: \(UserData1.shared.tokenModel?.accessToken ?? "")")
        debugPrint("userId: \(UserData1.shared.tokenModel?.userId ?? "")")
        header["fromType"] = "APP"
        //取时间戳
        let nowDate = NSDate.init()
        let timeStamp = nowDate.timeIntervalSince1970
        header["timestamp"] = String.init(format: "%.0f", timeStamp)
        var parametersNew = parameters
        parametersNew["timestamp"] = String.init(format: "%.0f", timeStamp)
        parametersNew["accessToken"] = UserData1.shared.tokenModel?.accessToken
        parametersNew["userId"] = UserData1.shared.tokenModel?.userId
        let sign = createMd5Sign(parametersNew, url: url as? String)
        header["signature"] = sign
        
        
        let operation = Alamofire.request(url, method: method, parameters: parameters, encoding: encoding, headers: header).responseJSON { (response) in
            let window = UIApplication.shared.windows.first
            window?.clearAllNotice()
            
            switch response.result {
            case .success(let value):
                AppLog("url: \(url)")
                AppLog("参数: \(parameters)")
                AppLog(JSON(value))
                let code = Utils.getReadString(dir: value as! NSDictionary, field: "code")
                if code == "2" || code == "401" {
                    //下线提醒
                    AppLog("异地登录")
                    let vc = window?.rootViewController
                    let popup = PopupDialog(title: "下线提示", message: "您的账号已在另一台设备中登录，如非本人操作，则密码可能已经泄露，建议立即修改密码！", image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

                    let sureBtn = AlertButton(title: "确认") {
                        ToolsFunc.showLoginVC()
                    }
                    popup.addButtons([sureBtn])
                    vc?.present(popup, animated: true, completion: nil)
                }
                else if code != "0" && code != "008"  && code != "015" && code != "" && code != "006" && code != "001" && code != "10000" && code != "10010" && code != "23" && code != "21" && code != "22" {
                    let msg = Utils.getReadString(dir: value as! NSDictionary, field: "msg")
                    if msg.contains("user not registered") == false {
                        window?.noticeOnlyText(msg)
                    } else {
                        
                    }
                }
//                if code == "2" {
//                    //重新登录
//                    ToolsFunc.changeWindowRootController()
//                }
//                else {
//
//                }
                //成功回调
                success(value as! [String : AnyObject])
                break
                
            case .failure(let error):
                debugPrint("errorURL: \(url)")
                AppLog(error)
                //失败回调
                failure(error)
                
                let errorStr = error.localizedDescription
                if errorStr.range(of: "JSON could not be serialized") != nil {
                    window?.noticeOnlyText("好像出错了~")
                }else if errorStr.range(of: "cancelled") != nil {
                    window?.pleaseWait()
                }else if errorStr.range(of: "已取消") != nil {
                    window?.pleaseWait()
                }else {
                    window?.noticeOnlyText(errorStr)
                }
                
                break
            }
        }
        
        return operation
    }
    
    /// 图片上传
    func upLoadImageRequest(oldUrl: String?, imageType: String, image: UIImage, success : @escaping (_ response : String)->(), failture : @escaping (_ error : Error?)->()) {
        
        let window = UIApplication.shared.windows.first
        window?.pleaseWait()
        let urlStr = APIURL.imageUpload
        
        let imageData = image.jpegData(compressionQuality: 0.3)
        
        //上传头像
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            AppLog("图片数据大小: \(imageData!.count/1024) kb")
           
            var cityID = "000000"
            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                if let valueStr = UserData.shared.substationModel?.cityId {
                    cityID = valueStr
                }
            }else if UserData.shared.userType == .gys {
                if let valueStr = UserData.shared.merchantModel?.cityId {
                    cityID = valueStr
                }
            }else if UserData.shared.userType == .yys {
                if let valueStr = UserData.shared.userInfoModel?.substation?.cityId {
                    cityID = valueStr
                }
            }
            
            var imageName = NSUUID().uuidString
            imageName = imageName.replacingOccurrences(of: "-", with: "")
            imageName = imageName.lowercased()
            
            //
            var url = "yzbfile/\(cityID)/\(imageType)/\(imageName).jpg"
            if imageType == "register/company" {
                url = "yzbfile/\(imageType)/\(imageName).jpg"
            }
            if let imageData1 = imageData {
                multipartFormData.append(imageData1, withName: "file", fileName: url, mimeType: "image/jpeg")
            }
            multipartFormData.append((url.data(using: String.Encoding.utf8))!, withName: "url")
            
            //
            let key = UserData1.shared.tokenModel?.accessToken
            if let key1 = key, let data = key1.data(using: String.Encoding.utf8) {
                multipartFormData.append((data), withName: "key")
            }
            
            //
            var oldPath = ""
            if oldUrl != nil && oldUrl != "" {
                oldPath = oldUrl!
                //删除第一个斜杠
                let startIndex = oldPath.index(oldPath.startIndex, offsetBy: 1)
                oldPath = String(oldPath.suffix(from: startIndex))
            }
            if let data = oldPath.data(using: String.Encoding.utf8) {
                multipartFormData.append(data, withName: "oldPath")
            }            
        }, to: urlStr) { (encodingResult) in
            
            switch encodingResult {
            case .success(let upload, _, _):
                
                upload.responseString(completionHandler: { (response) in
                    
                    AppLog(response)
                    
                    window?.clearAllNotice()
                    
                    if let value = response.result.value {
                        let dic = value.stringValueDic(value)
                        let data = Utils.getReadString(dir: dic! as NSDictionary, field: "data")
                        if value.range(of: "error") == nil {
                            success(data)
                        }else {
                            failture(nil)
                        }
                        
                    }else {
                        failture(nil)
                    }
                })
                
            case .failure(let encodingError):
                
                failture(nil)
                AppLog(encodingError)
            }
        }
    }
    
    
    //MARK: - 自动登录
    func autoLogin() {
        
//        var userId = ""
//        if let valueStr = UserData.shared.workerModel?.id {
//            userId = valueStr
//        }
//        
//        var parameters: Parameters = ["id": userId, "deviceType": "1", "deviceSystem": UIDevice.current.systemVersion, "deviceName": UIDevice.current.model, "appVersion": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String]
//        
//        let sign = createMd5Sign(parameters)
//        parameters["sign"] = sign
//        
//        AppLog(parameters)
//        
//        let window = UIApplication.shared.keyWindow
//        window?.clearAllNotice()
//        window?.pleaseWait()
//        let urlStr = APIURL.automaticLogin
//        
//        Alamofire.request(urlStr, method: .post, parameters: parameters).responseJSON { (response) in
//            
//            window?.clearAllNotice()
//            
//            switch response.result {
//            case .success(let value):
//                AppLog(value)
//                
//                let errorCode = Utils.getReadString(dir: value as! NSDictionary, field: "errorCode")
//                if errorCode == "000" {
//                    
//                    //储存用户数据
////                    AppUtils.setUserData(response: value as! [String : AnyObject])
//                }
//                else {
//                    let msg = Utils.getReadString(dir: value as! NSDictionary, field: "msg")
//                    window?.noticeOnlyText(msg)
//                }
//                
//                break
//                
//            case .failure(let error):
//                AppLog(error)
//                
//                let errorStr = error.localizedDescription
//                if errorStr.range(of: "JSON could not be serialized") != nil {
//                    window?.noticeOnlyText(AppData.yzbWarning)
//                }else {
//                    window?.noticeOnlyText(errorStr)
//                }
//                
//                break
//            }
//        }
    }
    
    //MARK: - 获取基础数据
    func getBaseInfo() {
        
        // 获取启动页
        getLaunchImage()
        
        let urlStr = APIURL.getBaseInfo
        
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let strNowTime = timeFormatter.string(from: date) as String
        
        AppLog(strNowTime)
        
        if var request = try? URLRequest.init(url: urlStr, method: .get) {
            
            request.timeoutInterval = 10
            
            Alamofire.request(request).responseJSON { response in
                
                let date2 = Date()
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let strNowTime = timeFormatter.string(from: date2) as String
                
                AppLog(strNowTime)
                
                let window = UIApplication.shared.windows.first
                
                switch response.result {
                case .success(let value):
                    AppLog("url: \(urlStr)")
                    AppLog(JSON(value))
                    let errorCode = Utils.getReadString(dir: value as! NSDictionary, field: "code")
                    if errorCode == "0" {
                        var dic = Utils.getReadDic(data: value as AnyObject, field: "data")
                        AppUtils.getBaseInfo(resData: dic)
                        dic = DeleteEmpty.deleteEmpty(dic as? [AnyHashable : Any])! as NSDictionary
                        UserDefaults.standard.set(dic, forKey: "baseData")
                    }
                    else {
                        if let dic = UserDefaults.standard.object(forKey: "baseData")  as? NSDictionary {
                            AppUtils.getBaseInfo(resData: dic)
                        }
                        else {
                            let msg = Utils.getReadString(dir: value as! NSDictionary, field: "msg")
                            window?.noticeOnlyText(msg)
                        }
                    }
                    
                    break
                    
                case .failure(let error):
                    AppLog(error)
                    
                    if let dic = UserDefaults.standard.object(forKey: "baseData") as? NSDictionary {
                        AppUtils.getBaseInfo(resData: dic)
                    }
                    else {
                        let errorStr = error.localizedDescription
                        if errorStr.range(of: "JSON could not be serialized") != nil {
                            window?.noticeOnlyText(AppData.yzbWarning)
                        }else {
                            window?.noticeOnlyText(errorStr)
                        }
                    }
                    
                    break
                }
            }
        }
    }
    
    /// 获取启动页
    func getLaunchImage() {
        
        let parameters: Parameters = [:]
        let urlStr = APIURL.getAppStartPage
           
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                if let valueStr = dataDic["value"] as? String {
                    UserDefaults.standard.set(valueStr, forKey: "AppStartPage")
                }
            }
            
        }) { (error) in
            
        }
    }
    
    
    //MARK: - 算法
    
    /// 计算文件名
    func getFileName() -> String {
        
        //取日期
        let dFormatter = DateFormatter()
        dFormatter.dateFormat = "yyMMdd"
        
        //日期格式化
        let dateStr = dFormatter.string(from: Date())
        
        //取时
        let calendar: Calendar = Calendar(identifier: .gregorian)
        let comps: DateComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: Date())
        
        let hour = comps.hour! * 60 * 60
        let minute = comps.minute! * 60
        let second = comps.second!
        
        let timeStr = String.init(format: "%ld", hour+minute+second)
        
        //取4位随机数
        let temp = Int(arc4random() % 10000)
        let tempStr = String.init(format: "%04d", temp)
        
        let name = dateStr + timeStr + tempStr
        AppLog("生成文件名: \(name)")
        
        return name
    }
    
    /// md5签名
        func createMd5Sign(_ parameters: Parameters!, url: String?) -> String {
            
    //        var address: String? = ""
    //        if url?.contains("jcdSys") ?? false {
    //            let addressList = url?.components(separatedBy: "jcdSys")
    //            address = addressList?.last
    //        } else if url?.contains("jcdGys") ?? false {
    //            let addressList = url?.components(separatedBy: "jcdGys")
    //            address = addressList?.last
    //        }
            guard let para = parameters else {
                return ""
            }
           // AppLog(para)
            
            var contentStr = ""
            
           // contentStr += signKey + (address ?? "")
            contentStr += signKey
            
            var keys = [String]()
            
            for key in para.keys {
                keys.append(key)
            }
            
            //参数名排序
            keys = keys.sorted(by: {$0 < $1})
            
            //拼接排序后的参数
            for key in keys {
                contentStr += key
                contentStr += "\(para[key] ?? "")"
            }
            
            //contentStr += signKey
           // AppLog("拼接后签名: \(contentStr)")
            
    //        //指定编码
    //        contentStr = contentStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet(charactersIn: "!\"#$%&'()+,/:;<>?@[\\]^`{|}~").inverted)!
    //        AppLog("编码后签名: \(contentStr)")
    //
    //        //空格替换为+
    //        contentStr = contentStr.replacingOccurrences(of: " ", with: "+")
    //        AppLog("去除空格后签名: \(contentStr)")
            
            
            let sign = contentStr.md5String()
          //  AppLog("md5签名: \(sign)")
            
            return sign
        }
    
    /// md5签名
    func createMd5Sign(_ parameters: Parameters!) -> String {
        
        AppLog(parameters!)
        
        var contentStr = ""
        contentStr += signKey
        
        var keys = [String]()
        
        for key in parameters.keys {
            keys.append(key)
        }
        
        //参数名排序
        keys = keys.sorted(by: {$0 < $1})
        
        //拼接排序后的参数
        for key in keys {
            contentStr += key
            contentStr += "\(parameters[key]!)"
        }
        
        contentStr += signKey
        AppLog("拼接后签名: \(contentStr)")
        
        //指定编码
        contentStr = contentStr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet(charactersIn: "!\"#$%&'()+,/:;<>?@[\\]^`{|}~").inverted)!
        AppLog("编码后签名: \(contentStr)")
        
        //空格替换为+
        contentStr = contentStr.replacingOccurrences(of: " ", with: "+")
        AppLog("去除空格后签名: \(contentStr)")
        
        let sign = contentStr.md5String()
        AppLog("md5签名: \(sign)")
        
        return sign
    }
    
    /// 密码md5加密
    func passwordMd5(password: String!) -> String {
        if password == nil {
            return ""
        }
        
        AppLog(password)
         
        let contentStr = passwordKey + password + passwordKey
        AppLog("拼接后密码: \(contentStr)")
        
        let newPassword = contentStr.md5String()
        AppLog("md5加密新密码: \(newPassword)")
        
        return newPassword
    }
    
}

