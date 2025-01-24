//
//  GXQCCLVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/21.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import TLTransitions
import ObjectMapper

class GXQCCLVC: BaseViewController, UITextFieldDelegate {
    private var pop: TLTransition?
    private var qcModel: GXQCModel?
    private var materials: [MaterialsModel] = []
    private var currentCategory: String?
    private var currentPrice: String? // 升序asc 降序desc
    private var currentBrand: String?
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
        setupSearchSubViews()
        setupBanner()
        setupSelectViews()
        setupCollectionViews()
        loadBrandsData()
        loadData()
        GlobalNotificationer.add(observer: self, selector: #selector(refresh), notification: .purchaseRefresh)
    }
        
    @objc func refresh() {
        current = 1
        loadData()
    }
    
    deinit {
        GlobalNotificationer.remove(observer: self, notification: .purchaseRefresh)
    }

    private func loadBrandsData() {
        YZBSign.shared.request(APIURL.getClearanceBrandAndCategory, method: .get, parameters: Parameters(), success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                self.qcModel = Mapper<GXQCModel>().map(JSONObject: dataDic)
            }
        }) { (error) in
            
        }
    }
    var current = 1
    private func loadData() {
        let pageSize = 10
        var parameters = Parameters()
        parameters["size"] = pageSize
        parameters["current"] = current
        if currentCategory != nil {
            parameters["categoryaId"] = currentCategory
        }
        if currentPrice != nil {
            parameters["priceSort"] = currentPrice
        }
        if currentBrand != nil {
            parameters["brandName"] = currentBrand
        }
        if searchTextField.text != "" {
            parameters["materialsName"] = searchTextField.text ?? ""
        }
        parameters["isCheck"] = "1"
        parameters["shelfFlag"] = "1"
        YZBSign.shared.request(APIURL.getClearancActivities, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let total = Utils.getReadString(dir: dataDic, field: "total")
                let models = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.collectionView.reloadData()
                if self.current == 1 {
                    self.materials = models
                } else {
                    self.materials.append(contentsOf: models)
                }
                self.collectionView.endHeaderRefresh()
                if total.toInt ?? 0 > self.materials.count {
                    self.collectionView.endFooterRefresh()
                } else {
                    self.collectionView.endFooterRefreshNoMoreData()
                }
                self.noDataBtn.isHidden = self.materials.count > 0
            }
        }) { (error) in
            self.collectionView.endHeaderRefresh()
            self.collectionView.endFooterRefresh()
        }
    }
    
    private let backBtn = UIButton().image(#imageLiteral(resourceName: "detail_back"))
    private let searchBg = UIView().backgroundColor(.kF0F0F0).cornerRadius(16).masksToBounds()
    private let searchTextField = UITextField()
    private let searchIcon = UIImageView().image(#imageLiteral(resourceName: "icon_searchBar"))
    private func setupSearchSubViews() {
        let line = UIView().backgroundColor(.kColorEE)
        view.sv(backBtn, searchBg, line)
        view.layout(
            PublicSize.kStatusBarHeight,
            |-5-backBtn.size(44)-20-searchBg.height(32)-51.5-|,
            0,
            |line.height(0.5)|,
            >=0
        )
        searchBg.sv(searchIcon, searchTextField)
        searchBg.layout(
            8.5,
            |-15-searchIcon.size(15)-5-searchTextField.height(32)-5-|,
            >=0
        )
        searchTextField.placeholder("请输入商品名").setPlaceHolderTextColor(.kColor99)
        searchTextField.font = .systemFont(ofSize: 14)
        searchTextField.delegate = self
        backBtn.addTarget(self, action: #selector(backBtnClick(btn:)))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        current = 1
        loadData()
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
    
    private let bannerIV = UIImageView().image(#imageLiteral(resourceName: "gx_qc_banner"))
    private func setupBanner() {
        view.sv(bannerIV)
        view.layout(
            PublicSize.kNavBarHeight+15,
            |-14-bannerIV.height(110)-14-|,
            >=0
        )
    }
    private var categorySelectBtn = UIButton()
    private var categorySelectLab = UILabel().text("分类").textColor(.kColor66).font(12)
    private var categorySelectIV = UIImageView().image(#imageLiteral(resourceName: "gx_qc_arrow_down"))
    private var priceSelectBtn = UIButton()
    private var priceSelectLab = UILabel().text("价格").textColor(.kColor66).font(12)
    private var priceSelectIV = UIImageView().image(#imageLiteral(resourceName: "gx_qc_arrow_down"))
    private var brandSelectBtn = UIButton()
    private var brandSelectLab = UILabel().text("品牌").textColor(.kColor66).font(12)
    private var brandSelectIV = UIImageView().image(#imageLiteral(resourceName: "gx_qc_pp_unselect"))
    private func setupSelectViews() {
        view.sv(categorySelectBtn, priceSelectBtn, brandSelectBtn)
        view.layout(
            PublicSize.kNavBarHeight+125,
            |categorySelectBtn-0-priceSelectBtn-0-brandSelectBtn|,
            >=0
        )
        categorySelectBtn.height(46)
        equal(widths: categorySelectBtn, priceSelectBtn, brandSelectBtn)
        equal(heights: categorySelectBtn, priceSelectBtn, brandSelectBtn)
        
        categorySelectBtn.sv(categorySelectLab, categorySelectIV)
        |-24-categorySelectLab.centerVertically()-5-categorySelectIV.centerVertically()
        
        let priceV = UIView()
        priceSelectBtn.sv(priceV)
        priceV.centerInContainer()
        priceV.sv(priceSelectLab, priceSelectIV)
        |priceSelectLab.centerVertically()-5-priceSelectIV.centerVertically()|
        
        brandSelectBtn.sv(brandSelectLab, brandSelectIV)
        brandSelectLab.centerVertically()-5-brandSelectIV.centerVertically()-24-|
        categorySelectBtn.addTarget(self, action: #selector(categorySelectBtnClick(btn:)))
        priceSelectBtn.addTarget(self, action: #selector(priceSelectBtnClick(btn:)))
        brandSelectBtn.addTarget(self, action: #selector(brandSelectBtnClick(btn:)))
    }
    
   
    // MARK: - 价格
    @objc private func priceSelectBtnClick(btn: UIButton) {
        priceSelectBtn.isSelected = !priceSelectBtn.isSelected
        if priceSelectBtn.isSelected {
            priceSelectIV.image(#imageLiteral(resourceName: "gx_qc_arrow_down"))
            currentPrice = "desc"
        } else {
            priceSelectIV.image(#imageLiteral(resourceName: "gx_qc_arrow_up"))
            currentPrice = "asc"
        }
        current = 1
        loadData()
    }
    
    // MARK: - 分类
    @objc private func categorySelectBtnClick(btn: UIButton) {
           categorySelectIV.image(#imageLiteral(resourceName: "gx_qc_arrow_up"))
           categoryPopView()
    }
    
    func categoryPopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.kScreenWidth, height: PublicSize.kScreenHeight))
        let sv = UIScrollView(frame: CGRect(x: 0, y: PublicSize.kNavBarHeight+171-PublicSize.kStatusBarHeight, width: view.width, height: 200)).backgroundColor(.white)
        v.addSubview(sv)
        v.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismiss(tap:))))
        pop = TLTransition.show(v, to: CGPoint(x: 0, y: 0))
        pop?.cornerRadius = 0
        setupCategoryBtns(sv)
    }
    
    private var currentCategoryIndex: Int?
    func setupCategoryBtns(_ sv: UIScrollView) {
        let spaceW = (view.width-313)/2
        var tmpCategorys = qcModel?.category
        let allCategory = GXQCCategoryModel()
        allCategory.name = "全部"
        tmpCategorys?.insert(allCategory, at: 0)
        tmpCategorys?.enumerated().forEach { (item) in
            let index = item.offset
            let categoryModel = item.element
            let offsetX: CGFloat =  (95 + spaceW) * CGFloat(index % 3) + 14
            let offsetY: CGFloat =  CGFloat(15 + 40 * (index / 3))
            let btn = UIButton().text(categoryModel.name ?? "").textColor(.kColor33).font(12).backgroundColor(.kF7F7F7).cornerRadius(15).masksToBounds()
            sv.sv(btn)
            sv.layout(
                offsetY,
                |-offsetX-btn.width(95).height(30),
                >=15
            )
            if index == currentCategoryIndex {
                btn.textColor(.k2FD4A7).backgroundColor(.kF2FFFB).borderColor(.k2FD4A7).borderWidth(0.5)
            }
            btn.tag = index
            btn.addTarget(self, action: #selector(categoryBtnsClick(btn:)))
        }
    }
    
    @objc func categoryBtnsClick(btn: UIButton) {
        currentCategoryIndex = btn.tag
        categorySelectLab.text(btn.titleLabel?.text ?? "分类")
        if btn.tag > 0 {
            currentCategory = qcModel?.category?[btn.tag-1].id ?? ""
        } else {
            currentCategory = nil
        }
        current = 1
        loadData()
        resetSelectStatus()
    }
    

    
    // MARK: - 品牌
    @objc private func brandSelectBtnClick(btn: UIButton) {
        setupBrandPopView()
    }
    
    private var brandPopView = UIView()
    private var brandSubPopView = UIView()
    func setupBrandPopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height)).backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3))
        view.addSubview(v)
        brandPopView = v
        brandPopView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dismissBrandPopView)))
        let v1 = UIView(frame: CGRect(x: view.width, y: 0, width: 285, height: PublicSize.kScreenHeight)).backgroundColor(.white)
        v.addSubview(v1)
        brandSubPopView = v1
        UIView.animate(withDuration: 0.3) {
            v1.frame.origin.x = self.view.width-285
        }
        setupBrandSubViews()
    }
    
    @objc private func dismissBrandPopView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.brandSubPopView.frame.origin.x = self.view.width
        }) { (action) in
            self.brandPopView.removeFromSuperview()
        }
    }
    
    
    func setupBrandSubViews() {
        let titleLab = UILabel().text("品牌").textColor(.kColor33).font(14)
        let arrowBtn = UIButton().image(#imageLiteral(resourceName: "gx_qc_arrow_back"))
        let sv = UIScrollView()
        let btnView = UIView().cornerRadius(20).masksToBounds().borderColor(.k1DC597).borderWidth(0.5)
        brandSubPopView.sv(titleLab, arrowBtn, sv, btnView)
        brandSubPopView.layout(
            68,
            |-14-titleLab.height(20)-(>=0)-arrowBtn.size(40)-5-|,
            0,
            |sv|,
            15,
            |-14-btnView.height(40)-14-|,
            45
        )
        let resetBtn = UIButton().text("重置").textColor(.k1DC597).font(12)
        let sureBtn = UIButton().text("确认").textColor(.white).font(12).backgroundColor(.k1DC597)
        btnView.sv(resetBtn, sureBtn)
        btnView.layout(
            0,
            |resetBtn.height(40)-0-sureBtn.height(40)|,
            0
        )
        equal(widths: resetBtn, sureBtn)
        resetBtn.addTarget(self, action: #selector(resetBtnClick(btn:)))
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        setupBrandBtns(v: sv)
    }
    private var currentBrandIndexs: [Int] = []
    private var currentBrandBtns: [UIButton] = []
    func setupBrandBtns(v: UIScrollView) {
        qcModel?.brandName?.enumerated().forEach { (item) in
            let index = item.offset
            let title = item.element
            let offsetX: CGFloat =  128.5 * CGFloat(index % 2) + 14
            let offsetY: CGFloat =  CGFloat(15 + 45 * (index / 2))
            let btn = UIButton().text(title).textColor(.kColor33).font(12).backgroundColor(.kF7F7F7).cornerRadius(15).masksToBounds()
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            v.sv(btn)
            v.layout(
                offsetY,
                |-offsetX-btn.width(123.5).height(30),
                >=15
            )
            currentBrandIndexs.forEach { (currentIndex) in
                if currentIndex == index {
                    btn.textColor(.k2FD4A7).backgroundColor(.kF2FFFB).borderColor(.k2FD4A7).borderWidth(0.5)
                }
            }
            btn.tag = index
            currentBrandBtns.append(btn)
            btn.addTarget(self, action: #selector(brandBtnsClick(btn:)))
        }
    }
    
    @objc private func resetBtnClick(btn: UIButton) {
        currentBrand = ""
        currentBrandIndexs.removeAll()
        currentBrandBtns.forEach { (brandBtn) in
            brandBtn.textColor(.kColor33).backgroundColor(.kF7F7F7).borderColor(.kF7F7F7).borderWidth(0.5)
        }
    }
    
    @objc private func sureBtnClick(btn: UIButton) {
        if currentBrand?.isEmpty ?? false {
            brandSelectLab.textColor(.kColor66)
            brandSelectIV.image(#imageLiteral(resourceName: "gx_qc_pp_unselect"))
        } else {
            brandSelectLab.textColor(.k2FD4A7)
            brandSelectIV.image(#imageLiteral(resourceName: "gx_qc_pp_select"))
        }
        current = 1
        loadData()
        dismissBrandPopView()
    }
    
    @objc func brandBtnsClick(btn: UIButton) {
        if currentBrandIndexs.contains(btn.tag) {
            currentBrandIndexs.removeAll(btn.tag)
            btn.textColor(.kColor33).backgroundColor(.kF7F7F7).borderColor(.kF7F7F7).borderWidth(0.5)
        } else {
            btn.textColor(.k2FD4A7).backgroundColor(.kF2FFFB).borderColor(.k2FD4A7).borderWidth(0.5)
            currentBrandIndexs.append(btn.tag)
        }
        currentBrand = ""
        currentBrandIndexs.forEach { (tag) in
            if !(currentBrand?.isEmpty ?? true) {
                currentBrand?.append(",")
            }
            currentBrand?.append(qcModel?.brandName?[tag] ?? "")
        }
    }
    
    
    @objc func dismiss(tap: UITapGestureRecognizer) {
        resetSelectStatus()
    }
    
    func resetSelectStatus() {
        pop?.dismiss()
        categorySelectIV.image(#imageLiteral(resourceName: "gx_qc_arrow_down"))
    }
    private var noDataBtn = UIButton()
    private var collectionView: UICollectionView!
    func setupCollectionViews() {
        let layout = UICollectionViewFlowLayout.init()
        let w: CGFloat = (view.width-39)/2
        layout.itemSize = CGSize(width: w, height: 73+w)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 14, bottom: 20, right: 14)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout).backgroundColor(.kBackgroundColor)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: GXQCCLCell.self)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.sv(collectionView)
        view.layout(
            PublicSize.kNavBarHeight+171,
            |collectionView|,
            0
        )
        collectionView.refreshHeader { [weak self] in
            self?.current = 1
            self?.loadData()
        }
        collectionView.refreshFooter { [weak self] in
            self?.current += 1
            self?.loadData()
        }
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无数据～").textColor(.kColor66).font(14)
        collectionView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
    }
    
}


extension GXQCCLVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return materials.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: GXQCCLCell.self
        , for: indexPath)
        cell.model = materials[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model = materials[indexPath.row]
        let vc = MaterialsDetailVC()
        vc.detailType = .qc
        let material = MaterialsModel()
        material.id = model.materialsId
        vc.skuId = model.skuId
        vc.activityId = model.activityId
        vc.materialsModel = material
        navigationController?.pushViewController(vc)
    }
}


class GXQCCLCell: UICollectionViewCell {
    
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
    private let title = UILabel().text("简约而不简单，工薪阶层现代 风三居").textColor(.kColor33).fontBold(12).numberOfLines(2)
    private let price = UILabel().text("￥1270.00").textColor(.kDF2F2F).fontBold(14)
    private let num = UILabel().text("数量1000").textColor(.kColor99).font(10)
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor(.white)
        cornerRadius(5)
        addShadowColor()
        sv(icon, title, price, num)
        let iconW = (PublicSize.kScreenWidth-39)/2
        layout(
            0,
            |icon.size(iconW)|,
            5,
            |-6-title-6-|,
            >=0,
            |-6-price-(>=0)-num-6-|,
            10
        )
        icon.contentMode = .scaleAspectFit
        icon.masksToBounds()
    }
    
    func configCell() {
        let imageUrl = model?.materials?.imageUrl
        let imageUrls = imageUrl?.components(separatedBy: ",")
        if !icon.addImage(imageUrls?.first) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        title.text(model?.materials?.name ?? "")
        price.text("\(model?.price ?? 0)")
        num.text("数量\(model?.materialsCount ?? 0)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



