//
//  NewHomeViewController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/12/4.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import ObjectMapper
import Kingfisher
import PopupDialog

class NewHomeViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, LLCycleScrollViewDelegate{
   
    var imageHeight : CGFloat =  IS_iPad ? PublicSize.PadRateHeight*373.0:PublicSize.RateHeight*230 //头视图高
    
    var tableView: UITableView!
    var rowsData: Array<PlusModel> = []
    var curPage = 1
    var unreadCount = 0
    
    var carousel:Array<CarouselModel> = []
    
    let identifier = "PlusCell"
    
    var noPlusView: UIView!
    
    lazy var cycleScrollView: LLCycleScrollView = {
        let frame = CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: imageHeight)
        let cycleView = LLCycleScrollView.llCycleScrollViewWithFrame(frame)
        cycleView.pageControlBottom = 20
        cycleView.customPageControlStyle = .snake
        cycleView.delegate = self
        cycleView.customPageControlTintColor = PublicColor.commonTextColor
        cycleView.customPageControlInActiveTintColor = .white
        cycleView.autoScrollTimeInterval = 4.0
        cycleView.coverImage = UIImage(named: "banner_icon")
        cycleView.placeHolderImage = UIImage(named: "banner_icon")
        return cycleView
    }()
    
    lazy var unreadView: UIView = {
        
        let bview = UIView.init()
        bview.isHidden = true
        bview.layer.cornerRadius = 6
        bview.clipsToBounds = true
        bview.backgroundColor = UIColor.red
        return bview
    }()
    
    ///待办
    var backlogModel: BacklogModel? {
        get {
            var model: BacklogModel? = nil
            if let response = UserDefaults.standard.object(forKey: "backlog") as? [String : AnyObject] {
                
                let localModel = Mapper<BacklogModel>().map(JSON: response)
                model = localModel
            }
            return model
        }
        set {
            
            if newValue != nil {
                if let dic = newValue?.toJSON() {
                    let localDic = DeleteEmpty.deleteEmpty(dic)!
                    UserDefaults.standard.set(localDic, forKey: "backlog")
                }else {
                    UserDefaults.standard.set("", forKey: "backlog")
                }
            }else {
                UserDefaults.standard.set("", forKey: "backlog")
            }
        }
    }
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>> 首页释放 <<<<<<<<<<<<<<")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = .white
        
        prepareTableView()
        prepareNoPlusView()
        
        //获取用户本地信息
        AppUtils.getLocalUserData()
        
