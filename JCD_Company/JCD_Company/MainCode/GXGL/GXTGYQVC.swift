//
//  GXTGYQVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/10/24.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import TLTransitions
import ObjectMapper

class GXTGYQVC: BaseViewController, CompanyTypePickerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    private let releaseBtn = UIButton().text("发布").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_next_btn"))
    
    private let titleTF = UITextField().placeholder("请输入团购标题")
    private var titleText = ""
    private let productBtn = UIButton().text("请选择产品").textColor(.kColor99).font(14)
    private let priceLabel = UILabel().text("选择产品后自动显示").textColor(.kColor99).font(14)
    private let skuLabel = UILabel().text("选择产品后自动显示").textColor(.kColor99).font(14)
    private var skuText = ""
    private var currentSkuIndex = 0
    private let numTF = UITextField().placeholder("请输入团购数量")
    private var numText = ""
    private let unitLabel = UILabel().text("选择产品后自动显示").textColor(.kColor99).font(14)
    private let tgPriceTF = UITextField().placeholder("请输入团购价")
    private var tgPriceText = ""
    private var pop: TLTransition?
    private var materialModel: MaterialsModel?
    private var currentSKU: MaterialsSkuListModel?
    private var pickerView: CompanyTypePicker!
    private var desTextView: UITextView!
    private var desText = ""
    private var returnId = ""
    private var isShareSuccess = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "团购邀请"
        
        [titleTF, numTF, tgPriceTF].forEach({
            $0.delegate = self
            $0.clearButtonMode = .whileEditing
        })
        numTF.keyboardType = .numberPad
        tgPriceTF.keyboardType = .numberPad
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.sv(tableView, releaseBtn)
        view.layout(
            0,
            |tableView|,
            30,
            releaseBtn.width(280).height(40).centerHorizontally(),
            79.5+PublicSize.kBottomOffset
        )
        
        productBtn.tapped { [weak self] (btn) in
            let vc = StoreViewController()
            self?.navigationController?.pushViewController(vc)
        }
        
        releaseBtn.tapped { [weak self] (btn) in
            self?.releaseRequest()
        }
        
        pickerView = CompanyTypePicker()
        pickerView.delegate = self
        view.addSubview(pickerView)
        
        pickerView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(returnMaterialIdNoti(noti:)), name: NotificationName.returnMaterialId, object: nil)
        
        //添加进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func refresh() {
        if isShareSuccess {
            self.navigationController?.popViewController()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func pickerViewSelectCompanyType(pickerView: CompanyTypePicker, selectIndex: Int, component: Int) {
        currentSKU = materialModel?.materialsSkuList?[selectIndex]
        skuLabel.text(currentSKU?.skuAttr1 ?? "").textColor(.kColor33)
        self.tableView.reloadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case titleTF:
            titleText = titleTF.text ?? ""
        case numTF:
            numText = numTF.text ?? ""
        case tgPriceTF:
            let tgPriceStr = tgPriceTF.text ?? "0"
            let tgPrice = Double.init(string: tgPriceStr) ?? 0
            let price = currentSKU?.price?.doubleValue ?? 0
            if tgPrice < 0.0 || tgPrice >= price {
                notice("团购价应大于0元且低于原价", autoClear: true, autoClearTime: 2)
                tgPriceTF.text = ""
            }
            tgPriceText = tgPriceTF.text ?? ""
        default:
            break
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        desText = desTextView.text
    }
    
    //MARK: - 通知返回
    @objc func returnMaterialIdNoti(noti: NSNotification) {
        if noti.name == NotificationName.returnMaterialId {
            getMaterialsRequest(id: noti.object as? String)
        }
    }
    
    // MARK: - 接口请求
    func getMaterialsRequest(id: String?) {
        var parameters = Parameters()
        parameters["materialsId"] = id
        self.pleaseWait()
        let urlStr = APIURL.getMaterialsDetailsById
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { response in
            self.clearAllNotice()
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let model1 = Mapper<MaterialsModel>().map(JSON: dataDic as! [String: Any])
                self.materialModel = model1 ?? MaterialsModel()
                if let skuModel = self.materialModel?.materialsSkuList?.first {
                    self.currentSKU = skuModel
                }
                self.tableView.reloadData()
            }
        }) { (error) in
            
        }
    }
    
    //MARK: - 发布请求
    func releaseRequest() {
        if titleTF.text?.isEmpty ?? false {
            self.noticeOnlyText("请输入团购标题")
            return
        }
         
        if materialModel?.id == nil {
            self.noticeOnlyText("请选择产品")
            return
        }
        
        if currentSKU?.id == nil {
            self.noticeOnlyText("请选择产品")
            return
        }
        
        if desTextView.text.isEmpty {
            self.noticeOnlyText("请描述一下活动详情")
            return
        }
        
        if numTF.text?.isEmpty ?? false {
            self.noticeOnlyText("请输入团购数量")
            return
        }
        
        if tgPriceTF.text?.isEmpty ?? false {
            self.noticeOnlyText("请输入团购价")
            return
        }
        
        var parameters = Parameters()
        parameters["title"] = titleTF.text
        parameters["materialsId"] = materialModel?.id
        parameters["skuId"] = currentSKU?.id
        parameters["remarks"] = desTextView.text
        parameters["groupNum"] = numTF.text
        parameters["groupPrice"] = tgPriceTF.text
        YZBSign.shared.request(APIURL.groupPurchaseInvites, method: .post, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                self.returnId = Utils.getReadString(dir: response as NSDictionary, field: "data")
                self.releaseSuccessPopView()
            }
        }) { (error) in
            
        }
    }
    //MARK: - 发布成功弹窗
    private func releaseSuccessPopView() {
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height)).backgroundColor(.clear)
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "gx_close_white"))
        let v = UIView().backgroundColor(.white).cornerRadius(5)
        let space = (view.width-272)/2
        contentView.sv(closeBtn, v)
        contentView.layout(
            134+PublicSize.kStatusBarHeight,
            closeBtn.size(40)-(space-9)-|,
            1,
            |-space-v.width(272).height(200)-space-|,
            >=0
        )
        let successIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_auth_success"))
        let lab1 = UILabel().text("发布成功").textColor(UIColor.hexColor("#1DC597")).font(16)
        let lab2 = UILabel().text("发布成功啦，赶紧去分享吧！").textColor(.kColor99).font(12)
        let sureBtn = UIButton().text("我要分享").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_put_btn")).cornerRadius(15).masksToBounds()
        v.sv(successIcon, lab1, lab2, sureBtn)
        v.layout(
            20,
            successIcon.size(50).centerHorizontally(),
            10,
            lab1.height(22.5).centerHorizontally(),
            6,
            lab2.height(16.5).centerHorizontally(),
            20,
            sureBtn.width(130).height(30).centerHorizontally(),
            >=0
        )
        contentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tap)))
        pop = TLTransition.show(contentView, popType: TLPopTypeAlert)
        closeBtn.tapped { [weak self] (btn) in
            self?.pop?.dismiss(completion: {
                self?.navigationController?.popViewController()
            })
        }
        sureBtn.tapped { [weak self] (btn) in
            self?.pop?.dismiss(completion: {
                let imageUrl = self?.currentSKU?.image
                self?.isShareSuccess = true
                let imageUrls = imageUrl?.components(separatedBy: ",")
                self?.configShareSelectView(title: self?.titleText, des: self?.desText, imageStr: imageUrls?.first, urlStr: "\(APIURL.webUrl)/other/jcd-active-h5/#/invitation?id=\(self?.returnId ?? "")", vc: self)
            })
        }
    }
    
    @objc func tap() {
        pop?.dismiss(completion: {
            self.navigationController?.popViewController()
        })
    }
}


