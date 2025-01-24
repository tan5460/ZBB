//
//  MyCenterActivityVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/6.
//

import UIKit
import ObjectMapper

class MyCenterActivityVC: BaseViewController {
    var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.white)
    private var noDataBtn = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "活动中心"
        view.backgroundColor(.white)
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
        tableView.refreshFooter {  [weak self] in
            self?.current += 1
            self?.loadData()
        }
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无活动～").textColor(.kColor66).font(14)
        tableView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
        pleaseWait()
        loadData()
    }
    private var current = 1
    private var size = 10
    private var dataSource = [MarketingActivityModel]()
    func loadData() {
        var parameters = Parameters()
        parameters["status"] = "2"
        parameters["openStatus"] = "2"
        parameters["current"] = current
        parameters["size"] = size
        YZBSign.shared.request(APIURL.jcdMarketingActivities, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let pageModel = Mapper<PagesModel>().map(JSON: dataDic as! [String : Any])
                let models = Mapper<MarketingActivityModel>().mapArray(JSONObject: pageModel?.records) ?? [MarketingActivityModel]()
                if self.current == 1 {
                    self.dataSource = models
                } else {
                    self.dataSource.append(contentsOf: models)
                }
                self.tableView.reloadData()
                if pageModel?.hasNextPage ?? false {
                    self.tableView.endFooterRefresh()
                } else {
                    self.tableView.endFooterRefreshNoMoreData()
                }
                self.tableView.endHeaderRefresh()
                self.noDataBtn.isHidden = self.dataSource.count > 0
            }
        }) { (error) in
            self.tableView.endHeaderRefresh()
            self.tableView.endFooterRefresh()
        }
    }
}

extension MyCenterActivityVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = UITableViewCell().backgroundColor(.white)
        let iv = UIImageView().image(#imageLiteral(resourceName: "home_banner_hyzx")).backgroundColor(.white)
        
        
        cell.sv(iv)
        cell.layout(
            5,
            |-14-iv.height(100)-14-|,
            5
        )
        if !iv.addImage(model.activityImg) {
            iv.image(#imageLiteral(resourceName: "home_banner_hyzx"))
        }
        iv.cornerRadius(5).masksToBounds()
        //iv.contentMode = .scaleAspectFill
        iv.addShadowColor()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        let vc = UIBaseWebViewController()
        if model.whetherCanShare == "2" {
            vc.isShare = false
        } else {
            vc.isShare = true
        }
        vc.urlStr = model.activityLink
        navigationController?.pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.white)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return PublicSize.kBottomOffset
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.white)
    }
}



class MarketingActivityModel : NSObject, Mappable {
    var whetherCanShare : String?
    var activityIconImg : String?
    var activityImg : String?
    var activityLink : String?
    var activityName : String?
    var activityNo : AnyObject?
    var cashCouponFlag : Int?
    var couponFlag : Int?
    var createBy : String?
    var createTime : String?
    var delFlag : AnyObject?
    var dividePercent : Int?
    var endTime : String?
    var id : String?
    var openStatus : Int?
    var productInFlag : Int?
    var remarks : AnyObject?
    var startTime : String?
    var status : Int?
    var updateBy : AnyObject?
    var updateTime : AnyObject?
    
    required init?(map: Map){
    }
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        whetherCanShare <- map["whetherCanShare"]
        activityIconImg <- map["activityIconImg"]
        activityImg <- map["activityImg"]
        activityLink <- map["activityLink"]
        activityName <- map["activityName"]
        activityNo <- map["activityNo"]
        cashCouponFlag <- map["cashCouponFlag"]
        couponFlag <- map["couponFlag"]
        createBy <- map["createBy"]
        createTime <- map["createTime"]
        delFlag <- map["delFlag"]
        dividePercent <- map["dividePercent"]
        endTime <- map["endTime"]
        id <- map["id"]
        openStatus <- map["openStatus"]
        productInFlag <- map["productInFlag"]
        remarks <- map["remarks"]
        startTime <- map["startTime"]
        status <- map["status"]
        updateBy <- map["updateBy"]
        updateTime <- map["updateTime"]
        
    }

}
