//
//  ZBBGoodsDetailViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/16.
//

import UIKit

class ZBBGoodsDetailViewController: BaseViewController {

    var id: String?
    
    private var backBtn: UIButton!
    private var shareBtn: UIButton!
    private var messageBtn: UIButton!
    
    private var bottomView: UIView!
    private var cartBtn: UIButton!
    private var addToCartBtn: UIButton!
    private var buyBtn: UIButton!
    
    private var scrollView: UIScrollView!
    private var imageBannerView: LLCycleScrollView!
    private var baseInfoView: ZBBGoodsDetailBaseInfoView!
    private var moreInfoView: ZBBGoodsDetailMoreInfoView!
    private var descInfoView: ZBBGoodsDetailDescInfoView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func createViews() {
        
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(50+PublicSize.kBottomOffset)
        }
        
        cartBtn = UIButton(type: .custom)
        cartBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -15, bottom: -20, right: 0)
        cartBtn.imageEdgeInsets = UIEdgeInsets(top: -15, left: 0, bottom: 0, right: -30)
        cartBtn.titleLabel?.font = .systemFont(ofSize: 10)
        cartBtn.setTitle("购物车", for: .normal)
        cartBtn.setTitleColor(.hexColor("#666666"), for: .normal)
        cartBtn.setImage(UIImage(named: "icon_shopping-cart"), for: .normal)
        cartBtn.addTarget(self, action: #selector(cartBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(cartBtn)
        cartBtn.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(5)
            make.width.height.equalTo(50)
        }
        
        addToCartBtn = UIButton(type: .custom)
        addToCartBtn.layer.cornerRadius = 20
        addToCartBtn.layer.masksToBounds = true
        addToCartBtn.backgroundColor = .hexColor("#FF9617")
        addToCartBtn.titleLabel?.font = .systemFont(ofSize: 14)
        addToCartBtn.setTitle("加入购物车", for: .normal)
        addToCartBtn.setTitleColor(.white, for: .normal)
        addToCartBtn.addTarget(self, action: #selector(addToCartBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(addToCartBtn)
        addToCartBtn.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.right.equalTo(-140)
            make.height.equalTo(40)
            make.width.equalTo(110)
        }
        
        buyBtn = UIButton(type: .custom)
        buyBtn.layer.cornerRadius = 20
        buyBtn.layer.masksToBounds = true
        buyBtn.backgroundColor = .hexColor("#007E41")
        buyBtn.titleLabel?.font = .systemFont(ofSize: 14)
        buyBtn.setTitle("立即购买", for: .normal)
        buyBtn.setTitleColor(.white, for: .normal)
        buyBtn.addTarget(self, action: #selector(buyBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(buyBtn)
        buyBtn.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.right.equalTo(-15)
            make.height.equalTo(40)
            make.width.equalTo(110)
        }
        
       
        scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        imageBannerView = LLCycleScrollView()
        imageBannerView.backgroundColor = .clear
        imageBannerView.autoScrollTimeInterval = 5
        imageBannerView.coverImage = UIImage(named: "loading")
        imageBannerView.pageControlBottom = 15
        imageBannerView.customPageControlStyle = .pill
        imageBannerView.customPageControlTintColor = .k27A27D
        imageBannerView.customPageControlInActiveTintColor = .white
        scrollView.addSubview(imageBannerView)
        imageBannerView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.width.height.equalTo(SCREEN_WIDTH)
        }
        
        
    }

    //MARK: - Action
    
    @objc private func cartBtnAction(_ sender: UIButton) {
        
    }
    
    @objc private func addToCartBtnAction(_ sender: UIButton) {
        
    }
    
    @objc private func buyBtnAction(_ sender: UIButton) {
        
    }
}
