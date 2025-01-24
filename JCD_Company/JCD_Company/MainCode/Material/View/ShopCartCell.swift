//
//  ShopCartCell.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/25.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

protocol CellCountTextFieldDelegate: NSObjectProtocol {
    func countTextFieldChanged(indexPath: IndexPath, count: Int)
}


class ShopCartCell: UITableViewCell, UITextFieldDelegate {
    var selectedBtn: UIButton!                          //选择按钮
    var showImageView: UIImageView!                     //图片
    var singleImage: UIImageView!                       //单品角标
    var combinationBtn: UIButton!                       //组合购标
    var nameBtn: UIButton!                              //标题
    var priceTitle: UILabel!                            //价格标题
    var marketPriceLabel: UILabel!                      //市场价
    var priceLabel: UILabel!                            //销售价
    var unitLabel: UILabel!                             //单位
    var brandLabel: UILabel!                            //品牌
    var countView: UIView!                      //计数框背景
    var countTextField: UITextField!            //数量输入框
    var reduceBtn: UIButton!                    //减按钮
    var addBtn: UIButton!                       //加按钮
    var countBlock: ((_ count: NSNumber)->())?   // 商品数block
    var detailBlock: (()->())?                          //详情block
    var selectedBlock: ((_ isCheck: Bool)->())?         //选中block
    
    let textFont = UIFont.systemFont(ofSize: 12)
    
    var materialsModel: MaterialsModel? {
        
        didSet {
            selectedBtn.isSelected = materialsModel!.isCheckBtn
            showImageView.image = UIImage.init(named: "loading")
            priceTitle.text = "销售价"
            priceLabel.text = "未定价"
            nameBtn.setTitle("产品名", for: .normal)
            nameBtn.isEnabled = false
            unitLabel.text = "单位: 无"
            brandLabel.text = "规格: 未知"
            countTextField.text = "1"
            if let imageStr = materialsModel?.image, let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
//                showImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading"))
                showImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading"))
            } else {
                showImageView.image = UIImage.init(named: "loading")
            }
            if materialsModel?.materials?.isOneSell == 2 {
                singleImage.isHidden = true
                combinationBtn.isHidden = false
                priceLabel.isHidden = false
                priceTitle.text = "市场价"
                marketPriceLabel.isHidden = true
            } else {
                singleImage.isHidden = false
                combinationBtn.isHidden = true
                priceLabel.isHidden = false
                marketPriceLabel.isHidden = false
                priceTitle.text = "销售价"
            }
            
            if let valueStr = materialsModel?.materials?.name {
                nameBtn.setTitle(valueStr, for: .normal)
                nameBtn.isEnabled = true
            }
            if let valueStr = materialsModel?.priceShow?.doubleValue {
                let value = valueStr.notRoundingString( afterPoint: 2)
                marketPriceLabel.text = String.init(format: "￥%@", value)
                marketPriceLabel.setLabelUnderline()
            }
            if let valueStr = materialsModel?.priceSell?.doubleValue {
                let value = valueStr.notRoundingString( afterPoint: 2)
                priceLabel.text = String.init(format: "￥%@", value)
            }
            unitLabel.text = "单位: \(materialsModel?.unitTypeName ?? "无")"
            
            if let valueStr = materialsModel?.skuAttr1 {
                brandLabel.text = "规格: \(valueStr)"
            }
            if let buyCount = materialsModel?.count{
                countTextField.text = "\(buyCount)"
                if buyCount.intValue > 1 {
                    reduceBtn.isEnabled = true
                } else {
                    reduceBtn.isEnabled = false
                }
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        self.selectionStyle = .none
        createSubView()
    }
    
    func createSubView() {
        //自定义分割线
        let separatorView = UIView()
        separatorView.backgroundColor = .kColor230
        contentView.addSubview(separatorView)
        
        separatorView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
        //选中按钮
        selectedBtn = UIButton.init(type: .custom)
        selectedBtn.setImage(UIImage.init(named: "login_uncheck"), for: .normal)
        selectedBtn.setImage(UIImage.init(named: "login_check"), for: .selected)
        selectedBtn.addTarget(self, action: #selector(selectedAction(_:)), for: .touchUpInside)
        contentView.addSubview(selectedBtn)
        
        selectedBtn.snp.makeConstraints { (make) in
            make.left.equalTo(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(38)
        }
        
        //商品图片
        showImageView = UIImageView()
        showImageView.isUserInteractionEnabled = true
        showImageView.contentMode = .scaleAspectFit
        showImageView.layer.cornerRadius = 3
        showImageView.layer.masksToBounds = true
        showImageView.image = UIImage.init(named: "loading")
        contentView.addSubview(showImageView)
        
        showImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(selectedBtn.snp.right)
            make.width.height.equalTo(100)
        }
        
        //图片点击手势
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(detailAction))
        tapOne.numberOfTapsRequired = 1
        showImageView.addGestureRecognizer(tapOne)
        
        //单品角标
        singleImage = UIImageView()
        singleImage.isHidden = true
        singleImage.contentMode = .scaleAspectFit
        showImageView.addSubview(singleImage)
        
        singleImage.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(26)
        }
        
        combinationBtn = UIButton()
        combinationBtn.setBackgroundImage(UIImage.init(named: "comBuy"), for: .normal)
        showImageView.addSubview(combinationBtn)
        combinationBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(54)
            make.height.equalTo(22)
        }
        
