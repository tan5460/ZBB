//
//  SubstationController.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/19.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class SubstationController: BaseViewController ,UITableViewDelegate,UITableViewDataSource {
    
    var tableView : UITableView!

    var substation: SubstationModel?             //分站Model
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "城市分站"
        prepareTableView()
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = PublicColor.backgroundViewColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        tableView.estimatedRowHeight = 50
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        tableView.register(NewUserInfoCell.self, forCellReuseIdentifier: NewUserInfoCell.self.description())
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    //MARK: - UITableViewDelegate && UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserData.shared.userType == .jzgs {
            return 4
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: NewUserInfoCell.self.description()) as! NewUserInfoCell
        
        cell.selectionStyle = .gray
        cell.line.isHidden = false
        if indexPath.row == 0 {
            cell.selectionStyle = .none
            cell.arrowImgView.isHidden = true
            cell.leftLabel?.text = "分站名称"
            cell.rightLabel?.text = substation?.fzName ?? ""
        }else if indexPath.row == 1 {
            cell.selectionStyle = .none
            cell.arrowImgView.isHidden = true
            cell.leftLabel?.text = "分站位置"
            cell.rightLabel?.text = (substation?.cityName ?? "") + (substation?.distName ?? "")
        }else if indexPath.row == 2 {
            cell.arrowImgView.isHidden = false
            cell.leftLabel?.text = "分站电话"
            cell.rightLabel?.text = substation?.mobile ?? ""
        }else if indexPath.row == 3 {
            cell.arrowImgView.isHidden = false
            cell.leftLabel?.text = "分站介绍"
            cell.rightLabel?.text = substation?.intro ?? ""
        }else if indexPath.row == 4 {
            cell.arrowImgView.isHidden = false
            cell.leftLabel?.text = "联系客服"
            cell.rightLabel?.text = ""
            cell.line.isHidden = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
           
        }else if indexPath.row == 1 {
            
        }else if indexPath.row == 2 {
            
            var name = ""
            if let valueStr = substation?.fzName {
                name = valueStr
            }
            
            var phone = ""
            if let valueStr = substation?.mobile {
                phone = valueStr
            }
            houseListCallTel(name: name, phone: phone)
            
        }else if indexPath.row == 3 {
            
            var urlStr = ""
            if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
                if let valueStr = UserData.shared.workerModel?.substation?.id {
                    urlStr = APIURL.wheelCityDetail + valueStr
                }
            }else if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
                if let valueStr = UserData.shared.merchantModel?.substation?.id {
                    urlStr = APIURL.wheelCityDetail + valueStr
                }
            }
            
            let vc = BrandDetailController()
            vc.title = "分站介绍"
            vc.detailUrl = urlStr
            navigationController?.pushViewController(vc, animated: true)
            
        }else if indexPath.row == 4 {
            contactSubstation()
        }
    }
    
    func contactSubstation() {
        
        var userId = ""
        var userName = ""
        var storeName = ""
        var headUrl = ""
        var nickname = ""
        var tel1 = ""
        let tel2 = ""
        let storeType = "3"
        
        if let valueStr = substation?.id {
            userId = valueStr
        }
        if let valueStr = substation?.userName {
            userName = valueStr
        }
        if let valueStr = substation?.fzName {
            storeName = valueStr
        }
        if let valueStr = substation?.headUrl {
            headUrl = valueStr
        }
        if let valueStr = substation?.realName {
            nickname = valueStr
        }
        if let valueStr = substation?.mobile {
            tel1 = valueStr
        }
        
        let ex: NSDictionary = ["detailTitle": storeName, "headUrl":headUrl, "tel1": tel1, "tel2": tel2, "storeType": storeType, "userId": userId]
        
        let user = JMSGUserInfo()
        user.nickname = nickname
        user.extras = ex as! [AnyHashable : Any]
        updConsultNumRequest(id: userId)
        YZBChatRequest.shared.createSingleMessageConversation(username: userName) { (conversation, error) in
            if error == nil {
                
                if let userInfo = conversation?.target as? JMSGUser {
                    
                    let userName = userInfo.username
                    self.pleaseWait()
                    
                    YZBChatRequest.shared.getUserInfo(with: userName) { (user, error) in
                        
                        self.clearAllNotice()
                        if error == nil {
                            let vc = ChatMessageController(conversation: conversation!)
                            vc.convenUser = user
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
                
            }else {
                if error!._code == 898002 {
                    
                    YZBChatRequest.shared.register(with: userName, pwd: YZBSign.shared.passwordMd5(password: userName), userInfo: user, errorBlock: { (error) in
                        if error == nil {
                            self.contactSubstation()
                        }
                    })
                }
            }
        }
    }

}
