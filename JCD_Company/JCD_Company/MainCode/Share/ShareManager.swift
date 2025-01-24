//
//  ShareManager.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/10.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit

class ShareManager: NSObject {
    var title: String?
    var imageStr: String?
    var urlStr: String?
    var des: String?
    weak var vc: UIViewController?
    var shareSelectStyle: ShareSelectStyle = .friend
    var imageData: Data?
    
    init(title: String?, des: String?, imageStr: String?, urlStr: String?, vc: UIViewController?) {
        super.init()
        self.title = title
        self.des = des
        self.imageStr = imageStr
        self.urlStr = urlStr
        self.vc = vc
    }
    
    init(data: Data?, vc: UIViewController?) {
        super.init()
        self.imageData = data
        self.vc = vc
    }
    
    func share() {
       // shareOrgian()
        switch shareSelectStyle {
        case .friend, .circle:
            if imageData != nil {
                shareWechatOnlyImage()
            } else {
                shareWechat()
            }
        case .qq, .qz:
            shareQQ()
        case .sina:
            if imageData == nil {
                shareSina()
            } else {
                shareSinaOnlyImage()
            }
        }
    }
    
    func shareYM() {
//        UMSocialUIManager.showShareMenuViewInWindow { (platformType, userInfo) in
//            var storeName = ""
//            if UserData.shared.userType == .gys {
//                if let valueStr = UserData.shared.merchantModel?.name {
//                    storeName = valueStr
//                }
//            }else {
//                if let valueStr = UserData.shared.workerModel?.store?.name {
//                    storeName = valueStr
//                }
//            }
//            guard let shareUrl = self.urlStr else { return }
//            let shareTitle = self.title ?? ""
//            let shareDescr = "来自 \(storeName) 分享的产品"
//            var shareImage: Any!
//
//            shareImage = UIImage.init(named: "shareImage")!
//            if let valueStr = self.imageStr {
//                if valueStr != "" {
//                    shareImage = APIURL.ossPicUrl + valueStr
//                }
//            }
//
//            let messageObject = UMSocialMessageObject()
//            let shareObject = UMShareWebpageObject.shareObject(withTitle: shareTitle, descr: shareDescr, thumImage: shareImage)
//            shareObject?.webpageUrl = APIURL.ossPicUrl + shareUrl
//            messageObject.shareObject = shareObject
//
//            UMSocialManager.default().share(to: platformType, messageObject: messageObject, currentViewController: self.vc, completion: { (data, error) in
//
//                if error != nil {
//                    AppLog("************Share fail with error \(error!)************")
//
//                }else {
//
//                    if let resp = data as? UMSocialShareResponse {
//
//                        AppLog("response message is \(String(describing: resp.message))")
//                        AppLog("response originalResponse data is \(String(describing: resp.originalResponse))")
//
//                    }else {
//                        AppLog("response data is \(data!)")
//                    }
//                }
//            })
//        }
    }
    
    private func shareWechat() {
        var shareImage = #imageLiteral(resourceName: "yzb_logo")
        if let valueStr = imageStr, !valueStr.isEmpty {
            let shareImageStr = APIURL.ossPicUrl + valueStr
            let url : URL = URL.init(string: shareImageStr)!
            let data : Data = try! Data.init(contentsOf: url)
            let image = UIImage(data:data, scale: 1.0)
            shareImage = image ?? UIImage()
        }
        var flag: LDWechatScene = .Session
        if shareSelectStyle == .friend {
            flag = .Session
        } else if shareSelectStyle == .circle {
            flag = .Timeline
        }
        if let shareUrl = urlStr {
            LDWechatShare.shareURL(shareUrl, title: title, description: des, thumbImg: shareImage, to: flag) { (boolen, result) in
                
            }
        }
    }
    
    private func shareWechatOnlyImage() {
        var flag: LDWechatScene = .Session
        if shareSelectStyle == .friend {
            flag = .Session
        } else if shareSelectStyle == .circle {
            flag = .Timeline
        }
        if let data = imageData {
            LDWechatShare.shareImage(data, to: flag) { (boolen, result) in
                
            }
        }
    }
    
    private func shareOrgian() {
        guard let shareUrl = urlStr else { return }
        let shareTitle = title ?? ""
        var shareImage = UIImage.init(named: "yzb_logo")
        if let valueStr = imageStr, !valueStr.isEmpty {
            let shareImageStr = APIURL.ossPicUrl + valueStr
            let url : URL = URL.init(string: shareImageStr)!
            let data : Data = try! Data.init(contentsOf: url)
            let image = UIImage(data:data, scale: 1.0)
            shareImage = image
        }
        let shareURL = URL.init(string: APIURL.ossPicUrl + shareUrl)!
        let items = [shareImage!, shareTitle, shareURL] as [Any]
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil)
        activityVC.completionWithItemsHandler =  { activity, success, items, error in
            print(activity as Any)
            print(success)
            print(items as Any)
            print(error as Any)
        }
        vc?.present(activityVC, animated: true, completion: { () -> Void in
            
        })
    }
    
    private func shareQQ() {
//        if let shareUrl = urlStr, !shareUrl.isEmpty {
//            let url = URL.init(string: APIURL.ossPicUrl + shareUrl)!
//            var flag: LDTencentFlag = .QQ
//            if shareSelectStyle == .qz {
//                flag = .QZone
//            }
//            LDTencentShare.shareVideo(url, preImgUrl: nil, title: title ?? "", description: title ?? "", flag: flag) { (boolen, result) in
//                
//            }
//        }
    }
    
    private func shareSina() {
        if let shareUrl = urlStr, !shareUrl.isEmpty {
           // LDSinaShare.shareWeb(APIURL.ossPicUrl + shareUrl, objectID: "124", title: title ?? "")
            let data = UIImage.init(named: "yzb_logo")!.pngData()
            LDSinaShare.shareWeb(APIURL.ossPicUrl + shareUrl, objectID: "124", title: "详情", text: title ?? "", description: "戳一下，查看详情！", scheme: "https://www.jcdcbm.com", thumbImgData: data, userInfo: nil, shareResultHandle: { (success, info) in
               // self.alert("\(text) success: \(success)--\(String(describing: info))")
            })

        }
    }
    
    private func shareSinaOnlyImage() {
        if let data = imageData {
            LDSinaShare.shareImage(data)
        }
    }
}
