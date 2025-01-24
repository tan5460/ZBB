//
//  ZBBOrderWaitSureViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/16.
//

import UIKit
import ObjectMapper

class ZBBOrderWaitSureViewController: BaseViewController {
    
    var model: MaterialsModel?
    var skuModel: MaterialsSkuListModel?
    private var subsidyModel: ZBBOrderSubsidyInfoModel?
    
    private var bottomView: UIView!
    private var priceLabel: UILabel!
    private var payBtn: UIButton!
    
    private var scrollView: UIScrollView!
    private var addressView: ZBBOrderWaitSureAddressView!
    private var goodsView: ZBBOrderWaitSureGoodsView!
    private var subsidyView: ZBBOrderWaitSureSubsidyView!
    private var priceView: ZBBOrderWaitSurePriceView!
     
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "确认订单"
        createViews()
        refreshViews()
        
        if let productTypeIdentification = model?.productTypeIdentification, productTypeIdentification == 0 {
            requestSubsidyInfo()
        }
    }
    
    private func createViews() {
        
        bottomView = UIView()
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(50+PublicSize.kBottomOffset)
        }
        
        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 16, weight: .medium)
        priceLabel.textColor = .hexColor("#FF3C2F")
        bottomView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(14)
            make.left.equalTo(10)
            make.height.equalTo(22)
        }
        
        payBtn = UIButton(type: .custom)
        payBtn.layer.cornerRadius = 20
        payBtn.layer.masksToBounds = true
        payBtn.backgroundColor = .hexColor("#007E41")
        payBtn.titleLabel?.font = .systemFont(ofSize: 15)
        payBtn.setTitle("立即付款", for: .normal)
        payBtn.setTitleColor(.white, for: .normal)
        payBtn.addTarget(self, action: #selector(payBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(payBtn)
        payBtn.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.right.equalTo(-10)
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
        
        addressView = ZBBOrderWaitSureAddressView()
        addressView.layer.cornerRadius = 10
        addressView.layer.masksToBounds = true
        addressView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressViewAction(_:))))
        scrollView.addSubview(addressView)
        addressView.snp.makeConstraints { make in
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
            make.width.equalTo(SCREEN_WIDTH - 20)
        }
        
        goodsView = ZBBOrderWaitSureGoodsView()
        goodsView.layer.cornerRadius = 10
        goodsView.layer.masksToBounds = true
        scrollView.addSubview(goodsView)
        goodsView.snp.makeConstraints { make in
            make.top.equalTo(addressView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        goodsView.remarkClosure = {[weak self] in
            let remarkVC = RemarksViewController(title: "备注", remark: self?.model?.remarks ?? "")
            remarkVC.remarksType = .remarks
            remarkVC.doneBlock = { (remarks, re2) in
                self?.model?.remarks = remarks ?? ""
                self?.goodsView.remarkLabel.text = remarks ?? "点击添加备注"
            }
            self?.present(remarkVC, animated: true, completion:nil)
        }
        
        subsidyView = ZBBOrderWaitSureSubsidyView()
        subsidyView.isHidden = true
        subsidyView.layer.cornerRadius = 10
        subsidyView.layer.masksToBounds = true
        scrollView.addSubview(subsidyView)
        subsidyView.snp.makeConstraints { make in
            make.top.equalTo(goodsView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
        
        priceView = ZBBOrderWaitSurePriceView()
        priceView.layer.cornerRadius = 10
        priceView.layer.masksToBounds = true
        scrollView.addSubview(priceView)
        priceView.snp.makeConstraints { make in
            if subsidyView.isHidden {
                make.top.equalTo(subsidyView)
            } else {
                make.top.equalTo(subsidyView.snp.bottom).offset(10)
            }
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-5)
        }
        
    }
    
    private func refreshViews() {
        goodsView.coverImageView.kf.setImage(with: URL(string: APIURL.ossPicUrl + (skuModel?.image ?? "")), placeholder: UIImage(named: "loading"))
        //
        goodsView.titleLabel.text = model?.name
        //
        goodsView.categoryLabel.text = nil
        if let categoryName = model?.categorybName {
            goodsView.categoryLabel.text = "品类：" + categoryName
        }
        //
        goodsView.unitLabel.text = nil
        if let unitName = model?.unitTypeName {
            goodsView.unitLabel.text = "单位：" + unitName
        }
        //
        if let price = skuModel?.priceSell?.doubleValue {
            let priceText = price.notRoundingString(afterPoint: 2)
            let attrText = NSMutableAttributedString(string: "销售价：¥\(priceText)")
            attrText.addAttribute(.font, value: UIFont.systemFont(ofSize: 14, weight: .medium), range: NSMakeRange(0, attrText.length))
            attrText.addAttribute(.foregroundColor, value: UIColor.hexColor("#FF3C2F"), range: NSMakeRange(0, attrText.length))
            attrText.addAttribute(.font, value: UIFont.systemFont(ofSize: 14), range: NSMakeRange(0, 4))
            attrText.addAttribute(.foregroundColor, value: UIColor.hexColor("#666666"), range: NSMakeRange(0, 4))
            goodsView.priceLabel.attributedText = attrText
        }
        //
        goodsView.countLabel.text = "x\(model?.buyCount ?? 0)"
        //
        if let remark = model?.remarks, !remark.isEmpty, remark != "无" {
            goodsView.remarkLabel.text = remark
        } else {
            goodsView.remarkLabel.text = "点击添加备注"
        }
        
        //商品类型
        let productTypeIdentification = model?.productTypeIdentification ?? -1
        //是否认证消费者
        let checkStatus = subsidyModel?.consumer?.checkStatus ?? -1
        let isConsumer = checkStatus == 1 || checkStatus == 3
        
        //
        let allPrice = calculateTotalPrice()
        priceView.priceLabel.text = "¥\(allPrice.notRoundingString(afterPoint: 2))"
        //
        priceView.hideSubsidy = productTypeIdentification != 0 || !isConsumer
        let subsidyLimit = (subsidyModel?.maxSubsidyAmount ?? 0) - (subsidyModel?.subsidedAmount ?? 0)
        let subsidyPrice = min(subsidyLimit, allPrice * (subsidyModel?.subsidyRatio ?? 0))
        priceView.subsidyLabel.text = "-¥\(subsidyPrice.notRoundingString(afterPoint: 2))"
        
        //
        let totalPrice = allPrice - (priceView.hideSubsidy ? 0 : subsidyPrice)
        let attrTotalPrice = NSMutableAttributedString(string: "合计" + "¥\(totalPrice.notRoundingString(afterPoint: 2))")
        attrTotalPrice.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .medium), range: NSMakeRange(0, attrTotalPrice.length))
        attrTotalPrice.addAttribute(.foregroundColor, value: UIColor.hexColor("#FF3C2F"), range: NSMakeRange(0, attrTotalPrice.length))
        attrTotalPrice.addAttribute(.font, value: UIFont.systemFont(ofSize: 15, weight: .medium), range: NSMakeRange(0, 3))
        attrTotalPrice.addAttribute(.foregroundColor, value: UIColor.hexColor("#131313"), range: NSMakeRange(0, 2))
        priceView.totalLabel.attributedText = attrTotalPrice
        //
        priceLabel.text = "¥\(totalPrice.notRoundingString(afterPoint: 2))"
        
        //
        subsidyView.isHidden = productTypeIdentification != 0
        subsidyView.nameLabel.isHidden = !isConsumer
        subsidyView.idCardLabel.isHidden = !isConsumer
        subsidyView.descBtn.isHidden = !isConsumer
        subsidyView.noticeView.isHidden = isConsumer
        subsidyView.nameLabel.text = subsidyModel?.consumer?.fullName
        subsidyView.idCardLabel.text = subsidyModel?.consumer?.idCardNumber
        subsidyView.descLabel.text = String(format: "已认证消费者，当前订单可补贴¥%@元", subsidyPrice.notRoundingString(afterPoint: 2))
        
        priceView.snp.remakeConstraints { make in
            if subsidyView.isHidden {
                make.top.equalTo(subsidyView)
            } else {
                make.top.equalTo(subsidyView.snp.bottom).offset(10)
            }
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-5)
        }
        
        
        
    }
    
    private func calculateTotalPrice() -> Double {
        let count = model?.buyCount.doubleValue ?? 0
        let price = skuModel?.priceSell?.doubleValue ?? 0
        let allPrice = count * price
        return allPrice
    }
    
    //MARK: - Action
    
    @objc private func addressViewAction(_ sender: UITapGestureRecognizer) {
        let vc = HouseViewController()
        vc.title = "请选择客户工地"
        vc.houseModel = addressView.houseModel
        vc.isOrder = true
        vc.isEditHouse = true
        vc.selectedHouseBlock = { [weak self] houseModel in
            self?.addressView.houseModel = houseModel
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func payBtnAction(_ sender: UIButton) {
        if addressView.houseModel == nil {
            noticeOnlyText("请选择收货地址")
            return
        }
        var param = Parameters()
        param["from"] = "APP"
        param["houseId"] = addressView.houseModel?.id
        
        
        var dic = [String: Any]()
        dic["materialsId"] = model?.id
        dic["materialsName"] = model?.name
        dic["skuId"] = skuModel?.id
        dic["count"] = model?.buyCount
        dic["remarks"] = model?.remarks ?? "无"
        
        let price = Decimal(skuModel?.priceSell?.doubleValue ?? 0)
        dic["price"] = "\(price)"
        
        let count = Decimal(model?.buyCount.doubleValue ?? 0)
        let payMoney = price * count
        
        var materialsDic = [String: Any]()
        materialsDic["payMoney"]  = payMoney
        materialsDic["supplyMoney"] = payMoney
        
        materialsDic["merchantId"] = model?.merchantId
        materialsDic["datas"] = [dic]
        
        materialsDic["bigRemarks"] = model?.remarks

        param["orderDatas"] = [materialsDic].jsonStr
        
        
        
//        param["orderStatus"] = 1
//        param["orderType"] = 1
//        param["storeId"] = UserData.shared.storeModel?.id
//        param["workerId"] = UserData.shared.workerModel?.id
//        param["houseId"] = addressView.houseModel?.id
//        param["customId"] = addressView.houseModel?.customId
//        param["payMoney"] = "\(calculateTotalPrice())"
        if let productTypeIdentification = model?.productTypeIdentification, productTypeIdentification == 0 {
            param["categoryAid"] = model?.categoryaId
        }
//        
//        var dict = [String : String]()
//        dict["id"] = model?.id ?? ""
//        dict["skuId"] = skuModel?.id ?? ""
//        dict["count"] = "\(model?.buyCount ?? 0)"
//        dict["priceCustom"] = "\(skuModel?.priceSell ?? 0)"
//        dict["remarks"] = model?.remarks
//        dict["materialsName"] = model?.materialsName
//        
//        param["materials"] = [dict]
//        
//        var parametersNew = Parameters()
//        parametersNew["comOrderStr"] = param.jsonStr
        
        YZBSign.shared.request(APIURL.savePurchaseOrder, method: .post, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let list = Utils.getReqArr(data: response as AnyObject)
                if let orderId = list.firstObject as? String {
                    let vc = ZBBOrderDetailViewController()
                    vc.orderId = orderId
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                    if let sself = self, var vcs = self?.navigationController?.viewControllers {
                        vcs.removeFirst { $0 == sself }
                        self?.navigationController?.viewControllers = vcs
                    }
                }
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
                
        }

    }
    
    
    private func requestSubsidyInfo() {
        var param = Parameters()
        param["categoryAid"] = model?.categoryaId
        YZBSign.shared.request(APIURL.zbbOrderSubsidyInfo, method: .get, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReadDic(data: response as AnyObject, field: "data")
                self?.subsidyModel = Mapper<ZBBOrderSubsidyInfoModel>().map(JSON: data as! [String : Any])
                self?.refreshViews()
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            
        }

    }

}

//MARK: -

class ZBBOrderSubsidyInfoModel: NSObject, Mappable {
    //分类名称
    var categoryName: String?
    //最高补贴金额
    var maxSubsidyAmount: Double?
    //已补贴金额
    var subsidedAmount: Double?
    //补贴金额
    var subsidyAmount: Double?
    //补贴比例
    var subsidyRatio: Double?
    //消费者信息
    var consumer: ZBBOrderSubsidyInfoConsumerModel?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        categoryName <- map["categoryName"]
        maxSubsidyAmount <- map["maxSubsidyAmount"]
        subsidedAmount <- map["subsidedAmount"]
        subsidyAmount <- map["subsidyAmount"]
        subsidyRatio <- map["subsidyRatio"]
        consumer <- map["consumer"]
    }
}

