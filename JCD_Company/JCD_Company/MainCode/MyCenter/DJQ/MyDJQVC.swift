//
//  MyDJQVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/7.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import TLTransitions

class MyDJQVC: BaseViewController {
    private var pop1: TLTransition?
    private let backBtn = UIButton().image(#imageLiteral(resourceName: "detail_back"))
   // private let instructionsBtn = UIButton().text("使用说明").textColor(.kColor66).font(14)
    private let titleLabel = UILabel().text("代金券").textColor(.kColor33).fontBold(18)
    private let yhqBtn = UIButton().text("优惠券").textColor(.kColor33).font(16, weight: .bold)
    private let djqBtn = UIButton().text("代金券").textColor(.kColor99).font(16, weight: .bold)
    private let yhqLine = UIView()
    private let djqLine = UIView()
    private var djqView: MyDJQView!
    private var yhqView: MyYHQView!
    
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
        view.backgroundColor(.white)
        statusStyle = .default
        let line = UIView().backgroundColor(.kColorEE)
        view.sv(backBtn, yhqBtn, djqBtn, line)
        view.layout(
            PublicSize.kStatusBarHeight,
            |-5-backBtn.size(44)-21-yhqBtn.height(44)-0-djqBtn.height(44)-70-|,
            0,
            |line.height(0.5)|,
            >=0
        )
        equal(widths: yhqBtn, djqBtn)
        yhqBtn.sv(yhqLine)
        yhqBtn.layout(
            >=0,
            yhqLine.width(36).height(2).centerHorizontally(),
            2
        )
        djqBtn.sv(djqLine)
        djqBtn.layout(
            >=0,
            djqLine.width(36).height(2).centerHorizontally(),
            2
        )
        yhqLine.fillGreenColorLF()
        djqLine.fillGreenColorLF()
        djqLine.isHidden = true
        // 点击代金券，优惠券按钮处理
        yhqBtn.tapped { [weak self] (tapBtn) in
            self?.yhqBtn.textColor(.kColor33)
            self?.yhqLine.isHidden = false
            self?.djqBtn.textColor(.kColor99)
            self?.djqLine.isHidden = true
            self?.yhqView.isHidden = false
            self?.djqView.isHidden = true
        }
        
        djqBtn.tapped { [weak self] (tapBtn) in
            self?.djqBtn.textColor(.kColor33)
            self?.djqLine.isHidden = false
            self?.yhqBtn.textColor(.kColor99)
            self?.yhqLine.isHidden = true
            self?.yhqView.isHidden = true
            self?.djqView.isHidden = false
        }
        
        
        yhqView = MyYHQView.init(frame: CGRect(x: 0, y: PublicSize.kNavBarHeight, width: view.width, height: view.height-PublicSize.kNavBarHeight))
        yhqView.viewController = self
        yhqView.loadData()
        view.addSubview(yhqView)
        
        djqView = MyDJQView.init(frame: CGRect(x: 0, y: PublicSize.kNavBarHeight, width: view.width, height: view.height-PublicSize.kNavBarHeight))
        view.addSubview(djqView)
        djqView.isHidden = true
       // instructionsBtn.addTarget(self, action: #selector(instructionsBtnClick(btn:)))
        backBtn.addTarget(self , action: #selector(backBtnClick(btn:)))
    }
    
    @objc private func instructionsBtnClick(btn: UIButton) {
        let v = UIView().backgroundColor(.white)
        v.frame = CGRect(x: 0, y: 0, width: 313, height: 390)
        pop1 = TLTransition.show(v, popType: TLPopTypeAlert)
        
        let title = UILabel().text("代金券使用说明").textColor(.kColor33).fontBold(16)
        let sv = UIScrollView()
        let okBtn = UIButton().text("我知道了").textColor(.white).font(14).cornerRadius(15).masksToBounds()
        
        v.sv(title, sv, okBtn)
        v.layout(
            15,
            title.height(22.5).centerHorizontally(),
            20,
            |-0-sv-0-|,
            17.5,
            okBtn.width(130).height(30).centerHorizontally(),
            25
        )
        
        let content = UILabel().text("一、定义\n\n1、全网券：可用于抵扣所有的产品，有使用范围限制，分为全场通用、指定商家和指定品类。\n2、天网券：可用于抵扣天网的产品，有使用范围限制，分为全场通用、指定商家和指定品类。\n3、地网券：可用于抵扣地网的产品，有使用范围限制，分为全场通用、指定商家和指定品类。\n\n二、代金券的使用规则\n\n1、代金券抵扣金额不超过订单金额的10%。\n2、代金券面额为代金券的最高抵扣金额。\n3、代金券的金额大于订单金额的10%时，差额部分不予退回。\n4、服务类商品不享受代金券优惠。\n5、预购产品在尾款阶段，可使用，抵扣金额不超过尾款的10%。\n6、订单中可同时叠加使用代金券。").textColor(.kColor66).font(14)
        content.numberOfLines(0).lineSpace(2)
        sv.sv(content)
        sv.layout(
            10,
            content.width(273).centerHorizontally(),
            10
        )
        okBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.99, green: 0.46, blue: 0.23, alpha: 1).cgColor, UIColor(red: 1, green: 0.23, blue: 0.23, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = okBtn.bounds
        bgGradient.startPoint = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 1, y: 0.5)
        okBtn.layer.insertSublayer(bgGradient, at: 0)
        okBtn.addTarget(self, action: #selector(okBtnClick(btn:)))
    }
    
    @objc private func okBtnClick(btn: UIButton) {
        pop1?.dismiss()
    }
    
    @objc private func backBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
}
//MARK: - 优惠券
class MyYHQView: UIView {
    weak var viewController: UIViewController?
    private let titleScrollView =  UIScrollView().backgroundColor(.clear)
    private let pageScrollView = UIScrollView().backgroundColor(.clear)
    private var titles = ["未使用", "已使用", "已失效"]
    private var titleBtns = [UIButton]()
    private var vcs = [MyYHQListVC]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        sv(titleScrollView ,pageScrollView)
        layout(
            0,
            |titleScrollView.height(37)|,
            0,
            |pageScrollView|,
            0
        )
        pageScrollView.layoutIfNeeded()
        pageScrollView.isPagingEnabled = true
        pageScrollView.bounces = true
        pageScrollView.delegate = self
        titleScrollView.showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        // pleaseWait()
        refresh()
    }
    
