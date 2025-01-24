//
//  AddComMerchantController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/31.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import PopupDialog
import ObjectMapper


class AddComMerchantController: BaseFormController {
    
    var categoryID = ""                         //分类ID
    var defaultPic: UIImage?                    //默认图
    var logoUrl = ""                            //logo图片地址
    var categoryAData: Array<CategoryModel> = []        //一级分类
    
    var addMerchantBlock: ((_ merchantModel: MerchantModel?)->())?      //添加成功block
    
    deinit {
        AppLog(">>>>>>>>>>>> 自建供应商界面释放 <<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if categoryAData.count <= 0 {
            loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func initializeForm() {
        
        form
            +++ Section(" ") {
                $0.header?.height = {30}
            }
            
            <<< ImageRow ("logo"){
                $0.title = "品牌Logo"
                
            }
            .onChange { [weak self] row in
                
                var image = row.baseValue as! UIImage
                AppLog("照片原尺寸: \(image.size)")
                image = image.resizeImage() ?? image
                AppLog("照片压缩后尺寸: \(image.size)")
                
                var storeNo = "000"
                if let valueStr = UserData.shared.workerModel?.store?.no?.stringValue {
                    storeNo = valueStr
                }
                
                let type = "company/\(storeNo)/brand"
                
                YZBSign.shared.upLoadImageRequest(oldUrl: self?.logoUrl, imageType: type, image: image, success: { (response) in
                    
                    self?.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                    let headStr = response.replacingOccurrences(of: "\"", with: "")
                    self?.logoUrl = headStr
                    self?.defaultPic = image
                    
                }, failture: { (error) in
                    
                    self?.noticeError("上传失败", autoClear: true, autoClearTime: 1)
                    row.value = self?.defaultPic
                    row.updateCell()
                })
            }

            <<< TextRow ("supplierName") {
                $0.title = "品牌商名称"
                $0.placeholder = "请输入名称"
            }
            
            <<< PickerInlineRow<String>("categoryA") {
                $0.title = "品牌商分类"
                
                var options: Array<String> = ["无"]
                for model in self.categoryAData {
                    let name = model.name
                    options.append(name!)
                }
                
                $0.options = options
                $0.value = options[0]
                
            }
            .onChange({ [weak self] row in
                var categoryId = ""
                let categoryName = row.baseValue as? String
                
                for categoryModel in self!.categoryAData {
                    if categoryModel.name == categoryName {
                        categoryId = categoryModel.id!
                    }
                }
                
                self?.categoryID = categoryId
            })

            <<< TextRow ("brand") {
                $0.title = "品牌名"
                $0.placeholder = "请输入品牌名"
            }
            <<< TextRow ("contact") {
                $0.title = "联系人"
                $0.placeholder = "请输入联系人"
            }
            <<< PhoneRow ("contactPhone") {
                $0.title = "电话"
                $0.placeholder = "请输入电话"
            }
            <<< TextAreaRow("particulars") {
                $0.placeholder = "简介"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 100)
            }
                        
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "添加"
            }
            .onCellSelection { [weak self] (cell, row) in
                
                let mobile = self?.form.tagToString("contactPhone") ?? ""
                
                if self?.form.tagToString("supplierName") == "" {
                    self?.noticeOnlyText("品牌商名称为空")
                    return
                }
                if self?.categoryID == "" {
                    self?.noticeOnlyText("请选择品牌商分类")
                    return
                }
                if self?.form.tagToString("brand") == "" {
                    self?.noticeOnlyText("品牌名为空")
                    return
                }
                if self?.form.tagToString("contact") == "" {
                    self?.noticeOnlyText("联系人为空")
                    return
                }
                if mobile == "" {
                    self?.noticeOnlyText("电话为空")
                    return
                }
                if mobile.count < 7 || mobile.count > 12 {
                    self?.noticeOnlyText("请输入7-12位联系电话")
                    return
                }
                else  {
                    self?.createMerchant()
                }
        }
    }
    
    //MARK: --  网络请求
    func loadData() {
        
//        let parameters: Parameters = ["parent.id": "0", "pageSize": "500"]
//        
//        self.pleaseWait()
//        let urlStr =  APIURL.getMaterialsCategory
//        
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//            
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" {
//                
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                let modelArray = Mapper<CategoryModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//                self.categoryAData = modelArray
//                
//                self.initializeForm()
//            }
//            
//        }) { (error) in
//            
//        }
    }

    func createMerchant() {
        
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        var parameters: Parameters = [:]
        parameters["store"] = storeID
        parameters["name"] = self.form.tagToString("supplierName") ?? ""
        parameters["logoUrl"] = self.logoUrl
        parameters["tel"] = self.form.tagToString("contactPhone") ?? ""
        parameters["contacts"] = self.form.tagToString("contact") ?? ""
        parameters["category.id"] = self.categoryID
        parameters["intro"] = self.form.tagToString("particulars") ?? ""
        parameters["brandName"] = self.form.tagToString("brand") ?? ""
        
        self.pleaseWait()
        let urlStr =  APIURL.addMerchant
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let merchantModel = Mapper<MerchantModel>().map(JSON: dataDic as! [String : Any])
                let popup = PopupDialog(title: "添加成功", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

                let sureBtn = AlertButton(title: "确定") {
                    
                    if let block = self.addMerchantBlock {
                        block(merchantModel)
                    }
                    
                    let vcArray = self.navigationController?.viewControllers
                    let vc = vcArray![vcArray!.count-3]
                    self.navigationController?.popToViewController(vc, animated: true)
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
    }
}