class ZBBOrderSubsidyInfoConsumerModel: NSObject, Mappable {
    var checkStatus: Int?
    var createDate: String?
    var delFlag: String?
    var fullName: String?
    var houseAddress: String?
    var id: String?
    var idCardNumber: String?
    var phoneNumber: String?
    var refuseReason: String?
    var substationId: String?
    var updateDate: String?
    var userId: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        checkStatus <- map["checkStatus"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        fullName <- map["fullName"]
        houseAddress <- map["houseAddress"]
        id <- map["id"]
        idCardNumber <- map["idCardNumber"]
        phoneNumber <- map["phoneNumber"]
        refuseReason <- map["refuseReason"]
        substationId <- map["substationId"]
        updateDate <- map["updateDate"]
        userId <- map["userId"]
    }
}



//MARK: -

fileprivate class ZBBOrderWaitSureAddressView: UIView {
    
    var houseModel: HouseModel? {
        didSet {
            tipLabel.isHidden = houseModel != nil;
            //
            nameLabel.isHidden = houseModel == nil;
            nameLabel.text = houseModel?.customName
            //
            phoneLabel.isHidden = houseModel == nil
            phoneLabel.text = houseModel?.customMobile
            //
            areaLabel.isHidden = houseModel == nil
            if let space = houseModel?.space?.doubleValue {
                let area = space.notRoundingString(afterPoint: 2, qian: false)
                areaLabel.text = String.init(format: "%@㎡", area)
            } else {
                areaLabel.text = nil
            }
            //
            addressLabel.isHidden = houseModel == nil
            addressLabel.text = houseModel?.shippingAddress
        }
    }
    
    private var icon: UIImageView!
    private var tipLabel: UILabel!
    private var nameLabel: UILabel!
    private var phoneLabel: UILabel!
    private var areaLabel: UILabel!
    private var addressLabel: UILabel!
    private var moreIcon: UIImageView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        backgroundColor = .white
        
        icon = UIImageView(image: UIImage(named: "zbbt_order_address"))
        addSubview(icon)
        icon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(15)
            make.width.height.equalTo(30)
        }
        
        tipLabel = UILabel()
        tipLabel.text = "请选择收货地址"
        tipLabel.font = .systemFont(ofSize: 14)
        tipLabel.textColor = .hexColor("#666666")
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.left.equalTo(icon.snp.right).offset(5)
        }

        nameLabel = UILabel()
        nameLabel.isHidden = true
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = .hexColor("#131313")
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(55)
            make.height.equalTo(20)
        }

        phoneLabel = UILabel()
        phoneLabel.isHidden = true
        phoneLabel.font = .systemFont(ofSize: 14)
        phoneLabel.textColor = .hexColor("#131313")
        addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(10)
        }

        areaLabel = UILabel()
        areaLabel.isHidden = true
        areaLabel.font = .systemFont(ofSize: 14)
        areaLabel.textColor = .hexColor("#131313")
        addSubview(areaLabel)
        areaLabel.snp.makeConstraints { make in
            make.centerY.equalTo(phoneLabel)
            make.left.equalTo(phoneLabel.snp.right).offset(10)
        }

        addressLabel = UILabel()
        addressLabel.isHidden = true
        addressLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addressLabel.textColor = .hexColor("#131313")
        addressLabel.numberOfLines = 2
        addSubview(addressLabel)
        addressLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.left.equalTo(nameLabel)
            make.right.equalTo(-40)
            make.height.greaterThanOrEqualTo(20)
            make.bottom.equalTo(-15)
        }

        moreIcon = UIImageView(image: UIImage(named: "purchase_arrow"))
        addSubview(moreIcon)
        moreIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
        }
    }
}

