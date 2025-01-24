//
//  MyMoneyBagSYMXVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/20.
//

import UIKit
import ObjectMapper

class MyMoneyBagSYMXVC: BaseViewController {

    private var noDataBtn = UIButton()
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "收益明细"
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
        noDataBtn.image(#imageLiteral(resourceName: "gx_th_nodata")).text("暂无记录～").textColor(.kColor66).font(14)
        tableView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
    }

    private var size = 15
    private var current = 1
    private var dataSource: [SYMXModel] = []
    func loadData() {
        var parameters = Parameters()
        parameters["current"] = current
        parameters["size"] = size
        YZBSign.shared.request(APIURL.jcdUserIncome, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let pageModel = Mapper<PagesModel>().map(JSON: dataDic as! [String : Any])
                let models = Mapper<SYMXModel>().mapArray(JSONObject: pageModel?.records) ?? [SYMXModel]()
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
                self.tableView.reloadData()
                self.noDataBtn.isHidden = self.dataSource.count > 0
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
}

extension MyMoneyBagSYMXVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let model = dataSource[indexPath.row]
        if indexPath.row % 2 == 0 {
            cell.backgroundColor(.white)
        } else {
            cell.backgroundColor(.kF7F7F7)
        }
        let width1: CGFloat = 100/375*(view.width)
        let width2: CGFloat = 50/375*(view.width)
        let width3: CGFloat = 100/375*(view.width)
        let width4: CGFloat = 50/375*(view.width)
        let width5: CGFloat = 75/375*(view.width)
        
        let lab1 = UILabel().text("\(model.updateTime ?? "")").textColor(.kColor33).font(12).textAligment(.center)
        let lab2 = UILabel().text("推广").textColor(.kColor33).font(12).textAligment(.center)
        let lab3 = UILabel().text("\(model.content ?? "")").textColor(.kColor33).font(12).textAligment(.center)
        
        var status = "未结算"
        // 1:未结算 2:已结算
        if model.status == "2" {
            status = "已结算"
        }
        
        let lab4 = UILabel().text("\(status)").textColor(.kColor33).font(12).textAligment(.center)
        let lab5 = UILabel().text("¥\(model.estimatedIncome?.doubleValue ?? 0.00)").textColor(.kColor33).font(12).textAligment(.center)
        
        cell.sv(lab1, lab2, lab3, lab4, lab5)
        cell.layout(
            0,
            |lab1.height(40)-0-lab2-0-lab3-0-lab4-0-lab5|,
            0
        )
        lab1.width(width1)
        lab2.width(width2)
        lab3.width(width3)
        lab4.width(width4)
        lab5.width(width5)
        lab1.numberOfLines(2).lineSpace(2)
        lab1.textAligment(.center)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 76
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 76))
        let v1 = UIView().backgroundColor(UIColor.hexColor("#FFEBD7"))
        let v2 = UIView().backgroundColor(UIColor.hexColor("#F7F7F7"))
        v.sv(v1, v2)
        v.layout(
            0,
            |v1.height(36)|,
            0,
            |v2.height(40)|,
            0
        )
        
        let lab = UILabel().text("可用金额只统计已结算状态的预计收益金额").textColor(.kColor66).font(12)
        v1.sv(lab)
        lab.centerInContainer()
        
        let width1: CGFloat = 100/375*(view.width)
        let width2: CGFloat = 50/375*(view.width)
        let width3: CGFloat = 100/375*(view.width)
        let width4: CGFloat = 50/375*(view.width)
        let width5: CGFloat = 75/375*(view.width)
        
        let lab1 = UILabel().text("日期").textColor(.kColor33).font(12).textAligment(.center)
        let lab2 = UILabel().text("类型").textColor(.kColor33).font(12).textAligment(.center)
        let lab3 = UILabel().text("备注").textColor(.kColor33).font(12).textAligment(.center)
        let lab4 = UILabel().text("状态").textColor(.kColor33).font(12).textAligment(.center)
        let lab5 = UILabel().text("预计收益").textColor(.kColor33).font(12).textAligment(.center)
        
        v2.sv(lab1, lab2, lab3, lab4, lab5)
        v2.layout(
            0,
            |lab1-0-lab2-0-lab3-0-lab4-0-lab5|,
            0
        )
        lab1.width(width1)
        lab2.width(width2)
        lab3.width(width3)
        lab4.width(width4)
        lab5.width(width5)
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PublicSize.kBottomOffset
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


class SYMXModel : NSObject, Mappable{

    var content : String?
    var createTime : String?
    var estimatedIncome : NSNumber?
    var id : String?
    var invitedId : String?
    var remarks : String?
    var status : String? // 1:未结算 2:已结算
    var type : String?
    var updateTime : String?
    var userId : String?

    required init?(map: Map){}
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        content <- map["content"]
        createTime <- map["createTime"]
        estimatedIncome <- map["estimatedIncome"]
        id <- map["id"]
        invitedId <- map["invitedId"]
        remarks <- map["remarks"]
        status <- map["status"]
        type <- map["type"]
        updateTime <- map["updateTime"]
        userId <- map["userId"]
    }

}
