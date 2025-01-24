//
//  ChatUserInfoController.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/22.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

class ChatUserInfoController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    var userInfo: JMSGUser?
    
    var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "公司信息"
        prepareTableView()
        
//        if let userName = userInfo?.username {
//            
//            YZBChatRequest.shared.getUserInfo(with: userName) { (user, error) in
//                if error == nil {
//                    self.userInfo = user
//                    self.tableView.reloadData()
//                }
//            }
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //设置导航栏分割线
        let shadImage = PublicColor.navigationLineColor.image()
        navigationController?.navigationBar.shadowImage = shadImage
    }
    
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.estimatedRowHeight = 49
        tableView.backgroundColor = PublicColor.backgroundViewColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        tableView.register(ChatUserInfoCell.self, forCellReuseIdentifier: ChatUserInfoCell.self.description())
        tableView.register(NewUserInfoCell.self, forCellReuseIdentifier: NewUserInfoCell.self.description())
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    //MARK: - 按钮事件
    @objc func headerImageAction() {
        
        let headUrl = getUserHeadImg()
        if headUrl != "" {
            
            if let headUrl = URL.init(string: APIURL.ossPicUrl + headUrl) {
                let phoneVC = IMUIImageBrowserController()
                phoneVC.imageArr = [headUrl]
                phoneVC.imgCurrentIndex = 0
                phoneVC.modalPresentationStyle = .overFullScreen
                self.present(phoneVC, animated: true, completion: nil)
            }
        }else {
            self.noticeOnlyText("用户头像未上传~")
        }
    }
    
    func getUserHeadImg() -> String {
        
        var headUrl = ""
        if let exdic = userInfo?.extras {
            
            var userHead = ""
            var userName = ""
            
            switch UserData.shared.userType {
            case .jzgs, .cgy:
                if let valueStr = UserData.shared.workerModel?.userName {
                    userName = valueStr
                }
                if let valueStr = UserData.shared.workerModel?.headUrl {
                    userHead = valueStr
                }
            case .gys:
                if let valueStr = UserData.shared.merchantModel?.userName {
                    userName = valueStr
                }
                if let valueStr = UserData.shared.merchantModel?.headUrl {
                    userHead = valueStr
                }
            case .yys:
                if let valueStr = UserData.shared.substationModel?.userName {
                    userName = valueStr
                }
                if let valueStr = UserData.shared.substationModel?.headUrl {
                    userHead = valueStr
                }
            case .fws:
                if let valueStr = UserData.shared.merchantModel?.userName {
                    userName = valueStr
                }
                if let valueStr = UserData.shared.merchantModel?.headUrl {
                    userHead = valueStr
                }
            }
            
            if let valueStr = userInfo?.username {
                if userName == valueStr {
                    headUrl = userHead
                }
            }
            
            if headUrl == "" {
                if let headStr = exdic["headUrl"] as? String {
                    headUrl = headStr
                }
            }
        }
        return headUrl
    }
    
    //MARK: - UITableViewDelegate && UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if let exdic = userInfo?.extras {
            
            if let storeType = exdic["storeType"] as? String {
                if storeType == "2" {
                    return 3
                }
            }
        }
        
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            if let exdic = userInfo?.extras {
                
                if let storeType = exdic["storeType"] as? String {
                    if storeType == "1" {
                        return 2
                    }
                }
            }
            return 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 || indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatUserInfoCell.self.description()) as! ChatUserInfoCell
  
            if indexPath.section == 0 {
                cell.hiddenHeaderBtn(false)
                cell.telBtn.isHidden = true
                cell.lineView.isHidden = true
                cell.headerBtn.setImage(UIImage.init(named: "headerImage_man"), for: .normal)
                cell.headerBtn.addTarget(self, action: #selector(headerImageAction), for: .touchUpInside)
                
                cell.nameLabel.text = userInfo?.displayName()
                cell.phoneLabel.text = ""
                
                if let exdic = userInfo?.extras {
                    
                    if let detailTitle = exdic["detailTitle"] as? String {
                        cell.phoneLabel.text = detailTitle
                    }
                    
                    let headUrl = getUserHeadImg()
                    if let imageUrl = URL(string: APIURL.ossPicUrl + headUrl) {
                        cell.headerBtn.kf.setImage(with: imageUrl, for: .normal, placeholder: UIImage.init(named: "headerImage_man"))
                    }
                }
                
            }else {
                cell.telBtn.isHidden = false
                cell.hiddenHeaderBtn(true)
                cell.lineView.isHidden = false
                
                
                if indexPath.row == 0 {
                    cell.nameLabel.text = "客服电话"
                    cell.phoneLabel.text = ""
                    
                    if let exdic = userInfo?.extras {
                        
                        var tel1Str = ""
                        if let tel1 = exdic["tel1"] as? String {
                            tel1Str = tel1
                        }
                        
                        if tel1Str.isEmpty {
                            if let tel2 = exdic["tel2"] as? String {
                                tel1Str = tel2
                            }
                        }
                        cell.phoneLabel.text = tel1Str
                        //打电话
                        cell.callPhoneBlock = { [weak self] in
                            
                            var name = "姓名未填"
                            if let valueStr = self?.userInfo?.displayName() {
                                name = valueStr
                            }
                            
                            self?.houseListCallTel(name: name, phone: tel1Str)
                        }
                    }
                }else {
                    cell.nameLabel.text = "订单联系电话"
                    cell.phoneLabel.text = ""
                    
                    if let exdic = userInfo?.extras {
                        
                        var tel2Str = ""
                        if let tel2 = exdic["tel2"] as? String {
                            tel2Str = tel2
                        }
                        
                        cell.phoneLabel.text = tel2Str
                        //打电话
                        cell.callPhoneBlock = { [weak self] in
                            
                            var name = "姓名未填"
                            if let valueStr = self?.userInfo?.displayName() {
                                name = valueStr
                            }
                            
                            self?.houseListCallTel(name: name, phone: tel2Str)
                        }
                    }
                }
            }
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: NewUserInfoCell.self.description()) as! NewUserInfoCell
        
        cell.line.isHidden = true
   
        cell.leftLabel?.text = "公司资质"
        cell.rightLabel?.text = ""
        
        return cell
    }
  
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 2 {
            return 0.0
        }
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            
            var comId = ""
            if let exdic = userInfo?.extras {
                if let valueStr = exdic["userId"] as? String {
                    comId = valueStr
                }
            }
            loadData1(comId: comId)
//            let vc = ShopQualificationController()
//            vc.comId = comId
//            navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    //提现记录
    func loadData1(comId: String) {
        
        self.pleaseWait()
        
        let parameters: Parameters = ["id": comId]
        let urlStr = APIURL.getMerchantInfo + comId
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                var urlStr = Utils.getReadString(dir: response as NSDictionary, field: "data")
                urlStr = APIURL.ossPicUrl + urlStr
                let vc = AgreementViewController()
                vc.urlStr = urlStr
                vc.type = .qualifications
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }) { (error) in
            
        }
    }

   
}
