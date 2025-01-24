//
//  GXTGMembersVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/10/28.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class GXTGMembersVC: BaseViewController {
    var id: String?
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "团购成员"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        
        tableView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        
        tableView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        prepareNoDateView("暂无团购成员～")
        loadData()
    }
    var current = 1
    var size = 10
    var dataSource: [GXGroupMemberModel] = []
    func loadData() {
        var parameters = Parameters()
        parameters["current"] = current
        parameters["size"] = size
        parameters["id"] = id
        YZBSign.shared.request(APIURL.groupPurchaseSignUp, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let pageModel = Mapper<PagesModel>().map(JSON: dataDic as! [String : Any])
                let models = Mapper<GXGroupMemberModel>().mapArray(JSONObject: pageModel?.records) ?? [GXGroupMemberModel]()
                if self.current == 1 {
                    self.dataSource = models
                } else {
                    self.dataSource.append(contentsOf: models)
                }
                if pageModel?.hasNextPage ?? false {
                    self.tableView.endFooterRefresh()
                } else {
                    self.tableView.endFooterRefreshNoMoreData()
                }
                self.tableView.endHeaderRefresh()
                self.noDataView.isHidden = self.dataSource.count > 0
                self.tableView.reloadData()
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
}


extension GXTGMembersVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let model = dataSource[indexPath.row]
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        let nameLabel = UILabel().text("\(model.name ?? "")").textColor(.kColor33).fontBold(14)
        let phoneLabel = UILabel().text("\(model.mobile ?? "")").textColor(.kColor66).font(12)
        let numLabel = UILabel().text("数量:\(model.purchaseNum ?? 0)").textColor(.kColor66).font(12)
        let phoneBtn = UIButton().image(#imageLiteral(resourceName: "sjs_contact"))
        v.sv(nameLabel, phoneLabel, numLabel, phoneBtn)
        v.layout(
            20,
            |-15-nameLabel.height(20)-10-phoneLabel-20-numLabel-(>=0)-phoneBtn.size(30)-15-|,
            20
        )
        phoneBtn.tapped { [weak self] (btn) in
            self?.houseListCallTel(name: "\(model.name ?? "")", phone: "\(model.mobile ?? "")")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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


class GXGroupMemberModel : NSObject, Mappable {
    var createBy : String?
    var createDate : String?
    var delFlag : String?
    var groupPurchaseId : String?
    var id : String?
    var mobile : String?
    var name : String?
    var purchaseNum : Int?
    var signUpDate : String?
    var updateBy : String?
    var updateDate : String?
    var userId : String?
    var userName : String?

    required init?(map: Map){}
    private override init(){
        super.init()
    }
    
    func mapping(map: Map)
    {
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        groupPurchaseId <- map["groupPurchaseId"]
        id <- map["id"]
        mobile <- map["mobile"]
        name <- map["name"]
        purchaseNum <- map["purchaseNum"]
        signUpDate <- map["signUpDate"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        userId <- map["userId"]
        userName <- map["userName"]
        
    }
}
