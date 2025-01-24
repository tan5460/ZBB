//
//  MyCenterHelpVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/16.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class MyCenterHelpVC: BaseViewController {
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "帮助中心"
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
        loadData()
    }
    private var current = 1
    private var pageSize = 20
    private var dataSource: [HelpCenterModel] = []
    func loadData() {
        var parameters = Parameters()
        parameters["current"] = current
        parameters["size"] = pageSize
        switch UserData.shared.userType {
        case .jzgs, .cgy:
            parameters["pushObj"] = 1
        case .gys:
            parameters["pushObj"] = 2
        case .fws:
            parameters["pushObj"] = 3
        case .yys:
            parameters["pushObj"] = 4
        }
        YZBSign.shared.request(APIURL.helpCenter, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let pageModel = Mapper<PagesModel>().map(JSONObject: dataDic)
                
                let list = Mapper<HelpCenterModel>().mapArray(JSONObject: pageModel?.records) ?? [HelpCenterModel]()
                if self.current == 1 {
                    self.dataSource = list
                } else {
                    self.dataSource.append(contentsOf: list)
                }
                self.tableView.reloadData()
                self.tableView.endHeaderRefresh()
                if pageModel?.hasNextPage ?? false {
                    self.tableView.endFooterRefresh()
                } else {
                    self.tableView.endFooterRefreshNoMoreData()
                }
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
}

extension MyCenterHelpVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = UITableViewCell()
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.textColor(.kColor33).font(14).text(model.title ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let vc = MyCenterHelpDetailVC()
//        vc.model = dataSource[indexPath.row]
        let model = dataSource[indexPath.row]
        let vc = UIBaseWebViewController()
        let urlStr = APIURL.webUrl + "/other/jcd-active-h5/#/help-center?id=\(model.id ?? "")"
        vc.urlStr = urlStr
        vc.isShare = true
        vc.title = model.title ?? ""
        navigationController?.pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 160)).backgroundColor(.kBackgroundColor)
        let bgIV = UIImageView().image(#imageLiteral(resourceName: "set_help_2"))
        let icon = UIImageView().image(#imageLiteral(resourceName: "set_help_1"))
        let lab1 = UILabel().text("常见问题 ").textColor(.white).fontBold(22)
        let lab2 = UILabel().text("快速帮你找到解决方法").textColor(.white).font(12)
        bgIV.isUserInteractionEnabled = true
        v.sv(bgIV, icon, lab1, lab2)
        v.layout(
            0,
            |bgIV.height(150)|,
            10
        )
        v.layout(
            40,
            |-14-lab1.height(31),
            10,
            |-14-lab2.height(16.5),
            >=0
        )
        v.layout(
            25,
            icon.width(110).height(88)-30-|,
            >=0
        )
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}




class HelpCenterModel : NSObject, Mappable{
    
    var belongName : String?
    var belongObj : String?
    var content : String?
    var createTime : String?
    var id : String?
    var pushFlag : Int?
    var pushObj : String?
    var sortNo : Int?
    var subTitle : String?
    var title : String?
    var type : Int?
    var updateTime : String?
    
    required init?(map: Map){
        
    }
    private override init(){
        super.init()
    }
    
    func mapping(map: Map)
    {
        belongName <- map["belongName"]
        belongObj <- map["belongObj"]
        content <- map["content"]
        createTime <- map["createTime"]
        id <- map["id"]
        pushFlag <- map["pushFlag"]
        pushObj <- map["pushObj"]
        sortNo <- map["sortNo"]
        subTitle <- map["subTitle"]
        title <- map["title"]
        type <- map["type"]
        updateTime <- map["updateTime"]
        
    }
}


class PagesModel: NSObject, Mappable{
    var current : Int?
    var orders : [AnyObject]?
    var pages : Int?
    var records : Any?
    var searchCount : Bool?
    var size : Int?
    var total : Int?
    var hasNextPage: Bool? {
        return (pages ?? 0) > (current ?? 0)
    }
    
    required init?(map: Map){}
    private override init(){
        super.init()
    }
    
    func mapping(map: Map)
    {
        current <- map["current"]
        orders <- map["orders"]
        pages <- map["pages"]
        records <- map["records"]
        searchCount <- map["searchCount"]
        size <- map["size"]
        total <- map["total"]
        
    }
}
