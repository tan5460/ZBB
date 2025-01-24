//
//  CompleteDataController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/3/14.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import ObjectMapper
import PopupDialog


class CompleteDataController: BaseFormController {
    
    var isRegister = false
    
    var regiestBaseModel: RegisterBaseModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if regiestBaseModel == nil {
            regiestBaseModel = RegisterBaseModel()
        }
        initializeForm()
    }
    
    override func backAction() {
        
        let popup = PopupDialog(title: "提示", message: "您的资料不完整，退出后可在下次登录时继续补全，是否继续退出？",buttonAlignment: .horizontal, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)
        let sureBtn = DestructiveButton(title: "退出") {
            
            if self.isRegister {
                if let viewControllers = self.navigationController?.viewControllers {
                    let vc = viewControllers[1]
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    func initializeForm() {
        
        form
            +++ Section()
            
            <<< TextRow ("storeName") {
                $0.title = "公司全称"
                $0.placeholder = "请输入公司全称"
                
                if let valueStr = regiestBaseModel?.registerRData?.comName {
                    $0.value = valueStr
                }
            }
            
            <<< TextRow ("name") {
                $0.title = "法人"
                $0.placeholder = "请输入法人姓名"
                
                if let valueStr = regiestBaseModel?.registerRData?.contacts {
                    $0.value = valueStr
                }
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
            
            <<< TextRow ("idcard") {
                $0.title = "身份证"
                $0.placeholder = "请输入法人身份证号码"
                
                if let valueStr = regiestBaseModel?.registerRData?.idcardNo {
                    $0.value = valueStr
                }
            }
            
            <<< TextRow ("license") {
                $0.title = "营业执照号"
                $0.placeholder = "请输入营业执照号"
                
                if let valueStr = regiestBaseModel?.registerRData?.licenseNo {
                    $0.value = valueStr
                }
            }
            
            <<< TextRow ("time") {
                $0.title = "营业时长(年)"
                $0.placeholder = "请输入公司营业时长"
                
                if let valueStr = regiestBaseModel?.registerRData?.setUpTime {
                    $0.value = valueStr
                }
            }
            
            <<< TextRow ("annualOutput") {
                $0.title = "年产值(万元)"
                $0.placeholder = "请输入公司年产值"
                
                if let valueStr = regiestBaseModel?.registerRData?.output {
                    $0.value = valueStr
                }
            }
            
            <<< TextRow ("count") {
                $0.title = "设计师数量(人)"
                $0.placeholder = "请输入设计师数量"
                
                if let valueStr = regiestBaseModel?.registerRData?.size {
                    $0.value = valueStr
                }
            }
            
            <<< TextAreaRow ("address") {
                $0.placeholder = "公司地址"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 70)
                
                if let valueStr = regiestBaseModel?.registerRData?.comAddress {
                    $0.value = valueStr
                }
            }
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "下一步"
            }
            .onCellSelection { [weak self] (cell, row) in
                
                let idcardStr = self?.form.tagToString("idcard") ?? ""
                let licenseStr = self?.form.tagToString("license") ?? ""
                
                if self?.form.tagToString("storeName") == "" {
                    self?.noticeOnlyText("公司全称为空")
                    return
                }
                if self?.form.tagToString("name") == "" {
                    self?.noticeOnlyText("联系人为空")
                    return
                }
                if idcardStr == "" {
                    self?.noticeOnlyText("身份证为空")
                    return
                }
                if idcardStr.count != 18 {
                    self?.noticeOnlyText("身份证格式错误")
                    return
                }
                if licenseStr == "" {
                    self?.noticeOnlyText("营业执照号为空")
                    return
                }
                if self?.form.tagToString("time") == "" {
                    self?.noticeOnlyText("营业时长为空")
                    return
                }
                if self?.form.tagToString("annualOutput") == "" {
                    self?.noticeOnlyText("年产值为空")
                    return
                }
                if self?.form.tagToString("count") == "" {
                    self?.noticeOnlyText("设计师数量为空")
                    return
                }
                if self?.form.tagToString("address") == "" {
                    self?.noticeOnlyText("公司地址为空")
                    return
                }
                
                self?.regiestBaseModel?.registerRData?.comName = self?.form.tagToString("storeName") ?? ""
                self?.regiestBaseModel?.registerRData?.contacts = self?.form.tagToString("name") ?? ""
                self?.regiestBaseModel?.registerRData?.idcardNo = idcardStr
                self?.regiestBaseModel?.registerRData?.licenseNo = licenseStr
                self?.regiestBaseModel?.registerRData?.setUpTime = self?.form.tagToString("time") ?? ""
                self?.regiestBaseModel?.registerRData?.output = self?.form.tagToString("annualOutput") ?? ""
                self?.regiestBaseModel?.registerRData?.size = self?.form.tagToString("count") ?? ""
                self?.regiestBaseModel?.registerRData?.comAddress = self?.form.tagToString("address") ?? ""
                
                let vc = UploadIDCardController()
                vc.type = "1"
                vc.regiestBaseModel = self?.regiestBaseModel
                self?.navigationController?.pushViewController(vc, animated: true)
            }
    }
}
