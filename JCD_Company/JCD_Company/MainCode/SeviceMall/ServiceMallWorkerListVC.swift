//
//  ServiceMallWorkerListVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/3.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh

class ServiceMallWorkerListVC: BaseViewController {
    
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    private var headerView = UIView()
    private let noDataBtn = UIButton().image(#imageLiteral(resourceName: "icon_empty")).text("暂无数据").textColor(.kColor66).font(14)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
        title = "工长列表"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        // tableView.separatorStyle = .none
        tableView.tableHeaderView = configHeaderView()
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        tableView.mj_header = MJRefreshGifCustomHeader()
        tableView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_footer = MJRefreshAutoNormalFooter()
        tableView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        tableView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.centerInContainer()
        noDataBtn.isHidden = true
        loadData()
       // loadBannerData()
        loadCitysData()
    }
    
    @objc func headerRefresh() {
        tableView.mj_footer?.resetNoMoreData()
        current = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        current += 1
        loadData()
    }
    
    private var dataSource = [WorkTeamModel?]()
    private var current = 1
    private var size = 20
    private var sortType = 3
    private var cityId = ""
    func loadData() {
        var parameters = Parameters()
        parameters["size"] = size
        parameters["current"] = current
        if sortType == 2 || sortType == 3 {
            parameters["sortType"] = "\(sortType)"
        }
        if !cityId.isEmpty {
            parameters["cityId"] = cityId
        }
        YZBSign.shared.request(APIURL.getMoreForemanTeam, method: .get, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let pageModel = BasePageModel.deserialize(from: model?.data as? [String: Any])
                let serviceTypeModels = [WorkTeamModel].deserialize(from:pageModel?.records) ?? [WorkTeamModel]()
                if self.current == 1 {
                    self.dataSource = serviceTypeModels
                } else {
                    self.dataSource.append(contentsOf: serviceTypeModels)
                }
                self.tableView.mj_header?.endRefreshing()
                if pageModel?.pages ?? 0 > pageModel?.current ?? 0 {
                    self.tableView.mj_footer?.endRefreshing()
                } else {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                self.noDataBtn.isHidden = self.dataSource.count > 0
                self.tableView.mj_footer?.isHidden = self.dataSource.count == 0
                self.tableView.reloadData()
            } else {
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.endRefreshing()
            }
        }) { (error) in
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
        }
    }
    
    func loadBannerData() {
        var parameters = Parameters()
        parameters["type"] = "3" //工长团队banner
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
    private var citys = [ProviceModel?]()
    func loadCitysData() {
        YZBSign.shared.request(APIURL.getSubstationCity, method: .get, parameters: Parameters(), success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                self.citys = [ProviceModel].deserialize(from: model?.data as? [Any]) ?? [ProviceModel]()
                self.citys.forEach { (proviceModel) in
                    self.regions.append(proviceModel?.shortName ?? "未知")
                }
                
            }
        }) { (error) in
            
        }
    }
    
    private let regionBtn = UIButton()
    private let recommendBtn = UIButton()
    private let popularityBtn = UIButton()
    
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = #imageLiteral(resourceName: "service_mall_banner_workerlist")
        cycleScrollView.placeHolderImage = #imageLiteral(resourceName: "service_mall_banner_workerlist")
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    
    func configHeaderView() -> UIView {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 227)).backgroundColor(.white)
        v.sv(cycleScrollView, regionBtn, recommendBtn, popularityBtn)
        v.layout(
            15,
            |-14-cycleScrollView-14-| ~ 170,
            0,
            |regionBtn-0-recommendBtn-0-popularityBtn|,
            0
        )
        equal(widths: [regionBtn, recommendBtn, popularityBtn])
        
        configRegionBtnSubViews()
        configRecommendBtnSubViews()
        configPopularityBtnSubViews()
        headerView = v
        return v
    }
    private var currentRegionIndex = 0
    private var currentSortIndex = 0
    /// 区域
    private let regionBtnTitle = UILabel().text("区域").textColor(.kColor66).font(12)
    private let regionBtnImage = UIImageView().image(#imageLiteral(resourceName: "service_mall_arrow_down"))
    private func configRegionBtnSubViews()  {
        regionBtn.sv(regionBtnTitle, regionBtnImage)
        |-24-regionBtnTitle.centerVertically()-5-regionBtnImage.centerVertically()
        regionBtn.addTarget(self, action: #selector(regionBtnClick(btn:)))
    }
    /// 推荐排序
    private let recommendBtnTitle = UILabel().text("推荐排序").textColor(.kColor66).font(12)
    private func configRecommendBtnSubViews()  {
        recommendBtn.sv(recommendBtnTitle)
        recommendBtnTitle.centerInContainer()
        recommendBtn.addTarget(self, action: #selector(recommendBtnClick(btn:)))
    }
    /// 人气优先
    private let popularityBtnTitle = UILabel().text("人气优先").textColor(.kColor66).font(12)
    private func configPopularityBtnSubViews()  {
        popularityBtn.sv(popularityBtnTitle)
        popularityBtnTitle.centerVertically()-24-|
        popularityBtn.addTarget(self, action: #selector(popularityBtnClick(btn:)))
    }
    private let regionPopBgView = UIView().backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.302547089))
    private let regionPopView = UIView().backgroundColor(.white)
    private var regions = ["全国"]
    private var regionBtns = [UIButton]()
    func configRegionPopView() {
        let w: CGFloat = view.width
        let btnW: CGFloat = (w-90)/3
        let btnH: CGFloat = 30
        regionPopBgView.removeSubviews()
        regionPopBgView.removeFromSuperview()
        regionPopView.removeSubviews()
        regionPopView.removeFromSuperview()
        regionPopBgView.frame = CGRect(x: 0, y: 0, width: w, height: view.height*2)
        tableView.addSubview(regionPopBgView)
        regionPopView.frame = CGRect(x: 0, y: 227, width: w, height: 0)
        tableView.addSubview(regionPopView)
        regions.enumerated().forEach { (item) in
            let index = item.offset
            let region = item.element
            let offsetX: CGFloat = (btnW + 31) * (CGFloat(index%3)) + 14
            let offsetY: CGFloat = (btnH + 10) * (CGFloat(index/3)) + 15
            let btn = UIButton().text(region).font(12).cornerRadius(15).masksToBounds()
            regionPopView.sv(btn)
            regionPopView.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(30),
                >=0
            )
            if index == 0 {
                btn.textColor(.k2FD4A7).borderColor(.k2FD4A7).borderWidth(0.5).backgroundColor(.kF2FFFB)
            } else {
                btn.textColor(.kColor33).borderColor(.kF7F7F7).borderWidth(0.5).backgroundColor(.kF7F7F7)
            }
            btn.tag = index
            btn.addTarget(self, action: #selector(regionBtnsClick))
            regionBtns.append(btn)
        }
        regionBtns.forEach { (btn) in
            btn.alpha = 0
        }
        regionPopBgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hidePopBgView)))
    }
    
    @objc func hidePopBgView() {
        hideRegionPopView()
    }
}

