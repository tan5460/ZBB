//
//  ZBBOrderDetailViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/15.
//

import UIKit
import ObjectMapper
import MJRefresh

class ZBBOrderDetailViewController: BaseViewController {
    
    var orderId: String?
    private var orderModel: OrderModel?
    private var materials: [MaterialsModel]?

    private var bottomView: UIView!
    private var statusIcon: UIImageView!
    private var statusLabel: UILabel!
    private var payBtn: UIButton!
    
    private var scrollView: UIScrollView!
    private var customerInfoView: ZBBOrderDetailCustomerInfoView!
    private var orderInfoView: ZBBOrderDetailOrderInfoView!
    private var goodsInfoView: ZBBOrderDetailGoodsInfoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "订单详情"
        createViews()
        requestOrderDetail()
    }
    
    private func createViews() {
        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 215)
//        gradientLayer.locations = [0, 1]
//        gradientLayer.startPoint = CGPointMake(0, 0)
//        gradientLayer.endPoint = CGPointMake(0, 1)
//        gradientLayer.colors = [UIColor.hexColor("#D1FFF9").cgColor, UIColor.hexColor("#F7F7F7", alpha: 0).cgColor]
//        view.layer.addSublayer(gradientLayer)
        
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(50+PublicSize.kBottomOffset)
        }
        
        statusIcon = UIImageView(image: UIImage(named: "orderState_wait"))
        bottomView.addSubview(statusIcon)
        statusIcon.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.width.height.equalTo(20)
        }
        
        statusLabel = UILabel()
        statusLabel.text = "待支付"
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = .hexColor("#6F7A75")
        bottomView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(statusIcon)
            make.left.equalTo(statusIcon.snp.right).offset(5)
        }
        
        payBtn = UIButton(type: .custom)
        payBtn.layer.cornerRadius = 17
        payBtn.layer.borderWidth = 1
        payBtn.layer.borderColor = UIColor.hexColor("#AAACB5").cgColor
        payBtn.layer.masksToBounds = true
        payBtn.titleLabel?.font = .systemFont(ofSize: 14)
        payBtn.setTitle("立即支付", for: .normal)
        payBtn.setTitleColor(.hexColor("#6F7A75"), for: .normal)
        payBtn.addTarget(self, action: #selector(payBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(payBtn)
        payBtn.snp.makeConstraints { make in
            make.centerY.equalTo(statusIcon)
            make.right.equalTo(-15)
            make.width.equalTo(84)
            make.height.equalTo(34)
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
        scrollView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.requestOrderDetail()
        })
        
        customerInfoView = ZBBOrderDetailCustomerInfoView()
        customerInfoView.layer.cornerRadius = 10
        customerInfoView.layer.masksToBounds = true
        scrollView.addSubview(customerInfoView)
        customerInfoView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.width.equalTo(SCREEN_WIDTH - 20)
        }
        
        orderInfoView = ZBBOrderDetailOrderInfoView()
        orderInfoView.layer.cornerRadius = 10
        orderInfoView.layer.masksToBounds = true
        scrollView.addSubview(orderInfoView)
        orderInfoView.snp.makeConstraints { make in
            make.top.equalTo(customerInfoView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        goodsInfoView = ZBBOrderDetailGoodsInfoView()
        goodsInfoView.layer.cornerRadius = 10
        goodsInfoView.layer.masksToBounds = true
        scrollView.addSubview(goodsInfoView)
        goodsInfoView.snp.makeConstraints { make in
            make.top.equalTo(orderInfoView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-10)
        }
    }
    
    private func refreshView() {
        //
        customerInfoView.nameLabel.text = orderModel?.customName
        customerInfoView.estateLabel.text = orderModel?.plotName
        customerInfoView.houseLabel.text = orderModel?.roomNo
        customerInfoView.phoneLabel.text = orderModel?.customeMobile
        if let houseSpace = orderModel?.houseSpace, houseSpace.intValue > 0 {
            customerInfoView.areaLabel.text = "\(houseSpace)㎡"
        } else {
            customerInfoView.areaLabel.text = nil
        }
        customerInfoView.addressLabel.text = orderModel?.address
        
        //
        if let materialsModel = materials?.first {
            let price = Double(truncating: materialsModel.materialsCount ?? 0) * (Double(string: materialsModel.materialsPriceCustom ?? "0") ?? 0)
            let priceText = price.notRoundingString(afterPoint: 2)
            orderInfoView.priceLabel.text = "¥\(priceText)"
        }
        orderInfoView.subsidyLabel.text = ""
        if let valueStr = orderModel?.payMoney?.doubleValue {
            let value = valueStr.notRoundingString(afterPoint: 2)
            orderInfoView.orderPriceLabel.text = "¥\(value)"
        }
        orderInfoView.orderLabel.text = orderModel?.orderNo
        orderInfoView.timeLabel.text = orderModel?.createDate
        
        //
        goodsInfoView.coverImageView.kf.setImage(with: URL(string: APIURL.ossPicUrl + (materials?.first?.materialsImageUrl ?? "")), placeholder: UIImage(named: "loading"))
        goodsInfoView.subsidyIcon.isHidden = (materials?.first?.productTypeIdentification ?? -1) != 0
        goodsInfoView.titleLabel.text = materials?.first?.materialsName
        goodsInfoView.sizeLabel.text = "规格：" + (materials?.first?.skuAttr1 ?? "")
        goodsInfoView.unitLabel.text = "单位：" + (materials?.first?.materialsUnitTypeName ?? "")
        goodsInfoView.priceLabel.text = "销售价：" + (materials?.first?.materialsPriceCustom ?? "")
        goodsInfoView.countLabel.text = "数量：" + "\(materials?.first?.materialsCount ?? 0)"
        goodsInfoView.remarkLabel.text = "备注：" + (materials?.first?.remarks ?? "")
    }
    
    
    //MARK: - Action
    
    @objc private func payBtnAction(_ sender: UIButton) {
        
    }
    
    //MARK: - Request
    
    private func requestOrderDetail() {
        guard let orderId = orderId else {
            noticeOnlyText("订单参数异常")
            return
        }
        
        let urlStr = APIURL.getYYSPurchaseOrderData + orderId
        YZBSign.shared.request(urlStr, method: .get, success: {[weak self] response in
            self?.scrollView.mj_header?.endRefreshing()
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                let listArray = Utils.getReadArrDic(data: data, field: "orderDataDTOList")
                self?.orderModel =  Mapper<OrderModel>().map(JSON: data as! [String : Any])
                self?.materials = Mapper<MaterialsModel>().mapArray(JSONArray: listArray as! [[String : Any]])
                self?.refreshView()
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        }) {[weak self] error in
            self?.scrollView.mj_header?.endRefreshing()
        }
    }

}


