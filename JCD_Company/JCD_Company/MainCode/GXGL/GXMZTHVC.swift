//
//  GXMZTHVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/21.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper

class GXMZTHVC: BaseViewController {
    
     
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    private let backBtn = UIButton().image(#imageLiteral(resourceName: "back_white"))
    private let titleLabel = UILabel().text("每周特惠").textColor(.white).fontBold(18)
    private let brandBtn = UIButton().image(#imageLiteral(resourceName: "gx_th_pp_icon")).text(" 品牌").textColor(.white).font(12).backgroundColor(#colorLiteral(red: 0.003921568627, green: 0.5333333333, blue: 0.3019607843, alpha: 1)).cornerRadius(15).masksToBounds()
    private let titleScrollView =  UIScrollView().backgroundColor(.clear)
    private let pageScrollView = UIScrollView().backgroundColor(.clear)
    private var titles = ["全部"]
    private var categorys: [GXQCCategoryModel] = []
    private var brands: [String] = []
    private var titleBtns = [UIButton]()
    private var vcs = [GXMZTHListVC]()
    private var currentCategoryaId: String?
    private var currentBrandName: String?
    private var currentIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
        statusStyle = .lightContent
        setupTopBgView()
        
        view.sv(backBtn, titleLabel, titleScrollView, brandBtn ,pageScrollView)
        view.layout(
            PublicSize.kStatusBarHeight,
            |-5-backBtn.size(44)-(>=0)-titleLabel.centerHorizontally(),
            5,
            |titleScrollView.height(58)-6-brandBtn.width(50).height(30)-14-|,
            0,
            |pageScrollView|,
            0
        )
        pageScrollView.layoutIfNeeded()
        pageScrollView.isPagingEnabled = true
        pageScrollView.bounces = true
        pageScrollView.delegate = self
        titleScrollView.showsHorizontalScrollIndicator = false
        backBtn.addTarget(self, action: #selector(backBtnClick(btn:)))
        brandBtn.addTarget(self, action: #selector(brandSelectBtnClick(btn:)))
        loadData()
        loadBrandData()
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
    
    func setupTopBgView() {
        let topBgView = UIView()
        topBgView.frame = CGRect(x: 0, y: 0, width: view.width, height: 192)
        // fill
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.87, green: 0.98, blue: 0.94, alpha: 1).cgColor, UIColor(red: 0, green: 0.53, blue: 0.3, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = topBgView.bounds
        bgGradient.startPoint = CGPoint(x: 0.5, y: 1)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 0)
        topBgView.layer.addSublayer(bgGradient)
        topBgView.alpha = 1
        topBgView.corner(byRoundingCorners: [.bottomLeft, .bottomRight], radii: 20)
        view.addSubview(topBgView)
    }
    
    func loadData() {
       // pleaseWait()
        YZBSign.shared.request(APIURL.getTHCategory, method: .get, parameters: Parameters(), success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataArr = Utils.getReqArr(data: response as AnyObject)
                self.categorys = Mapper<GXQCCategoryModel>().mapArray(JSONArray: dataArr as! [[String : Any]])
                self.refresh()
            }
        }) { (error) in
            
        }
        
    }
    
    func loadBrandData() {
        YZBSign.shared.request(APIURL.getTHBrand, method: .get, parameters: Parameters(), success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataArr = Utils.getReqArr(data: response as AnyObject) as? [String]
                self.brands = dataArr ?? [String]()
            }
        }) { (error) in
            
        }
    }
    
    func refresh() {
        self.categorys.forEach { (model) in
            self.titles.append(model.name ?? "")
        }
        
        var offsetX: CGFloat = 14
        titles.enumerated().forEach { (item) in
            // 标题栏
            let index = item.offset
            let title = item.element
            let titleBtn = UIButton().text(title).textColor(.white).font(14, weight: .bold)
            titleScrollView.sv(titleBtn)
            titleScrollView.layout(
                0,
                |-offsetX-titleBtn.height(58)-(>=70)-|,
                0
            )
            titleBtn.layoutIfNeeded()
            offsetX += titleBtn.width + 25
            titleBtn.tag = index
            titleBtn.addTarget(self, action: #selector(titleBtnClick(btn:)))
            titleBtns.append(titleBtn)
            
            let line = UIView().backgroundColor(.white).cornerRadius(1)
            line.tag = 10001
            titleBtn.sv(line)
            titleBtn.layout(
                >=0,
                |line.height(2)|,
                12
            )
            line.isHidden = index > 0
            
            // 页面栏
            let pageOffsetX: CGFloat = view.width*CGFloat(index)
            let ordersVC = GXMZTHListVC()
            ordersVC.index = index
            addChild(ordersVC)
            pageScrollView.sv(ordersVC.view)
            pageScrollView.layout(
                0,
                |-pageOffsetX-ordersVC.view-(>=0)-|,
                0
            )
            ordersVC.view.width(pageScrollView.width).height(pageScrollView.height)
            vcs.append(ordersVC)
        }
    }
    
    @objc func titleBtnClick(btn: UIButton) {
        switchBtn(index: btn.tag)
        let offsetX: CGFloat = CGFloat(btn.tag)*PublicSize.kScreenWidth
        pageScrollView.contentOffset = CGPoint(x: offsetX, y: 0)
    }
    
    private func switchBtn(index: Int) {
        currentIndex = index
        if index > 0 {
            currentCategoryaId = categorys[index-1].id
        }
        titleBtns.forEach { (titleBtn) in
            let line = titleBtn.viewWithTag(10001)
            if titleBtn.tag == index {
                line?.isHidden = false
            } else {
                line?.isHidden = true
            }
        }
        let vc = vcs[index]
        vc.current = 1
        vc.index = currentIndex
        vc.brandName = currentBrandName
        vc.categoryaId = currentCategoryaId
        vc.loadData()
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
        brands.enumerated().forEach { (item) in
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
        currentBrandIndexs.removeAll()
        currentBrandBtns.forEach { (brandBtn) in
            brandBtn.textColor(.kColor33).backgroundColor(.kF7F7F7).borderColor(.kF7F7F7).borderWidth(0.5)
        }
    }
    
    @objc private func sureBtnClick(btn: UIButton) {
        switchBtn(index: currentIndex)
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
        currentBrandName = ""
        currentBrandIndexs.forEach { (tag) in
            if !(currentBrandName?.isEmpty ?? true) {
                currentBrandName?.append(",")
            }
            currentBrandName?.append(brands[tag])
        }
    }
}

extension GXMZTHVC: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / PublicSize.kScreenWidth)
        switchBtn(index: index)
    }
}
