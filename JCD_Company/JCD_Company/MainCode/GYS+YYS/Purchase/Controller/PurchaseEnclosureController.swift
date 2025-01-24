//
//  PurchaseEnclosureController.swift
//  YZB_Company
//
//  Created by yzb_ios on 16.01.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire
import ObjectMapper

class PurchaseEnclosureController: BaseViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource,TZImagePickerControllerDelegate {
    var countField: UITextField!                //数量输入框
    var costLabel: UILabel!                     //会员价
    var priceLabel: UILabel!                    //平台价
    var costSumLabel: UILabel!                  //结算总价
    var priceSumLabel: UILabel!                 //平台总价
    var fileView: UIView!                       //文件上视图
    
    var fileUrlArray: Array<ImageFileModel> = []
    let textFont2 = UIFont.systemFont(ofSize: 12)
    var tableView: UITableView!
    var cellHeight: CGFloat = 100
    var purchaseMaterial: PurchaseMaterialModel?
    var orderStatus: NSNumber = 0                //0:未生成（可改数量、备注、附件），1/2：已生成（数量、备注），其他：只能查看
    var activityType = 1
    var saveModelBlock:((_ model:PurchaseMaterialModel?)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "产品信息"
        
        if let valueStr = purchaseMaterial?.materials?.name {
            title = valueStr
        }
        
        prepareNavItem()
        prepareSubView()
    }
    
    func prepareNavItem() {
        
        if orderStatus == 0 || ((orderStatus == 1 || orderStatus == 2) && (UserData.shared.userType == .gys || UserData.shared.userType == .yys)) {
            let saveBtn = UIButton(type: .custom)
            saveBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
            saveBtn.setTitle("保存", for: .normal)
            saveBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            saveBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            saveBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
            saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
            
            if activityType == 2 || activityType == 3 {
                saveBtn.isHidden = true
            }
            
            let editItem = UIBarButtonItem.init(customView: saveBtn)
            navigationItem.rightBarButtonItem = editItem
        }
    }
    
