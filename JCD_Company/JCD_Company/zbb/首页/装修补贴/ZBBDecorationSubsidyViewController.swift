//
//  ZBBDecorationSubsidyViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/6.
//

import UIKit
import MJRefresh
import ObjectMapper

class ZBBDecorationSubsidyViewController: BaseViewController {

    
    private var tableView: UITableView!
    private var dataList = [ZBBSubsidyOrderListModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "装修补贴"
        createViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }
    
    
    private func createViews() {
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = true
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(ZBBDecorationSubsidyTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.loadMoreData()
        })
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
        
        let headerView = UIView()
        headerView.backgroundColor = .white
        
        let headerImageView = UIImageView(image: UIImage(named: "zbb_bt_top"))
        headerImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 256.5/375.0*SCREEN_WIDTH)
        headerImageView.clipsToBounds = true
        headerImageView.contentMode = .scaleAspectFill
        headerView.addSubview(headerImageView)
        
        let headerStepView = UIImageView(image: UIImage(named: "zbb_bt_step"))
        headerStepView.frame = CGRectMake(25.5/375.0*SCREEN_WIDTH, headerImageView.frame.maxY + 10, 324.0/375.0*SCREEN_WIDTH, 60.0/375.0*SCREEN_WIDTH)
        headerStepView.clipsToBounds = true
        headerStepView.contentMode = .scaleAspectFill
        headerView.addSubview(headerStepView)
        
        let headerLine = UIView()
        headerLine.frame = CGRectMake(25, headerStepView.frame.maxY + 16, SCREEN_WIDTH - 50, 0.5)
        headerLine.backgroundColor = .hexColor("#F0F0F0")
        headerView.addSubview(headerLine)
        
        let policyBtn = UIButton(type: .custom)
        policyBtn.frame = CGRectMake(0, headerLine.frame.maxY, SCREEN_WIDTH, 35)
        policyBtn.titleLabel?.font = .systemFont(ofSize: 11, weight: .medium)
        policyBtn.setTitle("查看补贴政策 >", for: .normal)
        policyBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        policyBtn.addTarget(self, action: #selector(policyBtnAction(_:)), for: .touchUpInside)
        headerView.addSubview(policyBtn)
        
        headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, policyBtn.frame.maxY)
        tableView.tableHeaderView = headerView
    }
    
    //MARK: - Action
    
    @objc private func policyBtnAction(_ sender: UIButton) {
        let vc = ZBBDecorationSubsidyPolicyViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func recordBtnAction(_ sender: UIButton) {
        let vc = ZBBDecorationSubsidyRecordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }


}

extension ZBBDecorationSubsidyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBDecorationSubsidyTableViewCell
        let model = dataList[indexPath.row]
        cell.model = model
        cell.applyActionClosure = {[weak self] in
            let vc = ZBBDecorationSubsidyApplyViewController()
            vc.id = model.id
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ZBBOrderDetailViewController()
        vc.orderId = dataList[indexPath.row].orderId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = UIView()
        sectionView.backgroundColor = view.backgroundColor
        
        let leftLabel = UILabel()
        leftLabel.text = "待申领订单"
        leftLabel.font = .systemFont(ofSize: 16, weight: .medium)
        leftLabel.textColor = .hexColor("#131313")
        sectionView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        let recordBtn = UIButton(type: .custom)
        recordBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        recordBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -100)
        recordBtn.titleLabel?.font = .systemFont(ofSize: 12)
        recordBtn.setTitle("申领记录", for: .normal)
        recordBtn.setTitleColor(.hexColor("#666666"), for: .normal)
        recordBtn.setImage(UIImage(named: "purchase_arrow"), for: .normal)
        recordBtn.addTarget(self, action: #selector(recordBtnAction(_:)), for: .touchUpInside)
        sectionView.addSubview(recordBtn)
        recordBtn.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(55)
        }
        
        return sectionView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        42.5
    }

}

extension ZBBDecorationSubsidyViewController {
    
    private func refreshData() {
        requestDataList(with: 1) {[weak self] list in
            self?.tableView.mj_header?.endRefreshing()
            self?.page = 1
            self?.dataList.removeAll()
            self?.dataList.append(contentsOf: list ?? [])
            self?.tableView.reloadData()
            if let list = list, list.count == 0 {
                self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
            } else {
                self?.tableView.mj_footer?.resetNoMoreData()
            }
        }
    }
    
    private func loadMoreData() {
        let page = page + 1
        requestDataList(with: page) {[weak self] list in
            self?.tableView.mj_footer?.endRefreshing()
            if let list = list {
                self?.page = page
                self?.dataList.append(contentsOf: list)
                self?.tableView.reloadData()
                if list.count == 0 {
                    self?.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
            }
        }
    }
    
    private func requestDataList(with page: Int, complete: (([ZBBSubsidyOrderListModel]?) -> Void)?) {
        var param = Parameters()
        param["status"] = 1
        param["current"] = page
        param["size"] = 20
        YZBSign.shared.request(APIURL.zbbSubsidyOrderList, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let records = data["records"] as? [[String : Any]]
                let list = Mapper<ZBBSubsidyOrderListModel>().mapArray(JSONArray: records ?? [])
                complete?(list)
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
                complete?(nil)
            }
        } failure: { error in
            complete?(nil)
        }
    }
}