//MARK: -

fileprivate class ZBBOrderDetailCustomerInfoView: UIView {
    
    private var nameTitleLabel: UILabel!
    var nameLabel: UILabel!
    
    private var estateTitleLabel: UILabel!
    var estateLabel: UILabel!
    
    private var sexTitleLabel: UILabel!
    var sexLabel: UILabel!
    
    private var houseTitleLabel: UILabel!
    var houseLabel: UILabel!
    
    private var phoneTitleLabel: UILabel!
    var phoneLabel: UILabel!
    
    private var areaTitleLabel: UILabel!
    var areaLabel: UILabel!
    
    private var addressTitleLabel: UILabel!
    var addressLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        backgroundColor = .white
        
        nameTitleLabel = UILabel()
        nameTitleLabel.text = "姓名："
        nameTitleLabel.font = .systemFont(ofSize: 14)
        nameTitleLabel.textColor = .hexColor("#131313")
        nameTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(nameTitleLabel)
        nameTitleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.equalTo(20)
        }
        
        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 14, weight: .medium)
        nameLabel.textColor = .hexColor("#131313")
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(nameTitleLabel.snp.right)
            make.right.lessThanOrEqualTo(self.snp.centerX).offset(-7.5)
            make.centerY.equalTo(nameTitleLabel)
        }

        estateTitleLabel = UILabel()
        estateTitleLabel.text = "小区："
        estateTitleLabel.font = .systemFont(ofSize: 14)
        estateTitleLabel.textColor = .hexColor("#131313")
        estateTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        estateTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(estateTitleLabel)
        estateTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameTitleLabel)
            make.left.equalTo(self.snp.centerX).offset(7.5)
            make.height.equalTo(20)
        }
        
        estateLabel = UILabel()
        estateLabel.font = .systemFont(ofSize: 14, weight: .medium)
        estateLabel.textColor = .hexColor("#131313")
        addSubview(estateLabel)
        estateLabel.snp.makeConstraints { make in
            make.left.equalTo(estateTitleLabel.snp.right)
            make.right.lessThanOrEqualTo(-15)
            make.centerY.equalTo(estateTitleLabel)
        }

        sexTitleLabel = UILabel()
        sexTitleLabel.text = "性别："
        sexTitleLabel.font = .systemFont(ofSize: 14)
        sexTitleLabel.textColor = .hexColor("#131313")
        sexTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        sexTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(sexTitleLabel)
        sexTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }
        
        sexLabel = UILabel()
        sexLabel.text = "保密"
        sexLabel.font = .systemFont(ofSize: 14, weight: .medium)
        sexLabel.textColor = .hexColor("#131313")
        addSubview(sexLabel)
        sexLabel.snp.makeConstraints { make in
            make.left.equalTo(sexTitleLabel.snp.right)
            make.right.lessThanOrEqualTo(self.snp.centerX).offset(-7.5)
            make.centerY.equalTo(sexTitleLabel)
        }
        
        houseTitleLabel = UILabel()
        houseTitleLabel.text = "房间号："
        houseTitleLabel.font = .systemFont(ofSize: 14)
        houseTitleLabel.textColor = .hexColor("#131313")
        houseTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        houseTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(houseTitleLabel)
        houseTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(sexTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(self.snp.centerX).offset(7.5)
            make.height.equalTo(20)
        }
        
        houseLabel = UILabel()
        houseLabel.font = .systemFont(ofSize: 14, weight: .medium)
        houseLabel.textColor = .hexColor("#131313")
        addSubview(houseLabel)
        houseLabel.snp.makeConstraints { make in
            make.left.equalTo(houseTitleLabel.snp.right)
            make.right.lessThanOrEqualTo(-15)
            make.centerY.equalTo(houseTitleLabel)
        }
      
        phoneTitleLabel = UILabel()
        phoneTitleLabel.text = "电话："
        phoneTitleLabel.font = .systemFont(ofSize: 14)
        phoneTitleLabel.textColor = .hexColor("#131313")
        phoneTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        phoneTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(phoneTitleLabel)
        phoneTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }
        
        phoneLabel = UILabel()
        phoneLabel.font = .systemFont(ofSize: 14, weight: .medium)
        phoneLabel.textColor = .hexColor("#131313")
        addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.left.equalTo(phoneTitleLabel.snp.right)
            make.right.lessThanOrEqualTo(self.snp.centerX).offset(-7.5)
            make.centerY.equalTo(phoneTitleLabel)
        }
        
        areaTitleLabel = UILabel()
        areaTitleLabel.text = "面积："
        areaTitleLabel.font = .systemFont(ofSize: 14)
        areaTitleLabel.textColor = .hexColor("#131313")
        areaTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        areaTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(areaTitleLabel)
        areaTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(phoneTitleLabel)
            make.left.equalTo(self.snp.centerX).offset(7.5)
            make.height.equalTo(20)
        }
        
        areaLabel = UILabel()
        areaLabel.font = .systemFont(ofSize: 14, weight: .medium)
        areaLabel.textColor = .hexColor("#131313")
        addSubview(areaLabel)
        areaLabel.snp.makeConstraints { make in
            make.left.equalTo(areaTitleLabel.snp.right)
            make.right.lessThanOrEqualTo(-15)
            make.centerY.equalTo(areaTitleLabel)
        }
        
        addressTitleLabel = UILabel()
        addressTitleLabel.text = "地址："
        addressTitleLabel.font = .systemFont(ofSize: 14)
        addressTitleLabel.textColor = .hexColor("#131313")
        addressTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        addressTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        addSubview(addressTitleLabel)
        addressTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(phoneTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(20)
            make.bottom.equalTo(-15)
        }
        
        addressLabel = UILabel()
        addressLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addressLabel.textColor = .hexColor("#131313")
        addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.left.equalTo(phoneTitleLabel.snp.right)
            make.right.lessThanOrEqualTo(-15)
            make.centerY.equalTo(phoneTitleLabel)
        }
    }
    
}


