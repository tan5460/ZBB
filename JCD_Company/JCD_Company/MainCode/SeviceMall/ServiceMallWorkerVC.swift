//
//  ServiceMallWorkerVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/3.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire

class ServiceMallWorkerVC: BaseViewController {
    var headerHeight: CGFloat = 345 + 284 + PublicSize.kNavBarHeight
    struct Constants {
        static let titleBarHeight: CGFloat = PublicSize.kNavBarHeight
        static let tabViewHeight: CGFloat = 40.0
    }
    
    private lazy var titleBar: ZFTitleBar = {
        let titleBar = ZFTitleBar()
        titleBar.titleLabel.text("工人资源")
        titleBar.maxScrollY = 200.0
        return titleBar
    }()
    
    private lazy var headerView: ServiceMallWorkerHeaderView = {
        var headerView = ServiceMallWorkerHeaderView.init(frame: CGRect(x: 0, y: 0, width: view.width, height: headerHeight))
        return headerView
    }()
    private lazy var titles: [String] = {
        let workTypes = AppData.workTypes
        var titles = [String]()
        workTypes.forEach { (dic) in
            let title = Utils.getReadString(dir: dic, field: "label")
            titles.append(title)
        }
        return titles
    }()
    
    private lazy var tabView: ZFMultipleTabView = {
        let tabConfig = ZFMultipleTabViewConfig()
        tabConfig.titleFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        tabConfig.titleSelectedFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        tabConfig.titleColor = .kColor66
        tabConfig.titleSelectedColor = .kColor33
        tabConfig.indicatorColor = #colorLiteral(red: 0.3607843137, green: 0.862745098, blue: 0.6862745098, alpha: 1)
        tabConfig.indicatorHeight = 2
        tabConfig.indicatorCorner = 1
        tabConfig.indicatorBottomDistance = 6
        let tabView = ZFMultipleTabView(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: Constants.tabViewHeight), titles: self.titles , config: tabConfig)
        
        tabView.delegate = self
        return tabView
    }()
    
    // 多tab控制器
    private lazy var multiTabPageVC: ZFMultiTabPageViewController = {
        let multiTabPageVC = ZFMultiTabPageViewController(tabCount: self.titles.count, headerView: headerView, tabView: tabView, titleBarHeight: Constants.titleBarHeight)
        multiTabPageVC.delegate = self
        multiTabPageVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height-40-PublicSize.kBottomOffset)
        // 处理右滑退出手势冲突
        if let navi = self.navigationController {
            multiTabPageVC.handlePopGestureRecognizer(navi: navi)
        }
        addChild(multiTabPageVC)
        multiTabPageVC.move(to: 0, animated: false)
        return multiTabPageVC
    }()
    
    private var childVCDic: [Int: ZFMultiTabChildPageViewController] = [:]
    
    var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        loadData()
    }
    // MARK: 工人资源-工长团队、案例数据接口
    func loadData() {
        YZBSign.shared.request(APIURL.getForemanTeamAndCase, method: .get, parameters: Parameters(), success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                self.configViews(data: model?.data)
                self.headerView.configViews(data: model?.data)
            }
        }) { (error) in
            
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
    private func configViews(data: Any?) {
        let workDataModel = WorkDataModel.deserialize(from: data as? [String: Any])
        let teamModels = workDataModel?.team
        if teamModels?.count ?? 0 <= 2 {
            headerHeight -= 110
        }
        view.sv(titleBar)
        addChild(multiTabPageVC)
        view.sv(multiTabPageVC.view)
        
        view.layout(
            0,
            |titleBar| ~ Constants.titleBarHeight,
            >=0
        )
        self.view.bringSubviewToFront(titleBar)
    }
}


