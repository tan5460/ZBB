//
//  OrderMaterialCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 16.11.2018.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

enum OrderCellType {
    
    case nowMaterial        //当前主材
    case optional_did       //可选择显示切换
    case optional_un        //可选择显示选择
    case optional_set       //可选择显示已选
    case service            //施工
}

class OrderMaterialCell: UITableViewCell , UITextFieldDelegate {
    
    var changeCountBlock: (()->())?             //数量改变block
    var detailBlock: (()->())?                  //详情block
    let backgroundImg = PublicColor.gradualColorImage
    let backgroundHImg = PublicColor.gradualHightColorImage
    
    var newAddView: UIImageView!                //新增角标
    var showImageView: UIImageView!             //图片
    var singleImgView: UIImageView!             //单品标签
    var nameBtn: UIButton!                      //主材名按钮
    var brandLabel: UILabel!                    //品牌
    var priceTitleLabel: UILabel!               //价格标题
    var priceLabel: UILabel!                    //价格
    var unitLabel: UILabel!                     //单位
    var countView: UIView!                      //计数框背景
    var countTextField: UITextField!            //数量输入框
    var standardLabel: UILabel!                 //标配文本
    var reduceBtn: UIButton!                    //减按钮
    var addBtn: UIButton!                       //加按钮
    var operationBtn: UIButton!                 //操作
    var remarksLabel: UILabel!                  //备注
    var remarksBtn: UIButton!                   //备注按钮
    var lineView: UIView!                       //分割线
    
    var operationBlock: (()->())?               //操作block
    var remarkBlock: (()->())?                  //备注block
    var isFreeCell = false                      //是否为自由开单
    var isAddMaterial: Bool = false {
        didSet {
            newAddView.isHidden = !isAddMaterial
        }
    }
    
