//
//  MoreViewController.swift
//  YZB_Company
//
//  Created by 周化波 on 2017/12/28.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog
import Kingfisher
import Alamofire
import ObjectMapper


class MoreViewController: BaseViewController ,UITableViewDelegate ,UITableViewDataSource {

    var moretableView: UITableView!
    let identifier = "MoreCell"
    var cache = ""                      //缓存大小
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>>>> 设置界面释放 <<<<<<<<<<<<<<<<<<<")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        
        prepareTableView()
        getCacheSize()
    }
    
    func prepareTableView() {
        
        moretableView = UITableView()
        moretableView.delegate = self
        moretableView.dataSource = self
        moretableView.rowHeight = 45
        moretableView.estimatedRowHeight = moretableView.rowHeight
        moretableView.separatorStyle = .none
        moretableView.bounces = false
        moretableView.showsVerticalScrollIndicator = false
        moretableView.backgroundColor = .clear
        moretableView.register(MoreCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(moretableView)
        
        let topView: UIView = moretableView!
        let bottomHeight = 44

        moretableView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            
            if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
                if UserData.shared.workerModel?.jobType == 999 || UserData.shared.workerModel?.jobType == 4 {
                    make.height.equalTo(45*5)
                }else {
                    make.height.equalTo(45*5)
                }
            }else {
                make.height.equalTo(45*4)
            }
        }
        
        let exitBtn = UIButton()
        exitBtn.setBackgroundImage(PublicColor.gradualColorImage, for: .normal)
        exitBtn.setBackgroundImage(PublicColor.gradualHightColorImage, for: .highlighted)
        exitBtn.setTitle("退出登录", for: .normal)
        exitBtn.setTitleColor(UIColor.white, for: .normal)
        exitBtn.layer.cornerRadius = 4
        exitBtn.layer.masksToBounds = true
        exitBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        exitBtn.addTarget(self, action: #selector(exitAction), for: .touchUpInside)
        view.addSubview(exitBtn)
        
        exitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(bottomHeight)
            make.right.equalTo(-15)
            make.left.equalTo(15)
            make.height.equalTo(44)
        }
        
        
    }
    
    /// 计算图片内存大小  单位 M
    func getCacheSize(){
        let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let orderPath = cachePath.appendingPathComponent("order")
        
        let cacheSize =  forderSizeAtPath(folderPath: orderPath)
        
        ImageCache.default.calculateDiskCacheSize { (usedDiskCacheSize) in
            print("usedDiskCacheSize is \(usedDiskCacheSize)")
            self.cache = String(format: "%.1f M", Float(NSInteger(usedDiskCacheSize)+cacheSize)/1024/1024)
            if self.moretableView != nil{
                self.moretableView.reloadData()
            }
        }
    }
    
    /// 计算缓存的订单文件的大小
    func forderSizeAtPath(folderPath:String) -> NSInteger {
        let manage = FileManager.default
        if !manage.fileExists(atPath: folderPath) {
            return 0
        }
        let childFilePath = manage.subpaths(atPath: folderPath)
        var fileSize = 0
        for path in childFilePath! {
            let fileAbsoluePath = folderPath+"/"+path
            fileSize += returnFileSize(path: fileAbsoluePath)
        }
        return NSInteger(fileSize)
    }
    
    /// 计算单个文件的大小
    func returnFileSize(path:String) -> NSInteger {
        let manager = FileManager.default
        var fileSize = 0
        do {
            let attr = try manager.attributesOfItem(atPath: path)
            fileSize = Int(attr[FileAttributeKey.size] as! UInt64)
            let dict = attr as NSDictionary
            fileSize = Int(dict.fileSize())
        } catch {
            dump(error)
        }
        return fileSize
    }
    
    /// 清除缓存
    func clearCache(indexPath:IndexPath) {
        
        let popup = PopupDialog(title: "清除缓存", message: "清除缓存会导致下载的内容删除，是否清除?",buttonAlignment: .horizontal)
        let sureBtn = DestructiveButton(title: "清除") {
            let cells = self.moretableView.cellForRow(at: indexPath as IndexPath) as! MoreCell
            
            cells.activityView.startAnimating()
            cells.contentLabel.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                cells.activityView.stopAnimating()
                cells.contentLabel.isHidden = false
                self.getCacheSize()
            })
            
            ImageCache.default.clearMemoryCache()
            ImageCache.default.clearDiskCache()
            ImageCache.default.cleanExpiredDiskCache()
            
            let fileManager = FileManager.default
            let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
            let orderPath = cachePath.appendingPathComponent("order")
            if !fileManager.fileExists(atPath: orderPath) {
                AppLog("无缓存数据？")
            }
            else {
                self.deleteFolder(path: orderPath)
            }
            
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    /// 删除文件夹
    func deleteFolder(path: String) {
        let manage = FileManager.default
        if !manage.fileExists(atPath: path) {
        }
        let childFilePath = manage.subpaths(atPath: path)
        for path_1 in childFilePath! {
            let fileAbsoluePath = path+"/"+path_1
            self.deleteFile(path: fileAbsoluePath)
        }
    }
    
    //删除单个文件
    func deleteFile(path: String) {
        let manage = FileManager.default
        do {
            try manage.removeItem(atPath: path)
        } catch {
            
        }
    }
    
    //MARK: - 网络请求
    
    //版本验证
    func LoadRenew()  {
        self.pleaseWait()
        let urlStr = APIURL.getVersion
        
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let versionModel = Mapper<VersionModel>().map(JSON: dataDic as! [String: Any])
                //获取本地软件版本号
                let infoDictionary = Bundle.main.infoDictionary
                let systemVersion: String = infoDictionary! ["CFBundleShortVersionString"] as! String
                
                if versionModel?.ischeck != 0 || versionModel?.ver == nil || versionModel?.title == nil || versionModel?.isonline == nil || versionModel?.info == nil || versionModel?.isrequired == nil || versionModel?.downloadurl == nil {
                    
                    let title = String.init(format: "当前软件版本号: v%@", systemVersion)
                    
                    let popup = PopupDialog(title: title, message: nil, buttonAlignment: .vertical)
                    let sureBtn = AlertButton(title: "确认") {
                    }
                    popup.addButtons([sureBtn])
                    self.present(popup, animated: true, completion: nil)
                    
                    return
                }
                
                AppData.isExamine = (versionModel?.ischeck)!
                AppData.isOnLine = (versionModel?.isonline)!
                
                let newVersion = versionModel?.ver ?? "1.0"
                
                AppLog("服务器版本号: \(newVersion)")
                AppLog("本地版本号: \(systemVersion)")
                
                var updata:Bool=false
                var newVersionValue = newVersion.replacingOccurrences(of: ".", with: "")
                var systemVersionValue = systemVersion.replacingOccurrences(of: ".", with: "")
                
                let newVersionCount = newVersionValue.count
                let systemVersionCount = systemVersionValue.count
                let changCount = newVersionCount - systemVersionCount
                var absolute = changCount
                
                if changCount < 0 {
                    absolute = -changCount
                }
                
                for _ in 0..<absolute {
                    
                    if changCount > 0 {
                        systemVersionValue += "0"
                    }else {
                        newVersionValue += "0"
                    }
                }
                
                let newVersionValueInt = Int(newVersionValue) ?? 10
                let systemVersionValueInt = Int(systemVersionValue) ?? 10
                if newVersionValueInt > systemVersionValueInt {
                    updata = true
                }
                
                if updata {
                    let popup = PopupDialog(title: "", message: "当前版本可以更新，是否前往更新", buttonAlignment: .horizontal)
                    let sureBtn = AlertButton(title: "立即更新") {
                        let appUrl = URL.init(string: versionModel!.downloadurl!)!
                        if UIApplication.shared.canOpenURL(appUrl) {
                            UIApplication.shared.open(appUrl, options: [:], completionHandler: nil)
                        }
                    }
                    let cancelBtn = CancelButton(title: "取消") {
                    }
                    popup.addButtons([cancelBtn, sureBtn])
                    self.present(popup, animated: true, completion: nil)
                }else{
                    let popup = PopupDialog(title: "", message: "当前版本已是最新版本！")
                    let sureBtn = AlertButton(title: "确认") {
                    }
                    popup.addButtons([sureBtn])
                    self.present(popup, animated: true, completion: nil)
                }
            }
            
        }) { (error) in
            
        }
    }
    
    
    //MARK: - UITableViewDelegate && UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
            return 3
        }else {
            if UserData.shared.workerModel?.jobType == 999 {
                return UserData.shared.userType == .jzgs ? 5 : 5
            }
            return 3
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! MoreCell
        cell.topLineView.isHidden = true
        cell.downLineView.isHidden = false
        cell.arrowView.isHidden = true
        cell.exitLabel.isHidden = true
        cell.titleLabel.isHidden = false
        cell.contentLabel.isHidden = false
        
        cell.downLineView.snp.remakeConstraints { (make) in
            make.left.equalTo(20)
            make.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        //版本号（内部标示）
        let minorVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"]
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
            if indexPath.row == 0 {
                cell.titleLabel.text = "清除缓存"
                cell.contentLabel.text = self.cache
                cell.iconView.image = UIImage.init(named: "cleanCache")
            }
            else if indexPath.row == 1 {
                cell.downLineView.isHidden = true
                cell.titleLabel.text = "软件版本"
                cell.contentLabel.text = "v\(minorVersion ?? String.self)"
                cell.iconView.image = UIImage.init(named: "versionNumber")
            } else if indexPath.row == 2 {
                cell.arrowView.isHidden = false
                cell.titleLabel.text = "帮助中心"
                cell.iconView.image = UIImage.init(named: "set_help")
                cell.contentLabel.isHidden = true
            }
            
        }else {
            
            if indexPath.row == 0 {
                cell.contentLabel.isHidden = true
                cell.arrowView.isHidden = false
                cell.titleLabel.text = "修改密码"
                cell.arrowView.image = UIImage.init(named: "arrow_right")
                cell.iconView.image = UIImage.init(named: "modifyPassword")
            }
            else if indexPath.row == 1 {
                cell.titleLabel.text = "清除缓存"
                cell.contentLabel.text = self.cache
                cell.iconView.image = UIImage.init(named: "cleanCache")
            }
            else if indexPath.row == 2 {
                cell.titleLabel.text = "软件版本"
                cell.contentLabel.text = "v\(minorVersion ?? String.self)"
                cell.iconView.image = UIImage.init(named: "versionNumber")
            }
            else if indexPath.row == 3 {
                cell.arrowView.isHidden = false
                cell.titleLabel.text = "客服热线"
                cell.iconView.image = UIImage.init(named: "service_phone")
                cell.contentLabel.text = "18773202950"
            } else if indexPath.row == 4 {
                cell.arrowView.isHidden = false
                cell.titleLabel.text = "帮助中心"
                cell.iconView.image = UIImage.init(named: "set_help")
                cell.contentLabel.isHidden = true
            } else if indexPath.row == 5 {
                
                cell.arrowView.isHidden = false
                cell.titleLabel.text = "切换身份"
                cell.iconView.image = UIImage.init(named: "switch_job")
                
                if UserData.shared.userType == .jzgs {
                    cell.contentLabel.text = "管理员"
                }else {
                    cell.contentLabel.text = "采购员"
                }
                
                cell.downLineView.snp.remakeConstraints { (make) in
                    make.bottom.left.right.equalToSuperview()
                    make.height.equalTo(1)
                }
            }
        }
  
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if UserData.shared.userType == .gys || UserData.shared.userType == .fws || UserData.shared.userType == .yys {
            
            if indexPath.row == 0 {
                clearCache(indexPath: indexPath)
            }
            else if indexPath.row == 1 {
                
                if AppData.isExamine == 1 {
                    
                    //获取本地软件版本号
                    let infoDictionary = Bundle.main.infoDictionary
                    let systemVersion: String = infoDictionary! ["CFBundleShortVersionString"] as! String
                    let title = String.init(format: "当前软件版本号: v%@", systemVersion)
                    
                    let popup = PopupDialog(title: title, message: nil, buttonAlignment: .vertical)
                    let sureBtn = AlertButton(title: "确认") {
                    }
                    popup.addButtons([sureBtn])
                    self.present(popup, animated: true, completion: nil)
                    return
                }
                
                LoadRenew()
            } else if indexPath.row == 2 {
                let vc = MyCenterHelpVC()
                navigationController?.pushViewController(vc)
            }
            
        }else {
            
            if indexPath.row == 0 {
                let vc = PasswordModifyController()
                navigationController?.pushViewController(vc, animated: true)
            }
            else if indexPath.row == 1 {
                clearCache(indexPath: indexPath)
            }
            else if indexPath.row == 2 {
                
                if AppData.isExamine == 1 {
                    
                    //获取本地软件版本号
                    let infoDictionary = Bundle.main.infoDictionary
                    let systemVersion: String = infoDictionary! ["CFBundleShortVersionString"] as! String
                    let title = String.init(format: "当前软件版本号: v%@", systemVersion)
                    
                    let popup = PopupDialog(title: title, message: nil, buttonAlignment: .vertical)
                    let sureBtn = AlertButton(title: "确认") {
                    }
                    popup.addButtons([sureBtn])
                    self.present(popup, animated: true, completion: nil)
                    return
                }
                
                LoadRenew()
            }
            else if indexPath.row == 3 {
                self.houseListCallTel(name: "客服热线", phone: "18773202950")
            }
            else if indexPath.row == 4 {
                let vc = MyCenterHelpVC()
                navigationController?.pushViewController(vc)
            } else if indexPath.row == 5 {
                let vc = UINavigationController(rootViewController: ChangeIdentityController())
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func exitAction() {
        
        let popup = PopupDialog(title: "退出登录", message: "是否确定退出当前登录账号?", buttonAlignment: .horizontal)
        let sureBtn = AlertButton(title: "确认") {
            ToolsFunc.logout()
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }

}
