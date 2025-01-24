//
//  GRVC.swift
//  YZB_Company
//
//  Created by Cloud on 2020/3/23.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit

//
//  JZGSVC.swift
//  YZB_Company
//
//  Created by Cloud on 2020/3/23.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Then
import Alamofire
import HandyJSON
import SwifterSwift
import Kingfisher
import MJRefresh

class GRVC: BaseViewController {
    var serviceType = 5
    private var pageNum = 1
    private var pageSize = 10
    private var roleModels: [RoleModel]? {  // 设计师
        didSet {
            tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColor.backgroundViewColor
        configTableView()
        prepareNoDateView("暂无数据~", image: #imageLiteral(resourceName: "gr_nodata_vc"))
        loadData()
    }
    // MARK: - tableView配置
    private let tableView = UITableView.init(frame: .zero, style: .plain)
    private func configTableView() {
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height-PublicSize.kNavBarHeight)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        let header = MJRefreshNormalHeader.init { [weak self] in
            self?.pageNum = 1
            self?.loadData()
        }
        let footer = MJRefreshAutoNormalFooter.init { [weak self] in
            self?.pageNum += 1
            self?.loadData()
        }
        tableView.mj_header = header
        tableView.mj_footer = footer
    }
    
    private func loadData() {
        let url = APIURL.getRoleList
        var para = [String: Any]()
        para["current"] = pageNum
        para["size"] = pageSize
        para["serviceType"] = serviceType
        para["citySubstation"] = UserData.shared.substationModel?.id
        YZBSign.shared.request(url, method: .get, parameters: para, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let roleModelList = [RoleModel].deserialize(from: dataArray as? [Any]) as? [RoleModel]
                self.tableView.mj_header?.endRefreshing()
                if self.pageNum == 1 {
                    self.roleModels = roleModelList
                } else {
                    self.roleModels?.append(contentsOf: roleModelList ?? [RoleModel]())
                }
                self.tableView.mj_footer?.endRefreshing()
            } else {
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.endRefreshing()
            }
        }) { (error) in
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
        }
    }
    
}


