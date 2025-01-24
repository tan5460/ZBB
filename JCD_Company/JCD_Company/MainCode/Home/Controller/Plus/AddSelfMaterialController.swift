//
//  CustomMaterialsController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/9/7.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import PopupDialog
import ObjectMapper

class AddSelfMaterialController: BaseFormController {
    
    var packageModel: PackageModel?                 //主材包
    var isLoading = false                           //是否正在加载头像
    
    var addPackageBlock: ((_ packageModel: PackageModel)->())?      //添加主材包block
    
    var headPic: UIImage?                           //选择的图片
    var headImageUrl = ""
    
    
    deinit {
        AppLog(">>>>>>>>>>>>>> 新增套餐主材界面释放 <<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if packageModel == nil {
            packageModel = PackageModel()
        }
        
        if let valueStr = packageModel?.materials?.transformImageURL {
            headImageUrl = valueStr
        }
        
        if !AppData.isBaseDataLoaded {
            self.noticeOnlyText("基础数据未获取")
        }else {
            self.initializeForm()
        }
    }
    
    override func backAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func loadImage() {
        
        if headImageUrl == "" {
            return
        }
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("pig.png")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(APIURL.ossPicUrl+headImageUrl, to: destination).response { response in
            AppLog(response)
            
            if response.error == nil, let imagePath = response.destinationURL?.path {
                
                self.isLoading = true
                let image = UIImage(contentsOfFile: imagePath)
                self.form.rowBy(tag: "headIcon")?.baseValue = image
                self.form.rowBy(tag: "headIcon")?.updateCell()
            }
        }
    }
    
    func initializeForm() {
        
        loadImage()
        
        form
            +++ Section()
            
            <<< ImageRow ("headIcon"){
                $0.title = "产品图片"
                
            }.onChange { [weak self] row in
                
                if (self?.isLoading)! {
                    self?.isLoading = false
                    return
                }
                
                if row.baseValue == nil {
                    return
                }
                
                var image = row.baseValue as! UIImage
                AppLog("照片原尺寸: \(image.size)")
                image = image.resizeImage(valueMax: 500) ?? UIImage()
                AppLog("照片压缩后尺寸: \(image.size)")
                
                var storeNo = "000"
                if let valueStr = UserData.shared.workerModel?.store?.no?.stringValue {
                    storeNo = valueStr
                }
                
                let type = "company/\(storeNo)/customMaterials"
                
                YZBSign.shared.upLoadImageRequest(oldUrl: self?.headImageUrl, imageType: type, image: image, success: { (response) in
                    
                    self?.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                    let headStr = response.replacingOccurrences(of: "\"", with: "")
                    self?.headImageUrl = headStr
                    self?.headPic = image
                    
                }, failture: { (error) in
                    
                    self?.noticeError("上传失败", autoClear: true, autoClearTime: 1)
                    row.value = self?.headPic
                    row.updateCell()
                })
                    
            }
            
            <<< TextRow ("name") {
                $0.title = "产品名称"
                $0.placeholder = "请输入产品名称"
                
                if let valueStr = packageModel?.materials?.name {
                    $0.value = valueStr
                }
            }
            
            <<< DecimalRow ("priceCustom") {
                $0.title = "产品销售单价"
                $0.placeholder = "请输入产品套餐售价"
                
                if let valueStr = packageModel?.materials?.priceShow?.doubleValue {
                    $0.value = valueStr
                }
                
            }.cellSetup { cell, _  in
                cell.textField.keyboardType = .numbersAndPunctuation
            }
            
            <<< PickerInlineRow<String>("unitType") {
                $0.title = "单位"
                let options =  Utils.getFieldArrInDirArr(arr: AppData.unitTypeList, field: "label")
                $0.options = options
                $0.value = options[0]
                
                if let valueStr = packageModel?.materials?.unitType?.intValue {
                    if valueStr > 0 && valueStr <= AppData.unitTypeList.count {
                        $0.value = Utils.getReadString(dir: AppData.unitTypeList[valueStr-1], field: "label")
                    }
                }
            }
            
            <<< TextAreaRow("intro") {
                $0.placeholder = "备注"
                $0.value = "临时创建产品"
                $0.textAreaHeight = .dynamic(initialTextViewHeight: 90)
                
                if let valueStr = packageModel?.materials?.remarks {
                    $0.value = valueStr
                }
            }
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                if packageModel?.id != nil {
                    row.title = "修改"
                }else {
                    row.title = "添加"
                }
            }
               .onCellSelection { [weak self] (cell, row) in
                
                
                    if self?.form.tagToString("name") == "" {
                        self?.noticeOnlyText("请输入产品名称")
                        return
                    }
                    else if self?.form.tagToString("priceCustom") == nil {
                        self?.noticeOnlyText("产品销售单价为空")
                        return
                    }
                    
                    let strAll = "0123456789abcdefghijklmnopqrstuvwxyz"
                    var arcID = ""
                    
                    //主材包随机id
                    for _ in 0..<32 {
                        let index: Int = Int(arc4random() % UInt32(strAll.count-1))
                        let startIndex = strAll.index(strAll.startIndex, offsetBy: index)
                        let tempStr = strAll[startIndex]
                        
                        arcID = arcID.appending("\(tempStr)")
                    }
                    AppLog("随机产品包id: \(arcID)")
                    
                    if self?.packageModel?.id == nil {
                        self?.packageModel?.id = "B001"
                    }
                    
                    //主材包名
                    self?.packageModel?.name = "临时创建产品"
                    
                    //主材名
                    if self?.packageModel?.materials == nil {
                        self?.packageModel?.materials = MaterialsModel()
                    }
                    self?.packageModel?.materials?.name = self?.form.tagToString("name")
                    self?.packageModel?.materials?.imageUrl = self?.headImageUrl
                    
                    //主材随机id
                    arcID = ""
                    for _ in 0..<32 {
                        let index: Int = Int(arc4random() % UInt32(strAll.count-1))
                        let startIndex = strAll.index(strAll.startIndex, offsetBy: index)
                        let tempStr = strAll[startIndex]
                        
                        arcID = arcID.appending("\(tempStr)")
                    }
                    self?.packageModel?.materials?.id = arcID
                    AppLog("随机产品id: \(arcID)")
                    
                    //主材套餐售价
                    let priceValue = self?.form.rowBy(tag: "priceCustom")?.baseValue as! Double
                    self?.packageModel?.materials?.priceCustom = NSNumber.init(value: priceValue)
                    self?.packageModel?.materials?.priceShow = NSNumber.init(value: priceValue)
                    
                    //单位类型
                    let array = Utils.getFieldArrInDirArr(arr: AppData.unitTypeList, field: "label")
                    let str = self?.form.rowBy(tag: "unitType")?.baseValue as! String
                    let index = array.firstIndex(of: str)
                    self?.packageModel?.unitType = NSNumber.init(value: index!+1)
                    self?.packageModel?.materials?.unitType = NSNumber.init(value: index!+1)
                
                    self?.packageModel?.packageType = 3
                    self?.packageModel?.materials?.type = 3
                    
                    //备注
                self?.packageModel?.materials?.remarks = self?.form.tagToString("intro") ?? "无"
                    
                    self?.addPackageBlock!((self?.packageModel)!)
                    self?.navigationController?.dismiss(animated: true, completion: nil)
            }
    }

}
