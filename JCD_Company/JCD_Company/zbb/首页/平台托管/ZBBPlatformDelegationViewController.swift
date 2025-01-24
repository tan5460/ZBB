//
//  ZBBPlatformDelegationViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/27.
//

import UIKit
import JXSegmentedView
import MJRefresh
import ObjectMapper

class ZBBPlatformDelegationViewController: BaseViewController {

    private var segmentDataSource: JXSegmentedTitleDataSource!
    private var segmentView: JXSegmentedView!
    private var tableView: UITableView!
    
    private var dataList = [ZBBPlatformDelegationOrderModel]()
    private var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "平台托管"
        createViews()
        refreshData()
    }
    
    private func createViews() {
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        indicator.indicatorHeight = 3
        indicator.indicatorCornerRadius = 1.5
        indicator.verticalOffset = 6
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 1.5
        gradientLayer.masksToBounds = true
        gradientLayer.frame = CGRectMake(0, 0, 20, 3)
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 0)
        gradientLayer.colors = [UIColor.hexColor("#47DC94").cgColor, UIColor.hexColor("#007E41").cgColor]
        indicator.layer.addSublayer(gradientLayer)
        
        segmentDataSource = JXSegmentedTitleDataSource()
        segmentDataSource.titles = ["待签约", "托管中", "已完成", "已终止", "申述中"]
        segmentDataSource.titleNormalFont = .systemFont(ofSize: 14)
        segmentDataSource.titleNormalColor = .hexColor("#999999")
        segmentDataSource.titleSelectedFont = .systemFont(ofSize: 14, weight: .bold)
        segmentDataSource.titleSelectedColor = .hexColor("#131313")
        segmentDataSource.isTitleColorGradientEnabled = true
        
        segmentView = JXSegmentedView()
        segmentView.backgroundColor = .white
        segmentView.delegate = self
        segmentView.dataSource = segmentDataSource
        segmentView.contentEdgeInsetLeft = 15
        segmentView.contentEdgeInsetRight = 15
        segmentView.indicators = [indicator]
        view.addSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .hexColor("#F7F7F7")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(ZBBPlatformDelegationCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.right.bottom.equalTo(0)
        }
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {[weak self] in
            self?.loadMoreData()
        })
        
    }

}

extension ZBBPlatformDelegationViewController : JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        segmentedView.selectedIndex != index
    }
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        tableView.mj_header?.beginRefreshing()
    }
    
}

extension ZBBPlatformDelegationViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBPlatformDelegationCell
        cell.model = dataList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ZBBDelegationOrderViewController()
        vc.id = dataList[indexPath.row].id
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ZBBPlatformDelegationViewController {
    
    private func refreshData() {
        requestOrderCount()
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
    
    private func requestOrderCount() {
        YZBSign.shared.request(APIURL.zbbOrderStatusCount, method: .get) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let list = Utils.getReqArr(data: response as AnyObject)
                var titleList = ["待签约", "托管中", "已完成", "已终止", "申述中"]
                list.forEach { item in
                    if let dict = item as? [String : Any], let orderStatus = dict["orderStatus"] as? String, let index = orderStatus.int, let orderNum = dict["orderNum"] as? Int {
                        if orderNum > 0 {
                            if index > 0 && index <= 5 {
                                let title = titleList[index - 1]
                                titleList[index - 1] = title + "(\(orderNum))"
                            }
                        }
                    }
                }
                self?.segmentDataSource.titles = titleList
                self?.segmentView.reloadData()
            }
        } failure: { error in
            
        }

    }
    
    private func requestDataList(with page: Int, complete: (([ZBBPlatformDelegationOrderModel]?) -> Void)?) {
        var param = Parameters()
        param["userId"] = UserData1.shared.tokenModel?.userId
        param["orderStatus"] = segmentView.selectedIndex + 1
        param["current"] = page
        param["size"] = 20
        YZBSign.shared.request(APIURL.zbbOrderList, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let records = data["records"] as? [[String : Any]]
                let list = Mapper<ZBBPlatformDelegationOrderModel>().mapArray(JSONArray: records ?? [])
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

class ZBBPlatformDelegationOrderModel: NSObject, Mappable {
    //订单状态 1.待签约 2.托管中 3.已完成 4.已终止 5.申诉中
    var orderStatus: String?
    //申诉原因/终止原因
    var appealReason: String?
    //楼栋房号
    var buildNo: String?
    //业务类型 1.半包 2.全包
    var businessType: String?
    //城市id
    var cityId: String?
    //城市名称
    var cityName: String?
    //小区名字
    var communityName: String?
    //完成时间
    var completeTime: String?
    //合同金额
    var contractAmount: Int?
    //装修合同
    var contractFileUrl: String?
    //创建者
    var createBy: String?
    //创建时间
    var createDate: String?
    //当前节点
    var currentNode: Int?
    //客户id
    var customerId: String?
    //客户姓名
    var customerName: String?
    //删除标记
    var delFlag: String?
    //房屋地址
    var houseAddress: String?
    //订单id
    var id: String?
    //订单号
    var orderNo: String?
    //手机号
    var phoneNumber: String?
    //省份id
    var provId: String?
    //省份名称
    var provName: String?
    //可退金额
    var refundableAmount: Int?
    //地区id
    var regionId: String?
    //地区名称
    var regionName: String?
    //质保金缴纳比例
    var retentionMoneyRatio: Int?
    //服务商
    var serviceMerchantName: String?
    //分站id
    var substationId: String?
    //总增项费用
    var totalAdditionalAmount: Int?
    //总费用
    var totalAmount: Int?
    //更新者
    var updateBy: String?
    //更新时间
    var updateDate: String?
    ///订单节点信息
    var orderNodes: [ZBBPlatformDelegationOrderNodeModel]?
    ///支付记录
    var payRecords: [ZBBPlatformDelegationPayRecordModel]?
    
    override init() {
        super.init()
    }
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        orderStatus <- map["orderStatus"]
        appealReason <- map["appealReason"]
        buildNo <- map["buildNo"]
        businessType <- map["businessType"]
        cityId <- map["cityId"]
        cityName <- map["cityName"]
        communityName <- map["communityName"]
        completeTime <- map["completeTime"]
        contractAmount <- map["contractAmount"]
        contractFileUrl <- map["contractFileUrl"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        currentNode <- map["currentNode"]
        customerId <- map["customerId"]
        customerName <- map["customerName"]
        delFlag <- map["delFlag"]
        houseAddress <- map["houseAddress"]
        id <- map["id"]
        orderNo <- map["orderNo"]
        phoneNumber <- map["phoneNumber"]
        provId <- map["provId"]
        provName <- map["provName"]
        refundableAmount <- map["refundableAmount"]
        regionId <- map["regionId"]
        regionName <- map["regionName"]
        retentionMoneyRatio <- map["retentionMoneyRatio"]
        serviceMerchantName <- map["serviceMerchantName"]
        substationId <- map["substationId"]
        totalAdditionalAmount <- map["totalAdditionalAmount"]
        totalAmount <- map["totalAmount"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        orderNodes <- map["orderNodes"]
        payRecords <- map["payRecords"]
    }
}

class ZBBPlatformDelegationPayRecordModel: NSObject, Mappable {
    //
    var nodeId: Int?
    //节点名称
    var nodeName: String?
    //结算状态 0.待结算 1.已结算 2.已退款
    var settlementStatus: String?
    //交易金额
    var transactionAmount: Int?
    // 交易号，流水号
    var transactionId: String?
    //交易时间
    var transactionTime: String?
    //分佣记录
    var commissionRecordDTO: ZBBPlatformDelegationPayRecordDTOModel?
    
    override init() {
        super.init()
    }
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        nodeId <- map["nodeId"]
        nodeName <- map["nodeName"]
        settlementStatus <- map["settlementStatus"]
        transactionAmount <- map["transactionAmount"]
        transactionId <- map["transactionId"]
        transactionTime <- map["transactionTime"]
        commissionRecordDTO <- map["commissionRecordDTO"]
    }
}

class ZBBPlatformDelegationPayRecordDTOModel: NSObject, Mappable {
    //手续费
    var amountFee: Int?
    //客户已退
    var customerRefund: Int?
    //服务商收入
    var gysMoney: Int?
    //平台收入
    var managerMoney: Int?
    
    override init() {
        super.init()
    }
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        amountFee <- map["amountFee"]
        customerRefund <- map["customerRefund"]
        gysMoney <- map["gysMoney"]
        managerMoney <- map["managerMoney"]
    }
}

class ZBBPlatformDelegationOrderNodeModel: NSObject, Mappable {
    //
    var nodeId: Int?
    //ID
    var id: String?
    //删除标记
    var delFlag: String?
    //创建者
    var createBy: String?
    //创建时间
    var createDate: String?
    //更新者
    var updateBy: String?
    //更新时间
    var updateDate: String?
    
    //工程节点
    var nodeName: String?
    //节点状态，1.待开始 2.待支付 3.待完工 4.待验收 5.待整改 6.已完成
    var nodeStatus: String?
    
    //完工照片
    var finishPicture: String?
    //完工时间
    var finishTime: String?
    //整改照片
    var repairPicture: String?
    //整改时间
    var repairTime: String?
    //验收照片
    var acceptancePicture: String?
    //验收时间
    var acceptanceTime: String?
    
    
    //节点金额
    var nodeAmount: Int?
    //节点小计
    var totalAmount: Int?
    //节点附件
    var nodeFileUrl: String?
    //增项费用
    var additionalAmount: Int?
    //增项备注
    var additionalRemarks: String?
    //付款比例（%）
    var nodeRatio: Int?
    
    //应扣除质保金
    var deductRetentionMoney: Int?
    
    //订单id
    var orderId: String?
    //已付金额
    var paidAmount: Int?
    //付款时间
    var paymentTime: String?
    
    
    override init() {
        super.init()
    }
    
    required init?(map: ObjectMapper.Map) {
        
    }
    
    func mapping(map: ObjectMapper.Map) {
        nodeId <- map["nodeId"]
        id <- map["id"]
        delFlag <- map["delFlag"]
        createBy <- map["createBy"]
        createDate <- map["createDate"]
        updateBy <- map["updateBy"]
        updateDate <- map["updateDate"]
        
        nodeName <- map["nodeName"]
        nodeStatus <- map["nodeStatus"]
        
        finishPicture <- map["finishPicture"]
        finishTime <- map["finishTime"]
        repairPicture <- map["repairPicture"]
        repairTime <- map["repairTime"]
        acceptancePicture <- map["acceptancePicture"]
        acceptanceTime <- map["acceptanceTime"]
        
        nodeAmount <- map["nodeAmount"]
        totalAmount <- map["totalAmount"]
        nodeFileUrl <- map["nodeFileUrl"]
        additionalAmount <- map["additionalAmount"]
        additionalRemarks <- map["additionalRemarks"]
        nodeRatio <- map["nodeRatio"]
        
        deductRetentionMoney <- map["deductRetentionMoney"]
        
        orderId <- map["orderId"]

        paidAmount <- map["paidAmount"]
        paymentTime <- map["paymentTime"]
    }
}


