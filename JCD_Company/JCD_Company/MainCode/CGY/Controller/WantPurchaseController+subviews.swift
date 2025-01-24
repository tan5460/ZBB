//
//  WantPurchaseController+subviews.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/24.
//  Copyright © 2019 WZKJ. All rights reserved.
//

extension WantPurchaseController {
    func prepareTopView() {
        
        //顶部工地栏
        topView = UIView()
        topView.backgroundColor = .white
        topView.isUserInteractionEnabled = true
        view.addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            
            make.top.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        //手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(editHouseAction))
        tapOne.numberOfTapsRequired = 1
        topView.addGestureRecognizer(tapOne)
        
        //请选择客户工地
        houseHintLabel = UILabel()
        houseHintLabel.text = "请选择客户工地"
        houseHintLabel.textColor = PublicColor.minorTextColor
        houseHintLabel.font = UIFont.systemFont(ofSize: 15)
        topView.addSubview(houseHintLabel)
        
        houseHintLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
        }
        
        //工地详情内容
        houseDetailView = UIView()
        houseDetailView.isHidden = true
        houseDetailView.backgroundColor = .white
        topView.addSubview(houseDetailView)
        
        houseDetailView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //箭头
        let arrowImageView = UIImageView()
        arrowImageView.contentMode = .center
        arrowImageView.image = UIImage.init(named: "order_arrow")
        topView.addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(18)
        }
        
        //姓名
        nameLabel = UILabel()
        nameLabel.text = "姓名"
        nameLabel.textColor = PublicColor.minorTextColor
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        houseDetailView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(18)
            make.width.equalTo(130)
        }
        
        //电话
        phoneLabel = UILabel()
        phoneLabel.text = "电话"
        phoneLabel.textColor = nameLabel.textColor
        phoneLabel.font = nameLabel.font
        houseDetailView.addSubview(phoneLabel)
        
        phoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(5)
            make.centerY.equalTo(nameLabel)
            make.width.equalTo(170)
        }
        
        //小区
        plotLabel = UILabel()
        plotLabel.text = "小区"
        plotLabel.textColor = PublicColor.minorTextColor
        plotLabel.font = UIFont.systemFont(ofSize: 13)
        houseDetailView.addSubview(plotLabel)
        
        plotLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(15)
            make.width.height.equalTo(15)
            make.right.equalTo(-60)
        }
        
        
        //收货人
        consigneeNameLabel = UILabel()
        consigneeNameLabel.text = "收货人"
        consigneeNameLabel.textColor = PublicColor.minorTextColor
        consigneeNameLabel.font = UIFont.systemFont(ofSize: 13)
        houseDetailView.addSubview(consigneeNameLabel)
        
        consigneeNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(plotLabel.snp.bottom).offset(15)
            make.width.equalTo(130)
        }
        
        //收货人电话
        consigneePhoneLabel = UILabel()
        consigneePhoneLabel.text = "收货人电话"
        consigneePhoneLabel.textColor = nameLabel.textColor
        consigneePhoneLabel.font = nameLabel.font
        houseDetailView.addSubview(consigneePhoneLabel)
        
        consigneePhoneLabel.snp.makeConstraints { (make) in
            make.left.equalTo(consigneeNameLabel.snp.right).offset(5)
            make.centerY.equalTo(consigneeNameLabel)
            make.width.equalTo(170)
        }
        
        //收货人小区
        consigneePlotLabel = UILabel()
        consigneePlotLabel.text = "收货地址"
        consigneePlotLabel.numberOfLines = 2
        consigneePlotLabel.textColor = PublicColor.minorTextColor
        consigneePlotLabel.font = UIFont.systemFont(ofSize: 13)
        houseDetailView.addSubview(consigneePlotLabel)
        
        consigneePlotLabel.snp.makeConstraints { (make) in
            make.top.equalTo(consigneeNameLabel.snp.bottom).offset(5)
            make.left.equalTo(15)
            make.width.equalTo(15)
            make.right.equalTo(-60)
            
        }
        
        //全选视图
        allSelectView = UIView()
        allSelectView.backgroundColor = .white
        view.addSubview(allSelectView)
        
        allSelectView.snp.makeConstraints { (make) in
            
            make.top.equalTo(topView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(35)
        }
        
        //自定义分割线
        let separatorView = UIView()
        separatorView.backgroundColor = PublicColor.partingLineColor
        allSelectView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //选中按钮
        allSelectView.addSubview(selectedBtn)
        
        selectedBtn.snp.makeConstraints { (make) in
            make.left.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        //组名
        let allLabel = UILabel()
        allLabel.text = "全选"
        allLabel.textColor = PublicColor.commonTextColor
        allLabel.font = UIFont.systemFont(ofSize: 14)
        selectedBtn.addSubview(allLabel)
        
        allLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(selectedBtn)
            make.left.equalTo(selectedBtn.snp.right)
        }
    }
    
    func prepareBottomView() {
        
        //底部结算栏
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-44)
            } else {
                make.height.equalTo(44)
            }
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        bottomView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //去结算
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        placeOrderBtn = UIButton.init(type: .custom)
        placeOrderBtn.setTitle("下单采购", for: .normal)
        placeOrderBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        placeOrderBtn.setTitleColor(UIColor.white, for: .normal)
        placeOrderBtn.setBackgroundImage(backgroundImg, for: .normal)
        placeOrderBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        placeOrderBtn.setBackgroundImage(backgroundHImg, for: .disabled)
        placeOrderBtn.addTarget(self, action: #selector(placeOrderAction), for: .touchUpInside)
        bottomView.addSubview(placeOrderBtn)
        
        if IS_iPad {
            
            placeOrderBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
            placeOrderBtn.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.width.equalTo(200)
                make.height.equalTo(44)
            }
        }else {
            placeOrderBtn.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview()
                make.width.equalTo(100)
                make.height.equalTo(44)
            }
        }
        
        //主材项数
        materialCountLabel = UILabel()
        materialCountLabel.text = "产品项数: 0"
        materialCountLabel.textColor = PublicColor.commonTextColor
        materialCountLabel.font = UIFont.systemFont(ofSize: 14)
        bottomView.addSubview(materialCountLabel)
        
        if IS_iPad {
            
            materialCountLabel.font = UIFont.systemFont(ofSize: 15)
            materialCountLabel.snp.makeConstraints { (make) in
                make.left.equalTo(20)
                make.centerY.equalTo(placeOrderBtn)
            }
        }else {
            materialCountLabel.snp.makeConstraints { (make) in
                make.left.equalTo(15)
                make.centerY.equalTo(placeOrderBtn)
            }
        }
        priceLabel = UILabel()
        priceLabel.text = "合计：0.00"
        priceLabel.textColor = PublicColor.commonTextColor
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        bottomView.addSubview(priceLabel)
        
        if IS_iPad {
            
            priceLabel.font = UIFont.systemFont(ofSize: 15)
            priceLabel.snp.makeConstraints { (make) in
                make.right.equalTo(placeOrderBtn.snp.left).offset(-15)
                make.centerY.equalTo(placeOrderBtn)
            }
        }else {
            priceLabel.snp.makeConstraints { (make) in
                make.right.equalTo(placeOrderBtn.snp.left).offset(-10)
                make.centerY.equalTo(placeOrderBtn)
            }
        }
        
    }
    
    func prepareTableView() {
        
        //购物车空提示
        cartNullView = UIImageView()
        cartNullView.isHidden = true
        cartNullView.image = UIImage.init(named: "cartNull")
        cartNullView.contentMode = .scaleAspectFit
        view.addSubview(cartNullView)
        view.insertSubview(cartNullView, at: 0)
        
        cartNullView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
            make.width.height.equalTo(150)
        }
        
        //创建分类滑动视图
        materialTableView = UITableView(frame: CGRect.zero, style: .grouped)
        materialTableView.backgroundColor = UIColor.clear
        materialTableView.rowHeight = 117.0
        materialTableView.separatorStyle = .none
        materialTableView.delegate = self
        materialTableView.dataSource = self
        materialTableView.register(WantPurchaseCell.self, forCellReuseIdentifier: WantPurchaseCell.self.description())
        
        view.addSubview(materialTableView)
        materialTableView.snp.makeConstraints { (make) in
            make.top.equalTo(allSelectView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top).offset(-30)
        }
        
        
       
        view.addSubview(tipView)
        tipView.snp.makeConstraints { (make) in
            make.top.equalTo(materialTableView.snp.bottom)
            make.left.width.equalToSuperview()
            make.height.equalTo(30)
        }

        let tipLabel = UILabel().text("订单支付时，可使用代金券抵扣部分金额").textColor(#colorLiteral(red: 0.9254901961, green: 0.3882352941, blue: 0.1647058824, alpha: 1)).font(12)
        let vipType = UserData.shared.userInfoModel?.yzbVip?.vipType ?? 1
        if vipType == 1 {
            tipLabel.isUserInteractionEnabled = true
            tipLabel.text("升级成为中级会员，订单付款时，可参与代金券抵扣活动")
            tipLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(enterMembersVC)))
        }
        tipView.sv(tipLabel)
        tipLabel.centerInContainer()
        
        if #available(iOS 11.0, *) {
            materialTableView.contentInsetAdjustmentBehavior = .never
        }
        
        if !isOneKeyBuy {
            // 下拉刷新
            let header = MJRefreshGifCustomHeader()
            header.setRefreshingTarget(self, refreshingAction: #selector(refresh))
            materialTableView.mj_header = header
        }
    }
    
    
    @objc func enterMembersVC() {
        let vc = MembershipLevelsVC()
        navigationController?.pushViewController(vc)
    }
    
}