//        if let valueStr = UserDefaults.standard.object(forKey: "unreadCount") as? Int {
//            unreadCount = valueStr
//            updateUnreadSign()
//        }
//
//        //推送通知
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshFirstMsg), name: Notification.Name.init("ReceiveNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUnreadData), name: Notification.Name.init("RefreshUnread"), object: nil)
    
        self.pleaseWait()
        headerRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statusStyle = .lightContent
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: 创建视图
    func prepareTableViewHeaderView() -> UIView! {
        
        let imageArray = ["home_customer", "home_purchasing", "home_worker", "home_order", "home_brand", "home_shop"]
        let titleArray = ["客户管理", "采购管理", "员工管理", "订单管理", "品牌馆", "商城"]
        
        let imageArray2 = ["home_houseCase", "home_strategy", "home_VRdesign"]
        let titleArray2 = ["风格案例", "工艺展示", "VR设计"]
        
        let w = PublicSize.screenWidth/CGFloat(3)
        let h: CGFloat = 98
        
        let haedView = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: h*2+imageHeight+55+110))
        haedView.backgroundColor = PublicColor.backgroundViewColor
        haedView.addSubview(cycleScrollView)
        
        for (i,titel) in titleArray.enumerated() {
            let btn = UIButton(type: .custom)
            btn.backgroundColor = .white
            btn.tag = 1000 + i
            btn.frame = CGRect(x:w * CGFloat(i%3), y: imageHeight + h * CGFloat(i/3), width: w, height: h)
            btn.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btn.setTitleColor(PublicColor.commonTextColor, for: .normal)
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            haedView.addSubview(btn)
            
            btn.set(image: UIImage.init(named: imageArray[i]), title: titel, imagePosition: .top, additionalSpacing: 10, state: .normal)
            
            //未读标记
            if i == 1 {
                unreadView.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
                unreadView.center = CGPoint.init(x: w/2+28, y: h/2-28)
                btn.addSubview(unreadView)
            }
        }
        
        //营销管理
        let marketView = UIView(frame: CGRect(x: 0, y: h*2+imageHeight+10, width: PublicSize.screenWidth, height: 100))
        marketView.backgroundColor = .white
        haedView.addSubview(marketView)
        
        let marketLabel = UILabel()
        marketLabel.text = "营销管理"
        marketLabel.textColor = PublicColor.commonTextColor
        marketLabel.font = UIFont.systemFont(ofSize: 15)
        marketView.addSubview(marketLabel)
        
        marketLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(15)
        }
        
        let marketLine1 = UIView()
        marketLine1.backgroundColor = PublicColor.partingLineColor
        marketView.addSubview(marketLine1)
        
        marketLine1.snp.makeConstraints { (make) in
            make.centerY.equalTo(marketLabel)
            make.right.equalTo(marketLabel.snp.left).offset(-15)
            make.height.equalTo(1)
            make.width.equalTo(40)
        }
        
        let marketLine2 = UIView()
        marketLine2.backgroundColor = PublicColor.partingLineColor
        marketView.addSubview(marketLine2)
        
        marketLine2.snp.makeConstraints { (make) in
            make.centerY.width.height.equalTo(marketLine1)
            make.left.equalTo(marketLabel.snp.right).offset(15)
        }
        
        for (i,titel) in titleArray2.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = 2000 + i
            btn.frame = CGRect(x:w * CGFloat(i), y: 30, width: w, height: 70)
            btn.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            btn.setTitleColor(PublicColor.commonTextColor, for: .normal)
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            marketView.addSubview(btn)
            
            btn.set(image: UIImage.init(named: imageArray2[i]), title: titel, imagePosition: .top, additionalSpacing: 8, state: .normal)
        }
        
        //装修套餐
        let headBottomView = UIView(frame: CGRect(x: 0, y: h*2+imageHeight+120, width: PublicSize.screenWidth, height: 45))
        headBottomView.backgroundColor = .white
        haedView.addSubview(headBottomView)
        
        let tilLabel = UILabel()
        tilLabel.text = "装修套餐"
        tilLabel.textColor = PublicColor.commonTextColor
        tilLabel.font = UIFont.systemFont(ofSize: 15)
        headBottomView.addSubview(tilLabel)
        
        tilLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        let line1 = UIView()
        line1.backgroundColor = PublicColor.partingLineColor
        headBottomView.addSubview(line1)
        
        line1.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalTo(tilLabel.snp.left).offset(-15)
            make.height.equalTo(1)
            make.width.equalTo(40)
        }
        
        let line2 = UIView()
        line2.backgroundColor = PublicColor.partingLineColor
        headBottomView.addSubview(line2)
        
        line2.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(tilLabel.snp.right).offset(15)
            make.height.equalTo(1)
            make.width.equalTo(40)
        }
        
        return haedView
    }
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 270*PublicSize.RateWidth
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PlusCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.tableHeaderView = prepareTableViewHeaderView()
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
   
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        tableView.mj_footer = footer
        tableView.mj_footer?.isHidden = true
    }
    
    func prepareNoPlusView() {
        
        noPlusView = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth-20, height: 213))
        noPlusView.backgroundColor = .white
        tableView.tableFooterView = noPlusView
        
        let imgBgView = UIView()
        imgBgView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xEDEDED)
        imgBgView.clipsToBounds = true
        imgBgView.layer.borderWidth = 0.5
        imgBgView.layer.borderColor = PublicColor.navigationLineColor.cgColor
        imgBgView.layer.cornerRadius = 5
        noPlusView.addSubview(imgBgView)
        
        imgBgView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-40)
        }
        //套餐图片
        let packageImageView = UIImageView()
        packageImageView.clipsToBounds = true
        packageImageView.contentMode = .scaleAspectFit
        packageImageView.image = UIImage.init(named: "icon_empty")
        imgBgView.addSubview(packageImageView)
        
        packageImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
            make.width.equalTo(122)
            make.height.equalTo(110)
        }
        
        //标题
        let titleLb = UILabel()
        titleLb.text = "你还未设置套餐哦~ "
        titleLb.textColor = UIColor.colorFromRGB(rgbValue: 0x333333)
        titleLb.textAlignment = .center
        titleLb.font = UIFont.boldSystemFont(ofSize: 15)
        noPlusView.addSubview(titleLb)
        
        titleLb.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-13)
            make.right.equalToSuperview().offset(-12)
        }
    }
    
    //MARK: 按钮的点击
    @objc func clickAction(_ sender:UIButton) {
        
        if sender.tag == 1000 {
            //客户管理
            let vc = MyCustomController()
            vc.title = "客户管理"
            navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == 1001{
            //采购管理
//            self.noticeOnlyText("功能升级中，敬请期待~")
            if UserData.shared.workerModel?.jobType != 999 || UserData.shared.workerModel?.jobType != 4 {
                self.noticeOnlyText("‘采购管理’仅管理员和采购员可使用")
            }else {
                let vc = UINavigationController(rootViewController: ChangeIdentityController())
                self.present(vc, animated: true, completion: nil)
            }
        }
        else if sender.tag == 1002{
            //员工管理
            if UserData.shared.workerModel?.jobType != 999 {
                self.noticeOnlyText("‘员工管理’仅管理员可使用")
                return
            }
            let vc = WorkerViewController()
            vc.title = "员工管理"
            navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == 1003 {
            //订单管理
            let vc = AllOrdersViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == 1004 {
            //品牌馆
            let vc = BrandIntroductionController()
            navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == 1005 {
            //商城
            tabBarController?.selectedIndex = 1
        }
        else if sender.tag == 2000 {
            //案例营销
            let vc = WholeHouseController()
            navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == 2001 {
            //软文营销
            let vc = DecorationRaidersController()
            navigationController?.pushViewController(vc, animated: true)
        }
        else if sender.tag == 2002 {
            //VR营销
            let vc = VRDesignController()
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        loadData()
        loadCarouselData()
        refreshUnreadData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        
        if rowsData.count > 0 {
            curPage += 1
        }
        else {
            curPage = 1
        }
        loadData()
    }
    
    //获取首条消息
    @objc func refreshFirstMsg(nofi : Notification){
        
        AppLog(">>>>>>>>>>>>>>>>>>>>> 获取首条推送消息 <<<<<<<<<<<<<<<<<<<<")
        
        if let msgType = nofi.userInfo!["msgType"] as? String{
            
            if msgType == "待办" {
                loadBacklogData()
            }else if msgType == "聊天" {
                reloadConversationList()
            }
        }
    }
    
    ///更新未读标记
    func updateUnreadSign() {
        
        if UserData.shared.workerModel?.jobType != 999 || UserData.shared.workerModel?.jobType != 4 {
            return
        }
        
        if unreadCount > 0 || backlogModel?.isNewLog == true {
            unreadView.isHidden = false
            tabBarController?.tabBar.showBadgeOnItem(index: 0, btnCount: 5)
        }else {
            unreadView.isHidden = true
            tabBarController?.tabBar.hideBadgeOnItem(index: 0)
        }
        
        if unreadCount > 0 {
            tabBarController?.tabBar.showBadgeOnItem(index: 4, btnCount: 5)
        }else {
            tabBarController?.tabBar.hideBadgeOnItem(index: 4)
        }
    }
    
    //进入前台
    @objc func refreshUnreadData() {
        reloadConversationList()
        loadBacklogData()
    }
    
    
    //MARK: - 网络请求
    
    ///加载聊天会话
    @objc func reloadConversationList() {
        
        if UserData.shared.workerModel?.jobType != 999 || UserData.shared.workerModel?.jobType != 4{
            return
        }
        
        //聊天未读数
        let unreadCount = JMSGConversation.getAllUnreadCount().intValue
        UserDefaults.standard.set(unreadCount, forKey: "unreadCount")
        
        self.unreadCount = unreadCount
        self.updateUnreadSign()
    }
    
    ///获取待办
    func loadBacklogData() {
        
        if UserData.shared.workerModel?.jobType != 999 || UserData.shared.workerModel?.jobType != 4{
            return
        }
        
        var parameters: Parameters = ["pageSize": "1","pageNum": "1"]
        
        let urlStr = APIURL.getMessageList
        if UserData.shared.userType == .gys {
            var userId = ""
            if let valueStr = UserData.shared.merchantModel?.id {
                userId = valueStr
            }
            
            parameters["comId"] = userId
            
        }else if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
            var userId = ""
            if let valueStr = UserData.shared.workerModel?.store?.id {
                userId = valueStr
            }
            parameters["comId"] = userId
            
        }else if UserData.shared.userType == .yys {
            var userId = ""
            if let valueStr = UserData.shared.substationModel?.id {
                userId = valueStr
            }
            parameters["substationId"] = userId
        }
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" || errorCode == "015" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<BacklogModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if modelArray.count <= 0 {
                    let logModel = self.backlogModel
                    logModel?.isNewLog = false
                    self.backlogModel = logModel
                }
                
                if let firstModel = modelArray.first {
                    
                    if let backlogId = self.backlogModel?.id, backlogId != firstModel.id {
                        firstModel.isNewLog = true
                        self.backlogModel = firstModel
                    }
                    
                    if self.backlogModel == nil {
                        self.backlogModel = firstModel
                    }
                }
                
                //更新未读标记
                self.updateUnreadSign()
            }
            
        }) { (error) in
            
        }
    }
    
    //请求套餐
    func loadData() {
        
//        var storeId = ""
//        
//        if let valueStr = UserData.shared.workerModel?.store?.id {
//            storeId = valueStr
//        }else {
//            self.tableView.mj_header?.endRefreshing()
//            self.tableView.mj_footer?.endRefreshing()
//            return
//        }
//        
//        AppLog("店铺id: "+storeId)
//        
//        let pageSize = 10
//        
//        let parameters: Parameters = ["store": storeId, "pageSize": "\(pageSize)", "pageNo": "\(self.curPage)"]
//        
//        let urlStr = APIURL.getMaterialsPlus
//        
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//            
//            // 结束刷新
//            self.tableView.mj_header?.endRefreshing()
//            self.tableView.mj_footer?.endRefreshing()
//            self.tableView.mj_footer?.isHidden = false
//            
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" || errorCode == "015" {
//                
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                let modelArray = Mapper<PlusModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//                
//                if self.curPage > 1 {
//                    self.rowsData += modelArray
//                }
//                else {
//                    self.rowsData = modelArray
//                }
//                
//                if modelArray.count < pageSize {
//                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
//                }else {
//                    self.tableView.mj_footer?.resetNoMoreData()
//                }
//                
//            }else if errorCode == "008" {
//                self.rowsData.removeAll()
//                self.tableView.tableFooterView = self.noPlusView
//            }
//            if self.rowsData.count <= 0 {
//                self.tableView.tableFooterView = self.noPlusView
//                self.tableView.mj_footer?.isHidden = true
//            }else {
//                self.tableView.tableFooterView = nil
//            }
//            self.tableView.reloadData()
//          
//        }) { (error) in
//            if self.rowsData.count <= 0 {
//                self.tableView.tableFooterView = self.noPlusView
//                self.tableView.mj_footer?.isHidden = true
//            }else {
//                self.tableView.tableFooterView = nil
//                self.tableView.mj_footer?.isHidden = false
//            }
//            // 结束刷新
//            self.tableView.mj_header?.endRefreshing()
//            self.tableView.mj_footer?.endRefreshing()
//        }
    }
    
    ///请求轮播
    func loadCarouselData() {
        
        var storeId = ""
        
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeId = valueStr
        }else {

            return
        }
        
        AppLog("店铺id: "+storeId)

        let parameters: Parameters = ["store.id": storeId]
        
        let urlStr = APIURL.wheelList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            var arr:Array<String> = []
            if errorCode == "000" || errorCode == "015" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<CarouselModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.carousel = modelArray
                for model in modelArray {
                    if let imgUrl = model.imgUrl {
                        
                        arr.append(APIURL.ossPicUrl + imgUrl)
                    }
                }
                
            }else if errorCode == "008" {
                self.cycleScrollView.imagePaths = []
                self.carousel = []
            }
            
