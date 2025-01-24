//
//  ServiceMallWorkerCaseVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/5.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh

class ServiceMallWorkerCaseVC: BaseViewController {
    enum CaseType {
        case worker
        case design
    }
    enum selectBtnType {
        case style
        case houseType
        case area
    }
    public var caseType: CaseType = .worker
    override func viewDidLoad() {
        super.viewDidLoad()
        switch caseType {
        case .worker:
            title = "工长案例"
        case .design:
            title = "设计案例"
        }
        configSelectViews()
        configCollectionViews()
        loadData()
    }
    private var current = 1
    private var size = 20
    private var dataSource = [WorkCaseModel?]()
    private func loadData() {
        var parameters = Parameters()
        switch caseType {
        case .worker:
            parameters["type"] = "4"
        case .design:
            parameters["type"] = "5"
        }
        
        parameters["current"] = current
        parameters["size"] = size
        if currentStyleIndex > 0 {
            AppData.styleTypeList.forEach { (dic) in
                if styles[currentStyleIndex] == Utils.getReadString(dir: dic, field: "label") {
                    parameters["caseStyle"] = Utils.getReadString(dir: dic, field: "value")
                }
            }
            
        }
        if currentHouseTypeIndex > 0 {
            AppData.houseTypesList.forEach { (dic) in
                if houseTypes[currentHouseTypeIndex] == Utils.getReadString(dir: dic, field: "label") {
                    parameters["houseType"] = Utils.getReadString(dir: dic, field: "value")
                }
            }
        }
        if currentAreaIndex > 0 {
            AppData.houseAreaList.forEach { (dic) in
                if areas[currentAreaIndex] == Utils.getReadString(dir: dic, field: "label") {
                    parameters["houseArea"] = Utils.getReadString(dir: dic, field: "value")
                }
            }
        }
        YZBSign.shared.request(APIURL.findHouseCasePage, method: .get, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let pageModel = BasePageModel.deserialize(from: model?.data as? [String: Any])
                let caseModels = [WorkCaseModel].deserialize(from:pageModel?.records) ?? [WorkCaseModel]()
                if self.current == 1  {
                    self.dataSource = caseModels
                } else {
                    self.dataSource.append(contentsOf: caseModels)
                }
                self.collectionView.mj_header?.endRefreshing()
                if pageModel?.pages ?? 0 > pageModel?.current ?? 0 {
                    self.collectionView.mj_footer?.endRefreshing()
                } else {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }
                self.noDataView.isHidden = self.dataSource.count > 0
                self.collectionView.mj_footer?.isHidden = self.dataSource.count == 0
                self.collectionView.reloadData()
            } else {
                self.collectionView.mj_header?.endRefreshing()
                self.collectionView.mj_footer?.endRefreshing()
            }
        }) { (error) in
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
        }
    }
    
    private var selectView = UIView().backgroundColor(.white)
    private var styleBtn = UIButton()
    private var houseTypeBtn = UIButton()
    private var areaBtn = UIButton()
    
    private func configSelectViews() {
        view.sv(selectView.sv(styleBtn, houseTypeBtn, areaBtn))
        view.layout(
            0,
            |selectView| ~ 43,
            >=0
        )
        selectView.layout(
            0,
            |styleBtn-0-houseTypeBtn-0-areaBtn|,
            0
        )
        equal(widths: styleBtn, houseTypeBtn, areaBtn)
        configStyleBtn()
        configHouseTypeBtn()
        configAreaBtn()
    }
    let styleBtnTitle = UILabel().text("风格").textColor(.kColor66).font(12)
    let styleBtnimage = UIImageView().image(#imageLiteral(resourceName: "down_arrows"))
    private func configStyleBtn() {
        styleBtn.sv(styleBtnTitle, styleBtnimage)
        |-30-styleBtnTitle.centerVertically()-5-styleBtnimage.width(6).height(3).centerVertically()
        styleBtn.addTarget(self, action: #selector(styleBtnClick(btn:)))
    }
    let houseTypeBtnTitle = UILabel().text("户型").textColor(.kColor66).font(12)
    let houseTypeBtnimage = UIImageView().image(#imageLiteral(resourceName: "down_arrows"))
    private func configHouseTypeBtn() {
        let spaceView = UIView()
        houseTypeBtn.sv(spaceView)
        spaceView.centerInContainer()
        spaceView.sv(houseTypeBtnTitle, houseTypeBtnimage)
        |houseTypeBtnTitle.centerVertically()-5-houseTypeBtnimage.width(6).height(3).centerVertically()|
        houseTypeBtn.addTarget(self, action: #selector(houseTypeBtnClick(btn:)))
    }
    let areaBtnTitle = UILabel().text("面积").textColor(.kColor66).font(12)
    let areaBtnimage = UIImageView().image(#imageLiteral(resourceName: "down_arrows"))
    private func configAreaBtn() {
        areaBtn.sv(areaBtnTitle, areaBtnimage)
        areaBtnTitle.centerVertically()-5-areaBtnimage.width(6).height(3).centerVertically()-30-|
        areaBtn.addTarget(self, action: #selector(areaBtnClick(btn:)))
    }
    
    private let selectPopBgView = UIView().backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.302547089))
    private let selectPopView = UIView().backgroundColor(.white)
    private var selectBtns = [UIButton]()
    private lazy var styles: [String] = {
        let styleTypes = AppData.styleTypeList
        var styles = ["全部"]
        styleTypes.forEach { (dic) in
            let style = Utils.getReadString(dir: dic, field: "label")
            styles.append(style)
        }
        return styles
    }()
        
    private lazy var houseTypes: [String] = {
        let houseTypeList = AppData.houseTypesList
        var houseTypes = ["全部"]
        houseTypeList.forEach { (dic) in
            let houseType = Utils.getReadString(dir: dic, field: "label")
            houseTypes.append(houseType)
        }
        return houseTypes
    }()
    private lazy var areas: [String] = {
        let houseAreaList = AppData.houseAreaList
        var areas = ["全部"]
        houseAreaList.forEach { (dic) in
            let area = Utils.getReadString(dir: dic, field: "label")
            areas.append(area)
        }
        return areas
    }()
    private var currentSelectBtnType: selectBtnType = .style // 当前按钮风格
    private var currentStyleIndex = 0   // 当前风格索引
    private var currentHouseTypeIndex = 0 // 当前户型索引
    private var currentAreaIndex = 0 // 当前面积索引
    func configselectPopView() {
        selectPopView.removeSubviews()
        selectPopView.removeFromSuperview()
        selectPopBgView.removeSubviews()
        selectPopBgView.removeFromSuperview()
        let w: CGFloat = view.width
        let btnW: CGFloat = (w-90)/3
        let btnH: CGFloat = 30
        selectPopBgView.frame = CGRect(x: 0, y: 43, width: w, height: view.height*2)
        view.addSubview(selectPopBgView)
        selectPopView.frame = CGRect(x: 0, y: 43, width: w, height: 0)
        view.addSubview(selectPopView)
        
        var names = styles
        switch currentSelectBtnType {
        case .style:
            names = styles
        case .houseType:
            names = houseTypes
        case .area:
            names = areas
        }
        names.enumerated().forEach { (item) in
            let index = item.offset
            let region = item.element
            let offsetX: CGFloat = (btnW + 31) * (CGFloat(index%3)) + 14
            let offsetY: CGFloat = (btnH + 10) * (CGFloat(index/3)) + 15
            let btn = UIButton().text(region).font(12).cornerRadius(15).masksToBounds()
            selectPopView.sv(btn)
            selectPopView.layout(
                offsetY,
                |-offsetX-btn.width(btnW).height(30),
                >=0
            )
            var currentIndex = 0
            switch currentSelectBtnType {
            case .style:
                currentIndex = currentStyleIndex
            case .houseType:
                currentIndex = currentHouseTypeIndex
            case .area:
                currentIndex = currentAreaIndex
            }
            if index == currentIndex {
                btn.textColor(.k2FD4A7).borderColor(.k2FD4A7).borderWidth(0.5).backgroundColor(.kF2FFFB)
            } else {
                btn.textColor(.kColor33).borderColor(.kF7F7F7).borderWidth(0.5).backgroundColor(.kF7F7F7)
            }
            btn.tag = index
            btn.addTarget(self, action: #selector(selectBtnsClick(btn:)))
            selectBtns.append(btn)
        }
        selectBtns.forEach { (btn) in
            btn.alpha = 0
        }
        selectPopBgView.isHidden = true
    }
    
    private var collectionView: UICollectionView!
    func configCollectionViews() {
        let layout = UICollectionViewFlowLayout.init()
        let w: CGFloat = (view.width-39)/2
        layout.itemSize = CGSize(width: w, height: 211.5)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 14, bottom: 10, right: 14)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout).backgroundColor(.kBackgroundColor)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: ServiceMallWorkerCaseCell.self)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        view.sv(collectionView)
        view.layout(
            43,
            |collectionView|,
            0
        )
        collectionView.mj_header = MJRefreshGifCustomHeader()
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        collectionView.mj_footer = MJRefreshAutoNormalFooter()
        collectionView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        prepareNoDateView("暂无数据")
        noDataView.isHidden = true
    }
    
    @objc func headerRefresh() {
        collectionView.mj_footer?.resetNoMoreData()
        current = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        current += 1
        loadData()
    }
}
// MARK: - 按钮点击方法
extension ServiceMallWorkerCaseVC {
    @objc private func styleBtnClick(btn: UIButton) {
        currentSelectBtnType = .style
        configselectPopView()
        houseTypeBtn.isUserInteractionEnabled = false
        areaBtn.isUserInteractionEnabled = false
        let h: CGFloat = 15+CGFloat((styles.count+2)/3*40)
        selectPopBgView.isHidden = false
        styleBtnimage.image(#imageLiteral(resourceName: "service_mall_arrow_up"))
        styleBtnTitle.textColor(.kColor33)
        houseTypeBtnTitle.textColor(.kColor66)
        areaBtnTitle.textColor(.kColor66)
        UIView.animate(withDuration: 0.3, animations: {
            self.selectPopView.height = h
        }) { (action) in
            self.selectBtns.forEach { (btn) in
                btn.alpha = 1
            }
        }
    }
    
    @objc private func houseTypeBtnClick(btn: UIButton) {
        currentSelectBtnType = .houseType
        configselectPopView()
        styleBtn.isUserInteractionEnabled = false
        areaBtn.isUserInteractionEnabled = false
        let h: CGFloat = 15+CGFloat((houseTypes.count+2)/3*40)
        selectPopBgView.isHidden = false
        houseTypeBtnimage.image(#imageLiteral(resourceName: "service_mall_arrow_up"))
        styleBtnTitle.textColor(.kColor66)
        houseTypeBtnTitle.textColor(.kColor33)
        areaBtnTitle.textColor(.kColor66)
        UIView.animate(withDuration: 0.3, animations: {
            self.selectPopView.height = h
        }) { (action) in
            self.selectBtns.forEach { (btn) in
                btn.alpha = 1
            }
        }
    }
    
    @objc private func areaBtnClick(btn: UIButton) {
        currentSelectBtnType = .area
        configselectPopView()
        styleBtn.isUserInteractionEnabled = false
        houseTypeBtn.isUserInteractionEnabled = false
        let h: CGFloat = 15+CGFloat((areas.count+2)/3*40)
        selectPopBgView.isHidden = false
        areaBtnimage.image(#imageLiteral(resourceName: "service_mall_arrow_up"))
        styleBtnTitle.textColor(.kColor66)
        houseTypeBtnTitle.textColor(.kColor66)
        areaBtnTitle.textColor(.kColor33)
        UIView.animate(withDuration: 0.3, animations: {
            self.selectPopView.height = h
        }) { (action) in
            self.selectBtns.forEach { (btn) in
                btn.alpha = 1
            }
        }
    }
    
    @objc private func selectBtnsClick(btn: UIButton) {
        styleBtn.isUserInteractionEnabled = true
        houseTypeBtn.isUserInteractionEnabled = true
        areaBtn.isUserInteractionEnabled = true
        switch currentSelectBtnType {
        case .style:
            currentStyleIndex = btn.tag
            if btn.tag != 0 {
                styleBtnTitle.text(btn.titleLabel?.text ?? "")
            } else {
                styleBtnTitle.text("风格")
            }
        case .houseType:
            currentHouseTypeIndex = btn.tag
            if btn.tag != 0 {
                houseTypeBtnTitle.text(btn.titleLabel?.text ?? "")
            } else {
                houseTypeBtnTitle.text("户型")
            }
        case .area:
            currentAreaIndex = btn.tag
            if btn.tag != 0 {
                areaBtnTitle.text(btn.titleLabel?.text ?? "")
            } else {
                areaBtnTitle.text("面积")
            }
        }
        hideSelectPopView()
    }
    
    private func hideSelectPopView() {
        styleBtnimage.image(#imageLiteral(resourceName: "service_mall_arrow_down"))
        houseTypeBtnimage.image(#imageLiteral(resourceName: "service_mall_arrow_down"))
        areaBtnimage.image(#imageLiteral(resourceName: "service_mall_arrow_down"))
        selectPopBgView.isHidden = true
        self.selectBtns.forEach { (btn1) in
            btn1.alpha = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.selectPopView.height = 0
        }) { (action) in
        }
        loadData()
    }
    
    
    
}
 
extension ServiceMallWorkerCaseVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = dataSource[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withClass: ServiceMallWorkerCaseCell.self, for: indexPath)
        cell.model = model
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        let vc = WholeHouseDetailController()
        if let url = model?.url {
            vc.detailUrl = url
        }
       let caseModel = HouseCaseModel()
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
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


class ServiceMallWorkerCaseCell: UICollectionViewCell {
    var model: WorkCaseModel? {
        didSet {
            configCell()
        }
    }
    
    private func configCell() {
        topImage.addImage(model?.mainImgUrl)
        title.text(model?.caseRemarks ?? "")
        let style = model?.caseStyle
        var styleStr = ""
        AppData.styleTypeList.forEach { (dic) in
            if style == Utils.getReadString(dir: dic, field: "value") {
                styleStr = Utils.getReadString(dir: dic, field: "label")
            }
        }
        let houseStyle = model?.houseType
        var houseStyleStr = ""
        AppData.houseTypesList.forEach { (dic) in
            if houseStyle == Utils.getReadString(dir: dic, field: "value") {
                houseStyleStr = Utils.getReadString(dir: dic, field: "label")
            }
        }
        let houseArea = model?.houseArea
        var houseAreaStr = ""
        AppData.houseAreaList.forEach { (dic) in
            if houseArea == Utils.getReadString(dir: dic, field: "value") {
                houseAreaStr = Utils.getReadString(dir: dic, field: "label")
            }
        }
        detail.text("\(houseStyleStr)|\(styleStr)|\(houseAreaStr)")
        avatar.addImage(model?.headUrl)
        name.text(model?.name ?? "")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let topImage = UIImageView().image(#imageLiteral(resourceName: "plus_backImage"))
    private let title = UILabel().text("简约而不简单，工薪阶层现代风三居").textColor(.kColor33).font(12).numberOfLines(2)
    private let detail = UILabel().text("三室 | 现代简约 | 100㎡").textColor(.kColor66).font(11)
    private let avatar = UIImageView().image(#imageLiteral(resourceName: "home_worker"))
    private let name = UILabel().text("徐海").textColor(.kColor33).font(10)
    private func configViews() {
        backgroundColor(.white)
        title.lineSpace(5)
        sv(topImage, title, detail, avatar, name)
        layout(
            0,
            |topImage.height(120)|,
            5,
            |-6-title-6-|,
            >=5,
            |-6-detail.height(14),
            5,
            |-6-avatar.size(25)-5-name.height(10),
            7
        )
        avatar.cornerRadius(12.5).masksToBounds()
        topImage.contentMode = .scaleAspectFit
        topImage.corner(byRoundingCorners: [.topLeft, .topRight], radii: 5)
        topImage.corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 1)
        cornerRadius(5).masksToBounds()
    }
    
    
}