//MARK: -

fileprivate class ZBBOrderWaitSureGoodsView: UIView {
        
    var coverImageView: UIImageView!
    private var subsidyIcon: UIImageView!
    var titleLabel: UILabel!
    var categoryLabel: UILabel!
    var unitLabel: UILabel!
    var priceLabel: UILabel!
    var countLabel: UILabel!
    
    var remarkClosure: (() -> Void)?
    
    private var remarkTitleLabel: UILabel!
    var remarkLabel: UILabel!
    private var remarkBtn: UIButton!
    private var moreIcon: UIImageView!
    
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
            make.width.height.equalTo(110)
        }

        subsidyIcon = UIImageView(image: UIImage(named: "zbbt_subsidy1"))
        coverImageView.addSubview(subsidyIcon)
        subsidyIcon.snp.makeConstraints { make in
            make.top.right.equalTo(coverImageView)
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

        categoryLabel = UILabel()
        categoryLabel.font = .systemFont(ofSize: 12)
        categoryLabel.textColor = .hexColor("#666666")
        addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { make in
            make.top.equalTo(60)
            make.left.equalTo(coverImageView.snp.right).offset(10)
            make.height.equalTo(16.5)
        }

        unitLabel = UILabel()
        unitLabel.font = .systemFont(ofSize: 12)
        unitLabel.textColor = .hexColor("#666666")
        addSubview(unitLabel)
        unitLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLabel.snp.bottom).offset(5)
            make.left.equalTo(coverImageView.snp.right).offset(10)
            make.height.equalTo(16.5)
        }

        priceLabel = UILabel()
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.left.equalTo(coverImageView.snp.right).offset(10)
            make.height.equalTo(20)
            make.bottom.equalTo(coverImageView)
        }

        countLabel = UILabel()
        countLabel.font = .systemFont(ofSize: 14)
        countLabel.textColor = .hexColor("#666666")
        addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceLabel)
            make.right.equalTo(-15)
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

        remarkTitleLabel = UILabel()
        remarkTitleLabel.text = "备注："
        remarkTitleLabel.font = .systemFont(ofSize: 12)
        remarkTitleLabel.textColor = .hexColor("#666666")
        addSubview(remarkTitleLabel)
        remarkTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(15);
            make.left.equalTo(15)
            make.width.equalTo(50)
            make.height.equalTo(17)
            make.bottom.equalTo(-15)
        }
        
        remarkLabel = UILabel()
        remarkLabel.text = "点击添加备注"
        remarkLabel.font = .systemFont(ofSize: 12)
        remarkLabel.textColor = .hexColor("#666666")
        remarkLabel.numberOfLines = 2
        addSubview(remarkLabel)
        remarkLabel.snp.makeConstraints { make in
            make.centerY.equalTo(remarkTitleLabel)
            make.right.equalTo(-24)
            make.left.greaterThanOrEqualTo(remarkTitleLabel.snp.right)
        }

        remarkBtn = UIButton(type: .custom)
        remarkBtn.addTarget(self, action: #selector(remarkBtnAction(_:)), for: .touchUpInside)
        addSubview(remarkBtn)
        remarkBtn.snp.makeConstraints { make in
            make.centerY.equalTo(remarkTitleLabel)
            make.height.equalTo(40)
            make.right.equalTo(-24)
            make.left.equalTo(remarkTitleLabel.snp.right)
        }
        
        moreIcon = UIImageView(image: UIImage(named: "purchase_arrow"))
        addSubview(moreIcon)
        moreIcon.snp.makeConstraints { make in
            make.centerY.equalTo(remarkTitleLabel)
            make.right.equalTo(-15)
        }

    }
    
    @objc private func remarkBtnAction(_ sender: UIButton) {
        remarkClosure?()
    }
}

