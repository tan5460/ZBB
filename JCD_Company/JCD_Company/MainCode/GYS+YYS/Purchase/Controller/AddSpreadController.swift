//
//  AddSpreadController.swift
//  YZB_Company
//
//  Created by yzb_ios on 18.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import ObjectMapper

enum AddSpreadType {
    case edit       //修改
    case add        //添加
    case new        //采购下单新增（不与服务器交互）
    case look       //不可修改
}

class AddSpreadController: BaseViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var displayChangedNumber: UILabel!          //千分位显示框
    var priceField: UITextField!                //单价输入框
    var unitField: UITextField!                 //单位输入框
    var countField: UITextField!                //数量输入框
    var specField: UITextField!                 //规格输入框
    
    var doneHandler: (() -> Void)?              //添加完后
    
    let textFont = UIFont.systemFont(ofSize: 14)
    var tableView: UITableView!
    var cellHeight: CGFloat = 90
    
    var orderId = ""
    var purchaseMaterial: PurchaseMaterialModel?
    var spreadType: AddSpreadType = .edit
    
    var saveModelBlock:((_ model:PurchaseMaterialModel?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if purchaseMaterial == nil {
            purchaseMaterial = PurchaseMaterialModel()
            purchaseMaterial?.orderTemp = PurchaseMaterialModel()
        }
        
        prepareNavItem()
        prepareSubView()
    }
    
    func prepareNavItem() {
        
        if spreadType != .look {
            let saveBtn = UIButton(type: .custom)
            saveBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
            saveBtn.setTitle("保存", for: .normal)
            saveBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            saveBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
            saveBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
            saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
            
            let editItem = UIBarButtonItem.init(customView: saveBtn)
            navigationItem.rightBarButtonItem = editItem
        }
    }
    
    func prepareSubView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = PublicColor.partingLineColor
        tableView.tableFooterView = UIView()
        tableView.register(PurchaseRemarkCell.self, forCellReuseIdentifier: PurchaseRemarkCell.self.description())
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let heaserView = UIView(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: 186))
        tableView.tableHeaderView = heaserView
        
        
        //白色输入框背景
        let countWhiteView = UIView()
        countWhiteView.backgroundColor = .white
        heaserView.addSubview(countWhiteView)
        
        countWhiteView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(heaserView.height-10)
            make.top.equalTo(10)
        }
        
        //单价标题
        let priceTitle = UILabel()
        priceTitle.text = "单价:"
        priceTitle.textColor = PublicColor.minorTextColor
        priceTitle.font = textFont
        countWhiteView.addSubview(priceTitle)
        
        priceTitle.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalToSuperview()
            make.width.equalTo(66)
            make.height.equalTo(44)
        }
        
        //单价输入框
        priceField = UITextField()
        priceField.delegate = self
        priceField.tag = 101
        priceField.returnKeyType = .done
        priceField.keyboardType = .decimalPad
        priceField.placeholder = "请输入产品单价"
        priceField.textColor = PublicColor.commonTextColor
        priceField.font = textFont
        priceField.addTarget(self, action: #selector(textFieldEditChanged(_:)), for: .editingChanged)
        countWhiteView.addSubview(priceField)
        
        priceField.snp.makeConstraints { (make) in
            make.centerY.height.equalTo(priceTitle)
            make.left.equalTo(priceTitle.snp.right)
            make.right.equalTo(-15)
        }
        
        //千分位显示
        displayChangedNumber = UILabel()
        displayChangedNumber.textColor = PublicColor.commonTextColor
        displayChangedNumber.font = textFont
        countWhiteView.addSubview(displayChangedNumber)
        displayChangedNumber.snp.makeConstraints { (make) in
            make.centerY.height.equalTo(priceTitle)
            make.left.equalTo(priceTitle.snp.right)
            make.right.equalTo(-15)
        }
        
        //分割线1
        let lineView1 = UIView()
        lineView1.backgroundColor = PublicColor.partingLineColor
        countWhiteView.addSubview(lineView1)
        
        lineView1.snp.makeConstraints { (make) in
            make.bottom.left.equalTo(priceTitle)
            make.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //规格标题
        let specTitle = UILabel()
        specTitle.text = "规格:"
        specTitle.textColor = PublicColor.minorTextColor
        specTitle.font = textFont
        countWhiteView.addSubview(specTitle)
        
        specTitle.snp.makeConstraints { (make) in
            make.left.width.height.equalTo(priceTitle)
            make.top.equalTo(priceTitle.snp.bottom)
        }
        
        //规格输入框
        specField = UITextField()
        specField.delegate = self
        specField.tag = 104
        specField.returnKeyType = .done
        specField.placeholder = "非必填"
        specField.textColor = PublicColor.commonTextColor
        specField.font = textFont
        countWhiteView.addSubview(specField)
        
        specField.snp.makeConstraints { (make) in
            make.centerY.height.equalTo(specTitle)
            make.left.right.equalTo(priceField)
        }
        
        //分割线2
        let lineView2 = UIView()
        lineView2.backgroundColor = PublicColor.partingLineColor
        countWhiteView.addSubview(lineView2)
        
        lineView2.snp.makeConstraints { (make) in
            make.bottom.equalTo(specTitle)
            make.left.right.height.equalTo(lineView1)
        }
        
        //单位标题
        let unitTitle = UILabel()
        unitTitle.text = "单位:"
        unitTitle.textColor = PublicColor.minorTextColor
        unitTitle.font = textFont
        countWhiteView.addSubview(unitTitle)
        
        unitTitle.snp.makeConstraints { (make) in
            make.left.width.height.equalTo(priceTitle)
            make.top.equalTo(specTitle.snp.bottom)
        }
        
        //单位输入框
        unitField = UITextField()
        unitField.delegate = self
        unitField.tag = 102
        unitField.returnKeyType = .done
        unitField.placeholder = "请输入产品单位"
        unitField.textColor = PublicColor.commonTextColor
        unitField.font = textFont
        countWhiteView.addSubview(unitField)
        
        unitField.snp.makeConstraints { (make) in
            make.centerY.height.equalTo(unitTitle)
            make.left.right.equalTo(priceField)
        }
        
        //分割线3
        let lineView3 = UIView()
        lineView3.backgroundColor = PublicColor.partingLineColor
        countWhiteView.addSubview(lineView3)
        
        lineView3.snp.makeConstraints { (make) in
            make.bottom.equalTo(unitTitle)
            make.left.right.height.equalTo(lineView1)
        }
        
        //数量标题
        let countTitle = UILabel()
        countTitle.text = "数量:"
        countTitle.textColor = PublicColor.minorTextColor
        countTitle.font = textFont
        countWhiteView.addSubview(countTitle)
        
        countTitle.snp.makeConstraints { (make) in
            make.left.width.height.equalTo(priceTitle)
            make.top.equalTo(unitTitle.snp.bottom)
        }
        
        //数量输入框
        countField = UITextField()
        countField.delegate = self
        countField.tag = 103
        countField.returnKeyType = .done
        countField.placeholder = "请输入产品数量"
        countField.keyboardType = .decimalPad
        countField.textColor = PublicColor.commonTextColor
        countField.font = textFont
        countWhiteView.addSubview(countField)
        
        countField.snp.makeConstraints { (make) in
            make.centerY.height.equalTo(countTitle)
            make.left.right.equalTo(priceField)
        }
        
        //分割线4
        let lineView4 = UIView()
        lineView4.backgroundColor = PublicColor.partingLineColor
        countWhiteView.addSubview(lineView4)
        
        lineView4.snp.makeConstraints { (make) in
            make.bottom.equalTo(countTitle)
            make.left.right.height.equalTo(lineView1)
        }
        
        //赋值
        if let valueStr = purchaseMaterial?.orderTemp?.costPrice?.stringValue {
            priceField.text = valueStr
        }
        if let valueStr = purchaseMaterial?.orderTemp?.unitType {
            unitField.text = valueStr
        }
        if let valueStr = purchaseMaterial?.countInt, valueStr > 0 {
            countField.text = valueStr.notRoundingString(afterPoint: 2)
        }
        if let valueStr = purchaseMaterial?.orderTemp?.spec {
            specField.text = valueStr
        }
        
        if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
            priceTitle.textColor = PublicColor.placeholderTextColor
            priceField.isUserInteractionEnabled = false
            priceField.placeholder = "此处为品牌商填写"
            
            specField.textColor = PublicColor.placeholderTextColor
            specField.isUserInteractionEnabled = false
            specField.placeholder = "此处为品牌商填写"
        }
        
        if spreadType == .look {
            priceTitle.textColor = PublicColor.minorTextColor
            priceField.isUserInteractionEnabled = false
            unitField.isUserInteractionEnabled = false
            countField.isUserInteractionEnabled = false
            specField.isUserInteractionEnabled = false
        }
    }
    
    
    //MARK: - 按钮点击事件
    
    @objc func saveAction() {
        
        if let valueStr = Double(countField.text!) {
            purchaseMaterial?.countInt = valueStr
            purchaseMaterial?.materials?.buyCount = NSNumber(value: valueStr*100)
        }
        
        if priceField.text == "" && UserData.shared.userType != .cgy && UserData.shared.userType != .jzgs  {
            self.noticeOnlyText("请填写产品单价~")
            return
        }
        if purchaseMaterial!.countInt <= 0 {
            self.noticeOnlyText("请填写产品数量~")
            return
        }
        if purchaseMaterial?.orderTemp?.name == "" || purchaseMaterial?.orderTemp?.name == nil {
            self.noticeOnlyText("请填写产品名~")
            return
        }
        
        if UserData.shared.userType != .cgy && UserData.shared.userType != .jzgs {
            purchaseMaterial?.orderTemp?.costPrice = NSNumber(value: Double(string: priceField.text!)!)
        }
        
        purchaseMaterial?.orderTemp?.unitType = unitField.text
        purchaseMaterial?.orderTemp?.spec = specField.text
        
        if spreadType == .new {
            saveModelBlock?(purchaseMaterial)
            self.navigationController?.popViewController(animated: true)
        }else {
            var parameters: Parameters = [:]
            parameters["yzbPurchaseOrderId"] = orderId
            parameters["materialSinglCost"] = ""
            
            if let valueStr = purchaseMaterial?.orderTemp?.name {
                parameters["proName"] = valueStr
            }
            if let valueStr = purchaseMaterial?.orderTemp?.costPrice {
                parameters["materialSinglCost"] = valueStr
            }
            if let valueStr = purchaseMaterial?.orderTemp?.unitType {
                parameters["unitType"] = valueStr
            }
            if let valueStr = purchaseMaterial?.countInt {
                parameters["proNum"] = "\(valueStr)"
            }
            if let valueStr = purchaseMaterial?.orderTemp?.spec {
                parameters["materialSpec"] = valueStr
            }
            if let valueStr = purchaseMaterial?.remarks {
                parameters["remarks1"] = valueStr
            }
            if let valueStr = purchaseMaterial?.remarks2 {
                parameters["remarks2"] = valueStr
            }
            if let valueStr = purchaseMaterial?.remarks3 {
                parameters["remarks3"] = valueStr
            }
            
            var urlStr = APIURL.addSpreadProduct
            
            if spreadType == .edit {
                urlStr = APIURL.editSpreadProduct
                if let valueStr = purchaseMaterial?.id {
                    parameters["proDataId"] = valueStr
                }
            }
            self.pleaseWait()
            
            YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
                
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
                if errorCode == "000" {
                    
                    self.doneHandler?()
                    self.navigationController?.popViewController(animated: true)
                }
                
            }) { (error) in
                
            }
        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseRemarkCell.self.description(), for: indexPath) as! PurchaseRemarkCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        cell.placeholderLabel.text = "无"
        
        if spreadType == .look {
            cell.textView.isUserInteractionEnabled = false
        }
        
        cell.textViewChangeBlock = { [weak self] textStr in
            
            if indexPath.row == 0 {
                self?.purchaseMaterial?.orderTemp?.name = textStr
            }else if indexPath.row == 1 {
                if self?.spreadType == .new {
                    self?.purchaseMaterial?.orderTemp?.remarks = textStr
                }
                else {
                    self?.purchaseMaterial?.remarks = textStr
                }
            }else if indexPath.row == 2 {
                if self?.spreadType == .new {
                    self?.purchaseMaterial?.orderTemp?.remarks2 = textStr
                }
                else {
                    self?.purchaseMaterial?.remarks2 = textStr
                }
                
            }else if indexPath.row == 3 {
                if self?.spreadType == .new {
                    self?.purchaseMaterial?.orderTemp?.remarks3 = textStr
                }
                else {
                    self?.purchaseMaterial?.remarks3 = textStr
                }
            }
        }
        
        cell.textViewEndEditBlock = { tableView.reloadData() }
        
        cellHeight = 90
        var remarks = ""
        
        if indexPath.row == 0 {
            cell.placeholderLabel.text = "请输入产品名"
        }else {
            if spreadType == .edit {
                cell.placeholderLabel.text = "无"
            }else {
                cell.placeholderLabel.text = "非必填"
            }
        }
        
        if indexPath.row == 0 {
            cell.titleLabel.text = "产品名:"
            
            if let valueStr = purchaseMaterial?.orderTemp?.name {
                remarks = valueStr
            }
        }else if indexPath.row == 1 {
            cell.titleLabel.text = "备注:"
            
            if let valueStr = purchaseMaterial?.remarks {
                remarks = valueStr
            }
        }else if indexPath.row == 2 {
            cell.titleLabel.text = "颜色和样式:"
            
            if let valueStr = purchaseMaterial?.remarks2 {
                remarks = valueStr
            }
        }else if indexPath.row == 3 {
            cell.separatorInset = UIEdgeInsets.zero
            cell.titleLabel.text = "使用区域:"
            
            if let valueStr = purchaseMaterial?.remarks3 {
                remarks = valueStr
            }
        }
        
        if remarks != "" {
            cell.textView.text = remarks
            
            let otherHeight: CGFloat = 41
            let textHeight = cell.textView.sizeThatFits(CGSize.init(width: cell.textView.width, height: CGFloat(MAXFLOAT))).height
            let newHeight = textHeight+otherHeight+5
            
            if newHeight > cellHeight {
                cellHeight = newHeight
            }else {
                cellHeight = 90
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if cellHeight < 90 {
            return 90
        }else {
            return cellHeight
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    @objc func textFieldEditChanged(_ textField: UITextField) {
        
        if (displayChangedNumber.text ?? "").length > 3 {
            textField.font = UIFont.systemFont(ofSize: 16)
        }
        
        if (textField.text! as NSString).doubleValue >= 100000 || textField.text!.length >= 8 {
            textField.text = "99999.99"
        }
        
        displayChangedNumber.text = textField.text!.addMicrometerLevel()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //只允许输入数字
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newString == "" {
            return true
        }
        
        if textField.tag == 102 || textField.tag == 104 {
            return true
        }
        
        let expression = "^[0-9]+([.][0-9]{0,2})?$"
        if textField.tag == 101 {
            //单价
            
        }else if textField.tag == 103 {
            //数量
            if let newValue = Float(newString) {
                if newValue >= 1000 {
                    self.noticeOnlyText("最多只能买999件哦~")
                    return false
                }
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
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.tag == 101 || textField.tag == 103 {
            
            if let sumCount = Double(textField.text!) {
                
                if sumCount < 0.1 {
                    textField.text = "1"
                }
                
            }else {
                textField.text = "1"
            }
        }
    }
}
