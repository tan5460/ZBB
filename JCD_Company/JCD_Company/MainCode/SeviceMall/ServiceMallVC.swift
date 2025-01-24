//
//  ServiceMallVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/1.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire

var serviceMallHeaderViewHeight: CGFloat = 230 + 284 + PublicSize.kNavBarHeight

class ServiceMallVC: BaseViewController {

    struct Constants {
        static let titleBarHeight: CGFloat = PublicSize.kNavBarHeight
        static let tabViewHeight: CGFloat = 40.0
    }
    
    private lazy var titleBar: ZFTitleBar = {
        let titleBar = ZFTitleBar()
        titleBar.titleLabel.text("服务商城")
        titleBar.maxScrollY = 200.0
        titleBar.backButton.isHidden = true
        titleBar.mainBackButton.isHidden = true
        return titleBar
    }()
    
    private lazy var headerView: ServiceMallHeaderView = {
        var headerView = ServiceMallHeaderView.init(frame: CGRect(x: 0, y: 0, width: view.width, height: serviceMallHeaderViewHeight))
        return headerView
    }()
    private lazy var titles: [String] = {
        let serviceTypes = AppData.serviceTypes
        var titles = ["工人", "设计师"]
        serviceTypes.forEach { (dic) in
            if Utils.getReadString(dir: dic, field: "label") != "工人" && Utils.getReadString(dir: dic, field: "label") != "设计师" {
                titles.append(Utils.getReadString(dir: dic, field: "label"))
            }
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
        multiTabPageVC.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        // 处理右滑退出手势冲突
        if let navi = self.navigationController {
            multiTabPageVC.handlePopGestureRecognizer(navi: navi)
        }
        addChild(multiTabPageVC)
        multiTabPageVC.move(to: 0, animated: false)
        return multiTabPageVC
    }()
    
    private var childVCDic: [Int: ZFMultiTabChildPageViewController] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        if !PublicSize.isX {
            serviceMallHeaderViewHeight += 50
        }
        configViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private func configViews() {
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


extension ServiceMallVC: ZFMultiTabPageDelegate {
    
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
        let childVC = ServiceMallTabVC()
        childVC.index = index
        childVC.title = titles[index]
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
        let childVC = childVCDic[index] as? ServiceMallTabVC
        if childVC?.dataSource.count == 0 {
            childVC?.headerRefresh()
        }
    }
}

extension ServiceMallVC: ZFMultipleTabViewDelegate {
    func selectedIndexInMultipleTabView(multipleTabView: ZFMultipleTabView, selectedIndex: Int) {
        self.multiTabPageVC.move(to: selectedIndex, animated: false)
        switchWithLoadData(index: selectedIndex)
    }
}


class ServiceMallHeaderView: UIView {
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = #imageLiteral(resourceName: "service_mall_banner_bg")
        cycleScrollView.placeHolderImage = #imageLiteral(resourceName: "service_mall_banner_bg")
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configViews()
       // loadBannerData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadBannerData() {
        var parameters = Parameters()
        parameters["type"] = "1" //服务商城首页banner
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
    
    private func configViews() {
        let topIV = UIImageView().image(#imageLiteral(resourceName: "service_mall_top"))
        topIV.frame = CGRect(x: 0, y: 0, width: width, height: 156.5)
        addSubview(topIV)
        
        cycleScrollView.frame = CGRect(x: 14, y: 68-PublicSize.kStatusBarHeight+20, width: width-28, height: 170)
        addSubview(cycleScrollView)
        
        
        
        let titleLab = UILabel().text("服务商城").textColor(.kColor33).font(14)
        let detailTitleLab = UILabel().text("为装饰行业提供优质服务").textColor(.kColor66).font(10).textAligment(.right)
        titleLab.frame = CGRect(x: 14, y: cycleScrollView.bottom+25, width: 100, height: 14)
        addSubview(titleLab)
        
        detailTitleLab.frame = CGRect(x: width-164, y: 0, width: 150, height: 14)
        detailTitleLab.centerY = titleLab.centerY
        addSubview(detailTitleLab)

        let w: CGFloat = (width-4.5-8.5)/3
        let h: CGFloat = 145
        let titles = ["工人资源", "设计资源", "装企资源", "仓储物流", "保险金融", "其他服务"]
        let images = [#imageLiteral(resourceName: "service_mall_gr"), #imageLiteral(resourceName: "service_mall_sj"), #imageLiteral(resourceName: "service_mall_zq"), #imageLiteral(resourceName: "service_mall_cc"), #imageLiteral(resourceName: "service_mall_bx"), #imageLiteral(resourceName: "service_mall_qt")]
        titles.enumerated().forEach { (item) in
            let index = item.offset
            let title = item.element
            let image = images[index]
            let btn = UIButton().image(image)
            let offsetX: CGFloat = (4.5+w*CGFloat((index%3)))
            let offsetY: CGFloat = titleLab.bottom+15+h*CGFloat((index/3))
            btn.frame = CGRect(x: offsetX, y: offsetY, width: w, height: h)
            
            btn.contentMode = .scaleAspectFit
            let titleLab1 = UILabel().text(title).textColor(.kColor33).font(14).textAligment(.center)
            let detailTitleLab1 = UILabel().text("点击查看").textColor(.white).font(10).textAligment(.center).backgroundColor(.k2FD4A7).cornerRadius(10).masksToBounds()
            titleLab1.frame = CGRect(x: 0, y: 20, width: w, height: 14)
            btn.addSubview(titleLab1)
            detailTitleLab1.frame = CGRect(x: 0, y: titleLab1.bottom+6, width: 54, height: 20)
            detailTitleLab1.centerX = titleLab1.centerX
            btn.addSubview(detailTitleLab1)
            
            addSubview(btn)
            btn.tag = index
            btn.addTarget(self, action: #selector(serviceBtnsClick(btn:)))
        }


        let titleLab2 = UILabel().text("精选服务").textColor(.kColor33).font(14)
        if PublicSize.isX {
            titleLab2.frame = CGRect(x: 14, y: 576.5, width: 100, height: 14)
        } else {
            titleLab2.frame = CGRect(x: 14, y: 590.5, width: 100, height: 14)
        }
        addSubview(titleLab2)
    }
    @objc private func serviceBtnsClick(btn: UIButton) {
        switch btn.tag {
        case 0:
            parentController?.navigationController?.pushViewController(ServiceMallWorkerVC(), animated: true)
        case 1:
            parentController?.navigationController?.pushViewController(ServiceMallDesignResourceVC(), animated: true)
        case 2:
            if isSHAccountUserId {
                let vc = GRVC()
                vc.title = "装企资源"
                vc.serviceType = 10001
                self.parentController?.navigationController?.pushViewController(vc)
            } else {
                noticeOnlyText("开发中，敬请期待～")
            }
        case 3:
            if isSHAccountUserId {
                let vc = GRVC()
                vc.title = "仓储物流"
                vc.serviceType = 10001
                self.parentController?.navigationController?.pushViewController(vc)
            } else {
                noticeOnlyText("开发中，敬请期待～")
            }
        case 4:
            if isSHAccountUserId {
                let vc = GRVC()
                vc.title = "保险金融"
                vc.serviceType = 10001
                self.parentController?.navigationController?.pushViewController(vc)
            } else {
                noticeOnlyText("开发中，敬请期待～")
            }
        case 5:
            if isSHAccountUserId {
                let vc = GRVC()
                vc.title = "其他服务"
                vc.serviceType = 10001
                self.parentController?.navigationController?.pushViewController(vc)
            } else {
                noticeOnlyText("开发中，敬请期待～")
            }
        default:
            noticeOnlyText("开发中，敬请期待～")
            break
        }
    }
    
}
