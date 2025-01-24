//
//  ServiceMallDesignResourcesVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/8.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh

class ServiceMallDesignResourcesVC: BaseViewController {
    enum selectBtnType {
        case style
        case houseType
        case area
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设计资源列表"
        configSelectViews()
        configCollectionViews()
        loadData()
    }
    // MARK: - 数据请求
    private var current = 1
    private var size = 20
    private var sortType = ""
    private var designType = ""
    private var designStyle = ""
    private var dataSource = [WorkTeamModel?]()
    func loadData() {
        var parameters = Parameters()
        parameters["current"] = current
        parameters["size"] = size
        parameters["sortType"] = sortType
        parameters["designType"] = designType
        parameters["designStyle"] = designStyle
        YZBSign.shared.request(APIURL.getDesignResourcesList, method: .get, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let pageModel = BasePageModel.deserialize(from: model?.data as? [String: Any])
                let teamModels = [WorkTeamModel].deserialize(from:pageModel?.records) ?? [WorkTeamModel]()
                if self.current == 1 {
                    self.dataSource = teamModels
                } else {
                    self.dataSource.append(contentsOf: teamModels)
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
    let styleBtnTitle = UILabel().text("综合排序").textColor(.kColor66).font(12)
    let styleBtnimage = UIImageView().image(#imageLiteral(resourceName: "down_arrows"))
    private func configStyleBtn() {
        styleBtn.sv(styleBtnTitle, styleBtnimage)
        |-30-styleBtnTitle.centerVertically()-5-styleBtnimage.width(6).height(3).centerVertically()
        styleBtn.addTarget(self, action: #selector(styleBtnClick(btn:)))
    }
    var houseType: String? {
        didSet {
            houseTypeBtnTitle.text(self.houseType ?? "类型")
            houseTypes.enumerated().forEach { (item) in
                if item.element == houseType {
                    currentHouseTypeIndex = item.offset
                }
            }
            designType = houseType ?? ""
        }
    }
    let houseTypeBtnTitle = UILabel().text("类型").textColor(.kColor66).font(12)
    let houseTypeBtnimage = UIImageView().image(#imageLiteral(resourceName: "down_arrows"))
    private func configHouseTypeBtn() {
        let spaceView = UIView()
        houseTypeBtn.sv(spaceView)
        spaceView.centerInContainer()
        spaceView.sv(houseTypeBtnTitle, houseTypeBtnimage)
        |houseTypeBtnTitle.centerVertically()-5-houseTypeBtnimage.width(6).height(3).centerVertically()|
        houseTypeBtn.addTarget(self, action: #selector(houseTypeBtnClick(btn:)))
    }
    let areaBtnTitle = UILabel().text("擅长空间").textColor(.kColor66).font(12)
    let areaBtnimage = UIImageView().image(#imageLiteral(resourceName: "down_arrows"))
    private func configAreaBtn() {
        areaBtn.sv(areaBtnTitle, areaBtnimage)
        areaBtnTitle.centerVertically()-5-areaBtnimage.width(6).height(3).centerVertically()-30-|
        areaBtn.addTarget(self, action: #selector(areaBtnClick(btn:)))
    }
    
    private let selectPopBgView = UIView().backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.302547089))
    private let selectPopView = UIView().backgroundColor(.white)
    private var selectBtns = [UIButton]()
    private let styles = ["综合排序", "案例最多", "咨询最多"]
    private let houseTypes = ["全部", "住宅设计", "工装设计", "软装设计", "平面设计", "园林设计", "灯光设计", "图纸深化", "3D设计"]
    private let areas = ["全部", "现代", "美式", "欧式", "中式", "北欧", "混搭", "新古典", "简欧", "工业", "后现代", "日式"]
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
        selectPopBgView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(hideSelectPopView)))
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
        let w: CGFloat = view.width-28
        layout.itemSize = CGSize(width: w, height: 180)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 14, bottom: 10, right: 14)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout).backgroundColor(.kBackgroundColor)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: ServiceMallDesignResourcesCell.self)
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
extension ServiceMallDesignResourcesVC {
    @objc private func styleBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
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
        } else {
            
            hideSelectPopView()
        }
         
    }
    
    @objc private func houseTypeBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
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
        } else {
            hideSelectPopView()
        }
        
    }
    
    @objc private func areaBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
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
        } else {
            hideSelectPopView()
        }
        
    }
    
    @objc private func selectBtnsClick(btn: UIButton) {
        styleBtn.isUserInteractionEnabled = true
        houseTypeBtn.isUserInteractionEnabled = true
        areaBtn.isUserInteractionEnabled = true
        styleBtn.isSelected = false
        houseTypeBtn.isSelected = false
        areaBtn.isSelected = false
        switch currentSelectBtnType {
        case .style:
            currentStyleIndex = btn.tag
            if btn.tag != 0 {
                styleBtnTitle.text(btn.titleLabel?.text ?? "")
                if btn.tag == 1 {
                    sortType = "1"
                } else if btn.tag == 2  {
                    sortType = "2"
                }
            } else {
                styleBtnTitle.text("综合排序")
                sortType = ""
            }
        case .houseType:
            currentHouseTypeIndex = btn.tag
            if btn.tag != 0 {
                houseTypeBtnTitle.text(btn.titleLabel?.text ?? "")
                designType = btn.titleLabel?.text ?? ""
            } else {
                houseTypeBtnTitle.text("类型")
                designType = ""
            }
        case .area:
            currentAreaIndex = btn.tag
            if btn.tag != 0 {
                areaBtnTitle.text(btn.titleLabel?.text ?? "")
                designStyle = btn.titleLabel?.text ?? ""
            } else {
                areaBtnTitle.text("擅长空间")
                designStyle = ""
            }
        }
        loadData()
        hideSelectPopView()
    }
    
    @objc private  func hideSelectPopView() {
        styleBtn.isUserInteractionEnabled = true
        houseTypeBtn.isUserInteractionEnabled = true
        areaBtn.isUserInteractionEnabled = true
        styleBtn.isSelected = false
        houseTypeBtn.isSelected = false
        areaBtn.isSelected = false
        
        
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
        
    }
}
 
extension ServiceMallDesignResourcesVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ServiceMallDesignResourcesCell.self, for: indexPath)
        cell.model = dataSource[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = ServiceMallWorkerDetailVC()
        vc.id = dataSource[indexPath.row]?.id
        vc.detailType = .design
        navigationController?.pushViewController(vc)
    }
}


class ServiceMallDesignResourcesCell: UICollectionViewCell {
    var model: WorkTeamModel? {
        didSet {
            configCell()
        }
    }
    
    private func configCell() {
        if !avatar.addImage(model?.headUrl) {
            avatar.image(#imageLiteral(resourceName: "img_buyer"))
        }
        
        name.text(model?.name ?? "")
        des1.text("从业\(model?.workingYears ?? 0)年 | 案例\(model?.caseNum ?? 0)套")
        des2.text("擅长：\(model?.designStyle ?? "")")
        [img1, img2, img3].forEach { (iv) in
            iv.isHidden = true
        }
        model?.caseList?.enumerated().forEach({ (item) in
            let index = item.offset
            let caseModel = item.element
            if index == 0 {
                img1.addImage(caseModel.mainImgUrl)
                img1.isHidden = false
            }
            if index == 1 {
                img2.addImage(caseModel.mainImgUrl)
                img2.isHidden = false
            }
            if index == 2 {
                img3.addImage(caseModel.mainImgUrl)
                img3.isHidden = false
            }
        })
        if model?.caseList?.count ?? 0 > 0 {
            noDataBtn.isHidden = true
        } else {
            noDataBtn.isHidden = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let avatar = UIImageView().image(#imageLiteral(resourceName: "img_buyer"))
    let name = UILabel().text("谭设计").textColor(.kColor33).font(12)
    let des1 = UILabel().text("从业2年 | 案例3套").textColor(.kColor66).font(10)
    let des2 = UILabel().textColor(.kColor66).font(10)
    let img1 = UIImageView().backgroundColor(.clear).cornerRadius(5).masksToBounds()
    let img2 = UIImageView().backgroundColor(.clear).cornerRadius(5).masksToBounds()
    let img3 = UIImageView().backgroundColor(.clear).cornerRadius(5).masksToBounds()
    let noDataBtn = UIButton()
    private func configViews() {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        backgroundColor(.white).cornerRadius(5).masksToBounds()
        sv(avatar, name, des1, des2, scrollView)
        layout(
            12,
            |-12-avatar.size(44),
            11.5,
            |scrollView| ~ 100,
            12.5
        )
        layout(
            12,
            |-68-name.height(12),
            5,
            |-68-des1.height(12),
            5,
            |-68-des2.height(12)-14-|,
            >=0
        )
        avatar.cornerRadius(22).masksToBounds()
        noDataBtn.image(#imageLiteral(resourceName: "nodata_icon")).text("  暂无作品").textColor(.kColor66).font(14)
        scrollView.sv(noDataBtn)
        noDataBtn.width(200).height(100)
        noDataBtn.centerInContainer()
        noDataBtn.isHidden = true
        scrollView.isUserInteractionEnabled = false
        img1.isUserInteractionEnabled = false
        img2.isUserInteractionEnabled = false
        img3.isUserInteractionEnabled = false
        scrollView.sv(img1, img2, img3)
        scrollView.layout(
            0,
            |-12-img1.size(100)-11.5-img2.size(100)-11.5-img3.size(100)-(>=12)-|,
            0
        )
        
    }
}

