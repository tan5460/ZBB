//
//  SJSVC.swift
//  YZB_Company
//
//  Created by Mac on 20.03.2020.
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

class SJSVC: BaseViewController {
    private var sjsPageNum = 1
    private var sjgzsPageNum = 1
    private var pageSize = 10
    private var serviceType = 6
    private var roleModels: [RoleModel]? {  // 设计师
        didSet {
            tableView.reloadData()
        }
    }
    private var sjgzsRoleModels: [RoleModel]? { // 设计工作室
        didSet {
            sjgzsTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColor.backgroundViewColor
        statusStyle = .lightContent
        configTopView()
        configTableView()
        prepareNoDateView("暂无设计师", image: #imageLiteral(resourceName: "sjs_nodata_vc"))
        loadData()
        
    }
    // MARK: - 导航栏配置
    private let topView = UIView()
    private let backBtn = UIButton().image(#imageLiteral(resourceName: "back_arrow_white"))
    private let sjsBtn = UIButton().text("设计师").textColor(.white).font(18, weight: .bold).alpha(1)
    private let sjgzsBtn = UIButton().text("设计工作室").textColor(.white).font(18, weight: .bold).alpha(0.5)
    private func configTopView() {
        topView.frame = CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: PublicSize.kNavBarHeight)
        // fill
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.58, green: 0.84, blue: 0.36, alpha: 1).cgColor, UIColor(red: 0.41, green: 0.88, blue: 0.49, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = topView.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        topView.layer.addSublayer(bgGradient)
        view.addSubview(topView)
        
        backBtn.frame = CGRect(x: 0, y: PublicSize.kStatusBarHeight, width: 44, height: 44)
        sjsBtn.frame = CGRect(x: 60, y: PublicSize.kStatusBarHeight, width: (PublicSize.screenWidth-120)/2, height: 44)
        sjgzsBtn.frame = CGRect(x: 60+sjsBtn.width, y: PublicSize.kStatusBarHeight, width: sjsBtn.width, height: 44)
        topView.addSubviews([backBtn, sjsBtn, sjgzsBtn])
        
        backBtn.addTarget(self, action: #selector(backBtnClick))
        sjsBtn.addTarget(self, action: #selector(sjsBtnClick))
        sjgzsBtn.addTarget(self, action: #selector(sjgzsBtnClick))
    }
    /// 返回
    @objc func backBtnClick() {
        self.navigationController?.popViewController()
    }
    /// 切换到设计师
    @objc func sjsBtnClick() {
        sjsBtn.alpha = 1
        sjgzsBtn.alpha = 0.5
        serviceType = 6
        if roleModels?.count ?? 0 == 0 {
            loadData()
        } else {
            tableView.reloadData()
        }
        tableView.isHidden = false
        sjgzsTableView.isHidden = true
    }
    
    /// 切换到设计工作室
    @objc func sjgzsBtnClick() {
        sjsBtn.alpha = 0.5
        sjgzsBtn.alpha = 1
        serviceType = 1
        if sjgzsRoleModels?.count ?? 0 == 0 {
            loadData()
        } else {
            sjgzsTableView.reloadData()
        }
        tableView.isHidden = true
        sjgzsTableView.isHidden = false
    }
    
    // MARK: - tableView配置
    private let tableView = UITableView.init(frame: .zero, style: .plain)
    private let sjgzsTableView = UITableView.init(frame: .zero, style: .plain)
    private func configTableView() {
        tableView.frame = CGRect(x: 0, y: topView.bottom, width: topView.width, height: view.height-topView.height)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        sjgzsTableView.frame = CGRect(x: 0, y: topView.bottom, width: topView.width, height: view.height-topView.height)
        sjgzsTableView.delegate = self
        sjgzsTableView.dataSource = self
        sjgzsTableView.separatorStyle = .none
        view.addSubview(sjgzsTableView)
        sjgzsTableView.isHidden = true
        
        let header = MJRefreshNormalHeader.init { [weak self] in
            if self?.serviceType == 6 {
                self?.sjsPageNum = 1
            } else {
                self?.sjgzsPageNum = 1
            }
            self?.loadData()
        }
        let footer = MJRefreshAutoNormalFooter.init { [weak self] in
            if self?.serviceType == 6 {
                self?.sjsPageNum += 1
            } else {
                self?.sjgzsPageNum += 1
            }
            self?.loadData()
        }
        tableView.mj_header = header
        tableView.mj_footer = footer
        sjgzsTableView.mj_header = header
        sjgzsTableView.mj_footer = footer
    }
    
    private func loadData() {
        let url = APIURL.getRoleList
        var para = [String: Any]()
        if serviceType == 6 {
            para["current"] = sjsPageNum
        } else {
            para["current"] = sjgzsPageNum
        }
        para["size"] = pageSize
        para["serviceType"] = serviceType
        para["citySubstation"] = UserData.shared.substationModel?.id
        YZBSign.shared.request(url, method: .get, parameters: para, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let roleModelList = [RoleModel].deserialize(from: dataArray as? [Any]) as? [RoleModel]
                if self.serviceType == 6 {
                    self.tableView.mj_header?.endRefreshing()
                    if self.sjsPageNum == 1 {
                        self.roleModels = roleModelList
                    } else {
                        self.roleModels?.append(contentsOf: roleModelList ?? [RoleModel]())
                    }
                    self.tableView.mj_footer?.endRefreshing()
                } else {
                    self.sjgzsTableView.mj_header?.endRefreshing()
                    if self.sjgzsPageNum == 1 {
                        self.sjgzsRoleModels = roleModelList
                    } else {
                        self.sjgzsRoleModels?.append(contentsOf: roleModelList ?? [RoleModel]())
                    }
                    self.sjgzsTableView.mj_footer?.endRefreshing()
                }
            } else {
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.endRefreshing()
                self.sjgzsTableView.mj_header?.endRefreshing()
                self.sjgzsTableView.mj_footer?.endRefreshing()
                if self.serviceType == 6 {
                    self.tableView.isHidden = false
                    self.sjgzsTableView.isHidden = true
                    if self.roleModels?.count ?? 0 == 0 {
                        self.tableView.isHidden = true
                        self.noDataView.isHidden = false
                    } else {
                        self.noDataView.isHidden = true
                        self.tableView.reloadData()
                    }
                } else {
                    self.tableView.isHidden = true
                    self.sjgzsTableView.isHidden = false
                    if self.sjgzsRoleModels?.count ?? 0 == 0 {
                        self.noDataView.isHidden = false
                        self.sjgzsTableView.isHidden = true
                    } else {
                        self.noDataView.isHidden = true
                        self.sjgzsTableView.reloadData()
                    }
                }
              //  self.noDataView.isHidden = false
            }
        }) { (error) in
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.sjgzsTableView.mj_header?.endRefreshing()
            self.sjgzsTableView.mj_footer?.endRefreshing()
        }
    }
    
}


extension SJSVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if serviceType == 6 {
            if roleModels?.count ?? 0 == 0 {
                tableView.isHidden = true
                noDataView.isHidden = false
            } else {
                tableView.isHidden = false
                noDataView.isHidden = true
            }
            return roleModels?.count ?? 0
        } else {
            if sjgzsRoleModels?.count ?? 0 == 0 {
                tableView.isHidden = true
                noDataView.isHidden = false
            } else {
                tableView.isHidden = false
                noDataView.isHidden = true
            }
            return sjgzsRoleModels?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = SJSCell()
        if serviceType == 6 {
            cell.configCell(roleModels?[indexPath.row])
        } else {
            cell.configCell(sjgzsRoleModels?[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 205
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


class SJSCell: UITableViewCell {
    private let viewBG = UIView()
    private let avatar = UIImageView().image(#imageLiteral(resourceName: "sjs_avatar_default"))
    private let name = UILabel().text("谭设计").textColor(.kColor33).font(14)
    private let des = UILabel().text("test2020").textColor(.kColor99).font(10)
    private let chatBtn = UIButton().image(#imageLiteral(resourceName: "sjs_chat"))
    private let contactBtn = UIButton().image(#imageLiteral(resourceName: "sjs_contact"))
    private let scrollView = UIScrollView()
    private let noDataView = UIButton().image(#imageLiteral(resourceName: "sjs_nodata")).text("    暂无设计产品").textColor(.kColor99).font(12)
    
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
            make.right.equalToSuperview().offset(-90)
            make.top.equalTo(avatar).offset(5)
            make.height.equalTo(20)
        }
        des.snp.makeConstraints { (make) in
            make.left.equalTo(name)
            make.right.equalToSuperview().offset(-90)
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
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.addSubview(noDataView)
        noDataView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        noDataView.isHidden = true
        
        contactBtn.addTarget(self, action: #selector(contactBtnClick))
        chatBtn.addTarget(self, action: #selector(chatBtnClick))
    }
    
    private var roleModel: RoleModel?
    func configCell(_ model: RoleModel?) {
        roleModel = model
        if let urlStr = model?.logoUrl, !urlStr.isEmpty, let url = URL.init(string: APIURL.ossPicUrl + urlStr) {
            avatar.kf.setImage(with: url)
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
                        btn.layer.cornerRadius = 3
                        btn.layer.masksToBounds = true
                        if let url = materials.transformImageURL?.getUrlWithImageStr() {
                            btn.kf.setImage(with: url)
                        }
                       // btn.contentMode = .scaleToFill
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        debugPrint("\(type(of: self).className) 释放了")
    }
}

struct RoleListModel: HandyJSON {
    var list: [RoleModel]?
    var hasNextPage: Bool?
}

struct RoleModel: HandyJSON {
    // 设计师
    var name: String?
    var mobile: String?
    var materialsList: [MaterialsM]?
    var id: String?
    var userName: String?
    var logoUrl: String?
    var updateBy: NSNumber?
    var createBy: NSNumber?
    var createDate: NSNumber?
    var remarks: String?
    var isNewRecord: Bool?
    var updateDate: String?
    /// 装饰
    var storeLogo: String?
    var storeType: NSNumber?
    var citySubstation: String?
    
    var address : String?
    var appversion : AnyObject?
    var brandName : AnyObject?
    var businessScope : AnyObject?
    var businessTermEnd : AnyObject?
    var businessTermEndStr : AnyObject?
    var businessTermStart : AnyObject?
    var businessTermStartStr : AnyObject?
    var categoryaId : AnyObject?
    var certCode : AnyObject?
    var certpicUrl : AnyObject?
    var cityId : AnyObject?
    var companyType : AnyObject?
    var contacts : AnyObject?
    var contactsTel : AnyObject?
    var delFlag : AnyObject?
    var devicename : AnyObject?
    var devicesystem : AnyObject?
    var devicetype : AnyObject?
    var distId : AnyObject?
    var email : AnyObject?
    var evaluate : AnyObject?
    var evaluateScore : AnyObject?
    var groupName : AnyObject?
    var headUrl : AnyObject?
    var idCard : AnyObject?
    var idcardTermEnd : AnyObject?
    var idcardTermEndStr : AnyObject?
    var idcardTermStart : AnyObject?
    var idcardTermStartStr : AnyObject?
    var idcardpicUrlB : AnyObject?
    var idcardpicUrlF : AnyObject?
    var isActive : AnyObject?
    var isCheck : AnyObject?
    var isComFlag : AnyObject?
    var isFz : AnyObject?
    var ishide : AnyObject?
    var isshow : AnyObject?
    var lastLoginIp : AnyObject?
    var lastLoginTime : AnyObject?
    var latitude : AnyObject?
    var legalRepresentative : AnyObject?
    var longitude : AnyObject?
    var merchantNo : AnyObject?
    var merchantType : AnyObject?
    var money : AnyObject?
    var no : AnyObject?
    var password : AnyObject?
    var personal : AnyObject?
    var priceSellXs : AnyObject?
    var priceShowXs : AnyObject?
    var provId : AnyObject?
    var qq : AnyObject?
    var realName : AnyObject?
    var regIp : AnyObject?
    var registeredCapital : AnyObject?
    var relatedQualifications : AnyObject?
    var safepassword : AnyObject?
    var salesAmount : AnyObject?
    var serviceType : AnyObject?
    var servicephone : AnyObject?
    var size : AnyObject?
    var startDate : AnyObject?
    var storeId : AnyObject?
    var substationId : AnyObject?
    var tgStatus : AnyObject?
    var tgUserId : AnyObject?
    var tgUserName : AnyObject?
    var type : AnyObject?
    var vol : AnyObject?
    var wechat : AnyObject?
    var workType : AnyObject?
    var workingYears : AnyObject?
    var cityName: String?
    
}


struct BaseModel: HandyJSON {
    var code: Int?
    var data: Any?
    var msg: String?
}

struct BasePageModel: HandyJSON {
    var searchCount: Bool?
    var pages: Int?
    var orders: Any?
    var size: Int?
    var total: Int?
    var current: Int?
    var records: [Any]?
}

struct MaterialsM: HandyJSON {
    
    var id: String?                     //全部主材id
    var isNewRecord: NSNumber?          //是否新建
    var remarks: String = "无"               //备注
    var createDate: String?             //创建时间
    var updateDate: String?             //更新时间
    var name: String?                   //主材名
    var no: String?                     //主材编号
    var imageUrl: String?               //主图
    var transformImageURL: String? {    //对主图片中的异常字符进行转化
        get {
            guard let urlStr = imageUrl else { return nil }
            return urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        }
    }
    var images: String?                 //图片数组
    var status: NSNumber?               //上下架状态
    var intro: String?                  //主材简介
    var keywords: String?               //关键字数组
    var unitType: NSNumber?             //单位类型
    var unitTypeName: String?           //单位
    var count: NSNumber?                //数量
    var weight: String?                 //重量
    var price: NSNumber?                //秒杀价
    var priceShow: NSNumber?            //市场价
    var priceCustom: NSNumber?          //自定义价格(销售价)
    var cusPrice: NSNumber?             //差价
    var priceSell: NSNumber?
    var priceCost: NSNumber?            //成本价
    var beforePriceCost: NSNumber?      //片的成本价
    var priceSupply: NSNumber?          //进货价
    var beforeUnitType: NSNumber?       //单位：片
    var beforePriceSupply: NSNumber?    //片的价格
    var ishide: NSNumber?               //是否隐藏
    var materialSizetype: NSNumber?     //规格
    var url: String?                    //详情介绍网址
    var content: String?                //详情内容
    var beginPriceCustom: String?       //价格范围前
    var endPriceCustom: String?         //价格范围后
    var sort: NSNumber?                 //排序号
    var isCheck: Bool = false            //是否审核通过
    var zdyprice: NSNumber?             //自定义销售价
    var brandName: String?      //品牌名
    var merchantId: String?             //品牌id
    var type: NSNumber?                 //类型 1.平台主材，2.自建主材，3.临时主材
    var buyCount: NSNumber = 100        //购买数量
    var isOneSell: NSNumber?            //是否可单卖 1:单卖
    var capacity: NSNumber?             //几片每箱
    
    var recevingTerm: String?           //发货期限
    var installationFlag: String?       //是否提供安装服务 1不提供 2提供
    var upstairsFlag: String?           //是否上楼 1不 2上
    var allDeliverFlag: String?         //是否整箱发货 1不 2是
    var logisticsFlag: String?          //是否包含物流费 1否 2是
    var exPackagingSize: String?        //规格
    var exPackagingHigh: String?        //高
    var exPackagingLong: String?//" :   //长
    var exPackagingWide: String?        //宽
    var customizeFlag: String?          //自定义规格标记 1否 2是
    var merchant: MerchantModel?        //材料商
    var companymaterials: CompanyMaterialsModel?    //公司材料
    var categorya: CategoryModel?       //一级分类
    var categoryb: CategoryModel?       //二级分类
    var categoryc: CategoryModel?       //三级分类
    var categoryd: CategoryModel?       //四级分类
    var categorys: CategoryModel?       //订单储存的分类
    var yzbSpecification: SpecificationModel?       //主材规格
    
    var yzbMerchant: MerchantModel?        //供应商
    var materialsType: NSNumber?  // 产品： 1  服务： 2
    //自定义 备注是否展开
    var remarkIsOpen = false
    var areaRemark = ""                  //使用区域
    
    var priceSupplyMin: NSNumber?
    var priceSupplyMin1: NSNumber? {
        get {
            if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                return priceSellMin
            } else {
                return priceSupplyMin
            }
        }
    }
    var isTop: String?
    var createBy: String?
    var categorycId: String?
    var priceSellMax: NSNumber?
    var isQc: String?
    var cityId: String?
    var priceSellMin: NSNumber?
    var isTj: String?
    var attrdataId: String?
    var materialsSkuList: [MaterialsSkuListModel]?
    var priceSupplyMax: NSNumber?
    var sortNum: Int?
    var proArea: String?
    var specification: String?
    var categorybId: String?
    var categoryaId: String?
    var categorydId: String?
    var qrCode: String?
    var classificationId: String?
    var skuFlag: NSNumber?
    var updateBy: String?
    var delFlag: String?
    var upperFlag: String?
    var code: Int?
    var topFlag: String?
    var isNew: String?
    var sortNo: Int?
    
    var categoryaName: String?
    var categorybName: String?
    var categorycName: String?
    var categorydName: String?
    
    
    var worker: WorkerModel?            //员工
    var store: StoreModel?              //店铺
    var materials: MaterialsModel?      //主材
    var service: ServiceModel?          //施工
    
    
    var alertNum : Int?
    var image : String?
    var isDefault : AnyObject?
    var materialsId : String?
    var merchantName : String?
    var saleNum : Int?
    var skuAttr : String?
    var skuAttr1: String? {
        get {
            let arr = skuAttr?.getArrayByJsonString()
            var str = ""
            for dic in (arr ?? [[String: Any]]()) {
                let dic1 = dic as! [String: Any]
                let value =  dic1["skuValue"] as? String
                str.append("\(value ?? "") ")
            }
            return str
        }
    }
    var skuCode : String?
    var skuName : String?
    var stockNum : Int?
    
    var categoryAName : String?
    var materialsCount : NSNumber?
    var materialsImageUrl : String?
    var materialsName : String?
    var materialsPriceCustom : String?
    var materialsPriceSupply: String?
    var materialsPriceShow : String?
    var materialsSizeTypeName : String?
    var materialsUnitType : String?
    var materialsUnitTypeName : String?
    var orderDataId : String?
    var orderId : String?
    var skuId : String?
    /// 品牌馆
    var attrClassification : AnyObject?
    var attrDataList : AnyObject?
    var brandId : String?
    var groupName : AnyObject?
    
    var isFz : AnyObject?
    var materialsSortIsUpper : AnyObject?
    var materialsSortSortNo : AnyObject?
    var materialsSortUserId : AnyObject?
    var merchantType : String?
    
    var page : AnyObject?
    var sortType : AnyObject?
    var specName : AnyObject?
    var storeId : AnyObject?
    var substationId : AnyObject?
    var productParamAttr: String?
    
    var merchantRealName: String?
    var merchantUserName: String?
    var merchantMobile: String?
    var merchantServicephone:  String?
    var merchantAddress: String?
    var merchantHeadUrl: String?
}