// MARK: - 按钮点击方法
extension ServiceMallWorkerListVC {
    @objc private func regionBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            let h: CGFloat = 15+CGFloat((regions.count+2)/3*40)
            
            regionBtnImage.image(#imageLiteral(resourceName: "service_mall_arrow_up"))
            regionBtnTitle.textColor(.kColor33)
            recommendBtnTitle.textColor(.kColor66)
            popularityBtnTitle.textColor(.kColor66)
            configRegionPopView()
            regionPopBgView.isHidden = false
            tableView.isScrollEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                self.regionPopView.height = h
            }) { (action) in
                self.regionBtns.forEach { (btn) in
                    btn.alpha = 1
                }
            }
        } else {
            hideRegionPopView()
        }
    }
    
    @objc private func regionBtnsClick(btn: UIButton) {
        currentRegionIndex = btn.tag
        if btn.tag > 1 {
            cityId = citys[btn.tag-1]?.id ?? ""
        } else {
            cityId = ""
        }
        if btn.tag != 0 {
            regionBtnTitle.text(btn.titleLabel?.text ?? "")
        } else {
            regionBtnTitle.text("区域")
        }
        headerRefresh()
        hideRegionPopView()
    }
    
    @objc private func recommendBtnClick(btn: UIButton) {
        sortType = 1
        currentSortIndex = 0
        regionBtnTitle.textColor(.kColor66)
        recommendBtnTitle.textColor(.kColor33)
        popularityBtnTitle.textColor(.kColor66)
        headerRefresh()
        hideRegionPopView()
    }
    
    @objc private func popularityBtnClick(btn: UIButton) {
        sortType = 2
        currentSortIndex = 1
        regionBtnTitle.textColor(.kColor66)
        recommendBtnTitle.textColor(.kColor66)
        popularityBtnTitle.textColor(.kColor33)
        headerRefresh()
        hideRegionPopView()
    }
    
    func hideRegionPopView() {
        regionBtn.isSelected = false
        regionBtnImage.image(#imageLiteral(resourceName: "service_mall_arrow_down"))
        tableView.isScrollEnabled = true
        regionPopBgView.isHidden = true
        self.regionBtns.forEach { (btn1) in
            btn1.alpha = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.regionPopView.height = 0
        }) { (action) in
        }
    }
}