//            let resultData:NSDictionary = Utils.getReadDic(data: response as AnyObject, field: "body")
//            let dic = resultData["yzbCityDetail"]
//            if dic != nil {
//                if let m = Mapper<CarouselModel>().map(JSONObject: dic) {
//                    m.title = "展厅介绍"
//                    self.carousel.insert(m, at: 0)
//                    if let img = m.img {
//                        if img != "" {
//                            arr.insert(APIURL.ossPicUrl + img, at: 0)
//                        }
//                    }
//                }
//            }
            self.cycleScrollView.imagePaths = arr
            
        }) { (error) in
            
        }
    }
    
    
    //MARK: - LLCycleScrollViewDelegate
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        
        if self.carousel.count > 0 {
            let model = self.carousel[index]
            if let idStr = model.id {
                var urlStr = APIURL.wheelDetail + idStr
                
                if model.img != nil{
                    urlStr = APIURL.wheelCityDetail + idStr
                }
                
                let vc = BrandDetailController()
                vc.title = model.title
                vc.isShare = true
                if let imgUrl = model.imgUrl {
                    vc.shareImgUrl = APIURL.ossPicUrl + imgUrl
                }else if let imgUrl = model.img {
                    vc.shareImgUrl = APIURL.ossPicUrl + imgUrl
                }
               
                vc.detailUrl = urlStr
                navigationController?.pushViewController(vc, animated: true)
            }
            AppLog(index)
        }
    }
    
    
    //MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PlusCell
        
        let model = rowsData[indexPath.row]
        cell.setModelWithTableView(model,tableView)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let plusModel = rowsData[indexPath.row]
        let image = UIImage.init(named: "plus_backImage")
        //图片尺寸处理
        let width = PublicSize.screenWidth
        let height = image!.size.height * (width / image!.size.width)
        if let picUrl = plusModel.picUrl {
            let imgUrlStr = APIURL.ossPicUrl + picUrl
            let imageUrl = URL(string: imgUrlStr)
            return XHWebImageAutoSize.imageHeight(for: imageUrl!, layoutWidth: width-20, estimateHeight: height)+40+10
        }
        return height + 40 + 10
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = PlusDetailsController()
        if let valueStr = rowsData[indexPath.row].id {
            vc.detailUrl = APIURL.getPlusDetails+valueStr
        }
        
        vc.plusModel = self.rowsData[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }

}