    func prepareSubView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PurchaseRemarkCell.self, forCellReuseIdentifier: PurchaseRemarkCell.self.description())
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //主材数量背景
        let heaserView = UIView(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: 110))
        if orderStatus == 0 || ((orderStatus == 1 || orderStatus == 2) && (UserData.shared.userType == .gys || UserData.shared.userType == .yys)) {
            tableView.tableHeaderView = heaserView
        }
        
        //白色输入框背景
        let countWhiteView = UIView()
        countWhiteView.backgroundColor = .white
        heaserView.addSubview(countWhiteView)
        
        countWhiteView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(10)
        }
        
        //主材数量标题
        let countTitle = UILabel()
        countTitle.text = "产品数量: "
        countTitle.textColor = PublicColor.minorTextColor
        countTitle.font = UIFont.systemFont(ofSize: 14)
        countWhiteView.addSubview(countTitle)
        
        countTitle.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.equalTo(66)
        }
        
        //数量输入框
        countField = UITextField()
        countField.delegate = self
        countField.returnKeyType = .done
        countField.keyboardType = .decimalPad
        countField.text = "1"
        countField.textColor = PublicColor.commonTextColor
        countField.font = countTitle.font
        countWhiteView.addSubview(countField)
        
        if activityType == 2 || activityType == 3 {
            countField.isUserInteractionEnabled = false
        } else {
            countField.isUserInteractionEnabled = true
        }
        
        countField.snp.makeConstraints { (make) in
            make.centerY.height.equalToSuperview()
            make.left.equalTo(countTitle.snp.right)
            make.right.equalTo(-15)
        }
        
        //会员价
        costLabel = UILabel()
        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont2)])
        heaserView.addSubview(costLabel)
        
        costLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(countWhiteView.snp.bottom).offset(10)
            make.height.equalTo(14)
        }
        
        //平台销售价
        priceLabel = UILabel()
        priceLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "销售价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont2)])
        heaserView.addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints { (make) in
            make.height.centerY.equalTo(costLabel)
            make.left.equalTo(costLabel.snp.right).offset(20)
        }
        
        priceLabel.isHidden = true
        
        //总价
        costSumLabel = UILabel()
        costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont2)])
        heaserView.addSubview(costSumLabel)
        
        costSumLabel.snp.makeConstraints { (make) in
            make.left.height.equalTo(costLabel)
            make.top.equalTo(costLabel.snp.bottom).offset(3)
        }
        
        //台总价
        priceSumLabel = UILabel()
        priceSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: "未知", color: PublicColor.minorTextColor, font: textFont2)])
        heaserView.addSubview(priceSumLabel)
        
        priceSumLabel.snp.makeConstraints { (make) in
            make.height.centerY.equalTo(costSumLabel)
            make.left.equalTo(costSumLabel.snp.right).offset(20)
        }
        priceSumLabel.isHidden = true
        
        
        //附件背景
        let fileWidth = (PublicSize.screenWidth-30-40)/5
        let fileViewHeight = fileWidth + 40 + 20 + 16
        fileView = UIView(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: fileViewHeight))
        fileView.backgroundColor = .white
        tableView.tableFooterView = fileView
        
        //附件标题
        let fileTitle = UILabel()
        fileTitle.text = "附件:"
        fileTitle.textColor = PublicColor.minorTextColor
        fileTitle.font = countTitle.font
        fileView.addSubview(fileTitle)
        
        fileTitle.snp.makeConstraints { (make) in
            make.left.top.equalTo(15)
            make.height.equalTo(16)
        }
        
        //附件
        for i in 0..<5 {
            let btn = UIButton()
            btn.tag = 100+i
            btn.isHidden = true
            btn.layer.cornerRadius = 4
            btn.layer.masksToBounds = true
            btn.setImage(UIImage.init(named: "loading"), for: .normal)
            btn.addTarget(self, action: #selector(fileBtnClick), for: .touchUpInside)
            fileView.addSubview(btn)
            
            let left = 15+CGFloat(i)*(fileWidth+10)
            btn.snp.makeConstraints { (make) in
                make.top.equalTo(fileTitle.snp.bottom).offset(20)
                make.height.width.equalTo(fileWidth)
                make.left.equalTo(left)
            }
            
            let delBtn = UIButton()
            delBtn.tag = 200+i
            delBtn.isHidden = true
            delBtn.layer.cornerRadius = 4
            delBtn.layer.masksToBounds = true
            delBtn.setImage(UIImage.init(named: "room_reduce"), for: .normal)
            delBtn.addTarget(self, action: #selector(delBtnClick), for: .touchUpInside)
            fileView.addSubview(delBtn)
            
            delBtn.snp.makeConstraints { (make) in
                make.top.equalTo(btn.snp.top).offset(-10)
                make.right.equalTo(btn.snp.right).offset(10)
                make.height.width.equalTo(20)
            }
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = PublicColor.partingLineColor
        fileView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(fileTitle)
            make.height.equalTo(1)
            make.top.right.equalToSuperview()
        }
        
        //赋值
        if let valueStr = purchaseMaterial?.countInt, valueStr > 0 {
            
            countField.text = valueStr.notRoundingString(afterPoint: 2)
        }
        
        updateSubView()
    }
    
    func updateSubView() {
        var titleStr = "会员价: "
        if activityType == 2 {
            titleStr = "一口价: "
        } else if activityType == 3 {
            titleStr = "特惠价: "
        }
        if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
            titleStr = "销售价"
        }
        if purchaseMaterial?.materials?.materialsCount == nil {
            if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
                let count = purchaseMaterial?.materials?.count?.doubleValue ?? 0
                countField.text = "\(count)"
                priceLabel.isHidden = true
                priceSumLabel.isHidden = true
                var sumStr = "0.00"
                var moneyStr = "0.00"
                
                if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
                    if let valueStr = purchaseMaterial?.materials?.priceSell?.doubleValue {
                        let sumMoney = count*valueStr
                        sumStr   = sumMoney.notRoundingString(afterPoint: 2)
                        moneyStr = valueStr.notRoundingString(afterPoint: 2)
                    }
                } else {
                    if let valueStr = purchaseMaterial?.materials?.price?.doubleValue {
                        let sumMoney = count*valueStr
                        sumStr   = sumMoney.notRoundingString(afterPoint: 2)
                        moneyStr = valueStr.notRoundingString(afterPoint: 2)
                    }
                }
                
                
                if purchaseMaterial?.materials?.materials?.isOneSell ==  2 {
                    costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: titleStr, color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: "***", color: PublicColor.minorTextColor, font: textFont2)])
                    costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: "***", color: PublicColor.minorTextColor, font: textFont2)])
                } else {
                    costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: titleStr, color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: moneyStr, color: PublicColor.minorTextColor, font: textFont2)])
                    costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: sumStr, color: PublicColor.minorTextColor, font: textFont2)])
                }
            }else {
                let count = Double.init(string: purchaseMaterial?.materialsCount ?? "0") ?? 0
                countField.text = "\(count)"
                if activityType == 2 {
                    if let valueStr = purchaseMaterial?.moneyMaterials?.doubleValue {
                        let sumMoney = count*valueStr
                        let moneyStr = valueStr.notRoundingString(afterPoint: 2)
                        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: titleStr, color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: moneyStr, color: PublicColor.minorTextColor, font: textFont2)])
                        costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: moneyStr, color: PublicColor.orangeLabelColor, font: textFont2)])
                    }
                } else if activityType == 3 {
                    if let valueStr = purchaseMaterial?.moneyMaterials?.doubleValue {
                        let sumMoney = count*valueStr
                        let sumStr   = sumMoney.notRoundingString(afterPoint: 2)
                        let moneyStr = valueStr.notRoundingString(afterPoint: 2)
                        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: titleStr, color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: moneyStr, color: PublicColor.minorTextColor, font: textFont2)])
                        costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: sumStr, color: PublicColor.orangeLabelColor, font: textFont2)])
                    }
                } else {
                    if let valueStr = purchaseMaterial?.price?.doubleValue {
                        let sumMoney = count*valueStr
                        let sumStr   = sumMoney.notRoundingString(afterPoint: 2)
                        let moneyStr = valueStr.notRoundingString(afterPoint: 2)
                        costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: titleStr, color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: moneyStr, color: PublicColor.minorTextColor, font: textFont2)])
                        costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: sumStr, color: PublicColor.orangeLabelColor, font: textFont2)])
                    }
                }
                
            }
                                                
            if let valueStr = purchaseMaterial?.fileUrls {
                
                var urlArray = valueStr.components(separatedBy: ",")
                urlArray = urlArray.filter{$0 != ""}
                
                fileUrlArray = urlArray.compactMap({ (url) -> ImageFileModel in
                    
                    let imgUrl = ImageFileModel()
                    imgUrl.imageUrl = url
                    return imgUrl
                })
               
            }
        } else {
            let count = purchaseMaterial?.materials?.materialsCount?.doubleValue ?? 0
            countField.text = "\(count)"
            if UserData.shared.userType == .cgy || UserData.shared.userType == .jzgs {
                priceLabel.isHidden = true
                priceSumLabel.isHidden = true
                var sumStr = "0.00"
                var moneyStr = "0.00"
                
                if let valueStr = Double.init(string: purchaseMaterial?.materials?.materialsPriceSupply1 ?? "0") {
                    let sumMoney = count*valueStr
                    sumStr   = sumMoney.notRoundingString(afterPoint: 2)
                    moneyStr = valueStr.notRoundingString(afterPoint: 2)
                }
                if purchaseMaterial?.materials?.isOneSell ==  2 {
                    costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "会员价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: "***", color: PublicColor.minorTextColor, font: textFont2)])
                    costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: "***", color: PublicColor.minorTextColor, font: textFont2)])
                } else {
                    costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: titleStr, color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: moneyStr, color: PublicColor.minorTextColor, font: textFont2)])
                    costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: sumStr, color: PublicColor.minorTextColor, font: textFont2)])
                }
            }else {
                if let valueStr = Double.init(string: purchaseMaterial?.materials?.materialsPriceSupply1 ?? "0")  {
                    let sumMoney = count*valueStr
                    let sumStr   = sumMoney.notRoundingString(afterPoint: 2)
                    let moneyStr = valueStr.notRoundingString(afterPoint: 2)
                    costLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: titleStr, color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: moneyStr, color: PublicColor.minorTextColor, font: textFont2)])
                    costSumLabel.attributedText = String.getMixtureAttributString([MixtureAttr(string: "总价: ", color: PublicColor.minorTextColor, font: textFont2), MixtureAttr(string: sumStr, color: PublicColor.orangeLabelColor, font: textFont2)])
                }
            }
            if let valueStr = purchaseMaterial?.fileUrls {
                
                var urlArray = valueStr.components(separatedBy: ",")
                urlArray = urlArray.filter{$0 != ""}
                
                fileUrlArray = urlArray.compactMap({ (url) -> ImageFileModel in
                    
                    let imgUrl = ImageFileModel()
                    imgUrl.imageUrl = url
                    return imgUrl
                })
               
            }
        }
        
        updateImageBtn()
    }
    
    func updateImageBtn() {
        
        for i in 0..<5 {
            if i < fileUrlArray.count {
                
                let fileUrl = fileUrlArray[i].imageUrl ?? ""
                if let btn = fileView.viewWithTag(100+i) as? UIButton {
                    btn.isHidden = false
                    let imageUrl = URL(string: APIURL.ossPicUrl + fileUrl)!
                    btn.kf.setImage(with: imageUrl, for: .normal, placeholder: UIImage.init(named: "loading"))
                }
                if orderStatus == 0 {
                    
                    if let btn = fileView.viewWithTag(200+i) as? UIButton {
                        btn.isHidden = false
                    }
                }
            }else if i == fileUrlArray.count{
                
                if let btn = fileView.viewWithTag(100+i) as? UIButton {
                    if orderStatus == 0 {
                        btn.isHidden = false
                        btn.setImage(UIImage(named: "imageRow_camera"), for: .normal)
                    }else {
                        btn.isHidden = true
                    }
                }
                
                
                if let btn = fileView.viewWithTag(200+i) as? UIButton {
                    btn.isHidden = true
                }
               
            }else {
                if let btn = fileView.viewWithTag(100+i) as? UIButton {
                    btn.isHidden = true
                }
                if let btn = fileView.viewWithTag(200+i) as? UIButton {
                    btn.isHidden = true
                }
            }
        }
        
        if fileUrlArray.count > 0 {
            
            purchaseMaterial?.fileUrls = fileUrlArray.compactMap({ (imgModel) -> String? in
                
                let imgUrl = imgModel.imageUrl
                return imgUrl
                
            }).joined(separator: ",")
        }else {
            purchaseMaterial?.fileUrls = ""
        }
    }
    
    func upLoadFileImages(_ selectImages:[UIImage]) {
        
        DispatchQueue.main.async {
            var finishNum = 0
            for img in selectImages {
                
                var image = img
                
                AppLog("照片原尺寸: \(image.size)")
                image = image.resizeImage(valueMax: 1000) ?? UIImage()
                AppLog("照片压缩后尺寸: \(image.size)")
                
                var storeNo = "000"
                if let valueStr = UserData.shared.workerModel?.store?.no?.stringValue {
                    storeNo = valueStr
                }
                
                let type = "company/\(storeNo)/accessory"
                
                let imgModel = ImageFileModel()
                imgModel.imageUrl = ""
                self.fileUrlArray.append(imgModel)
                
                YZBSign.shared.upLoadImageRequest(oldUrl: nil, imageType: type, image: image, success: { (response) in
                    
                    let headStr = response.replacingOccurrences(of: "\"", with: "")
                    imgModel.imageUrl = headStr
                    finishNum += 1
                    if finishNum == selectImages.count {
                        
                        self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                        self.updateImageBtn()
                        
                    }
                    
                }, failture: { (error) in
                    
                    self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
                    
                })
            }
        }
    }
    
    //MARK: - 按钮点击事件
    
    @objc func saveAction() {
        
        if countField.text == "" {
            self.noticeOnlyText("请填写产品数量~")
            return
        }
        
        if let valueStr = Double(countField.text!) {
            purchaseMaterial?.countInt = valueStr
            purchaseMaterial?.materials?.count = NSNumber(value: valueStr)
        }
        
        if purchaseMaterial!.countInt <= 0 {
            self.noticeOnlyText("请填写产品数量~")
            return
        }
        
        if orderStatus == 0 {
            saveModelBlock?(purchaseMaterial)
            self.navigationController?.popViewController(animated: true)
        }else {
            var parameters = Parameters()
            parameters["orderDataId"] = purchaseMaterial?.id
            parameters["num"] = countField.text
            if let value = purchaseMaterial?.remarks, !value.isEmpty {
                parameters["remarks"] = value
            } else {
                parameters["remarks"] = "无"
            }
            if let value = purchaseMaterial?.remarks2, !value.isEmpty {
                parameters["remarks2"] = value
            } else {
                parameters["remarks2"] = "无"
            }
            if let value = purchaseMaterial?.remarks3, !value.isEmpty {
                parameters["remarks3"] = value
            } else {
                parameters["remarks3"] = "无"
            }
            parameters["orderId"] = purchaseMaterial?.purchaseOrderId
            YZBSign.shared.request(APIURL.editOrderSku, method: .put, parameters: parameters, success: { (response) in
                let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
                if code == "0" {
                    self.saveModelBlock?(self.purchaseMaterial)
                    self.navigationController?.popViewController(animated: true)
                }
            }) { (error) in
                
            }
            
        }
    }
    
    
    @objc func fileBtnClick(_ sender: UIButton) {
        
        if sender.tag - 100 < fileUrlArray.count {
            
            let urlArray = fileUrlArray.compactMap({ (imgModel) -> URL? in
                let imgUrl = imgModel.imageUrl
                let fileUrl = URL.init(string: APIURL.ossPicUrl + (imgUrl ?? ""))
                return fileUrl
            })
 
            let phoneVC = IMUIImageBrowserController()
            phoneVC.imageArr = urlArray
            phoneVC.imgCurrentIndex = sender.tag-100
            phoneVC.modalPresentationStyle = .overFullScreen
            self.present(phoneVC, animated: true, completion: nil)
        }else {
            
            let maxCount = 5 - fileUrlArray.count
            
            let imgPicker = TZImagePickerController(maxImagesCount: maxCount, columnNumber: 4, delegate: self)
            imgPicker?.allowPickingVideo = false            //不能选择视频
            imgPicker?.allowPickingOriginalPhoto = false   //不能选择原图
            
            self.present(imgPicker!, animated: true, completion: nil)
        }
        
    }
    
    //删除
    @objc func delBtnClick(_ sender: UIButton) {
        
        if sender.tag - 200 < fileUrlArray.count {
            fileUrlArray.remove(at: sender.tag - 200)
        }
        updateImageBtn()
    }
    
    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PurchaseRemarkCell.self.description(), for: indexPath) as! PurchaseRemarkCell
        cell.placeholderLabel.text = "无"
        
        if orderStatus == 0 || ((orderStatus == 1 || orderStatus == 2) && (UserData.shared.userType == .gys || UserData.shared.userType == .yys)) {
            cell.textView.isEditable = true
        }else {
            cell.textView.isEditable = false
        }
        
        if orderStatus == 0 || ((orderStatus == 1 || orderStatus == 2) && (UserData.shared.userType == .gys || UserData.shared.userType == .yys)) {
            cell.placeholderLabel.text = "非必填"
        }
        
        cell.textViewChangeBlock = { [weak self] textStr in
            
            if indexPath.row == 0 {
                self?.purchaseMaterial?.remarks = textStr
            }else if indexPath.row == 1 {
                self?.purchaseMaterial?.remarks2 = textStr
            }else if indexPath.row == 2 {
                self?.purchaseMaterial?.remarks3 = textStr
            }
        }
        
        cell.textViewEndEditBlock = { tableView.reloadData() }
        
        cellHeight = 100
        var remarks = ""
        
        if indexPath.row == 0 {
            cell.titleLabel.text = "备注:"
            
            if let valueStr = purchaseMaterial?.remarks {
                remarks = valueStr
            }
        }else if indexPath.row == 1 {
            cell.titleLabel.text = "颜色和样式:"
            
            if let valueStr = purchaseMaterial?.remarks2 {
                remarks = valueStr
            }
        }else if indexPath.row == 2 {
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
                cellHeight = 100
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if cellHeight < 100 {
            return 100
        }else {
            return cellHeight
        }
        
    }
    
    //MARK: - TZImagePickerControllerDelegate
    //选择图片
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {

        upLoadFileImages(photos)
    }
    
    //MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //只允许输入数字
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)

        if let newValue = Double(newString) {
            if newValue >= 1000 {
                self.noticeOnlyText("最多只能买999件哦~")
                return false
            }
        }

        if newString == "" {
            return true
        }

        var expression = "^[0-9]*$"

        if purchaseMaterial?.price != nil  {
            if let rang = newString.range(of: ".") {
                let preString = String(newString.prefix(upTo: rang.lowerBound))
                textField.text = preString
                return false
            }

        }else if let valueStr = purchaseMaterial?.unitType {

            let unitStr = Utils.getFieldValInDirArr(arr: AppData.unitTypeList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
            if unitStr == "平方" || unitStr == "米" || unitStr == "公斤" || unitStr == "立方" {
                expression = "^[0-9]+([.][0-9]{0,2})?$"
            }else {
                expression = "^[0-9]+([.][0-9]{0,2})?$"
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
        let doubleCount = Double.init(string: newString) ?? 0
        if purchaseMaterial?.materials?.materialsCount == nil {
            if UserData.shared.userType == .gys || UserData.shared.userType == .yys {
                purchaseMaterial?.materialsCount = newString
            } else {
                purchaseMaterial?.materials?.count = NSNumber.init(value: doubleCount)
            }
            
        } else {
            purchaseMaterial?.materials?.materialsCount = NSNumber.init(value: doubleCount)
        }
//        updateSubView()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //收起键盘
        textField.resignFirstResponder()
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
        
        if let valueStr = Double(textField.text!) {
            purchaseMaterial?.countInt = valueStr
            purchaseMaterial?.materials?.count = NSNumber(value: valueStr)
        }
        
        updateSubView()
    }
}

class ImageFileModel: NSObject {
    
    var imageUrl: String?
}
