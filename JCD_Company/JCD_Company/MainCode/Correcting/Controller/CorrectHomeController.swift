//
//  CorrectHomeController.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import ObjectMapper
import Kingfisher
import PopupDialog
import Stevia
import Then
class CorrectHomeController: BaseViewController, UITableViewDelegate, UITableViewDataSource, LLCycleScrollViewDelegate{
    
    var imageHeight : CGFloat =  IS_iPad ? PublicSize.PadRateHeight*373.0 :PublicSize.RateWidth*170 //头视图高
    
    var tableView: UITableView!
    
    var secoudView: CorrectHomeHeadView?
    
    let identifier = "PlusCell"
    
    
    private var viewModel: CorrectHomeViewModel!
    
    lazy var cycleScrollView: LLCycleScrollView = {
        let frame = CGRect(x: 14, y: 68, width: PublicSize.screenWidth-28, height: imageHeight)
        let cycleView = LLCycleScrollView.llCycleScrollViewWithFrame(frame)
        cycleView.pageControlBottom = 13
        cycleView.customPageControlStyle = .pill
        cycleView.delegate = self
        cycleView.customPageControlTintColor = #colorLiteral(red: 0.3607843137, green: 0.862745098, blue: 0.6862745098, alpha: 1)
        cycleView.customPageControlInActiveTintColor = .white
        cycleView.autoScrollTimeInterval = 4.0
        cycleView.coverImage = UIImage(named: "banner_icon")
        cycleView.placeHolderImage = UIImage(named: "banner_icon")
        return cycleView
    }()
    
  
    deinit {
        AppLog(">>>>>>>>>>>>>>>> 首页释放 <<<<<<<<<<<<<<")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = .white
        
        viewModel = CorrectHomeViewModel()
        viewModel.delegate = self
        
        prepareTableView()
        
        //获取用户本地信息
        AppUtils.getLocalUserData()
        
        self.pleaseWait()
        headerRefresh()
        
       // configShareAdView()
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
    
    
    /// 会员立即邀请分享
    func configShareAdView() {
        let v = ShareAdInviateView.init(frame: CGRect(x: 0, y: 0, width: 301.5, height: 330)).backgroundColor(.clear)
    }
    
    //MARK: 创建视图
    func prepareTableViewHeaderView() -> UIView! {

        let imageArray = ["home_brand", "home_sjs", "home_gr", "home_ccwl", "home_zsgs", "home_order", "home_customer", "home_gdgl", "icon_case", "icon_vr", "home_gxgl", "home_bxjr"]
        let titleArray = ["品牌馆", "设计师", "工人", "仓储物流", "装饰公司", "订单管理", "客户管理", "工地管理", "示范案例", "VR设计", "供需市场", "保险金融"]

        let w = (PublicSize.screenWidth)/CGFloat(4)
        let h: CGFloat = 615

        let headView = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: h+imageHeight))
        headView.backgroundColor = .white
        
        
        let headTopIV = UIImageView().image(#imageLiteral(resourceName: "home_top_bg"))
        headTopIV.frame = CGRect(x: 0, y: 0, width: PublicSize.kScreenWidth, height: 156.5)
        headView.addSubview(headTopIV)
        headView.addSubview(cycleScrollView)
        let btnBG = UIView(frame: CGRect(x: 0, y: cycleScrollView.bottom+16.5, width: PublicSize.kScreenWidth, height: 225))
        headView.addSubview(btnBG)

        titleArray.enumerated().forEach { (i, title) in
            let btn = UIButton(type: .custom)
            btn.tag = i
            btn.frame = CGRect(x:w * CGFloat(i%4), y: CGFloat(81*(i/4)), width: w, height: 75)
            btn.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
            btn.setTitle(titleArray[i], for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            btn.setTitleColor(.kColor33, for: .normal)
            btn.setImage(UIImage.init(named: imageArray[i]), for: .normal)
            btnBG.addSubview(btn)
            btn.layoutButton(imageTitleSpace: 4)
        }
        
        let localSJSBtn = UIButton().image(#imageLiteral(resourceName: "home_local_sjs"))
        let localLab1 = UILabel().text("本地设计师").textColor(.kColor33).font(14)
        let localLab2 = UILabel().text("点击查看").textColor(.white).font(10).backgroundColor(.k2FD4A7).cornerRadius(10).masksToBounds()
        localSJSBtn.frame = CGRect(x: 0, y: btnBG.bottom+15, width: (view.width/2), height: 105)
        headView.addSubview(localSJSBtn)
        localLab1.frame = CGRect(x: 30, y: 18, width: 100, height: 14)
        localLab2.frame = CGRect(x: 30, y: localLab1.bottom+7.5, width: 54, height: 20)
        localLab2.textAligment(.center)
        localSJSBtn.addShadowColor()
        localSJSBtn.addSubviews([localLab1, localLab2])
        
        let nearGRBtn = UIButton().image(#imageLiteral(resourceName: "home_near_worker"))
        let nearGRLab1 = UILabel().text("附近的工人").textColor(.kColor33).font(14)
        let nearGRLab2 = UILabel().text("点击查看").textColor(.white).font(10).backgroundColor(.k2FD4A7).cornerRadius(10).masksToBounds()
        nearGRBtn.frame = CGRect(x: 0, y: localSJSBtn.bottom, width: (view.width/2), height: 105)
        headView.addSubview(nearGRBtn)
        nearGRLab1.frame = CGRect(x: 30, y: 18, width: 100, height: 14)
        nearGRLab2.frame = CGRect(x: 30, y: localLab1.bottom+7.5, width: 54, height: 20)
        nearGRLab2.textAligment(.center)
        //nearGRBtn.addShadowColor()
        nearGRBtn.addSubview(nearGRLab1)
        nearGRBtn.addSubview(nearGRLab2)
        
        let caseLabel = UILabel().text("示范案例").textColor(.kColor33).font(14)
        let caseBtn = UIButton()
        let caseIV1 = UIImageView().image(#imageLiteral(resourceName: "home_case_btn_iv1"))
        let caseIV2 = UIImageView().image(#imageLiteral(resourceName: "home_case_btn_iv2"))
        let caseIV3 = UIImageView().image(#imageLiteral(resourceName: "home_case_btn_iv3"))
        let caseIV4 = UIImageView().image(#imageLiteral(resourceName: "home_case_btn_iv4"))

        caseLabel.frame = CGRect(x: nearGRBtn.right+15, y: localSJSBtn.top+5, width: 100, height: 14)
        caseBtn.frame = CGRect(x: nearGRBtn.right+15, y: caseLabel.bottom+15, width: (view.width)/2-15, height: (view.width)/2-15)
        let ivWidth: CGFloat = ((view.width)/2-47)/2
        caseBtn.sv(caseIV1, caseIV2, caseIV3, caseIV4)
        caseBtn.layout(
            4,
            |caseIV1.size(ivWidth)-8-caseIV2.size(ivWidth)-14-|,
            8,
            |caseIV3.size(ivWidth)-8-caseIV4.size(ivWidth)-14-|,
            >=0
        )
        headView.addSubviews([caseLabel, caseBtn])
        
        let oneLineIV = UIImageView().image(#imageLiteral(resourceName: "home_oneline_buy"))
        oneLineIV.frame = CGRect(x: 14.5, y: nearGRBtn.bottom+5, width: view.width-14.5-4, height: 97.5)
        headView.addSubview(oneLineIV)
        
        localSJSBtn.addTarget(self, action: #selector(toSJSVC))
        nearGRBtn.addTarget(self, action: #selector(toGRVC))
        caseBtn.addTarget(self , action: #selector(toWholeHouse))
        return headView
    }
    
    //MARK: - 创建UITableView
    func prepareTableView() {
        
        tableView = UITableView(frame: CGRect.zero, style: .grouped)
        tableView.backgroundColor = PublicColor.backgroundViewColor
        tableView.estimatedRowHeight = 270*PublicSize.RateWidth
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(CorrectHomeSellCell.self, forCellReuseIdentifier: CorrectHomeSellCell.description())
        tableView.register(CorrectHomeNewCell.self, forCellReuseIdentifier: CorrectHomeNewCell.description())
        tableView.register(CorrectingHomeCell.self, forCellReuseIdentifier: CorrectingHomeCell.description())
        tableView.register(CorrectingHomeImageCell.self, forCellReuseIdentifier: CorrectingHomeImageCell.description())
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
       
    }
    
    //MARK: 按钮的点击
    @objc func clickAction(_ sender:UIButton) {
       // viewModel.clickAction(sender: sender)
        switch sender.tag {
        case 0:
            toBrandHouse()
        case 1:
            toSJSVC()
        case 2:
            toGRVC()
        case 3:
            toCCWLVC()
        case 4:
            toGSGSVC()
        case 5:
            if UserData.shared.workerModel?.jobType == 999 || UserData.shared.workerModel?.jobType == 4  {
                toOrder()
            } else {
                alertInfo(text: "‘采购管理’仅管理员和采购员可使用")
            }
        case 6:
            toMyCustom()
        case 7:
            toSiteManager()
        case 8:
            toWholeHouse()
        case 9:
            toVR()
        case 10:
            toGXManager()
        case 11:
            toBXJRVC()
        default:
            fatalError("\(sender.tag) Tag is undefine")
        }
    }
    
    @objc func headerRefresh() {
        viewModel?.headerRefresh()
    }
    
    
    //MARK: - LLCycleScrollViewDelegate
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        AppLog(index)
        if index == 0 && viewModel.haveBackImage {
            let vc = UIBaseWebViewController()
            vc.urlStr = viewModel.downLoadURL
            navigationController?.pushViewController(vc)
        }
        if index == 1 && viewModel.downLoadURL2 != nil {
            let vc = UIBaseWebViewController()
            vc.urlStr = viewModel.downLoadURL2
            navigationController?.pushViewController(vc)
        }
        if index == 2 && viewModel.downLoadURL3 != nil {
            let vc = UIBaseWebViewController()
            vc.urlStr = viewModel.downLoadURL3
            navigationController?.pushViewController(vc)
        }
    }
    //MARK: - tableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var num = 0
        if section == 0 {
            if let count = viewModel?.secondData?.data1?.count {
                 num =  count
            }
        } else if section == 1 {
            num = viewModel?.data?.data3?.count ?? 0
        } else if section == 2 {
            num = 1
        } else {
            num = 1
        }
        return num
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return cellForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0.01
        if indexPath.section == 0 {
            height = 158
        }else if indexPath.section == 1 {
            //let curW: CGFloat = (view.width-28-24)/3
            height = 183
        }else if indexPath.section == 2 {
            if let count = viewModel?.data?.data2?.count, count > 0 {
                let n = count/2 + count%2
                return (CorrectingHomeCell.cellHeight+13)*CGFloat(n) + 10
            } else {
                height = 239
            }
        } else {
            height = 0
        }
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            if let arr = viewModel?.secondData?.data1 {
                let arr1 = arr.sorted { (model1, model2) -> Bool in
                    let no1 = Int(model1.no ?? "0")
                    let no2 = Int(model2.no ?? "0")
                    return no1! < no2!
                }
               let vc = MaterialsDetailVC()
               vc.hidesBottomBarWhenPushed = true
               vc.isMainPageEnter = true
               vc.materialsModel = arr1[indexPath.row]
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else if indexPath.section == 1 {
            if let arr = viewModel?.data?.data3{
                let arr1 = arr.sorted { (model1, model2) -> Bool in
                    let no1 = Int(model1.no ?? "0")
                    let no2 = Int(model2.no ?? "0")
                    return no1 ?? 0 < no2 ?? 0
                }
                let model = arr1[indexPath.row]
                let vc = MaterialsDetailVC()
                vc.hidesBottomBarWhenPushed = true
                vc.isMainPageEnter = true
                vc.materialsModel = model
                navigationController?.pushViewController(vc, animated: true)
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headView = CorrectHomeHeadView(frame: CGRect(x: 0, y: 0, width: PublicSize.kScreenWidth, height: 55))
        if section == 0 {
            if let arr = viewModel?.secondData?.data1{
                if arr.count == 0 {
                    return UIView()
                }
            }else {
                return UIView()
            }
            if secoudView == nil {
                headView.titleLabel.text = "限时秒杀"
               // headView.iconImage.image = UIImage.init(named: "CorrectingHome1")
                headView.timerCount = viewModel?.secondData?.second ?? 12323
                headView.isStart = viewModel?.secondData?.isStart ?? 2
                secoudView = headView
            }else {
                if secoudView?.isStart != 3 &&  secoudView?.isStart != viewModel?.secondData?.isStart {
                    headView.timerCount = viewModel?.secondData?.second ?? 0
                    headView.isStart = viewModel?.secondData?.isStart ?? 0
                }
                
                headView = secoudView!
            }
            
        } else if section == 1 {
            headView.titleLabel.font = .systemFont(ofSize: 14)
            headView.titleLabel.textColor = .kColor33
            headView.titleLabel.text = "新品专区"
            headView.invalidateTimer()
            headView.titleLabel.isHidden = true
            
            let icon = UIImageView().image(#imageLiteral(resourceName: "home_new_img"))
            headView.sv(icon)
            headView.layout(
                23.5,
                |-14-icon,
                >=0
            )
        } else if section == 2 {
            headView.titleLabel.font = .systemFont(ofSize: 14)
            headView.titleLabel.textColor = .kColor33
            headView.titleLabel.text = "特惠专区"
            headView.invalidateTimer()
            headView.titleLabel.isHidden = true
            
            let icon = UIImageView().image(#imageLiteral(resourceName: "home_hot_img"))
            headView.sv(icon)
            headView.layout(
                13.5,
                |-14-icon,
                >=0
            )
        }
        return headView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if let arr = viewModel?.secondData?.data1{
                if arr.count == 0 {
                    return 0.01
                }
            }else {
                return 0.01
            }
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func cellForRowAt(indexPath: IndexPath) -> UITableViewCell {
        
//        if indexPath.row > 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: CorrectingHomeImageCell.description(), for: indexPath) as! CorrectingHomeImageCell
//            if indexPath.section == 0 {
//                cell.setImageWithTableView(viewModel?.data?.banner1,tableView)
//            }else {
//                cell.setImageWithTableView(viewModel?.data?.banner2,tableView)
//            }
//
//            return cell
//        }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CorrectHomeSellCell.description(), for: indexPath) as! CorrectHomeSellCell
            //cell.isStart = true
            if let arr = viewModel?.secondData?.data1{
                let arr1 = arr.sorted { (model1, model2) -> Bool in
                    let no1 = Int(model1.no ?? "0")
                    let no2 = Int(model2.no ?? "0")
                    return no1 ?? 0 < no2 ?? 0
                }
               // cell.original = "秒杀价"
                cell.configCell(model: arr1[indexPath.row])
            }
            return cell
        }else if indexPath.section == 1 { // 新品
            let cell = CorrectHomeNewCell1()
            if let arr = viewModel?.data?.data3{
                let arr1 = arr.sorted { (model1, model2) -> Bool in
                    let no1 = Int(model1.no ?? "0")
                    let no2 = Int(model2.no ?? "0")
                    return no1 ?? 0 < no2 ?? 0
                }
                cell.model = arr1[indexPath.row]
            }
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CorrectingHomeCell.description(), for: indexPath) as! CorrectingHomeCell
            cell.isStart = true
            if let arr = viewModel?.data?.data2{
                let arr1 = arr.sorted { (model1, model2) -> Bool in
                    let no1 = Int(model1.no ?? "0")
                    let no2 = Int(model2.no ?? "0")
                    return no1 ?? 0 < no2 ?? 0
                }
              //  cell.original = "新品价"
                cell.itemsData = arr1
            }
            cell.collectionView.reloadData()
            return cell
        }
        return UITableViewCell()
    }
}
// MARK: - CorrectHomeViewModelDelegate
extension CorrectHomeController: CorrectHomeViewModelDelegate {
    
    // 提醒消息
    func alertInfo(text: String) {
        self.noticeOnlyText(text)
    }
    
    
    
    // 员工管理
    func toWorker() {
        let vc = WorkerViewController()
        vc.title = "员工管理"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 品牌馆
    func toBrandHouse() {
        let vc = BrandIntroductionController()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// 设计师
    @objc func toSJSVC() {
        let vc = ServiceMallDesignResourceVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 工人
    @objc func toGRVC() {
        let vc = ServiceMallWorkerVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 仓储物流
    func toCCWLVC() {
        let vc = GRVC()
        vc.title = "仓储物流"
        vc.serviceType = 2
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 装饰公司
    func toGSGSVC() {
        let vc = CompanysVC()
        navigationController?.pushViewController(vc, animated: true)
    }
        
    /// 订单管理
    func toOrder() {
        let vc = AllOrdersViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 客户管理
    func toMyCustom() {
        let vc = MyCustomController()
        vc.title = "客户管理"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 工地管理
    func toSiteManager() {
        let vc = HouseViewController()
        vc.title = "我的工地"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 客户案例
    @objc func toWholeHouse() {
        let vc = WholeHouseController()
        navigationController?.pushViewController(vc, animated: true)
    }
    /// VR
    func toVR() {
        let vc = VRDesignController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    ///供需市场
    func toGXManager() {
        let vc = GXGLVC()
        navigationController?.pushViewController(vc)
    }
    
    ///保险金融
    func toBXJRVC() {
        let vc = GRVC()
        vc.title = "保险金融"
        vc.serviceType = 3
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // 结束刷新
    func endRefresh() {
        self.tableView.mj_header?.endRefreshing()
    }
    
    // tableView刷新
    func tableViewUpdate() {
        self.tableView.reloadData()
    }
    
    // 头部轮播刷新
    func refreshHeader() {
        self.cycleScrollView.imagePaths = viewModel.imagePaths
    }
}


class CorrectHomeSellCell: UITableViewCell {
    private var model: MaterialsModel?
    private let viewBG = UIView().then {
        $0.layer.shadowColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.16).cgColor
        $0.layer.shadowOffset = CGSize(width: 2, height: 2)
        $0.layer.shadowOpacity = 1
        $0.layer.shadowRadius = 8
        // fill
        $0.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        $0.layer.cornerRadius = 5;
        $0.alpha = 1
    }
    private let icon = UIImageView().image("loading")
    private let comBuy = UIImageView().image("comBuy").then {
        $0.isHidden = true
    }
    private let title = UILabel().text("现代简约ins意式轻奢布艺沙发").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(16, weight: .bold).numberOfLines(2)
    private let price1 = UILabel().text("￥1270").textColor(#colorLiteral(red: 0.9607843137, green: 0.2470588235, blue: 0.2470588235, alpha: 1)).font(16, weight: .bold)
    private let price1Des = UILabel().text("销售价").textColor(#colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)).font(10)
    private let price2 = UILabel().text("￥1998").textColor(#colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)).font(10)
    private let addBtn = UIButton().text("加购").textColor(.white).font(12)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = PublicColor.backgroundViewColor
        viewBG.frame = CGRect(x: 10, y: 0, width: PublicSize.kScreenWidth-20, height: 148)
        contentView.addSubview(viewBG)
        viewBG.sv(icon, title, price1, price1Des, price2, addBtn)
        viewBG.layout(
            14,
            |-14-icon.size(120),
            14
        )
        viewBG.layout(
            14,
            |-148-title-20-| ~ 45,
            4,
            |-148-price1.height(22.5)-5-price1Des.height(14)-(>=0)-|,
            3,
            |-148-price2.height(14)-(>=0)-|,
            2,
            |-(>=0)-addBtn.width(75).height(30)-22-|,
            14
        )
        icon.sv(comBuy)
        icon.layout(
            10,
            comBuy-10-|,
            >=0
        )
        price2.setLabelUnderline()
        configAddBtn()
    }
    
    private func configAddBtn() {
        addBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0, green: 0.89, blue: 0.41, alpha: 1).cgColor, UIColor(red: 0.47, green: 0.84, blue: 0.23, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = addBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 0.99, y: 0.5)
        addBtn.layer.insertSublayer(bgGradient, at: 0)
        //addBtn.layer.addSublayer(bgGradient)
        addBtn.layer.cornerRadius = 15;
        addBtn.layer.masksToBounds = true
        addBtn.addTarget(self, action: #selector(addBtnClick))
    }
    
    func configCell(model: MaterialsModel) {
        self.model = model
        if let imgStr = model.transformImageURL, !imgStr.isEmpty, let url = URL.init(string: APIURL.ossPicUrl + imgStr) {
            icon.kf.setImage(with: url, placeholder: UIImage.init(named: "loading"))
        } else {
            icon.image = UIImage.init(named: "loading")
        }
        title.text = model.name ?? ""
        if model.isOneSell == 2 {
            comBuy.isHidden = false
            price1.text = "￥\(model.priceShow ?? 0)"
            price1.setLabelUnderline()
            price1Des.text = "市场价"
            price2.isHidden = true
        } else {
            comBuy.isHidden = true
            
            price1.text = "￥\(model.priceSellMin ?? 0)"
            price1Des.text = "销售价"
            price2.text = "￥\(model.priceShow ?? 0)"
            price2.setLabelUnderline()
            price2.isHidden = false
        }
    }
    
    @objc func addBtnClick() {
        addCart()
    }
    
    func addCart() {
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        var parameters: Parameters = ["worker": userId, "store": storeID, "materials": model!.id!, "type": "1"]
        
        if let valueStr = model?.type {
            parameters["materialsType"] = valueStr
        }
        
        self.clearAllNotice()
        self.pleaseWait()
        let urlStr = APIURL.saveCartList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                self.noticeSuccess("添加购物车成功", autoClear: true, autoClearTime: 0.8)
            }
            
        }) { (error) in
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CorrectHomeNewCell: UITableViewCell {
    
    private let scrollView = UIScrollView()
    private var models: [MaterialsModel]?
    private var noDataView: UIButton!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        scrollView.frame = CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: (PublicSize.screenWidth-28-24)/3)
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.addSubview(scrollView)
        
        // 无数据图片
        noDataView = UIButton().text("暂无推荐~").textColor(.kColor99).font(14).image(#imageLiteral(resourceName: "home_nodata_image"))
        scrollView.sv(noDataView)
        noDataView.centerInContainer()
        noDataView.layoutButton(imageTitleSpace: 10)
        noDataView.isHidden = true
    }
    
    func configCell(models: [MaterialsModel]) {
        self.models = models
        let w: CGFloat = (PublicSize.screenWidth-28-24)/3
        let h: CGFloat = w
        scrollView.contentSize = CGSize(width: 14 + (w+12)*CGFloat(models.count), height: h)
        models.enumerated().forEach { (arg0) in
            let (index, model) = arg0
            let hotView = CorrectHomeNewView.init(frame: CGRect(x: 14+(w+12)*CGFloat(index), y: 0, width: w, height: h))
            scrollView.addSubview(hotView)
            hotView.configView(model: model)
            hotView.tag = index
            hotView.addTarget(self, action: #selector(hotViewClick(btn:)))
        }
        if models.count == 0 {
            scrollView.backgroundColor = .white
            noDataView.isHidden = false
        } else {
            scrollView.backgroundColor = PublicColor.backgroundViewColor
            noDataView.isHidden = true
        }
    }
    
    @objc func hotViewClick(btn: UIButton) {
        let vc = MaterialsDetailVC()
        vc.hidesBottomBarWhenPushed = true
        vc.isMainPageEnter = true
        vc.materialsModel = (models?[btn.tag]) ?? MaterialsModel()
        self.viewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


class CorrectHomeNewCell1: UITableViewCell {
    private var noDataView: UIButton!
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
    private let comBuyIV = UIImageView().image(#imageLiteral(resourceName: "comBuy"))
    private let title = UILabel().text("2020年新款欧美风现代简约ins意式轻奢布沙发").textColor(.kColor33).font(14)
    private let price1 = UILabel().text("市场价：¥6981").textColor(.kColor66).font(10.26)
    private let price2 = UILabel().text("专享价：").textColor(.kColor33).font(14)
    private let price3 = UILabel().text("¥3324.3").textColor(.kRedColor).font(14)
    private let buyBtn = UIButton().text("立即抢购").textColor(.white).font(12).backgroundColor(.kFFAB3D).cornerRadius(10).masksToBounds()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 无数据图片
        noDataView = UIButton().text("暂无推荐~").textColor(.kColor99).font(14).image(#imageLiteral(resourceName: "home_nodata_image"))
        sv(noDataView)
        noDataView.centerInContainer()
        noDataView.layoutButton(imageTitleSpace: 10)
        noDataView.isHidden = true
        
        sv(icon, title, price1, price2, price3, buyBtn)
        layout(
            10,
            |-17.5-icon.size(163),
            10
        )
        icon.contentMode = .scaleAspectFit
        icon.cornerRadius(5).masksToBounds()
        icon.sv(comBuyIV)
        icon.layout(
            10,
            comBuyIV-10-|,
            >=0
        )
        comBuyIV.isHidden = true
        layout(
            10,
            |-193.5-title-14.5-|,
            >=0,
            |-193.5-price1.height(10),
            6,
            |-193.5-price2.height(13.5)-1-price3.height(13.5),
            13,
            |-193.5-buyBtn.height(26)-15.5-|,
            15
        )
        title.numberOfLines(0).lineSpace(2)
    }
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    private func configCell() {
        if !icon.addImage(model?.imageUrl) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        price1.setLabelUnderline()
        if model?.isOneSell == 2 {
            comBuyIV.isHidden = false
            price2.isHidden = true
            price3.isHidden = true
        } else {
            comBuyIV.isHidden = true
            price2.isHidden = false
            price3.isHidden = false
        }
        title.text(model?.name ?? "")
        price1.text("市场价：¥\(model?.priceShow ?? 0)")
        price3.text("¥\(model?.priceSellMin ?? 0)")
        buyBtn.isUserInteractionEnabled = false
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
class CorrectHomeNewView: UIButton {
    
    private var model: MaterialsModel?
    private let viewBG = UIView()
    private let icon = UIImageView().image("loading")
    private let endLab = UILabel().text("END").textColor(.white).font(9).textAligment(.center).backgroundColor(#colorLiteral(red: 0.8745098039, green: 0.1764705882, blue: 0.1764705882, alpha: 1)).cornerRadius(7).masksToBounds()
    
    private let comBuy = UIImageView().image("comBuy").then {
        $0.isHidden = true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = PublicColor.backgroundViewColor
        sv(icon, endLab)
        layout(
            0,
            |icon|,
            0
        )
        layout(
            6,
            endLab.width(30).height(14)-6-|,
            >=0
        )
        icon.sv(comBuy)
        icon.layout(
            10,
            comBuy-10-|,
            >=0
        )
        icon.sv(comBuy)
        icon.layout(
            10,
            comBuy-10-|,
            >=0
        )
        icon.contentMode = .scaleAspectFit
        icon.cornerRadius(5).masksToBounds()
        endLab.isHidden = true
    }
    
    func configView(model: MaterialsModel) {
        self.model = model
        if model.isOneSell == 2 {
            comBuy.isHidden = false
        } else {
            comBuy.isHidden = true
        }
        if !icon.addImage(model.imageUrl) {
            icon.image = UIImage.init(named: "loading")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