    func refresh() {
        let btnW: CGFloat = PublicSize.kScreenWidth/CGFloat(titles.count)
        titles.enumerated().forEach { (item) in
            // 标题栏
            let index = item.offset
            let title = item.element
            let offsetX: CGFloat = btnW * CGFloat(index)
            let titleBtn = UIButton().text(title).textColor(.white).font(12)
            titleScrollView.sv(titleBtn)
            titleScrollView.layout(
                0,
                |-offsetX-titleBtn.width(btnW).height(37),
                0
            )
            titleBtn.tag = index
            titleBtn.addTarget(self, action: #selector(titleBtnClick(btn:)))
            titleBtns.append(titleBtn)
            
            let line = UIView()
            line.tag = 10001
            titleBtn.sv(line)
            titleBtn.layer.insertSublayer(line.layer, at: 0)
            line.width(79).height(24).centerInContainer()
            line.corner(radii: 12).fillGreenColorLF()
            if index > 0 {
                line.isHidden = true
                titleBtn.textColor(.kColor99)
            }
            
            // 页面栏
            let pageOffsetX: CGFloat = PublicSize.kScreenWidth*CGFloat(index)
            let ordersVC = MyYHQListVC()
            ordersVC.viewController = viewController
            ordersVC.index = index
            parentController?.addChild(ordersVC)
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
        titleBtns.forEach { (titleBtn) in
            let line = titleBtn.viewWithTag(10001)
            if titleBtn.tag == index {
                line?.isHidden = false
                titleBtn.textColor(.white)
            } else {
                line?.isHidden = true
                titleBtn.textColor(.kColor99)
            }
        }
        let vc = vcs[index]
        vc.index = index
        
        if vc.rowsData.count == 0 {
            vc.current = 1
            vc.loadData()
        }
    }
}

extension MyYHQView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / PublicSize.kScreenWidth)
        switchBtn(index: index)
    }
}

//MARK: - 代金券
class MyDJQView: UIView {
    private let titleScrollView =  UIScrollView().backgroundColor(.clear)
    private let pageScrollView = UIScrollView().backgroundColor(.clear)
    private var titles = ["未使用", "已使用", "已失效", "未激活"]
    private var titleBtns = [UIButton]()
    private var vcs = [MyDJQListVC]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        sv(titleScrollView ,pageScrollView)
        layout(
            0,
            |titleScrollView.height(37)|,
            0,
            |pageScrollView|,
            0
        )
        pageScrollView.layoutIfNeeded()
        pageScrollView.isPagingEnabled = true
        pageScrollView.bounces = true
        pageScrollView.delegate = self
        titleScrollView.showsHorizontalScrollIndicator = false
        
        loadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        // pleaseWait()
        refresh()
    }
    
    func refresh() {
        let btnW: CGFloat = PublicSize.kScreenWidth/CGFloat(titles.count)
        titles.enumerated().forEach { (item) in
            // 标题栏
            let index = item.offset
            let title = item.element
            let offsetX: CGFloat = btnW * CGFloat(index)
            let titleBtn = UIButton().text(title).textColor(.white).font(12)
            titleScrollView.sv(titleBtn)
            titleScrollView.layout(
                0,
                |-offsetX-titleBtn.width(btnW).height(37),
                0
            )
            titleBtn.tag = index
            titleBtn.addTarget(self, action: #selector(titleBtnClick(btn:)))
            titleBtns.append(titleBtn)
            
            let line = UIView()
            line.tag = 10001
            titleBtn.sv(line)
            titleBtn.layer.insertSublayer(line.layer, at: 0)
            line.width(79).height(24).centerInContainer()
            line.corner(radii: 12).fillGreenColorLF()
            if index > 0 {
                line.isHidden = true
                titleBtn.textColor(.kColor99)
            }
            
            // 页面栏
            let pageOffsetX: CGFloat = PublicSize.kScreenWidth*CGFloat(index)
            let ordersVC = MyDJQListVC()
            ordersVC.index = index
            parentController?.addChild(ordersVC)
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
        titleBtns.forEach { (titleBtn) in
            let line = titleBtn.viewWithTag(10001)
            if titleBtn.tag == index {
                line?.isHidden = false
                titleBtn.textColor(.white)
            } else {
                line?.isHidden = true
                titleBtn.textColor(.kColor99)
            }
        }
        let vc = vcs[index]
        vc.index = index
        
        if vc.rowsData.count == 0 {
            vc.current = 1
            vc.loadData()
        }
    }
}

extension MyDJQView: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / PublicSize.kScreenWidth)
        switchBtn(index: index)
    }
}



