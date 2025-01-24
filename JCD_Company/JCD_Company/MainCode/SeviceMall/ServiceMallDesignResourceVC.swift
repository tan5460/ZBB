//
//  ServiceMallDesignResourceVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/5.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh

class ServiceMallDesignResourceVC: BaseViewController, UIScrollViewDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private lazy var titleBar: ZFTitleBar = {
        let titleBar = ZFTitleBar()
        titleBar.mainTitleLabel.text("设计资源")
        titleBar.titleLabel.text("设计资源")
        titleBar.maxScrollY = 200.0
        return titleBar
    }()
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    
    
    private let navBarView = UIView().backgroundColor(.white)
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
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
        view.sv(tableView, titleBar)
        view.layout(
            0,
            |titleBar| ~ PublicSize.kNavBarHeight,
            >=0
        )
        view.layout(
            0,
            |tableView|,
            0
        )
        navBarView.alpha = 0
        tableView.tableHeaderView = tableHeaderView()
        view.bringSubviewToFront(titleBar)
        loadData()
       // loadBannerData()
    }
    private var designerModel = DesignerModel()
    private var dataSource = [WorkTeamModel?]()
    func loadData() {
        var parameters = Parameters()
        parameters["sortType"] = 1
        YZBSign.shared.request(APIURL.getDesignResources, method: .get, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                self.designerModel = DesignerModel.deserialize(from: model?.data as? [String: Any]) ?? DesignerModel()
                self.dataSource = self.designerModel.designerData ?? [WorkTeamModel]()
                self.tableView.reloadData()
            }
        }) { (error) in
            
        }
    }
    
    func loadBannerData() {
        var parameters = Parameters()
        parameters["type"] = "5" //设计资源一级页面banner
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
    
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = #imageLiteral(resourceName: "service_mall_sj_banner")
        cycleScrollView.placeHolderImage = #imageLiteral(resourceName: "service_mall_sj_banner")
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    
    private let headerView = UIView()
    private func tableHeaderView() -> UIView {
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: 415+PublicSize.kNavBarHeight)
        let topBgView = UIView()
        headerView.sv(topBgView, cycleScrollView)
        headerView.layout(
            0,
            |topBgView| ~ 156.5-88+PublicSize.kNavBarHeight,
            >=0
        )
        topBgView.corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 15)
        topBgView.fillGreenColorV()
        headerView.layout(
            PublicSize.kNavBarHeight+15,
            |-14-cycleScrollView-14-| ~ 110,
            >=0
        )
        
        
        let names = ["住宅设计", "工装设计", "软装设计", "平面设计", "园林设计","灯光设计", "图纸深化", "3D设计"]
        let images = [#imageLiteral(resourceName: "service_mall_sj_zzsj"), #imageLiteral(resourceName: "service_mall_sj_gzsj"), #imageLiteral(resourceName: "service_mall_sj_rzsj"), #imageLiteral(resourceName: "service_mall_sj_pmsj"), #imageLiteral(resourceName: "service_mall_sj_ylsj"), #imageLiteral(resourceName: "service_mall_sj_dgsj"), #imageLiteral(resourceName: "service_mall_sj_tzsj"), #imageLiteral(resourceName: "service_mall_sj_3dsj")]
        let btnW: CGFloat = view.width/4
        let btnH: CGFloat = 70
        names.enumerated().forEach { (item) in
            let index = item.offset
            let image = images[index]
            let name = item.element
            let offsetY: CGFloat = 143.5+PublicSize.kNavBarHeight + 70*CGFloat(index/4)
            let offsetX: CGFloat = btnW*CGFloat(index%4)
            let btn = UIButton().image(image).text(name).textColor(.kColor33).font(10)
            headerView.sv(btn)
            headerView.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(btnH),
                >=0
            )
            btn.layoutButton(imageTitleSpace: 0)
            btn.tag = index
            btn.addTarget(self, action: #selector(sjBtnsClick(btn:)))
        }
        
        
        let sjCaseBtn = UIButton()
        let sjRJBtn = UIButton()
        let sjLine = UIView().backgroundColor(.kColor220)
        headerView.sv(sjCaseBtn, sjRJBtn, sjLine)
        headerView.layout(
            300+PublicSize.kNavBarHeight,
            |sjCaseBtn.height(105)-0-sjLine.width(0.5).height(105)-0-sjRJBtn.height(105)|,
            >=0
        )
        equal(widths: sjCaseBtn, sjRJBtn)
        configSJCaseViews(v: sjCaseBtn)
        configSJRJViews(v: sjRJBtn)
        sjCaseBtn.addTarget(self, action: #selector(sjCaseBtnClick(btn:)))
        sjRJBtn.addTarget(self, action: #selector(sjRJBtnClick(btn:)))
        return headerView
    }
    
    private func configSJCaseViews(v: UIButton) {
        let label = UILabel().text("设计案例").textColor(.kColor33).font(14)
        let image1 = UIImageView().image(#imageLiteral(resourceName: "service_mall_sj_1"))
        let image2 = UIImageView().image(#imageLiteral(resourceName: "service_mall_sj_2"))
        let vW: CGFloat = (view.width-1)/2
        let imageW: CGFloat = (vW-36)/2
        v.sv(label, image1, image2)
        v.layout(
            0,
            |-14-label.height(14),
            15,
            |-14-image1.size(imageW)-8-image2.size(imageW)-14-|,
            >=0
        )
    }
    
    private func configSJRJViews(v: UIButton) {
        let label = UILabel().text("设计软件").textColor(.kColor33).font(14)
        let image1 = UIImageView().image(#imageLiteral(resourceName: "service_mall_sj_3"))
        let image2 = UIImageView().image(#imageLiteral(resourceName: "service_mall_sj_4"))
        let vW: CGFloat = (view.width-1)/2
        let imageW: CGFloat = (vW-36)/2
        v.sv(label, image1, image2)
        v.layout(
            0,
            |-14-label.height(14),
            15,
            |-14-image1.size(imageW)-8-image2.size(imageW)-14-|,
            >=0
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        titleBar.setTransparent(scrollView.contentOffset.y)
    }

}
// MARK: - 按钮点击方法
extension ServiceMallDesignResourceVC {
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
    
    @objc private func sjBtnsClick(btn: UIButton) {
        let vc = ServiceMallDesignResourcesVC()
        vc.houseType = btn.titleLabel?.text
        navigationController?.pushViewController(vc)
    }
    
    @objc private func sjCaseBtnClick(btn: UIButton) {
        let vc = ServiceMallWorkerCaseVC()
        vc.caseType = .design
        navigationController?.pushViewController(vc)
    }
    
    @objc private func sjRJBtnClick(btn: UIButton) {
        noticeOnlyText("开发中，敬请期待～")
    }
    
    @objc private func moreBtnClick(btn: UIButton) {
        navigationController?.pushViewController(ServiceMallDesignResourcesVC())
    }
}

extension ServiceMallDesignResourceVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = UITableViewCell().backgroundColor(.kBackgroundColor)
        cell.frame = CGRect(x: 0, y: 0, width: view.width, height: 300)
        let content = UIView().backgroundColor(.white)
        cell.sv(content)
        cell.layout(
            0,
            |-14-content-14-| ~ 285,
            15
        )
        content.cornerRadius(5)
        content.addShadowColor()
        
        let avatar = UIImageView().image(#imageLiteral(resourceName: "img_buyer"))
        
        let name = UILabel().text(model?.name ?? "").textColor(.kColor33).font(12)
        let detail = UILabel().text("从业\(model?.workingYears ?? 0)年 | 案例\(model?.caseNum ?? 0)套").textColor(.kColor66).font(10)
        let detail1 = UILabel().text("擅长：\(model?.designStyle ?? "")").textColor(.kColor66).font(10)
        let image = UIImageView()
        let noDataBtn = UIButton().image(#imageLiteral(resourceName: "nodata_icon")).text("  暂无作品").textColor(.kColor66).font(14)
        image.sv(noDataBtn)
        noDataBtn.width(200).height(100)
        noDataBtn.centerInContainer()
        noDataBtn.isHidden = true
        if model?.caseList?.count ?? 0 > 0 {
            if !image.addImage(model?.caseList?.first?.mainImgUrl) {
                noDataBtn.isHidden = false
            } else {
                noDataBtn.isHidden = true
            }
            
        } else {
            noDataBtn.isHidden = false
        }
//        if !image.addImage(model?.logoUrl) {
//
//        }
        content.sv(avatar, name, detail, detail1, image)
        content.layout(
            12,
            |-12-avatar.size(44),
            12,
            |-12-image-12-| ~ 205,
            >=0
        )
        avatar.addImage(model?.headUrl)
        avatar.contentMode = .scaleAspectFit
        avatar.cornerRadius(22).masksToBounds()
        image.contentMode = .scaleAspectFit
        image.cornerRadius(5).masksToBounds()
        content.layout(
            12,
            |-68-name.height(12),
            5,
            |-68-detail.height(12),
            5,
            |-68-detail1.height(12)-14-|,
            >=0
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ServiceMallWorkerDetailVC()
        vc.detailType = .design
        vc.id = dataSource[indexPath.row]?.id
        navigationController?.pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300.0
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        let title = UILabel().text("精选推荐").textColor(.kColor33).font(14)
        let moreBtn = UIButton().text("更多资源>").textColor(.kColor33).font(12)
        
        let line = UIView().backgroundColor(#colorLiteral(red: 0.9960784314, green: 0.6823529412, blue: 0.1176470588, alpha: 1))
        v.sv(title, line, moreBtn)
        v.layout(
            15,
            |-14-title.height(14)-(>=0)-moreBtn.height(40)-14-|,
            3,
            |-14-line.width(58).height(2),
            >=0
        )
        moreBtn.addTarget(self, action: #selector(moreBtnClick))
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