extension ServiceMallWorkerListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let teamModel = dataSource[indexPath.row]
        
        let cell = UITableViewCell()
        
        let avatar = UIImageView().image(#imageLiteral(resourceName: "img_buyer")).cornerRadius(5).masksToBounds()
        if !avatar.addImage(teamModel?.headUrl) {
            avatar.image(#imageLiteral(resourceName: "img_buyer"))
        }
        avatar.contentMode = .scaleAspectFit
        let name = UILabel().text(teamModel?.name ?? "未知").textColor(.kColor33).font(14)
        let name1 = UILabel().text("  行业从事\(teamModel?.workingYears ?? 0)年  ").textColor(.white).font(10).textAligment(.center).backgroundColor(#colorLiteral(red: 0.9647058824, green: 0.7019607843, blue: 0.4980392157, alpha: 1)).cornerRadius(2).masksToBounds()
        var detailStr = ""
        teamModel?.workerTypeNames?.enumerated().forEach({ (item) in
            let index = item.offset
            let workerTypeName = item.element
            if index > 0 {
                detailStr.append("、")
            }
            detailStr.append(workerTypeName)
        })
        let detail = UILabel().text(detailStr).textColor(.kColor66).font(10)
        let groupView = UIView()
        let moreBtn = UIButton().text("了解更多").textColor(.white).font(10).backgroundColor(#colorLiteral(red: 0.9843137255, green: 0.6705882353, blue: 0, alpha: 1)).cornerRadius(10)
        moreBtn.isUserInteractionEnabled = false
        cell.sv(avatar, name, name1, detail, groupView, moreBtn)
        |-14-avatar.size(60).centerVertically()
        moreBtn.width(60).height(20).centerVertically()-26-|
        cell.layout(
            16,
            |-89-name.height(14)-10-name1.height(16),
            7,
            |-89-detail.height(10)-100-|,
            10,
            |-89-groupView.height(18)-100-|,
            >=0
        )
        teamModel?.workerData?.enumerated().forEach { (item) in
            let index = item.offset
            let workData = item.element
            let imageOffsetX: CGFloat = 24*CGFloat(index)
            if index > 4 {
                return
            }
            if index == 4 {
                let groupIV = UIImageView().image(#imageLiteral(resourceName: "service_mall_more"))
                groupIV.frame = CGRect(x: imageOffsetX+4, y: 8, width: 10, height: 2)
                groupView.addSubview(groupIV)
            } else {
                let groupIV = UIImageView().image(#imageLiteral(resourceName: "img_buyer")).cornerRadius(9).masksToBounds()
                groupIV.frame = CGRect(x: imageOffsetX, y: 0, width: 18, height: 18)
                groupView.addSubview(groupIV)
                groupIV.addImage(workData.headImg)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let teamModel = dataSource[indexPath.row]
        let vc = ServiceMallWorkerGroupVC()
        vc.teamId = teamModel?.id ?? ""
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.25
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
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

