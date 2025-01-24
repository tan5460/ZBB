//
//  CompanyMembersVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/12.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class CompanyMembersVC: BaseViewController {
    var storeId: String?
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    private var noDataBtn = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "团队成员"
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
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无数据～").textColor(.kColor66).font(14)
        tableView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
        loadData()
    }
    private var current = 1
    private var size = 10
    private var dataSource: [RegisterModel] = []
    func loadData() {
        var parameters = Parameters()
        parameters["storeId"] = storeId
        parameters["current"] = current
        parameters["size"] = size
        YZBSign.shared.request(APIURL.getComWorkers, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let models = Mapper<RegisterModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current == 1 {
                    self.dataSource = models
                } else {
                    self.dataSource.append(contentsOf: models)
                }
                if models.count < self.size {
                    self.tableView.endFooterRefreshNoMoreData()
                } else {
                    self.tableView.endFooterRefresh()
                }
                self.tableView.reloadData()
                self.noDataBtn.isHidden = self.dataSource.count > 0
            }
            self.tableView.endHeaderRefresh()
            
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
    
}

extension CompanyMembersVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = UITableViewCell().backgroundColor(.kBackgroundColor)
        
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            v.width(view.width-28).height(80).centerHorizontally(),
            5
        )
        v.cornerRadius(5)
        
        let icon = UIImageView().image(#imageLiteral(resourceName: "loading")).cornerRadius(30)
        if !icon.addImage(model.headUrl) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        
        let name = UILabel().text(model.realName ?? "").textColor(.kColor33).fontBold(14)
        var job = ""
        switch model.jobType {
        case 1:
            job = "工长"
        case 2:
            job = "客户经理"
        case 3:
            job = "设计师"
        case 4:
            job = "采购员"
        case 999:
            job = "管理员"
        default:
            break
        }
        let detail1 = UILabel().text(job).textColor(.kColor66).font(12)
        let detail2 = UILabel().text("从业经验\(model.workingYear ?? "0")年").textColor(.kColor66).font(12)
        v.sv(icon, name, detail1, detail2)
        v.layout(
            10,
            |-15-icon.size(60),
            10
        )
        v.layout(
            15,
            |-90-name.height(20),
            13.5,
            |-90-detail1.height(16.5)-20-detail2,
            15
        )
        icon.contentMode = .scaleAspectFit
        icon.masksToBounds()
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
        return PublicSize.kBottomOffset + 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