//MARK: -
fileprivate class ZBBOrderDetailOrderInfoView: UIView {
    
    private var priceTitleLabel: UILabel!
    var priceLabel: UILabel!
    
    private var subsidyTitleLabel: UILabel!
    var subsidyLabel: UILabel!
    private var subsidyMoreIcon: UIImageView!
    private var subsidyDetailBtn: UIButton!
    
    private var orderPriceTitleLabel: UILabel!
    var orderPriceLabel: UILabel!
    
    private var orderTitleLabel: UILabel!
    var orderLabel: UILabel!
    private var orderCopyBtn: UIButton!
    
    private var timeTitleLabel: UILabel!
    var timeLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        backgroundColor = .white

        priceTitleLabel = UILabel()
        priceTitleLabel.font = .systemFont(ofSize: 14)
        priceTitleLabel.textColor = .hexColor("#131313")
        addSubview(priceTitleLabel)
        priceTitleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.equalTo(20)
        }
        
        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 14, weight: .medium)
        priceLabel.textColor = .hexColor("#131313")
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(priceTitleLabel.snp.right)
            make.centerY.equalTo(priceTitleLabel)
        }

        subsidyTitleLabel = UILabel()
        subsidyTitleLabel.font = .systemFont(ofSize: 14)
        subsidyTitleLabel.textColor = .hexColor("#131313")
        addSubview(subsidyTitleLabel)
        subsidyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(priceTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }
        
        subsidyLabel = UILabel()
        subsidyLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subsidyLabel.textColor = .hexColor("#131313")
        addSubview(subsidyLabel)
        subsidyLabel.snp.makeConstraints { make in
            make.left.equalTo(subsidyTitleLabel.snp.right)
            make.centerY.equalTo(subsidyTitleLabel)
        }

        subsidyMoreIcon = UIImageView(image: UIImage(named: "purchase_arrow"))
        addSubview(subsidyMoreIcon)
        subsidyMoreIcon.snp.makeConstraints { make in
            make.centerY.equalTo(subsidyLabel)
            make.left.equalTo(subsidyLabel.snp.right).offset(5)
            make.width.equalTo(5)
            make.height.equalTo(9)
        }

        subsidyDetailBtn = UIButton(type: .custom)
        subsidyDetailBtn.addTarget(self, action: #selector(subsidyDetailBtn(_:)), for: .touchUpInside)
        addSubview(subsidyDetailBtn)
        subsidyDetailBtn.snp.makeConstraints { make in
            make.centerY.equalTo(subsidyTitleLabel)
            make.height.equalTo(30)
            make.left.equalTo(subsidyLabel)
            make.right.equalTo(subsidyMoreIcon)
        }

        orderPriceTitleLabel = UILabel()
        orderPriceTitleLabel.font = .systemFont(ofSize: 14)
        orderPriceTitleLabel.textColor = .hexColor("#131313")
        addSubview(orderPriceTitleLabel)
        orderPriceTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(subsidyTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }
        
        orderPriceLabel = UILabel()
        orderPriceLabel.font = .systemFont(ofSize: 14, weight: .medium)
        orderPriceLabel.textColor = .hexColor("#131313")
        addSubview(orderPriceLabel)
        orderPriceLabel.snp.makeConstraints { make in
            make.left.equalTo(orderPriceTitleLabel.snp.right)
            make.centerY.equalTo(orderPriceTitleLabel)
        }

        orderTitleLabel = UILabel()
        orderTitleLabel.font = .systemFont(ofSize: 14)
        orderTitleLabel.textColor = .hexColor("#131313")
        addSubview(orderTitleLabel)
        orderTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(orderPriceTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }
        
        orderLabel = UILabel()
        orderLabel.font = .systemFont(ofSize: 14, weight: .medium)
        orderLabel.textColor = .hexColor("#131313")
        addSubview(orderLabel)
        orderLabel.snp.makeConstraints { make in
            make.left.equalTo(orderTitleLabel.snp.right)
            make.centerY.equalTo(orderTitleLabel)
        }

        orderCopyBtn = UIButton(type: .custom)
        orderCopyBtn.layer.cornerRadius = 9
        orderCopyBtn.layer.masksToBounds = true
        orderCopyBtn.backgroundColor = .hexColor("#F0F0F0")
        orderCopyBtn.titleLabel?.font = .systemFont(ofSize: 12)
        orderCopyBtn.setTitle("复制", for: .normal)
        orderCopyBtn.setTitleColor(.hexColor("#333333"), for: .normal)
        orderCopyBtn.addTarget(self, action: #selector(orderCopyBtn(_:)), for: .touchUpInside)
        addSubview(orderCopyBtn)
        orderCopyBtn.snp.makeConstraints { make in
            make.left.equalTo(orderLabel.snp.right).offset(10)
            make.centerY.equalTo(orderLabel)
            make.width.equalTo(40)
            make.height.equalTo(18)
        }
        
        timeTitleLabel = UILabel()
        timeTitleLabel.font = .systemFont(ofSize: 14)
        timeTitleLabel.textColor = .hexColor("#131313")
        addSubview(timeTitleLabel)
        timeTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(orderTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(20)
            make.bottom.equalTo(-15)
        }
        
        timeLabel = UILabel()
        timeLabel.font = .systemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = .hexColor("#131313")
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(timeTitleLabel.snp.right)
            make.centerY.equalTo(timeTitleLabel)
        }
        
    }
    
    //MARK: - Action
    
    @objc private func subsidyDetailBtn(_ sender: UIButton) {
        let vc = ZBBOrderSubsidyInfoViewController()
        getCurrentVC().navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func orderCopyBtn(_ sender: UIButton) {
        UIPasteboard.general.string = orderLabel.text
        noticeOnlyText("复制成功")
    }
    
    
}