        //商品标题
        nameBtn = UIButton(type: .custom)
        nameBtn.contentHorizontalAlignment = .left
        nameBtn.titleLabel?.numberOfLines = 2
        nameBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        nameBtn.setTitle("产品名", for: .normal)
        nameBtn.setTitleColor(.kColor33, for: .normal)
        nameBtn.setTitleColor(.kColor33, for: .highlighted)
        nameBtn.addTarget(self, action: #selector(detailAction), for: .touchUpInside)
        contentView.addSubview(nameBtn)
        
        nameBtn.snp.makeConstraints { (make) in
            make.top.equalTo(showImageView)
            make.left.equalTo(showImageView.snp.right).offset(10)
            make.right.equalTo(-15)
        }
        
        
        //单位
        unitLabel = UILabel()
        unitLabel.text = "单位:"
        unitLabel.textColor = .kColor66
        unitLabel.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(unitLabel)
        
        unitLabel.snp.makeConstraints { (make) in
            make.left.equalTo(showImageView.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        //规格
        brandLabel = UILabel()
        brandLabel.text = "规格: 未知"
        brandLabel.textColor = .kColor66
        brandLabel.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(brandLabel)
        
        brandLabel.snp.makeConstraints { (make) in
            make.left.equalTo(unitLabel.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        
        //价格
        priceLabel = UILabel()
        priceLabel.text = ""
        priceLabel.textColor = #colorLiteral(red: 1, green: 0.6705882353, blue: 0.2392156863, alpha: 1)
        priceLabel.font = UIFont.boldSystemFont(ofSize: 12)
        contentView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(showImageView.snp.right).offset(10)
            make.bottom.equalTo(showImageView.snp.bottom).offset(-19)
        }
        
        
        //市场价
        priceTitle = UILabel()
        priceTitle.text = "销售价"
        priceTitle.textColor = PublicColor.minorTextColor
        priceTitle.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(priceTitle)
        
        priceTitle.snp.makeConstraints { (make) in
            make.left.equalTo(priceLabel.snp.right).offset(5)
            make.centerY.equalTo(priceLabel)
        }
        
        
        //价格
        marketPriceLabel = UILabel()
        marketPriceLabel.text = ""
        marketPriceLabel.textColor = #colorLiteral(red: 1, green: 0.6705882353, blue: 0.2392156863, alpha: 1)
        marketPriceLabel.font = UIFont.systemFont(ofSize: 10)
        contentView.addSubview(marketPriceLabel)
        
        marketPriceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(showImageView.snp.right).offset(10)
            make.bottom.equalTo(showImageView.snp.bottom)
        }
        
        
        //计数框背景
        countView = UIView()
        countView.layer.borderWidth = 0.5
        countView.layer.borderColor = UIColor.kColor220.cgColor
        contentView.addSubview(countView)
        
        countView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-14)
            make.width.equalTo(75)
            make.height.equalTo(22)
            make.bottom.equalTo(showImageView)
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
            make.width.equalTo(31)
        }
        
        //减按钮
        reduceBtn = UIButton(type: .custom)
        reduceBtn.setImage(UIImage.init(named: "order_reduce"), for: .normal)
        reduceBtn.isEnabled = false
        reduceBtn.addTarget(self, action: #selector(reduceAction(_:)), for: .touchUpInside)
        countView.addSubview(reduceBtn)
        
        reduceBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(22)
            make.centerY.left.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        //加按钮
        addBtn = UIButton(type: .custom)
        addBtn.setImage(UIImage.init(named: "order_add_cell"), for: .normal)
        addBtn.addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
        countView.addSubview(addBtn)
        
        addBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(reduceBtn)
            make.centerY.right.equalToSuperview()
        }
    }
    