extension GRVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if roleModels?.count ?? 0 == 0 {
            noDataView.isHidden = false
            tableView.isHidden = true
        } else {
            noDataView.isHidden = true
            tableView.isHidden = false
        }
        return roleModels?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = GRCell()
        cell.configCell(roleModels?[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 205
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


class GRCell: UITableViewCell {
    private let viewBG = UIView()
    private let avatar = UIImageView().image(#imageLiteral(resourceName: "sjs_avatar_default"))
    private let name = UILabel().text("陈工").textColor(.kColor33).font(14)
    private let des = UILabel().text("test2020").textColor(.kColor99).font(10)
    private let chatBtn = UIButton().image(#imageLiteral(resourceName: "sjs_chat"))
    private let contactBtn = UIButton().image(#imageLiteral(resourceName: "sjs_contact"))
    private let scrollView = UIScrollView()
    private let noDataView = UIButton().image(#imageLiteral(resourceName: "sjs_nodata")).text("    暂无产品").textColor(.kColor99).font(12)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.sv(viewBG)
        contentView.layout(
            5,
            |-10-viewBG-10-|,
            5
        )
        viewBG.layer.shadowColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.16).cgColor
        viewBG.layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
        viewBG.layer.shadowOpacity = 1
        viewBG.layer.shadowRadius = 5
        viewBG.backgroundColor = .white
        viewBG.layer.cornerRadius = 10;
        
        viewBG.addSubviews([avatar, name, des, chatBtn, contactBtn, scrollView])
        avatar.snp.makeConstraints { (make) in
            make.top.left.equalTo(15)
            make.width.height.equalTo(50)
        }
        name.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(15)
            make.right.equalTo(-100)
            make.top.equalTo(avatar).offset(0)
            //make.height.equalTo(20)
        }
        name.numberOfLines(0).lineSpace(2)
        des.snp.makeConstraints { (make) in
            make.left.equalTo(name)
            make.top.equalTo(name.snp.bottom).offset(5)
            make.height.equalTo(14)
        }
        
        contactBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatar)
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(30)
        }
        
        chatBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatar)
            make.right.equalTo(contactBtn.snp.left).offset(-15)
            make.width.height.equalTo(contactBtn)
        }
        
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.bottom).offset(15)
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        scrollView.addSubview(noDataView)
        noDataView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        noDataView.isHidden = true
        contactBtn.addTarget(self, action: #selector(contactBtnClick))
        chatBtn.addTarget(self, action: #selector(chatBtnClick))
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("\(type(of: self).className) 释放了")
    }
    
    private var roleModel: RoleModel?
        func configCell(_ model: RoleModel?) {
            roleModel = model
            if let urlStr = model?.logoUrl, !urlStr.isEmpty, let url = URL.init(string: APIURL.ossPicUrl + urlStr) {
                avatar.kf.setImage(with: url)
//                avatar.kf.setImage(with: ImageResource.init(downloadURL: url))
            } else {
                _ = avatar.image(#imageLiteral(resourceName: "sjs_avatar_default"))
            }
            name.text = model?.name ?? "未知"
            des.text = model?.userName ?? "未知"
            let materialsList = model?.materialsList
            if materialsList?.count ?? 0 > 0 {
                noDataView.isHidden = true
                materialsList?.enumerated().forEach({
                            let index = $0.offset
                            let materials = $0.element
                            let w = (PublicSize.screenWidth-65)/2
                            let btn = UIImageView().backgroundColor(.kColor230)
                            scrollView.addSubview(btn)
                            btn.snp.makeConstraints { (make) in
                                make.top.equalToSuperview()
                                make.left.equalTo(15+(w+15)*CGFloat(index))
                                make.width.equalTo(w)
                                make.height.equalTo(100)
                                if index == (materialsList?.count ?? 0) - 1 {
                                    make.right.equalToSuperview().offset(-15).priorityHigh()
                                }
                            }
                    if let urlStr = materials.transformImageURL, !urlStr.isEmpty, let url = URL.init(string:APIURL.ossPicUrl + urlStr) {
//                                btn.kf.setImage(with: ImageResource.init(downloadURL: url))
                        btn.kf.setImage(with: url)
                            }
                            btn.contentMode = .scaleToFill
                })
            } else {
                noDataView.isHidden = false
            }
        }
        
        @objc private func contactBtnClick() {
            let vc = parentController as? BaseViewController
            vc?.houseListCallTel(name: roleModel?.name ?? "", phone: roleModel?.mobile ?? "")
        }
        
        @objc private func chatBtnClick() {
            contactSubstation()
        }
        
        /// 进入联系客服页面
        func contactSubstation() {
          //  let substation = UserData.shared.workerModel?.substation
            var userId = ""
            var userName = ""
            var storeName = ""
            var headUrl = ""
            var nickname = ""
            var tel1 = ""
            let tel2 = ""
            let storeType = "3"
            
    //        if let valueStr = substation?.id {
    //            userId = valueStr
    //        }
            if let valueStr = roleModel?.userName {
                userName = valueStr
            }
    //        if let valueStr = substation?.fzName {
    //            storeName = valueStr
    //        }
            if let valueStr = roleModel?.logoUrl {
                headUrl = valueStr
            }
    //        if let valueStr = substation?.realName {
    //            nickname = valueStr
    //        }
            if let valueStr = roleModel?.mobile {
                tel1 = valueStr
            }
            
            let ex: NSDictionary = ["detailTitle": storeName, "headUrl":headUrl, "tel1": tel1, "tel2": tel2, "storeType": storeType, "userId": userId]
            
            let user = JMSGUserInfo()
            user.nickname = nickname
            user.extras = ex as! [AnyHashable : Any]
            let vc = parentController as? BaseViewController
            vc?.updConsultNumRequest(id: userId)
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
                                self.parentController?.navigationController?.pushViewController(vc, animated: true)
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