class ZBBSubsidyOrderListModel: NSObject, Mappable {
    
    //id
    var id: String?
    //创建时间
    var createDate: String?
    //更新时间
    var updateDate: String?
    //分类名称
    var categoryName: String?
    //商家
    var merchantName: String?
    //订单id
    var orderId: String?
    //订单总额
    var orderAmount: Float?
    //政府补贴
    var subsidyAmount: Float?
    //产品数据
    var orderDataList: [ZBBSubsidyOrderDataModel]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        createDate <- map["createDate"]
        updateDate <- map["updateDate"]
        categoryName <- map["categoryName"]
        merchantName <- map["merchantName"]
        orderId <- map["orderId"]
        orderAmount <- map["orderAmount"]
        subsidyAmount <- map["subsidyAmount"]
        orderDataList <- map["orderDataList"]
    }
}

class ZBBSubsidyOrderDataModel: NSObject, Mappable {
    
    var brandName: String?
    var categoryAid: String?
    var categoryName: String?
    var createBy: String?
    var createDate: String?
    var cusCostMoney: Int?
    var cusMoney: Int?
    var cusMoneyRemarks: String?
    var delFlag: String?
    var fileUrls: String?
    var id: String?
    var image: String?
    var imageUrl: String?
    var isOneSell: Int?
    var isSelfSupport: Int?
    var materialsCount: String?
    var materialsId: String?
    var materialsImageUrl: String?
    var materialsMoney: Double?
    var materialsName: String?
    var materialsPriceSupply: String?
    var materialsPurMoney: Double?
    var materialsSpecification: String?
    var materialsSpecificationName: String?
    var materialsUnitType: Int?
    var materialsUnitTypeName: String?
    var merchantId: String?
    var merchantName: String?
    var moneyAll: Int?
    var moneyExpress: Int?
    var moneyInstall: Int?
    var moneyMaterials: Int?
    var moneyMaterialsCost: Int?
    var moneyMaterialsCustom: Int?
    var moneyMeasure: Int?
    var moneyOther: Int?
    var orderNo: String?
    var orderPayTime: String?
    var orderStatus: String?
    var price: Int?
    var productTypeIdentification: Int?
    var purchaseOrderId: String?
    var queryBeginTime: String?
    var queryEndTime: String?
    var remarks: String?
    var remarks2: String?
    var remarks3: String?
    var skuAttr: String?
    var skuId: String?
    var skuSnapshot: String?
    var storeId: String?
    var storeName: String?
    var subsidyAmount: Int?
    var substationId: String?
    var timeExpress: String?
    var timeInstall: String?
    var timeMeasure: String?
    var unitName: String?
    var updateBy: String?
    var updateDate: String?
    
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        brandName <- map["brandName"]
        categoryAid <- map["categoryAid"]
        categoryName <- map["categoryName"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        cusCostMoney <- map["cusCostMoney"]
        cusMoney <- map["cusMoney"]
        cusMoneyRemarks <- map["cusMoneyRemarks"]
        delFlag <- map["delFlag"]
        fileUrls <- map["fileUrls"]
        id <- map["id"]
        image <- map["image"]
        imageUrl <- map["imageUrl"]
        isOneSell <- map["isOneSell"]
        isSelfSupport <- map["isSelfSupport"]
        materialsCount <- map["materialsCount"]
        materialsId <- map["materialsId"]
        materialsImageUrl <- map["materialsImageUrl"]
        materialsMoney <- map["materialsMoney"]
        materialsName <- map["materialsName"]
        materialsPriceSupply <- map["materialsPriceSupply"]
        materialsPurMoney <- map["materialsPurMoney"]
        materialsSpecification <- map["materialsSpecification"]
        materialsSpecificationName <- map["materialsSpecificationName"]
        materialsUnitType <- map["materialsUnitType"]
        materialsUnitTypeName <- map["materialsUnitTypeName"]
        merchantId <- map["merchantId"]
        merchantName <- map["merchantName"]
        moneyAll <- map["moneyAll"]
        moneyExpress <- map["moneyExpress"]
        moneyInstall <- map["moneyInstall"]
        moneyMaterials <- map["moneyMaterials"]
        moneyMaterialsCost <- map["moneyMaterialsCost"]
        moneyMaterialsCustom <- map["moneyMaterialsCustom"]
        moneyMeasure <- map["moneyMeasure"]
        moneyOther <- map["moneyOther"]
        orderNo <- map["orderNo"]
        orderPayTime <- map["orderPayTime"]
        orderStatus <- map["orderStatus"]
        price <- map["price"]
        productTypeIdentification <- map["productTypeIdentification"]
        purchaseOrderId <- map["purchaseOrderId"]
        queryBeginTime <- map["queryBeginTime"]
        queryEndTime <- map["queryEndTime"]
        remarks <- map["remarks"]
        remarks2 <- map["remarks2"]
        remarks3 <- map["remarks3"]
        skuAttr <- map["skuAttr"]
        skuId <- map["skuId"]
        skuSnapshot <- map["skuSnapshot"]
        storeId <- map["storeId"]
        storeName <- map["storeName"]
        subsidyAmount <- map["subsidyAmount"]
        substationId <- map["substationId"]
        timeExpress <- map["timeExpress"]
        timeInstall <- map["timeInstall"]
        timeMeasure <- map["timeMeasure"]
        unitName <- map["unitName"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
    }
}