extension ServiceMallWorkerVC: ZFMultiTabPageDelegate {
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
        titleBar.setTransparent(scrollView.contentOffset.y)
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrollViewDidScroll scrollView: UIScrollView) {
        tabView.pagerDidScroll(pager: scrollView)
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrollViewDidEndDecelerating scrollView: UIScrollView) {
        if scrollView.bounds.size.width > 0 {
            tabView.pagerDidEndDecelerating(pager: scrollView)
        }
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, pageScrolllViewDidEndScrollingAnimation scrollView: UIScrollView) {
        if scrollView.bounds.size.width > 0 {
            tabView.pagerDidEndScrollingAnimation(pager: scrollView)
        }
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, childViewController index: Int) -> ZFMultiTabChildPageViewController? {
        if let childVC = self.childVCDic[index] {
            return childVC
        }
        let childVC = ServiceMallWorkerTabVC()
        childVC.index = index
        childVCDic[index] = childVC
        return childVC
    }

    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, willDisplay index: Int) {
        print("yzf ---> willDisplay = \(index)")
        switchWithLoadData(index: index)
    }
    
    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, displaying index: Int) {
        print("yzf ---> displaying = \(index)")
    }

    func multiTabPageViewController(_ viewController: ZFMultiTabPageViewController, didEndDisplaying index: Int) {
        print("yzf ---> didEndDisplaying = \(index)")
    }
     
    func switchWithLoadData(index: Int) {
        if index == 0 {
            return
        }
        let childVC = childVCDic[index] as? ServiceMallWorkerTabVC
        if childVC?.dataSource.count == 0 {
            childVC?.headerRefresh()
        }
    }
}

extension ServiceMallWorkerVC: ZFMultipleTabViewDelegate {
    func selectedIndexInMultipleTabView(multipleTabView: ZFMultipleTabView, selectedIndex: Int) {
        self.multiTabPageVC.move(to: selectedIndex, animated: false)
        switchWithLoadData(index: selectedIndex)
    }
}