    var orderCellType: OrderCellType = .nowMaterial {
        didSet {
            
            lineView.isHidden = true
            
            switch orderCellType {
            case .nowMaterial:
                
                lineView.isHidden = false
                remarksBtn.isHidden = false
                operationBtn.isHidden = true
                
                showImageView.snp.remakeConstraints { (make) in
                    make.top.equalTo(10)
                    make.left.equalTo(12)
                    make.width.height.equalTo(75)
                }
                
                remarksBtn.snp.remakeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(showImageView.snp.bottom).offset(10)
                    make.bottom.equalTo(-10)
                    make.height.equalTo(22)
                }
                
            case .optional_did:
                
//                standardLabel.isHidden = true
                countView.isHidden = true
                remarksBtn.isHidden = true
                operationBtn.isHidden = false
                operationBtn.setTitle("更换", for: .normal)
                operationBtn.layer.borderWidth = 1
                operationBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
                operationBtn.setBackgroundImage(PublicColor.buttonColorImage, for: .normal)
                operationBtn.setBackgroundImage(PublicColor.buttonHightColorImage, for: .highlighted)
                
                showImageView.snp.remakeConstraints { (make) in
                    make.top.equalTo(10)
                    make.left.equalTo(12)
                    make.width.height.equalTo(75)
                    make.bottom.equalTo(-10)
                }
                
                remarksBtn.snp.removeConstraints()
                
            case .optional_un:
                
//                standardLabel.isHidden = true
                countView.isHidden = true
                remarksBtn.isHidden = true
                operationBtn.isHidden = false
                operationBtn.setTitle("选择", for: .normal)
                operationBtn.layer.borderWidth = 1
                operationBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
                operationBtn.setBackgroundImage(PublicColor.buttonColorImage, for: .normal)
                operationBtn.setBackgroundImage(PublicColor.buttonHightColorImage, for: .highlighted)
                
                showImageView.snp.remakeConstraints { (make) in
                    make.top.equalTo(10)
                    make.left.equalTo(12)
                    make.width.height.equalTo(75)
                    make.bottom.equalTo(-10)
                }
                
                remarksBtn.snp.removeConstraints()
                
            case .optional_set:
                
//                standardLabel.isHidden = true
                countView.isHidden = true
                remarksBtn.isHidden = true
                operationBtn.isHidden = false
                operationBtn.setTitle("已选", for: .normal)
                operationBtn.layer.borderWidth = 0
                operationBtn.setTitleColor(.white, for: .normal)
                operationBtn.setBackgroundImage(backgroundImg, for: .normal)
                operationBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
                
                showImageView.snp.remakeConstraints { (make) in
                    make.top.equalTo(10)
                    make.left.equalTo(12)
                    make.width.height.equalTo(75)
                    make.bottom.equalTo(-10)
                }
                
                remarksBtn.snp.removeConstraints()
                
            case .service:
                
                remarksBtn.isHidden = false
                operationBtn.isHidden = true
                
                showImageView.snp.remakeConstraints { (make) in
                    make.top.equalTo(10)
                    make.left.equalTo(12)
                    make.width.height.equalTo(75)
                }
                
                remarksBtn.snp.remakeConstraints { (make) in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(showImageView.snp.bottom).offset(10)
                    make.bottom.equalTo(-10)
                    make.height.equalTo(22)
                }
            }
        }
    }
    
    var materialModel: MaterialsModel? {
        
        didSet {
            
            newAddView.isHidden = true
            showImageView.image = UIImage.init(named: "order_material_back")
            nameBtn.isEnabled = true
            nameBtn.setTitle("产品名", for: .normal)
            brandLabel.text = "品牌: 无"
            brandLabel.isHidden = false
            unitLabel.text = "单位:"
            priceTitleLabel.text = "加减价: "
            priceLabel.text = " "
//            standardLabel.isHidden = true
            countTextField.text = "0"
            countTextField.isUserInteractionEnabled = false
            countView.isHidden = false
            addBtn.isEnabled = false
            reduceBtn.isEnabled = false
            remarksLabel.text = "点击添加备注"
            remarksLabel.textColor = PublicColor.minorTextColor
            
            unitLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(brandLabel.snp.right).offset(20)
                make.centerY.equalTo(brandLabel)
            }
            
            priceTitleLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(nameBtn)
                make.top.equalTo(brandLabel.snp.bottom).offset(4)
            }
            
            if let imageStr = materialModel?.transformImageURL, let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
                showImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "order_material_back"))
            } else {
                showImageView.image = UIImage.init(named: "loading")
            }
            
            if let nameStr = materialModel?.name {
                nameBtn.setTitle(nameStr, for: .normal)
            }
            
            if let valueStr = materialModel?.brandName {
                brandLabel.text = "品牌: \(valueStr)"
            }
            
            if materialModel?.type == 1 {
//                singleImgView.image = UIImage.init(named: "single_icon")
            }else {
                singleImgView.image = UIImage.init(named: "built_mark")
            }
            
            //单品判断
            if isFreeCell {
                
                if materialModel?.isOneSell == 1 {
                    
                    singleImgView.isHidden = true
                    
                    priceTitleLabel.text = "销售价:"
                    
                    if let value = materialModel?.priceCustom?.doubleValue {
                        let valueStr = value.notRoundingString(afterPoint: 2)
                        priceLabel.text = String.init(format: "￥%@", valueStr)
                        
                    }
                }else {
                    singleImgView.isHidden = true
                    priceTitleLabel.text = "市场价:"
                    
                    if let value = materialModel?.priceShow?.doubleValue {
                        let valueStr = value.notRoundingString(afterPoint: 2)
                        priceLabel.text = String.init(format: "￥%@", valueStr)
                        priceLabel.attributedText = priceLabel.text!.addUnderline()
                        priceLabel.textColor = Color.black.withAlphaComponent(0.4)
                    }
                }
            }
            else {
                if let value = materialModel?.priceCustom?.doubleValue {
                    let valueStr = value.notRoundingString(afterPoint: 2)
                    if value == 0 {
                        priceLabel.text = "标配"
//                        standardLabel.isHidden = false
//                        countView.isHidden = true
                    }else if value > 0 {
                        priceLabel.text = String.init(format: "￥+%@", valueStr)
                    }else if value < 0 {
                        priceLabel.text = String.init(format: "￥%@", valueStr)
                    }
                }
            }
            
            if let valueType = materialModel?.unitType?.intValue {
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(valueType)", fieldB: "label")
                if unitStr.count > 0  {
                    unitLabel.text = "单位: \(unitStr)"
                }
            }
            
            if let valueStr = materialModel?.buyCount.intValue {
                
                addBtn.isEnabled = true
                countTextField.isUserInteractionEnabled = true
                
                let value = Double(valueStr) / 100
                countTextField.text = value.notRoundingString(afterPoint: 2)
                
                if value > 1 {
                    reduceBtn.isEnabled = true
                }else {
                    reduceBtn.isEnabled = false
                }
            }
            
            if let valueStr = materialModel?.remarks {
                remarksLabel.text = valueStr
                remarksLabel.textColor = PublicColor.commonTextColor
            }
        }
    }
    
    var serviceModel: ServiceModel? {
        
        didSet {
            
            nameBtn.isEnabled = true
            nameBtn.setTitle("[分类]施工", for: .normal)
            brandLabel.isHidden = true
            unitLabel.text = "单位:"
//            standardLabel.isHidden = true
            countTextField.text = "1"
            countTextField.isUserInteractionEnabled = true
            countView.isHidden = false
            addBtn.isEnabled = true
            reduceBtn.isEnabled = false
            remarksLabel.text = "点击添加备注"
            remarksLabel.textColor = PublicColor.minorTextColor
            
            priceTitleLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(nameBtn)
                make.top.equalTo(nameBtn.snp.bottom).offset(14)
            }
            
            unitLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(priceLabel.snp.right).offset(20)
                make.centerY.equalTo(priceTitleLabel)
            }
            
            if serviceModel?.serviceType == 1 {
                newAddView.isHidden = true
            }else {
                newAddView.isHidden = false
            }
            
            var titleStr = ""
            if let valueType = serviceModel?.category?.stringValue {
                if AppData.serviceCategoryList.count > 0 {
                    let str = Utils.getFieldValInDirArr(arr: AppData.serviceCategoryList, fieldA: "value", valA: valueType, fieldB: "label")
                    if str == "" {
                        titleStr = "[分类缺失]"
                    }else {
                        titleStr = "[" + str + "]"
                    }
                    
                    imageType = valueType
                }
            }
            
            if let valueStr = serviceModel?.name {
                titleStr += valueStr
            }
            nameBtn.setTitle(titleStr, for: .normal)
            
            if isFreeCell {
                priceTitleLabel.text = "施工价: "
                priceLabel.text = "￥0.0"
                
                if let value = serviceModel?.cusPrice?.doubleValue {
                    let valueStr = value.notRoundingString(afterPoint: 2)
                    priceLabel.text = String.init(format: "￥%@", valueStr)
                }
            }
            else {
                priceTitleLabel.text = "加减价: "
                priceLabel.text = "标配"
                if let value = serviceModel?.cusPrice?.doubleValue {
                    let valueStr = value.notRoundingString(afterPoint: 2)
                    if value == 0 {
                        priceLabel.text = "标配"
//                        standardLabel.isHidden = false
//                        countView.isHidden = true
                    }else if value > 0 {
                        priceLabel.text = String.init(format: "￥+%@", valueStr)
                    }else if value < 0 {
                        priceLabel.text = String.init(format: "￥%@", valueStr)
                    }
                }
            }
            
            if let valueType = serviceModel?.unitType?.intValue {
                let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(valueType)", fieldB: "label")
                if unitStr.count > 0 {
                    unitLabel.text = "单位: \(unitStr)"
                }
            }
            
            if let valueStr = serviceModel?.buyCount.intValue {
                
                let value = Double(valueStr) / 100
                countTextField.text = value.notRoundingString(afterPoint: 2)
                
                if value > 1 {
                    reduceBtn.isEnabled = true
                }else {
                    reduceBtn.isEnabled = false
                }
            }
            
            if let valueStr = serviceModel?.remarks {
                remarksLabel.text = valueStr
                remarksLabel.textColor = PublicColor.commonTextColor
            }
        }
    }
    
    var imageType: String = "0" { //设置施工图片
        didSet {
            var imgName = ""
            switch imageType {
            case "1":
                imgName = "reorganization_img"
            case "2":
                imgName = "soilpave_img"
            case "3":
                imgName = "ceiling_img"
            case "4":
                imgName = "wallspace_img"
            case "5":
                imgName = "woodworking_img"
            case "6":
                imgName = "painter_img"
            case "7":
                imgName = "bricklayer_img"
            case "8":
                imgName = "waterproofing_img"
            case "9":
                imgName = "administrative_img"
            case "10":
                imgName = "whitefuel_img"
            case "11":
                imgName = "other_img"
            default:
                imgName = "other_img"
            }
            showImageView.image = UIImage(named: imgName)
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //图片
        showImageView = UIImageView()
        showImageView.isUserInteractionEnabled = true
        showImageView.contentMode = .scaleAspectFit
        showImageView.layer.cornerRadius = 5
        showImageView.layer.masksToBounds = true
        showImageView.image = UIImage.init(named: "order_material_back")
        contentView.addSubview(showImageView)
        
        showImageView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(12)
            make.width.height.equalTo(75)
        }
        
        //图片点击手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(detailAction))
        tapOne.numberOfTapsRequired = 1
        showImageView.addGestureRecognizer(tapOne)
        
        //单品标签
        singleImgView = UIImageView()
        singleImgView.isHidden = true
        singleImgView.contentMode = .scaleAspectFit
//        singleImgView.image = UIImage.init(named: "single_icon")
        showImageView.addSubview(singleImgView)
        
        singleImgView.snp.makeConstraints { (make) in
            make.left.top.equalTo(showImageView)
            make.width.height.equalTo(26)
        }
        
        //新增角标
        newAddView = UIImageView()
        newAddView.isHidden = true
        newAddView.image = UIImage.init(named: "addLabel_icon")
        newAddView.contentMode = .scaleAspectFit
        showImageView.addSubview(newAddView)
        
        newAddView.snp.makeConstraints { (make) in
            make.edges.equalTo(singleImgView)
        }
        
        //名称
        nameBtn = UIButton(type: .custom)
        nameBtn.isEnabled = false
        nameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        nameBtn.contentHorizontalAlignment = .left
        nameBtn.setTitle("产品名", for: .normal)
        nameBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        nameBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        nameBtn.addTarget(self, action: #selector(detailAction), for: .touchUpInside)
        contentView.addSubview(nameBtn)
        
        nameBtn.snp.makeConstraints { (make) in
            make.top.equalTo(showImageView).offset(-3)
            make.left.equalTo(showImageView.snp.right).offset(10)
            make.right.equalTo(-10)
            make.height.equalTo(22)
        }
        
        //品牌
        brandLabel = UILabel()
        brandLabel.text = "品牌: 无"
        brandLabel.font = UIFont.systemFont(ofSize: 10)
        brandLabel.textColor = PublicColor.minorTextColor
        contentView.addSubview(brandLabel)
        
        brandLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameBtn.snp.bottom)
            make.left.equalTo(nameBtn)
        }
        
        //单位
        unitLabel = UILabel()
        unitLabel.text = "单位:"
        unitLabel.font = brandLabel.font
        unitLabel.textColor = brandLabel.textColor
        contentView.addSubview(unitLabel)
        
        unitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(brandLabel.snp.right).offset(20)
            make.centerY.equalTo(brandLabel)
        }
        
        //价格标题
        priceTitleLabel = UILabel()
        priceTitleLabel.text = "加减价："
        priceTitleLabel.font = brandLabel.font
        priceTitleLabel.textColor = brandLabel.textColor
        contentView.addSubview(priceTitleLabel)
        
        priceTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameBtn)
            make.top.equalTo(brandLabel.snp.bottom).offset(4)
        }
        
        //价格
        priceLabel = UILabel()
        priceLabel.text = "￥+0.00"
        priceLabel.font = priceTitleLabel.font
        priceLabel.textColor = priceTitleLabel.textColor
        contentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(priceTitleLabel)
            make.left.equalTo(priceTitleLabel.snp.right)
        }
        
        //计数框背景色
        let countColor = PublicColor.navigationLineColor
        
        //计数框背景
        countView = UIView()
        countView.layer.borderWidth = 1
        countView.layer.borderColor = countColor.cgColor
        countView.layer.cornerRadius = 2
        contentView.addSubview(countView)
        
        countView.snp.makeConstraints { (make) in
            make.left.equalTo(nameBtn)
            make.bottom.equalTo(showImageView).offset(-2)
            make.width.equalTo(75)
            make.height.equalTo(21)
        }
        
        //分割线
        let leftLineView = UIView()
        leftLineView.backgroundColor = countColor
        countView.addSubview(leftLineView)
        
        leftLineView.snp.makeConstraints { (make) in
            make.left.equalTo(18)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
        
        //分割线
        let rightLineView = UIView()
        rightLineView.backgroundColor = countColor
        countView.addSubview(rightLineView)
        
        rightLineView.snp.makeConstraints { (make) in
            make.right.equalTo(-18)
            make.top.bottom.width.equalTo(leftLineView)
        }
        
        //计数框
        countTextField = UITextField()
        countTextField.delegate = self
        countTextField.returnKeyType = .done
        countTextField.textAlignment = .center
        countTextField.keyboardType = .decimalPad
        countTextField.text = "1"
        countTextField.textColor = PublicColor.minorTextColor
        countTextField.font = UIFont.systemFont(ofSize: 10)
        countView.addSubview(countTextField)
        
        countTextField.snp.makeConstraints { (make) in
            make.center.height.equalToSuperview()
            make.left.equalTo(leftLineView.snp.right)
            make.right.equalTo(rightLineView.snp.left)
        }
        
        //减按钮
        reduceBtn = UIButton(type: .custom)
        reduceBtn.setImage(UIImage.init(named: "order_reduce"), for: .normal)
        reduceBtn.isEnabled = false
        reduceBtn.addTarget(self, action: #selector(reduceAction(_:)), for: .touchUpInside)
        countView.addSubview(reduceBtn)
        
        reduceBtn.snp.makeConstraints { (make) in
            make.height.equalTo(40)
            make.centerY.left.equalToSuperview()
            make.right.equalTo(leftLineView.snp.left)
        }
        
        //加按钮
        addBtn = UIButton(type: .custom)
        addBtn.setImage(UIImage.init(named: "order_add_cell"), for: .normal)
        addBtn.addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
        countView.addSubview(addBtn)
        
        addBtn.snp.makeConstraints { (make) in
            make.height.equalTo(reduceBtn)
            make.centerY.right.equalToSuperview()
            make.left.equalTo(rightLineView.snp.right)
        }
        
        //标配
//        standardLabel = UILabel()
//        standardLabel.text = "标配"
//        standardLabel.font = UIFont.systemFont(ofSize: 11)
//        standardLabel.textColor = priceTitleLabel.textColor
//        contentView.addSubview(standardLabel)
//
//        standardLabel.snp.makeConstraints { (make) in
//            make.left.bottom.equalTo(countView)
//        }
        
        //操作
        operationBtn = UIButton(type: .custom)
        operationBtn.layer.cornerRadius = 2
        operationBtn.layer.borderWidth = 1
        operationBtn.layer.borderColor = PublicColor.navigationLineColor.cgColor
        operationBtn.layer.masksToBounds = true
        operationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        operationBtn.setTitle("选择", for: .normal)
        operationBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        operationBtn.setBackgroundImage(PublicColor.buttonColorImage, for: .normal)
        operationBtn.setBackgroundImage(PublicColor.buttonHightColorImage, for: .highlighted)
        operationBtn.addTarget(self, action: #selector(operationAction), for: .touchUpInside)
        contentView.addSubview(operationBtn)
        
        operationBtn.snp.makeConstraints { (make) in
            make.right.equalTo(nameBtn)
            make.bottom.equalTo(countView)
            make.width.equalTo(50)
            make.height.equalTo(22)
        }
        
        //备注按钮
        remarksBtn = UIButton()
        remarksBtn.addTarget(self, action: #selector(remarkAction), for: .touchUpInside)
        contentView.addSubview(remarksBtn)
        
        remarksBtn.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(showImageView.snp.bottom).offset(10)
            make.bottom.equalTo(-10)
            make.height.equalTo(22)
        }
        
        //备注标题
        let remarksTitle = UILabel()
        remarksTitle.text = "备注:"
        remarksTitle.font = UIFont.systemFont(ofSize: 12)
        remarksTitle.textColor = PublicColor.commonTextColor
        remarksBtn.addSubview(remarksTitle)
        
        remarksTitle.snp.makeConstraints { (make) in
            make.left.equalTo(showImageView)
            make.centerY.equalToSuperview()
            make.width.equalTo(36)
        }
        
        //备注
        remarksLabel = UILabel()
        remarksLabel.text = "点击添加备注"
        remarksLabel.font = remarksTitle.font
        remarksLabel.textColor = PublicColor.minorTextColor
        remarksBtn.addSubview(remarksLabel)
        
        remarksLabel.snp.makeConstraints { (make) in
            make.left.equalTo(remarksTitle.snp.right)
            make.centerY.equalTo(remarksTitle)
            make.right.equalTo(nameBtn)
        }
        
        //分割线
        lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(showImageView).offset(5)
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
            make.right.equalTo(-15)
        }
    }
    
    //主材详情
    @objc func detailAction() {
        if let block = detailBlock {
            block()
        }
    }
    
    //加
    @objc func addAction(_ sender: UIButton) {
        
        if let sumCount = Double(countTextField.text!) {
            let sum = sumCount + 1
            countTextField.text = sum.notRoundingString(afterPoint: 2)
            getSumValue(countTextField.text!)
        }
    }
    
    //减
    @objc func reduceAction(_ sender: UIButton) {
        
        if let sumCount = Double(countTextField.text!) {
            let sum = sumCount - 1
            countTextField.text = sum.notRoundingString(afterPoint: 2)
            getSumValue(countTextField.text!)
        }
    }
    
    //选择
    @objc func operationAction() {
        
        if let block = operationBlock {
            block()
        }
    }
    
    //备注
    @objc func remarkAction() {
        
        if let block = remarkBlock {
            block()
        }
    }
    
    //计算
    func getSumValue(_ newString: String) {
        
        if let sumCount = Double(newString) {
            
            if sumCount > 1 {
                reduceBtn.isEnabled = true
            }else {
                reduceBtn.isEnabled = false
            }
            
            if sumCount < 999 {
                addBtn.isEnabled = true
            }else {
                addBtn.isEnabled = false
            }
            
            countTextField.text = sumCount.notRoundingString(afterPoint: 2)
            
            if materialModel != nil {
                materialModel?.buyCount = NSNumber.init(value: sumCount*100)
            }else {
                serviceModel?.buyCount = NSNumber.init(value: sumCount*100)
            }
            
            if let block = changeCountBlock {
                block()
            }
        }
        else {
            reduceBtn.isEnabled = false
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //只允许输入数字
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newString == "" {
            return true
        }
        
        if let newValue = Float(newString) {
            if newValue >= 1000 {
                self.noticeOnlyText("最多只能买999件哦!")
                return false
            }
        }
        
        var expression = "^[0-9]*$"
        
        if serviceModel != nil {
            expression = "^[0-9]+([.][0-9]{0,2})?$"
        }
        else if let valueStr = materialModel?.unitType {
            
            let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
            if unitStr == "平方" || unitStr == "米" || unitStr == "公斤" || unitStr == "立方" {
                expression = "^[0-9]+([.][0-9]{0,2})?$"
            }else {
                if let rang = newString.range(of: ".") {
                    let preString = String(newString.prefix(upTo: rang.lowerBound))
                    textField.text = preString
                    return false
                }
            }
        }else {
            if let rang = newString.range(of: ".") {
                let preString = String(newString.prefix(upTo: rang.lowerBound))
                textField.text = preString
                return false
            }
        }
        
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        
        if numberOfMatches == 0 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //收起键盘
        textField.resignFirstResponder()
        //打印出文本框中的值
        AppLog(textField.text!)
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if let sumCount = Double(textField.text!) {
            
            if sumCount < 0.1 {
                textField.text = "1"
            }
            
        }else {
            textField.text = "1"
        }
        
        getSumValue(textField.text!)
    }
}
