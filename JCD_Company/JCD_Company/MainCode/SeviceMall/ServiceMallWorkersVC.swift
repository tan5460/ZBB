//
//  ServiceMallWorkersVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/5.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh

class ServiceMallWorkersVC: BaseViewController {
    enum selectBtnType {
        case region
        case workType
    }
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    private let noDataLabel = UILabel().text("暂无数据").textColor(.kColor66).font(14)
    private var headerView = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
        title = "工人列表"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
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
        
        
        tableView.sv(noDataLabel)
        noDataLabel.centerInContainer()
        noDataLabel.isHidden = true
        
        loadData()
        loadProvData()
       // loadBannerData()
    }
    private var current: Int = 1
    private var size: Int = 20
    var dataSource = [WorkTeamModel?]()
    //MARK: - Data
    public func loadData() {
        var parameters = Parameters()
        parameters["serviceType"] = "5"
        if currentWorkTypeIndex > 0 {
            let workTypes = AppData.workTypes
            let workType = workTypes[currentWorkTypeIndex-1]
            parameters["workType"] = Utils.getReadString(dir: workType, field: "value")
        }
        if currentRegionIndex > 0 {
            parameters["provId"] = proviceModels[currentRegionIndex-1]?.id
        }
        if popularityBtn.isSelected {
            parameters["sortType"] = 25
        }
        
        parameters["current"] = current
        parameters["size"] = size
        YZBSign.shared.request(APIURL.getServiceWorkerPage, method: .get, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let pageModel = BasePageModel.deserialize(from: model?.data as? [String: Any])
                let teamModels = [WorkTeamModel].deserialize(from:pageModel?.records) ?? [WorkTeamModel]()
                if self.current == 1 {
                    self.dataSource = teamModels
                } else {
                    self.dataSource.append(contentsOf: teamModels)
                }
                self.tableView.mj_header?.endRefreshing()
                if pageModel?.pages ?? 0 > pageModel?.current ?? 0 {
                    self.tableView.mj_footer?.endRefreshing()
                } else {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }
                self.noDataLabel.isHidden = self.dataSource.count > 0
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
    
    @objc func headerRefresh() {
        tableView.mj_footer?.resetNoMoreData()
        current = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        current += 1
        loadData()
    }
    private var proviceModels = [ProviceModel?]()
    private var provs = ["全国"]
    private func loadProvData() {
        YZBSign.shared.request(APIURL.getProvs, method: .get, parameters: Parameters(), success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                self.proviceModels = [ProviceModel].deserialize(from: model?.data as? [Any]) ?? [ProviceModel]()
                self.proviceModels.forEach { (proviceModel) in
                    self.provs.append(proviceModel?.shortName ?? "")
                }
                self.regions = self.provs
            }
        }) { (error) in
            
        }
    }
    
    func loadBannerData() {
        var parameters = Parameters()
        parameters["type"] = "4" //工人资源二级页面banner
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
    
    private let regionBtn = UIButton()
    private let workTypeBtn = UIButton()
    private let popularityBtn = UIButton()
    
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = #imageLiteral(resourceName: "service_mall_banner_workerlist1")
        cycleScrollView.placeHolderImage = #imageLiteral(resourceName: "service_mall_banner_workerlist1")
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(5).masksToBounds()
    }
    
    func configHeaderView() -> UIView {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 227)).backgroundColor(.white)
        v.sv(cycleScrollView, regionBtn, workTypeBtn, popularityBtn)
        v.layout(
            15,
            |-14-cycleScrollView-14-| ~ 170,
            0,
            |regionBtn-0-workTypeBtn-0-popularityBtn|,
            0
        )
        equal(widths: [regionBtn, workTypeBtn, popularityBtn])
        
        configRegionBtnSubViews()
        configworkTypeBtnSubViews()
        configPopularityBtnSubViews()
        headerView = v
        return v
    }
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
    private let workTypeBtnTitle = UILabel().text("工种类型").textColor(.kColor66).font(12)
    private let workTypeBtnImage = UIImageView().image(#imageLiteral(resourceName: "down_arrows"))
    private func configworkTypeBtnSubViews()  {
        let spaceView = UIView()
        workTypeBtn.sv(spaceView)
        spaceView.centerInContainer()
        spaceView.sv(workTypeBtnTitle, workTypeBtnImage)
        |workTypeBtnTitle.centerVertically()-5-workTypeBtnImage.width(6).height(3).centerVertically()|
        workTypeBtn.addTarget(self, action: #selector(workTypeBtnClick(btn:)))
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
    private var regionBtns = [UIButton]()
    private var regions = ["全国", "北京市", "北京市", "上海市", "长沙市", "南京市", "南昌市"]
    private var workTypes: [String] = {
        var workTypes = ["全国"]
        let workTypeList = AppData.workTypes
        AppData.workTypes.forEach { (dic) in
            workTypes.append(Utils.getReadString(dir: dic, field: "label"))
        }
        return workTypes
    }()
    private var currentSelectBtnType: selectBtnType = .region // 当前按钮风格
    private var currentRegionIndex = 0   // 当前区域索引
    private var currentWorkTypeIndex = 0 // 当前类型索引
    func configRegionPopView() {
        regionPopView.removeSubviews()
        regionPopView.removeFromSuperview()
        regionPopBgView.removeSubviews()
        regionPopBgView.removeFromSuperview()
        let w: CGFloat = view.width
        let btnW: CGFloat = (w-90)/3
        let btnH: CGFloat = 30
        regionPopBgView.frame = CGRect(x: 0, y: 0, width: w, height: view.height*2)
        tableView.addSubview(regionPopBgView)
        regionPopView.frame = CGRect(x: 0, y: 227, width: w, height: 0)
        tableView.addSubview(regionPopView)
        var names = regions
        switch currentSelectBtnType {
        case .region:
            names = regions
        case .workType:
            names = workTypes
        }
        names.enumerated().forEach { (item) in
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
            var currentIndex = 0
            switch currentSelectBtnType {
            case .region:
                currentIndex = currentRegionIndex
            case .workType:
                currentIndex = currentWorkTypeIndex
            }
            if index == currentIndex {
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
    }
}

// MARK: - 按钮点击方法
extension ServiceMallWorkersVC {
    @objc private func regionBtnClick(btn: UIButton) {
        let h: CGFloat = 15+CGFloat((regions.count+2)/3*40)
        regionPopBgView.isHidden = false
        tableView.isScrollEnabled = false
        regionBtnImage.image(#imageLiteral(resourceName: "service_mall_arrow_up"))
        regionBtnTitle.textColor(.kColor33).fontBold(12)
        currentSelectBtnType = .region
        configRegionPopView()
        workTypeBtn.isUserInteractionEnabled = false
        popularityBtn.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
            self.regionPopView.height = h
        }) { (action) in
            self.regionBtns.forEach { (btn) in
                btn.alpha = 1
            }
        }
    }
    
    @objc private func regionBtnsClick(btn: UIButton) {
        regionBtn.isUserInteractionEnabled = true
        workTypeBtn.isUserInteractionEnabled = true
        popularityBtn.isUserInteractionEnabled = true
        switch currentSelectBtnType {
        case .region:
            currentRegionIndex = btn.tag
            if btn.tag != 0 {
                regionBtnTitle.text(btn.titleLabel?.text ?? "")
            } else {
                regionBtnTitle.text("区域")
            }
        case .workType:
            currentWorkTypeIndex = btn.tag
            if btn.tag != 0 {
                workTypeBtnTitle.text(btn.titleLabel?.text ?? "")
            } else {
                workTypeBtnTitle.text("工种类型")
            }
        }
        hideRegionPopView()
    }
    
    @objc private func workTypeBtnClick(btn: UIButton) {
        let h: CGFloat = 15+CGFloat((workTypes.count+2)/3*40)
        regionPopBgView.isHidden = false
        tableView.isScrollEnabled = false
        workTypeBtnImage.image(#imageLiteral(resourceName: "service_mall_arrow_up"))
        workTypeBtnTitle.textColor(.kColor33).fontBold(12)
        currentSelectBtnType = .workType
        configRegionPopView()
        regionBtn.isUserInteractionEnabled = false
        popularityBtn.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3, animations: {
            self.regionPopView.height = h
        }) { (action) in
            self.regionBtns.forEach { (btn) in
                btn.alpha = 1
            }
        }
    }
    
    @objc private func popularityBtnClick(btn: UIButton) {
        popularityBtn.isSelected = !popularityBtn.isSelected
        currentSortIndex = 1
        if popularityBtn.isSelected {
            popularityBtnTitle.textColor(.kColor33).fontBold(12)
        } else {
            popularityBtnTitle.textColor(.kColor66).font(12)
        }
        hideRegionPopView()
    }
    
    func hideRegionPopView() {
        regionBtnImage.image(#imageLiteral(resourceName: "service_mall_arrow_down"))
        workTypeBtnImage.image(#imageLiteral(resourceName: "service_mall_arrow_down"))
        tableView.isScrollEnabled = true
        regionPopBgView.isHidden = true
        self.regionBtns.forEach { (btn1) in
            btn1.alpha = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.regionPopView.height = 0
        }) { (action) in
        }
        loadData()
    }
}


extension ServiceMallWorkersVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = UITableViewCell().backgroundColor(.kBackgroundColor)
        cell.selectionStyle = .none
        let content = UIView().backgroundColor(.white).cornerRadius(5).masksToBounds()
        cell.sv(content)
        cell.layout(
            0,
            |-14-content-14-|,
            14
        )
        let avatar = UIImageView().image(#imageLiteral(resourceName: "img_buyer")).cornerRadius(20).masksToBounds()
        avatar.addImage(model?.headUrl)
        let name = UILabel().text(model?.name ?? "").textColor(.kColor33).font(12)
        let name1 =  UILabel().text("服务区域：\(model?.cityName ?? "全国")").textColor(.kColor66).font(10).textAligment(.center)
        
        var workTypeStr = "无"
        let workType = model?.workType
        let workTypes = workType?.components(separatedBy: ",")
        workTypes?.forEach({ (tmpWorkType) in
            AppData.workTypes.forEach { (dic) in
                if tmpWorkType == Utils.getReadString(dir: dic, field: "value") {
                    let workTyeeLabel = Utils.getReadString(dir: dic, field: "label")
                    if workTypeStr == "无" {
                        workTypeStr = workTyeeLabel
                    } else {
                        workTypeStr += ",\(workTyeeLabel)"
                    }
                }
                
            }
        })
        
        let detail = UILabel().text("\(workTypeStr)、从业\(model?.workingYears ?? 0)年").textColor(.kColor66).font(10)
        let moreBtn = UIButton().text("了解更多").textColor(.white).font(10).backgroundColor(#colorLiteral(red: 0.9843137255, green: 0.6705882353, blue: 0, alpha: 1)).cornerRadius(10)
        detail.numberOfLines(2).lineSpace(2)
        content.sv(avatar, name, name1, detail, moreBtn)
        |-13-avatar.size(40).centerVertically()
        moreBtn.width(60).height(20).centerVertically()-29-|
        content.layout(
            15,
            |-66-name.height(12)-15-name1.height(10),
            13,
            |-66-detail-100-|,
            >=0
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        let vc = ServiceMallWorkerDetailVC()
        vc.detailType = .worker
        vc.id = model?.id
        navigationController?.pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView().backgroundColor(.kBackgroundColor)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
