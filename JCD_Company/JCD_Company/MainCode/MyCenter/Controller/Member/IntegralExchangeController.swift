//
//  IntegralExchangeController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/22.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import PopupDialog
import ObjectMapper


class IntegralExchangeController: BaseFormController {

    var mallModel: IntegralMallModel?
    var provArray: Array<CityModel> = []        //省
    var cityArray: Array<CityModel> = []        //市
    var distArray: Array<CityModel> = []        //区
    
    deinit {
        AppLog(">>>>>>>>>>>> 商品兑换界面释放 <<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "商品兑换"
        
        prepareCityData()
        initializeForm()
    }
    
    override func backAction() {
        
        navigationController?.popViewController(animated: true)
    }
    
    func prepareCityData(parentId: String = "100000", type: Int = 1) {
        
        if type == 1 {
            //省
            if let provList = THFMDB.querySubData(parentId) {
                
                provArray = provList
                let firstProv = provArray.first
                
                //市
                if let cityList = THFMDB.querySubData((firstProv?.id)!) {
                    
                    cityArray = cityList
                    let firstCity = cityArray.first
                    
                    //区
                    if let distList = THFMDB.querySubData((firstCity?.id)!) {
                        
                        distArray = distList
                    }
                }
            }
        }else if type == 2 {
            //市
            if let cityList = THFMDB.querySubData(parentId) {
                
                cityArray = cityList
                let firstCity = cityArray.first
                
                //区
                if let distList = THFMDB.querySubData((firstCity?.id)!) {
                    
                    distArray = distList
                }
            }
        }else {
            //区
            if let distList = THFMDB.querySubData(parentId) {
                
                distArray = distList
            }
        }
    }

    func initializeForm() {
        
        form
            +++ Section()
        
            <<< TextRow ("name") {
                
                $0.title = "收货人"
                $0.placeholder = "请填写收货人姓名"
            }.onCellHighlightChanged({ (cell, row) in
                
                if !row.isHighlighted {
                    if let nameStr = row.value {
                        
                        if nameStr.count > 5 {
                            
                            let index = nameStr.index(nameStr.startIndex, offsetBy: 5)
                            let nameStrNew = String(nameStr.prefix(upTo: index))
                            row.value = nameStrNew
                        }
                    }
                }
            })
            
            <<< IntRow ("mobile") {
                
                $0.title = "手机号"
                $0.placeholder = "请填写手机号"
                let numberFormatter = NumberFormatter()
                $0.formatter = numberFormatter
            }
            
            <<< PickerInlineRow<String>("prov") {
                $0.title = "省"
                $0.value = "无"
                
                var options: Array<String> = []
                for model in self.provArray {
                    let name = model.name
                    options.append(name!)
                }
                $0.options = options
                
            }
            .onChange({ [weak self] row in
                    
                if let rowB: PickerInlineRow<String> = self?.form.rowBy(tag: "city") {
                    
                    let provName = row.baseValue as? String
                    var provId = ""
                    
                    for provModel in self!.provArray {
                        if provModel.name == provName {
                            provId = provModel.id!
                        }
                    }
                    
                    self?.prepareCityData(parentId: provId, type: 2)
                    
                    var options: Array<String> = []
                    for model in self!.cityArray {
                        let name = model.name
                        options.append(name!)
                    }
                    rowB.value = options[0]
                    rowB.options = options
                    rowB.updateCell()
                }
            })
            
            <<< PickerInlineRow<String>("city") {
                $0.title = "市"
                $0.value = "无"
            }
            .onChange({ [weak self] row in
                
                if let rowB: PickerInlineRow<String> = self?.form.rowBy(tag: "dist") {
                    
                    let cityName = row.baseValue as? String
                    var cityId = ""
                    
                    for cityModel in self!.cityArray {
                        if cityModel.name == cityName {
                            cityId = cityModel.id!
                        }
                    }
                    
                    self?.prepareCityData(parentId: cityId, type: 3)
                    
                    var options: Array<String> = []
                    for model in self!.distArray {
                        let name = model.name
                        options.append(name!)
                    }
                    rowB.value = options[0]
                    rowB.options = options
                    rowB.updateCell()
                }
            })
            
            <<< PickerInlineRow<String>("dist") {
                $0.title = "市"
                $0.value = "无"
            }
            
            <<< TextAreaRow("address") {
                $0.placeholder = "详细地址"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 90)
            }
        
            
            +++ Section()
            
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                
                row.title = "确认兑换"
            }
            .onCellSelection { [weak self] (cell, row) in
                
                if self?.form.tagToString("name") == "" {
                    self?.noticeOnlyText("请填写收货人姓名")
                    return
                }
                
                let mobile = self?.form.tagToString("mobile")
                
                if mobile == "" {
                    self?.noticeOnlyText("请填写手机号")
                    return
                }
                else if !Utils_objectC.isMobileNumber2(mobile) {
                    self?.noticeOnlyText("请输入正确的手机号!")
                    return
                }
                
                if self?.form.tagToString("prov") == "无" {
                    self?.noticeOnlyText("请选择省市区")
                    return
                }
                
                if self?.form.tagToString("address") == "" {
                    self?.noticeOnlyText("请填写详细地址")
                    return
                }
                
                var workerId = ""
                if let valueStr = UserData.shared.workerModel?.id {
                    workerId = valueStr
                }
                
                var parameters: Parameters = [:]
                parameters["worker.id"] = workerId
                parameters["type"] = "1"
                parameters["goodsCount"] = "1"
                parameters["money"] = ""
                parameters["goods.id"] = ""
                
                if let valueStr = self?.mallModel?.integration {
                    parameters["money"] = valueStr
                }
                
                if let valueStr = self?.mallModel?.id {
                    parameters["goods.id"] = valueStr
                }
                
                parameters["contact"] = self?.form.rowBy(tag: "name")?.baseValue as? String ?? ""
                
                parameters["tel"] = self?.form.rowBy(tag: "mobile")?.baseValue as? String ?? ""
                
                let provStr = self?.form.rowBy(tag: "prov")?.baseValue as? String ?? ""
                let cityStr = self?.form.rowBy(tag: "city")?.baseValue as? String ?? ""
                let distStr = self?.form.rowBy(tag: "dist")?.baseValue as? String ?? ""
                let detailStr = self?.form.rowBy(tag: "address")?.baseValue as? String ?? ""
                
                let addressStr = provStr+cityStr+distStr+detailStr
                parameters["address"] = addressStr
                
                self?.pleaseWait()
                let urlStr = APIURL.exchangeGoods
                
                YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
                    
                    let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
                    if errorCode == "000" {
                        
                        let popup = PopupDialog(title: "兑换成功", message: "工作人员将会把商品寄往您的地址，请耐心等待!", buttonAlignment: .vertical)
                        let sureBtn = AlertButton(title: "确认") {
                            self?.navigationController?.popViewController(animated: true)
                        }
                        popup.addButtons([sureBtn])
                        self?.present(popup, animated: true, completion: nil)
                    }
                    
                }) { (error) in
                    
                }
                    
            }
        
    }
}
extension Eureka.Form {
    
    func tagToString(_ tag: String) -> String? {
        return rowBy(tag: tag)?.baseValue as? String
    }
    
    func tagToDictionary(_ tag: String) -> DicResult? {
        return rowBy(tag: tag)?.baseValue as? DicResult
    }
}
