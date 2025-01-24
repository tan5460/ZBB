//
//  AddServiceController.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/10/16.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import PopupDialog
import ObjectMapper

class AddServiceController: BaseFormController {
    
    var isPortrait: Bool = true                     //是否竖屏 默认竖屏
    var isFreeAdd: Bool = false                     //是否自由开单添加
    
    var serviceModel: ServiceModel?
    
    var addServiceBlock: ((_ serviceModel: ServiceModel)->())?      //添加施工block
    
    
    deinit {
        AppLog(">>>>>>>>>>>>>> 新增套餐自定义施工界面释放 <<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceModel = ServiceModel()
        
        initializeForm()
    }
    
    override func backAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func initializeForm() {
        
        
        form
            +++ Section()
            
            <<< TextRow ("name") {
                $0.title = "施工名称"
                $0.placeholder = "请输入施工名称"
            }
            
            <<< DecimalRow ("priceCustom") {
                $0.title = "施工单价"
                $0.placeholder = "请输入施工单价"
                
            }.cellSetup { cell, _  in
                cell.textField.keyboardType = .numbersAndPunctuation
            }
            
            <<< PickerInlineRow<String>("roomType") {
                $0.title = "房间类型"
                
                if isFreeAdd {
                    $0.hidden = true
                }
                
                let options = Utils.getFieldArrInDirArr(arr: AppData.roomTypeList, field: "label")
                $0.options = options
                $0.value = options[0]
            }
            
            <<< PickerInlineRow<String>("type") {
                $0.title = "施工类型"
                
                let options = Utils.getFieldArrInDirArr(arr: AppData.serviceCategoryList, field: "label")
                $0.options = options
                $0.value = options[0]
            }
            
            <<< PickerInlineRow<String>("unitType") {
                $0.title = "单位"
                let options =  Utils.getFieldArrInDirArr(arr: AppData.unitTypeList, field: "label")
                $0.options = options
                $0.value = options[0]
            }
            
            <<< TextAreaRow("intro") {
                $0.placeholder = "备注"
                $0.value = "临时创建施工"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 90)
            }
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                
                row.title = "添加"
                
            }
            .onCellSelection { [weak self] (cell, row) in
                
                if self?.form.tagToString("name") == "" {
                    self?.noticeOnlyText("施工名称为空")
                    return
                }
                else if self?.form.tagToString("priceCustom") == nil {
                    self?.noticeOnlyText("施工单价为空")
                    return
                }
                
                //施工id
                self?.serviceModel?.id = "S001"
                
                //施工名
                self?.serviceModel?.name = self?.form.tagToString("name")
                
                //施工单价
                let priceValue = self?.form.rowBy(tag: "priceCustom")?.baseValue as! Double
                self?.serviceModel?.cusPrice = NSNumber.init(value: priceValue)
                
                //房屋类型
                var array = Utils.getFieldArrInDirArr(arr: AppData.roomTypeList, field: "label")
                var str = self?.form.rowBy(tag: "roomType")?.baseValue as! String
                var index = array.firstIndex(of: str)
                self?.serviceModel?.roomType = NSNumber.init(value: index!+1)
                
                //施工类型
                str = self?.form.rowBy(tag: "type")?.baseValue as! String
                let valueStr = Utils.getFieldValInDirArr(arr: AppData.serviceCategoryList, fieldA: "label", valA: str, fieldB: "value")
                if let index = Int(valueStr) {
                    self?.serviceModel?.category = NSNumber.init(value: index)
                }
                
                //单位类型
                array = Utils.getFieldArrInDirArr(arr: AppData.unitTypeList, field: "label")
                str = self?.form.rowBy(tag: "unitType")?.baseValue as! String
                index = array.firstIndex(of: str)
                self?.serviceModel?.unitType = NSNumber.init(value: index!+1)
                
                //备注
                self?.serviceModel?.remarks = self?.form.tagToString("intro") ?? "无"
                self?.serviceModel?.serviceType = 4
                
                self?.addServiceBlock!((self?.serviceModel)!)
                self?.navigationController?.dismiss(animated: true, completion: nil)
                    
        }
    }
    
    //MARK: - 横竖屏
    
    //是否支持转屏
    override var shouldAutorotate: Bool {
        return false
    }
    
    //支持方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if isPortrait {
            return .portrait
        }else {
            return .landscapeRight
        }
    }
    
    //初始方向
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if isPortrait {
            return .portrait
        }else {
            return .landscapeRight
        }
    }
}