class ServiceMallWorkerHeaderView: UIView {
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = #imageLiteral(resourceName: "service_mall_worker_banner_bg")
        cycleScrollView.placeHolderImage = #imageLiteral(resourceName: "service_mall_worker_banner_bg")
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //configViews()
        //loadBannerData()
    }
    
    func loadBannerData() {
        var parameters = Parameters()
        parameters["type"] = "2" //工人资源一级页面
        YZBSign.shared.request(APIURL.getBannerByType, method: .get, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let imageStr = model?.data as? String
                let images = imageStr?.components(separatedBy: ",")
                var imagePaths = [String]()
                images?.forEach({ (image) in
                    let image1 = APIURL.ossPicUrl + image
                    imagePaths.append(image1)
                })
                self.cycleScrollView.imagePaths = imagePaths
            }
        }) { (error) in
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var workDataModel: WorkDataModel?
    func configViews(data: Any?) {
        workDataModel = WorkDataModel.deserialize(from: data as? [String: Any])
        let teamModels = workDataModel?.team
        let caseModels = workDataModel?.cases
        
        let topIV = UIImageView().image(#imageLiteral(resourceName: "service_mall_top"))
        topIV.frame = CGRect(x: 0, y: 0, width: width, height: 156.5)
        addSubview(topIV)
        
        cycleScrollView.frame = CGRect(x: 14, y: 68-PublicSize.kStatusBarHeight+20, width: width-28, height: 170)
        addSubview(cycleScrollView)
        
        let titleLab = UILabel().text("工长团队").textColor(.kColor33).font(14)
        let moreGroupBtn = UIButton().text("更多团队>").textColor(.kColor66).font(10)
        titleLab.frame = CGRect(x: 14, y: cycleScrollView.bottom+25, width: 100, height: 14)
        addSubview(titleLab)
        moreGroupBtn.addTarget(self, action: #selector(moreTeamBtnClick(btn:)))
        
        moreGroupBtn.frame = CGRect(x: width-64, y: 0, width: 50, height: 40)
        moreGroupBtn.centerY = titleLab.centerY
        addSubview(moreGroupBtn)
        
        
        let lineV = UIView().backgroundColor(.kColorEE)
        lineV.frame = CGRect(x: width/2, y: titleLab.bottom+15, width: 0.5, height: 212.5)
        addSubview(lineV)
        
        let lineH = UIView().backgroundColor(.kColorEE)
        lineH.frame = CGRect(x: 14, y: titleLab.bottom+15+100, width: width-28, height: 0.5)
        addSubview(lineH)
        
        if teamModels?.count ?? 0 <= 2 {
            lineV.height = 105.5
            lineH.isHidden = true
        }

        let w: CGFloat = (width-40)/2
        let h: CGFloat = 103.5
        teamModels?.enumerated().forEach { (item) in
            let index = item.offset
            let teamModel = item.element
            
            let btnBgView = UIView()
            let offsetX: CGFloat = (20+(w+20)*CGFloat((index%2)))
            let offsetY: CGFloat = titleLab.bottom+15+h*CGFloat((index/2))
            btnBgView.frame = CGRect(x: offsetX, y: offsetY, width: w, height: h)
            
            let btn = UIButton()
            btn.frame = btnBgView.frame
            
            let icon = UIImageView().image(#imageLiteral(resourceName: "img_buyer")).cornerRadius(5).masksToBounds()
            icon.frame = CGRect(x: 0, y: 9, width: 49, height: 49)
            btnBgView.addSubview(icon)
            icon.addImage(teamModel.headUrl)
            
            let name = UILabel().text(teamModel.name ?? "未知").textColor(.kColor33).font(12)
            name.frame = CGRect(x: icon.right+9, y: 9, width: w-49-9, height: 12)
            btnBgView.addSubview(name)
            
            var workTypeNames = "拥有"
            teamModel.workerTypeNames?.enumerated().forEach({ (item) in
                let index = item.offset
                let workerTypeName = item.element
                if index > 0 {
                    workTypeNames.append("、")
                }
                workTypeNames.append(workerTypeName)
            })
            if teamModel.workerTypeNames?.count == 0 {
                workTypeNames = "暂无团队"
            }
            let des = UILabel().text(workTypeNames).textColor(.kColor66).font(10).numberOfLines(2)
            des.frame = CGRect(x: name.left, y: name.bottom+5, width: 90, height: 27)
            des.lineSpace(5)
            btnBgView.addSubview(des)
            
            let groupIconsView = UIView()
            groupIconsView.frame = CGRect(x: 0, y: icon.bottom+10, width: w, height: 18)
            btnBgView.addSubview(groupIconsView)
            
            teamModel.workerData?.enumerated().forEach { (item) in
                let index = item.offset
                let workerDataModel = item.element
                let imageOffsetX: CGFloat = 20.5*CGFloat(index)
                
                if index == 6 {
                    let groupIV = UIImageView().image(#imageLiteral(resourceName: "service_mall_more"))
                    groupIV.frame = CGRect(x: imageOffsetX+4, y: 8, width: 10, height: 2)
                    groupIconsView.addSubview(groupIV)
                } else {
                    let groupIV = UIImageView().image(#imageLiteral(resourceName: "sjs_avatar_default")).cornerRadius(9).masksToBounds()
                    groupIV.frame = CGRect(x: imageOffsetX, y: 0, width: 18, height: 18)
                    groupIconsView.addSubview(groupIV)
                    groupIV.addImage(workerDataModel.headImg)
                }
            }
            addSubview(btnBgView)
            addSubview(btn)
            btn.tag = index
            btn.addTarget(self, action: #selector(serviceBtnsClick(btn:)))
        }
        

        let titleLab2 = UILabel().text("工长案例").textColor(.kColor33).font(14)
        titleLab2.frame = CGRect(x: 14, y: lineV.bottom+12.5, width: 100, height: 14)
        addSubview(titleLab2)
        
        let moreGroupBtn2 = UIButton().text("更多案例>").textColor(.kColor66).font(10)
        moreGroupBtn2.frame = CGRect(x: width-64, y: 0, width: 50, height: 40)
        moreGroupBtn2.centerY = titleLab2.centerY
        addSubview(moreGroupBtn2)
        moreGroupBtn2.addTarget(self, action: #selector(moreCaseBtnClick(btn:)))
        
        let caseModel1 = caseModels?.first
        let caseW: CGFloat = (width-28-11)/2
        let caseH: CGFloat = 120
        let caseBtn1 = UIButton().backgroundColor(.kBackgroundColor).cornerRadius(5).masksToBounds()
        caseBtn1.frame = CGRect(x: 14, y: titleLab2.bottom+15, width: caseW, height: caseH)
        addSubview(caseBtn1)
        caseBtn1.tag = 0
        caseBtn1.addTarget(self, action: #selector(caseBtnsClick(btn:)))
        
        let caseIV1 = UIImageView()
        caseIV1.frame = caseBtn1.frame
        addSubview(caseIV1)
        
        caseIV1.addImage(caseModel1?.mainImgUrl)
        
        
        let styleTypeList = AppData.styleTypeList
        var styleType = ""
        styleTypeList.forEach { (dic) in
            let tmpStyleType = Utils.getReadString(dir: dic, field: "value")
            if tmpStyleType == caseModel1?.caseStyle {
                styleType = Utils.getReadString(dir: dic, field: "label")
            }
        }
        
        let houseTypeList = AppData.houseTypesList
        var houseType = ""
        houseTypeList.forEach { (dic) in
            let tmpHouseType = Utils.getReadString(dir: dic, field: "value")
            if tmpHouseType == caseModel1?.houseType {
                houseType = Utils.getReadString(dir: dic, field: "label")
            }
        }
        
        let houseAreaLise = AppData.houseAreaList
        var houseArea = ""
        houseAreaLise.forEach { (dic) in
            let tmpHouseArea = Utils.getReadString(dir: dic, field: "value")
            if tmpHouseArea == caseModel1?.houseArea {
                houseArea = Utils.getReadString(dir: dic, field: "label")
            }
        }
        
        let caseTitleLabel1 = UILabel().textAligment(.center).backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        caseTitleLabel1.numberOfLines(0).lineSpace(2)
        caseTitleLabel1.frame = CGRect(x: 0, y: caseH-30, width: caseW, height: 30)
        caseTitleLabel1.text("\(houseType) | \(styleType) | \(houseArea)  ").textColor(.white).font(12)
        caseIV1.addSubview(caseTitleLabel1)
        
        if caseModels?.count ?? 0 > 1 {
            let caseModel2 = caseModels?.last
            let caseBtn2 = UIButton().backgroundColor(.kBackgroundColor).cornerRadius(5).masksToBounds()
            caseBtn2.frame = CGRect(x: caseBtn1.right+11, y: titleLab2.bottom+15, width: caseW, height: caseH)
            addSubview(caseBtn2)
            caseBtn2.tag = 1
            caseBtn2.addTarget(self, action: #selector(caseBtnsClick(btn:)))
            
            
            let caseIV2 = UIImageView()
            caseIV2.frame = caseBtn2.frame
            addSubview(caseIV2)
            
            caseIV2.addImage(caseModel2?.mainImgUrl)
            
            var styleType2 = ""
            styleTypeList.forEach { (dic) in
                let tmpStyleType = Utils.getReadString(dir: dic, field: "value")
                if tmpStyleType == caseModel2?.caseStyle {
                    styleType2 = Utils.getReadString(dir: dic, field: "label")
                }
            }
            
            var houseType2 = ""
            houseTypeList.forEach { (dic) in
                let tmpHouseType = Utils.getReadString(dir: dic, field: "value")
                if tmpHouseType == caseModel2?.houseType {
                    houseType2 = Utils.getReadString(dir: dic, field: "label")
                }
            }
            
            var houseArea2 = ""
            houseAreaLise.forEach { (dic) in
                let tmpHouseArea = Utils.getReadString(dir: dic, field: "value")
                if tmpHouseArea == caseModel2?.houseArea {
                    houseArea2 = Utils.getReadString(dir: dic, field: "label")
                }
            }
            
            let caseTitleLabel2 = UILabel().textAligment(.center).backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
            caseTitleLabel2.numberOfLines(0).lineSpace(2)
            
            caseTitleLabel2.frame = CGRect(x: 0, y: caseH-30, width: caseW, height: 30)
            caseTitleLabel2.text("\(houseType2) | \(styleType2) | \(houseArea2)  ").textColor(.white).font(12)
            caseIV2.addSubview(caseTitleLabel2)
        }
        
        let spaceView = UIView().backgroundColor(.kBackgroundColor)
        spaceView.frame = CGRect(x: 0, y: caseBtn1.bottom+25, width: width, height: 10)
        addSubview(spaceView)
        
        let titleLab3 = UILabel().text("推荐工人").textColor(.kColor33).font(14)
        titleLab3.frame = CGRect(x: 14, y: spaceView.bottom+12.5, width: 100, height: 14)
        addSubview(titleLab3)
        
        let moreWorkerBtn2 = UIButton().text("更多工人>").textColor(.kColor66).font(10)
        moreWorkerBtn2.frame = CGRect(x: width-64, y: 0, width: 50, height: 40)
        moreWorkerBtn2.centerY = titleLab3.centerY
        addSubview(moreWorkerBtn2)
        moreWorkerBtn2.addTarget(self, action: #selector(moreWorkerBtnClick(btn:)))
        
    }
    @objc private func serviceBtnsClick(btn: UIButton) {
        let teamModels = workDataModel?.team
        let vc = ServiceMallWorkerGroupVC()
        vc.teamId = teamModels?[btn.tag].id ?? ""
        parentController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func caseBtnsClick(btn: UIButton) {
        let caseModels = workDataModel?.cases
        if btn.tag <= caseModels?.count ?? 0 - 1 {
            let vc = WholeHouseDetailController()
              if let url = caseModels?[btn.tag].url {
                  vc.detailUrl = url
              }
            let caseModel = HouseCaseModel()
            let model = caseModels?[btn.tag]
            caseModel.caseNo = model?.caseNo
            caseModel.caseRemarks = model?.caseRemarks
            caseModel.caseStyle = model?.caseStyle
            caseModel.communityId = model?.communityId
            caseModel.communityName = model?.communityName
            caseModel.createTime = model?.createTime
            caseModel.houseArea = model?.houseArea
            caseModel.houseType = model?.houseType
            caseModel.id = model?.id
            caseModel.mainImgUrl = model?.mainImgUrl
            caseModel.showFlag = model?.showFlag
            caseModel.type = model?.type
            caseModel.updateTime = model?.updateTime
            caseModel.userId = model?.userId
            caseModel.caseStyleName = model?.caseStyleName
            caseModel.houseAreaName = model?.houseAreaName
            caseModel.houseTypeName = model?.houseTypeName
            caseModel.url = model?.url
            caseModel.userName = model?.userName
            vc.caseModel = caseModel
            parentController?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func caseBtn1Click(btn: UIButton) {
        noticeOnlyText("点击了按钮")
    }
    
    @objc private func caseBtn2Click(btn: UIButton) {
        noticeOnlyText("点击了按钮")
    }
    
    @objc private func moreTeamBtnClick(btn: UIButton) {
        parentController?.navigationController?.pushViewController(ServiceMallWorkerListVC(), animated: true)
    }
    
    @objc private func moreCaseBtnClick(btn: UIButton) {
        let vc = ServiceMallWorkerCaseVC()
        vc.caseType = .worker
        parentController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func moreWorkerBtnClick(btn: UIButton) {
        parentController?.navigationController?.pushViewController(ServiceMallWorkersVC())
    }
    
}