extension GXTGYQVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let titleLabel = UILabel().textColor(.kColor33).font(14)
        cell.sv(titleLabel)
        switch indexPath.section {
        case 0:
            titleLabel.text("团购标题")
            titleTF.setPlaceHolderTextColor(.kColor99)
            titleTF.font(14)
            titleTF.textAlignment = .right
            
            cell.sv(titleTF)
            cell.layout(
                12,
                |-14-titleLabel.width(60).height(20)-5-titleTF.height(44)-14-|,
                12
            )
            
            if !titleText.isEmpty {
                titleTF.text(titleText)
            }
        case 1:
            titleLabel.text("商品名称")
            cell.sv(productBtn)
            cell.layout(
                12,
                |-14-titleLabel.height(20)-(>=20)-productBtn.height(44)-5-|,
                12
            )
            if let name = materialModel?.name {
                productBtn.text(name).textColor(.kColor33)
                productBtn.titleLabel?.numberOfLines(2).lineSpace(2)
                productBtn.titleLabel?.lineBreakMode = .byTruncatingTail
            }
            cell.accessoryType = .disclosureIndicator
        case 2:
            titleLabel.text("原价")
            cell.sv(priceLabel)
            cell.layout(
                12,
                |-14-titleLabel.height(20)-(>=0)-priceLabel.height(44)-14-|,
                12
            )
            if let curSKU = currentSKU {
                priceLabel.text("¥\(curSKU.price?.doubleValue ?? 0)").textColor(.kColor33)
            }
        case 3:
            titleLabel.text("属性")
            cell.sv(skuLabel)
            cell.layout(
                12,
                |-14-titleLabel.height(20)-(>=20)-skuLabel.height(44)-14-|,
                12
            )
            if let curSKU = currentSKU {
                skuLabel.text(curSKU.skuAttr1 ?? "未知").textColor(.kColor33)
            }
            cell.accessoryType = .disclosureIndicator
        case 4:
            titleLabel.text("团购数量")
            numTF.setPlaceHolderTextColor(.kColor99)
            numTF.font(14)
            numTF.textAlignment = .right
            cell.sv(numTF)
            cell.layout(
                12,
                |-14-titleLabel.height(20)-5-numTF.height(44)-14-|,
                12
            )
            if !numText.isEmpty {
                numTF.text(numText)
            }
        case 5:
            titleLabel.text("单位")
            cell.sv(unitLabel)
            cell.layout(
                12,
                |-14-titleLabel.height(20)-(>=0)-unitLabel.height(44)-14-|,
                12
            )
            if let unit = materialModel?.unitTypeName {
                unitLabel.text(unit).textColor(.kColor33)
            }
        case 6:
            titleLabel.text("团购价")
            tgPriceTF.setPlaceHolderTextColor(.kColor99)
            tgPriceTF.font(14)
            tgPriceTF.textAlignment = .right
            cell.sv(tgPriceTF)
            cell.layout(
                12,
                |-14-titleLabel.height(20)-5-tgPriceTF.height(44)-14-|,
                12
            )
            if !tgPriceText.isEmpty {
                tgPriceTF.text(tgPriceText)
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 {
            var skuArr: [String] = []
            materialModel?.materialsSkuList?.forEach({ (skuModel) in
                skuArr.append(skuModel.skuAttr1 ?? "未知")
            })
            if skuArr.count > 0 {
                self.pickerView.companyTypes = skuArr
                self.pickerView.picker.reloadAllComponents()
                self.pickerView.showPicker()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 6 {
            return 184
        }
        return 0.01
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 6 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 184))
            desTextView = UITextView()
            v.sv(desTextView)
            v.layout(
                12,
                |-14-desTextView-14-|,
                12
            )
            desTextView.layoutIfNeeded()
            desTextView.delegate = self
            desTextView.placeholdFont = .systemFont(ofSize: 14)
            desTextView.font = .systemFont(ofSize: 14)
            desTextView.placeHolderEx = "在这里详细描述一下活动详情吧~（限150字内）"
            desTextView.placeholdColor = .kColor99
            desTextView.limitLength = 150
            desTextView.limitLabelColor = .kColor99
            desTextView.limitLabelFont = .systemFont(ofSize: 12)
            if !desText.isEmpty {
                desTextView.text = desText
                desTextView.placeHolderExLabel?.isHidden = true
            } else {
                desTextView.placeHolderExLabel?.isHidden = false
            }
            return v
        }
        return UIView()
    }
}