//MARK: -

fileprivate class ZBBOrderWaitSureSubsidyView: UIView {
    
    private var titleLabel: UILabel!
    var nameLabel: UILabel!
    var idCardLabel: UILabel!
    
    var descBtn: UIButton!
    private var descLeftIcon: UIImageView!
    var descLabel: UILabel!
    private var descRightIcon: UIImageView!
    
    var noticeView: UIView!
    private var noticeIcon: UIImageView!
    private var noticeLabel: UILabel!
    private var noticeBtn: UIButton!
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        backgroundColor = .white
        
        titleLabel = UILabel()
        titleLabel.text = "参与政府补贴"
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.equalTo(20)
        }

        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
        }
        
        nameLabel = UILabel()
        nameLabel.isHidden = true
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = .hexColor("#131313")
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }

        idCardLabel = UILabel()
        idCardLabel.isHidden = true
        idCardLabel.font = .systemFont(ofSize: 14)
        idCardLabel.textColor = .hexColor("#131313")
        addSubview(idCardLabel)
        idCardLabel.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(15)
            make.left.equalTo(nameLabel.snp.right).offset(15)
            make.height.equalTo(20)
        }

        descBtn = UIButton(type: .custom)
        descBtn.isHidden = true
        descBtn.layer.cornerRadius = 2
        descBtn.layer.masksToBounds = true
        descBtn.backgroundColor = .hexColor("#007E41")
        descBtn.addTarget(self, action: #selector(descBtnAction(_:)), for: .touchUpInside)
        addSubview(descBtn)
        descBtn.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(20)
        }

        descLeftIcon = UIImageView(image: UIImage(named: "zbbt_order_descLeft"))
        descBtn.addSubview(descLeftIcon)
        descLeftIcon.snp.makeConstraints { make in
            make.left.equalTo(5)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        descLabel = UILabel()
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .hexColor("#007E41")
        descBtn.addSubview(descLabel)
        descLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(descLeftIcon.snp.right).offset(4)
        }

        descRightIcon = UIImageView(image: UIImage(named: "zbbt_order_desc"))
        descBtn.addSubview(descRightIcon)
        descRightIcon.snp.makeConstraints { make in
            make.left.equalTo(descLabel.snp.right).offset(5)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(12.5)
        }
        

        noticeView = UIView()
        noticeView.layer.cornerRadius = 2
        noticeView.layer.masksToBounds = true
        noticeView.backgroundColor = .hexColor("#FF3C2F", alpha: 0.1)
        addSubview(noticeView)
        noticeView.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(15)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(50)
            make.bottom.equalTo(-15)
        }

        noticeIcon = UIImageView(image: UIImage(named: "zbbt_order_notice"))
        noticeView.addSubview(noticeIcon)
        noticeIcon.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(14)
        }

        noticeLabel = UILabel()
        noticeLabel.text = "未认证消费者，不能参与政府补贴！"
        noticeLabel.font = .systemFont(ofSize: 12)
        noticeLabel.textColor = .hexColor("#131313")
        noticeView.addSubview(noticeLabel)
        noticeLabel.snp.makeConstraints { make in
            make.left.equalTo(noticeIcon.snp.right).offset(5)
            make.centerY.equalTo(noticeIcon)
        }

        noticeBtn = UIButton(type: .custom)
        noticeBtn.layer.cornerRadius = 15
        noticeBtn.layer.masksToBounds = true
        noticeBtn.backgroundColor = .hexColor("#FF3C2F")
        noticeBtn.titleLabel?.font = .systemFont(ofSize: 13)
        noticeBtn.setTitle("立即认证", for: .normal)
        noticeBtn.setTitleColor(.white, for: .normal)
        noticeBtn.addTarget(self, action: #selector(noticeBtnAction(_:)), for: .touchUpInside)
        noticeView.addSubview(noticeBtn)
        noticeBtn.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(30)
        }
    }
    
    //MARK: - Action
    
    @objc private func descBtnAction(_ sender: UIButton) {
        
    }
    
    @objc private func noticeBtnAction(_ sender: UIButton) {
        let vc = ZBBCreditAuthViewController()
        getCurrentVC().navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: -

fileprivate class ZBBOrderWaitSurePriceView: UIView {
    
    
    private var priceTitleLabel: UILabel!
    var priceLabel: UILabel!
    
    private var subsidyTitleLabel: UILabel!
    var subsidyLabel: UILabel!
    
    var totalLabel: UILabel!
    
    var hideSubsidy = false {
        didSet {
            subsidyTitleLabel.isHidden = hideSubsidy
            subsidyLabel.isHidden = hideSubsidy
            totalLabel.snp.remakeConstraints { make in
                if subsidyTitleLabel.isHidden {
                    make.top.equalTo(subsidyTitleLabel)
                } else {
                    make.top.equalTo(subsidyTitleLabel.snp.bottom).offset(10)
                }
                make.right.equalTo(-15)
                make.height.equalTo(25)
                make.bottom.equalTo(-15)
            }
        }
    }
    
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
        priceTitleLabel.text = "商品总价"
        priceTitleLabel.font = .systemFont(ofSize: 14)
        priceTitleLabel.textColor = .hexColor("#131313")
        addSubview(priceTitleLabel)
        priceTitleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.equalTo(20)
        }

        priceLabel = UILabel()
        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .hexColor("#131313")
        addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(priceTitleLabel)
            make.right.equalTo(-15)
        }

        subsidyTitleLabel = UILabel()
        subsidyTitleLabel.text = "政府补贴"
        subsidyTitleLabel.font = .systemFont(ofSize: 14)
        subsidyTitleLabel.textColor = .hexColor("#131313")
        addSubview(subsidyTitleLabel)
        subsidyTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(priceTitleLabel.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }
        
        subsidyLabel = UILabel()
        subsidyLabel.font = .systemFont(ofSize: 14)
        subsidyLabel.textColor = .hexColor("#FF3C2F")
        addSubview(subsidyLabel)
        subsidyLabel.snp.makeConstraints { make in
            make.centerY.equalTo(subsidyTitleLabel)
            make.right.equalTo(-15)
        }

        totalLabel = UILabel()
        addSubview(totalLabel)
        totalLabel.snp.makeConstraints { make in
            make.top.equalTo(subsidyTitleLabel.snp.bottom).offset(10)
            make.right.equalTo(-15)
            make.height.equalTo(25)
            make.bottom.equalTo(-15)
        }
    }
}