//MARK: -

fileprivate class ZBBOrderDetailGoodsInfoView: UIView {
    
    var coverImageView: UIImageView!
    var subsidyIcon: UIImageView!
    
    var titleLabel: UILabel!
    
    var sizeLabel: UILabel!
    var unitLabel: UILabel!
    var priceLabel: UILabel!
    var countLabel: UILabel!
    
    var remarkLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        backgroundColor = .white
        
        coverImageView = UIImageView()
        coverImageView.layer.cornerRadius = 5
        coverImageView.layer.masksToBounds = true
        coverImageView.contentMode = .scaleAspectFill
        addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.width.height.equalTo(93)
        }

        subsidyIcon = UIImageView(image: UIImage(named: "zbbt_subsidy1"))
        coverImageView.addSubview(subsidyIcon)
        subsidyIcon.snp.makeConstraints { make in
            make.top.right.equalTo(0)
            make.width.equalTo(34)
            make.height.equalTo(17)
        }

        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        titleLabel.numberOfLines = 2
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(coverImageView.snp.right).offset(10)
            make.right.equalTo(-15)
            make.height.greaterThanOrEqualTo(20)
        }

        sizeLabel = UILabel()
        sizeLabel.font = .systemFont(ofSize: 12)
        sizeLabel.textColor = .hexColor("#666666")
        addSubview(sizeLabel)
        sizeLabel.snp.makeConstraints { make in
            make.top.equalTo(65)
            make.left.equalTo(titleLabel)
            make.height.equalTo(16.5)
        }

        unitLabel = UILabel()
        unitLabel.font = .systemFont(ofSize: 12)
        unitLabel.textColor = .hexColor("#666666")
        addSubview(unitLabel)
        unitLabel.snp.makeConstraints { make in
            make.centerY.equalTo(sizeLabel)
            make.left.equalTo(sizeLabel.snp.right).offset(25)

        }

        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 12)
        priceLabel.textColor = .hexColor("#666666")
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(sizeLabel.snp.bottom).offset(10)
            make.left.equalTo(titleLabel)
            make.height.equalTo(16.5)
        }
        
        countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 12)
        countLabel.textColor = .hexColor("#666666")
        addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.left.equalTo(priceLabel.snp.right).offset(25)
            
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
        }

        remarkLabel = UILabel()
        remarkLabel.font = .systemFont(ofSize: 12)
        remarkLabel.textColor = .hexColor("#666666")
        remarkLabel.numberOfLines = 0
        addSubview(remarkLabel)
        remarkLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.greaterThanOrEqualTo(16.5)
            make.bottom.equalTo(-15)
        }
    }
    
    
}