    //加
    @objc func addAction(_ sender: UIButton) {
        if let sumCount = Double(countTextField.text!) {
            let sum = sumCount + 1
            countTextField.text = sum.notRoundingString( afterPoint: 2)
            getSumValue(countTextField.text!)
        }
    }
    
    //减
    @objc func reduceAction(_ sender: UIButton) {
        
        if let sumCount = Double(countTextField.text!) {
            let sum = sumCount - 1
            countTextField.text = sum.notRoundingString( afterPoint: 2)
            getSumValue(countTextField.text!)
        }
        
    }
    
    private func updateNumRequest() {
        var parameters = [String: Any]()
        parameters["skuId"] = materialsModel?.id
        parameters["num"] = materialsModel?.count ?? 0
        parameters["operType"] = 1
        self.pleaseWait()
        let urlStr = APIURL.saveCartList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                
            }
        }) { (error) in  }
    }
    
    //计算
    func getSumValue(_ newString: String) {
        
        if let sumCount = Double(newString) {
            if sumCount > 1 {
                reduceBtn.isEnabled = true
            } else {
                reduceBtn.isEnabled = false
            }
            countTextField.text = sumCount.notRoundingString( afterPoint: 2)
            materialsModel?.count = NSNumber.init(value: sumCount)
            if let block = countBlock {
                block(materialsModel?.count ?? 1)
            }
            updateNumRequest()
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
        
        let expression = "^[0-9]*$"
        
        //        if serviceModel != nil {
        //            expression = "^[0-9]+([.][0-9]{0,2})?$"
        //        }
        //        else if let valueStr = packageModel?.materials?.unitType {
        //
        //            let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
        //            if unitStr == "平方" || unitStr == "米" || unitStr == "公斤" || unitStr == "立方" {
        //                expression = "^[0-9]+([.][0-9]{0,2})?$"
        //            }else {
        //                if let rang = newString.range(of: ".") {
        //                    let preString = String(newString.prefix(upTo: rang.lowerBound))
        //                    textField.text = preString
        //                    return false
        //                }
        //            }
        //        }else {
        //            if let rang = newString.range(of: ".") {
        //                let preString = String(newString.prefix(upTo: rang.lowerBound))
        //                textField.text = preString
        //                return false
        //            }
        //        }
        
        let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
        let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
        
        if numberOfMatches == 0 {
            return false
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //        if let block = beginEditingBlock {
        //            block()
        //        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //收起键盘
        textField.resignFirstResponder()
        //打印出文本框中的值
        AppLog(textField.text!)
        return true
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
    
    //选中
    @objc func selectedAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        materialsModel?.isCheckBtn = sender.isSelected
        
        if let block = selectedBlock {
            block(sender.isSelected)
        }
    }
    
    @objc func detailAction() {
        AppLog("点击了主材详情")
        if let block = detailBlock {
            block()
        }
    }
}
