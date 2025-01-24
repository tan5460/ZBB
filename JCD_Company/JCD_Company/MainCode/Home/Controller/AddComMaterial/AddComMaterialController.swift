//
//  AddComMaterialController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/8/31.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import ObjectMapper
import PopupDialog

class AddComMaterialController: BaseFormController {
    
    var categoryAData: Array<CategoryModel> = []            //一级分类
    var categoryBData: Array<CategoryModel> = []            //二级分类
    var categoryCData: Array<CategoryModel> = []            //三级分类
    var categoryDData: Array<CategoryModel> = []            //四级分类
    var categoryAID = ""                                    //一级分类ID
    var categoryBID = ""                                    //二级分类ID
    var categoryCID = ""                                    //三级分类ID
    var categoryDID = ""                                    //四级分类ID
    var specificationsID = ""                               //规格ID
    var unitTypeID = 1                                      //单位ID
    var specificationData: Array<SpecificationModel> = []   //规格
    var thumbnailPicUrl = ""                                //缩略图图片地址
    var thumbnailPic: UIImage?                              //缩略图图片
    var detailsPicUrlArray = [""]                           //详情图片地址数组
    var detailsPicArray: Array<UIImage?> = []               //现有图片数组记录
    
    var brandID = ""                                        //品牌ID
    var ishidden:Condition = true                           //是否显示一级分类
    var haveB = false                                       //是否有第二级分类
    var haveC = false                                       //是否有第三级分类
    var haveD = false                                       //是否有第四级分类
    
    
    deinit {
        AppLog(">>>>>>>>>>>> 自建主材界面释放 <<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "自建产品"
        
        if detailsPicArray.count <= 0 {
            
            detailsPicArray.append(nil)
            
            if !AppData.isBaseDataLoaded {
                self.noticeOnlyText("基础数据未获取")
            }else {
                loadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
    }
    
    func loadData() {
        
//        let parameters: Parameters = ["parent": "", "pageSize": "500"]
//        
//        self.pleaseWait()
//        let urlStr = APIURL.getMaterialsCategory
//        
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//            
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" {
//                
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                let modelArray = Mapper<CategoryModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//                
//                for categoryModel in modelArray {
//                    if categoryModel.type?.intValue == 1 {
//                        self.categoryAData.append(categoryModel)
//                    }
//                    else if categoryModel.type?.intValue == 2 {
//                        self.categoryBData.append(categoryModel)
//                    }
//                    else if categoryModel.type?.intValue == 3 {
//                        self.categoryCData.append(categoryModel)
//                    }
//                    else if categoryModel.type?.intValue == 4 {
//                        self.categoryDData.append(categoryModel)
//                    }
//                }
//                
//                self.initializeForm()
//            }
//            
//        }) { (error) in
//            
//        }
    }
    
    func initializeForm() {
        
        form
            
            +++ Section("产品信息") {
                $0.header?.height = {50}
            }
            
            <<< ImageRow ("thumbnail"){
                
                $0.title = "展示图"
                
                if thumbnailPic != nil {
                    $0.value = thumbnailPic
                }
                
            }.onChange { [weak self] row in
                
                self?.isChange = true
                var image = row.baseValue as! UIImage
                AppLog("照片原尺寸: \(image.size)")
                image = image.resizeImage() ?? UIImage()
                AppLog("照片压缩后尺寸: \(image.size)")
                
                var storeNo = "000"
                if let valueStr = UserData.shared.workerModel?.store?.no?.stringValue {
                    storeNo = valueStr
                }
                
                let type = "company/\(storeNo)/materials/thumbnail"
                
                YZBSign.shared.upLoadImageRequest(oldUrl: self?.thumbnailPicUrl, imageType: type, image: image, success: { (response) in
                    
                    self?.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                    let headStr = response.replacingOccurrences(of: "\"", with: "")
                    self?.thumbnailPicUrl = headStr
                    self?.thumbnailPic = image
                    
                }, failture: { (error) in
                    
                    self?.noticeError("上传失败", autoClear: true, autoClearTime: 1)
                    row.value = self?.thumbnailPic
                    row.updateCell()
                })
            }
            <<< TextRow ("name") {
                $0.title = "产品名称"
                $0.placeholder = "请输入名称"
            }.onChange({ (row) in
                self.isChange = true
            })
            <<< DecimalRow ("purchasePrice") {
                $0.title = "会员价"
                $0.placeholder = "请输入会员价"
                
            }.cellSetup { cell, _  in
                cell.textField.keyboardType = .numbersAndPunctuation
            }.onChange({ (row) in
                self.isChange = true
            })
            <<< DecimalRow ("retailPrice") {
                $0.title = "会员建议零售价"
                $0.placeholder = "请输入零售价"
                
                }.cellSetup { cell, _  in
                    cell.textField.keyboardType = .numbersAndPunctuation
            }.onChange({ (row) in
                self.isChange = true
            })
            <<< DecimalRow ("marketPrice") {
                $0.title = "市场价"
                $0.placeholder = "请输入市场价"
                
            }.cellSetup { cell, _  in
                cell.textField.keyboardType = .numbersAndPunctuation
            }.onChange({ (row) in
                self.isChange = true
            })
            <<< IntRow ("count") {
                $0.title = "库存数量"
                $0.placeholder = "请输入库存数量"
                
                }.cellSetup { cell, _  in
                    cell.textField.keyboardType = .numberPad
            }.onChange({ (row) in
                self.isChange = true
            })
            <<< SearchRow ("brands") {
                $0.title = "品牌"
                $0.selectorTitle="请选择品牌"
                
            }.onChange({ [weak self] row in
                self?.isChange = true
                let categoryAId = row.value?.subTitle2
                
                if categoryAId != "" && categoryAId != nil {
                    
                    self?.categoryAID = categoryAId!
                    
                    for categoryModel in self!.categoryAData {
                        
                        if categoryModel.id == categoryAId! {
                            
                            if let rowA: PickerInlineRow<String> = self?.form.rowBy(tag: "categoryA") {
                                
                                let categoryName = categoryModel.name
                                rowA.value = categoryName
                                rowA.updateCell()
                            }
                        }
                    }
                }
            })
            
            <<< PickerInlineRow<String>("categoryA") {
                $0.title = "一级分类"
                
                var options: Array<String> = []
                for model in self.categoryAData {
                    let name = model.name
                    options.append(name!)
                }
                
                $0.options = options
                $0.value = options[0]
                categoryAID = categoryAData[0].id!
            }
            .onChange({ [weak self] row in
                self?.isChange = true
                if let rowB: PickerInlineRow<String> = self?.form.rowBy(tag: "categoryB") {
                    
                    var categoryId = ""
                    var specificationsId = ""
                    let categoryName = row.baseValue as? String
                    
                    for categoryModel in self!.categoryAData {
                        if categoryModel.name == categoryName {
                            categoryId = categoryModel.id!
                            
                            if categoryModel.specification != nil{
                                let specificationModel = categoryModel.specification!
                                specificationsId = specificationModel.id!
                            }
                        }
                    }
                    
                    self?.categoryAID = categoryId
                    
                    var options: Array<String> = ["无"]
                    for categoryBModel in self!.categoryBData {
                        if categoryBModel.parentId == categoryId {
                            let name = categoryBModel.name
                            options.append(name!)
                        }
                    }
                    
                    if specificationsId == "" {
                        let rowsep: PickerInlineRow<String> = (self?.form.rowBy(tag: "specification"))!
                        let options: Array<String> = ["无"]
                        rowsep.value = "无"
                        rowsep.options = options
                        rowsep.updateCell()
                    }else{
                        self?.getSpecifications(specificationsId: specificationsId as NSString)
                    }
                    
                    if options.count == 1 {
                        rowB.hidden = true
                        self?.haveB = false
                    }else {
                        rowB.hidden = false
                        self?.haveB = true
                    }
                    
                    rowB.options = options
                    rowB.value = options[0]
                    rowB.updateCell()
                }
            })
            
            <<< PickerInlineRow<String>("categoryB") {
                $0.title = "二级分类"
                $0.value = "无"
                $0.hidden = "$categoryA == '无'"
                
                var options: Array<String> = ["无"]
                let categoryId = categoryAData[0].id
                
                for categoryBModel in categoryBData {
                    if categoryBModel.parentId == categoryId {
                        let name = categoryBModel.name
                        options.append(name!)
                    }
                }
                
                $0.options = options
                $0.value = options[0]
            }
            .onChange({ [weak self] row in
                self?.isChange = true
                if let rowC: PickerInlineRow<String> = self?.form.rowBy(tag: "categoryC") {
                    
                    var categoryId = ""
                    var specificationsId = ""
                    let categoryName = row.baseValue as? String
                    
                    for categoryModel in self!.categoryBData {
                        if categoryModel.name == categoryName {
                            categoryId = categoryModel.id!
                            
                            if categoryModel.specification != nil{
                                let specificationModel = categoryModel.specification!
                                specificationsId = specificationModel.id!
                            }
                        }
                    }
                    
                    self?.categoryBID = categoryId
                    
                    var options: Array<String> = ["无"]
                    for categoryCModel in self!.categoryCData {
                        if categoryCModel.parentId == categoryId {
                            let name = categoryCModel.name
                            options.append(name!)
                        }
                    }
                    
                    if specificationsId == "" {
                        let rowsep: PickerInlineRow<String> = (self?.form.rowBy(tag: "specification"))!
                        let options: Array<String> = ["无"]
                        rowsep.value = "无"
                        rowsep.options = options
                        rowsep.updateCell()
                    }else{
                        self?.getSpecifications(specificationsId: specificationsId as NSString)
                    }
                    
                    if options.count == 1 {
                        rowC.hidden = true
                        self?.haveC = false
                    }else {
                        rowC.hidden = false
                        self?.haveC = true
                    }
                    
                    rowC.options = options
                    rowC.value = options[0]
                    rowC.updateCell()
                }
            })
            
            <<< PickerInlineRow<String>("categoryC") {
                $0.title = "三级分类"
                $0.value = "无"
                $0.hidden = "$categoryB == '无'"
                
            }
            .onChange({ [weak self] row in
                self?.isChange = true
                if let rowD: PickerInlineRow<String> = self?.form.rowBy(tag: "categoryD") {
                    
                    var categoryId = ""
                    var specificationsId = ""
                    let categoryName = row.baseValue as? String
                    
                    for categoryModel in self!.categoryCData {
                        if categoryModel.name == categoryName {
                            categoryId = categoryModel.id!
                            
                            if categoryModel.specification != nil{
                                let specificationModel = categoryModel.specification!
                                specificationsId = specificationModel.id!
                            }
                        }
                    }
                    
                    self?.categoryCID = categoryId
                    
                    var options: Array<String> = ["无"]
                    for categoryDModel in self!.categoryDData {
                        if categoryDModel.parentId == categoryId {
                            let name = categoryDModel.name!
                            options.append(name)
                        }
                    }
                    
                    if specificationsId == "" {
                        let rowsep: PickerInlineRow<String> = (self?.form.rowBy(tag: "specification"))!
                        let options: Array<String> = ["无"]
                        rowsep.value = "无"
                        rowsep.options = options
                        rowsep.updateCell()
                    }else{
                        self?.getSpecifications(specificationsId: specificationsId as NSString)
                    }
                    
                    if options.count == 1 {
                        rowD.hidden = true
                        self?.haveD = false
                    }else {
                        rowD.hidden = false
                        self?.haveD = true
                    }
                    
                    rowD.options = options
                    rowD.value = options[0]
                    rowD.updateCell()
                }
            })
            
            <<< PickerInlineRow<String>("categoryD") {
                $0.title = "四级分类"
                $0.value = "无"
                $0.hidden = "$categoryC == '无'"
            }
            .onChange({ [weak self] row in
                self?.isChange = true
                var categoryId = ""
                var specificationsId = ""
                
                let categoryName = row.baseValue as? String
                
                for categoryModel in self!.categoryDData {
                    if categoryModel.name == categoryName {
                        categoryId = categoryModel.id!
                        
                        if categoryModel.specification != nil{
                            let specificationModel = categoryModel.specification!
                            specificationsId = specificationModel.id!
                        }
                    }
                }
                
                self?.categoryDID = categoryId
                
                if specificationsId == "" {
                    let rowsep: PickerInlineRow<String> = (self?.form.rowBy(tag: "specification"))!
                    let options: Array<String> = ["无"]
                    rowsep.value = "无"
                    rowsep.options = options
                    rowsep.updateCell()
                }else{
                    self?.getSpecifications(specificationsId: specificationsId as NSString)
                }
            })
            
            <<< PickerInlineRow<String>("specification") {
                $0.title = "商品规格"
                $0.value = "无"
                $0.options = ["无"]
            }
            .onChange({ [weak self] row in
                self?.isChange = true
                let specificationName = row.baseValue as? String
                self?.specificationsID = ""
                
                for specificationModel in self!.specificationData {
                    
                    let name = specificationModel.name
                    if name == specificationName {
                        self?.specificationsID = specificationModel.id!
                        break
                    }
                }
            })
            
            <<< PickerInlineRow<String>("unitType") {
                $0.title = "单位"
                let options =  Utils.getFieldArrInDirArr(arr: AppData.unitTypeList, field: "label")
                $0.options = options
                $0.value = options[0]
            }
            .onChange({ [weak self] row in
                self?.isChange = true
                let unitTypeName = row.baseValue as? String
                for unitTypeDic in AppData.unitTypeList {
                    let unitType = Utils.getReadString(dir: unitTypeDic, field: "label")
                    if unitType == unitTypeName {
                        self?.unitTypeID = Utils.getReadInt(dir: unitTypeDic, field: "value")
                        break
                    }
                }
            })

            +++
            
            MultivaluedSection(multivaluedOptions: [.Insert, .Delete],
                               header: "详情内容",
                               footer: "") {
                                
                $0.header?.height = {30}
                
                $0.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "添加详情图"
                        }.cellUpdate { cell, row in
                            cell.textLabel?.textAlignment = .left
                    }
                }
                
                $0.multivaluedRowToInsertAt = { index in
                    
                    return ImageRow {
                        $0.title = "详情图"
                        
                    }.onChange { [weak self] row in
                        
                        let indexPath = row.indexPath
                        AppLog("row下标: \(indexPath!)")
                        
                        var image = row.baseValue as! UIImage
                        AppLog("照片原尺寸: \(image.size)")
                        image = image.resizeImage(valueMax: 500) ?? image
                        AppLog("照片压缩后尺寸: \(image.size)")
                        
                        var storeNo = "000"
                        if let valueStr = UserData.shared.workerModel?.store?.no?.stringValue {
                            storeNo = valueStr
                        }
                        
                        let type = "company/\(storeNo)/materials/image"
                        
                        YZBSign.shared.upLoadImageRequest(oldUrl: self?.detailsPicUrlArray[indexPath!.row], imageType: type, image: image, success: { (response) in
                            
                            self?.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                            let headStr = response.replacingOccurrences(of: "\"", with: "")
                            self?.detailsPicUrlArray[indexPath!.row] = headStr
                            self?.detailsPicArray[indexPath!.row] = image
                            
                        }, failture: { (error) in
                            
                            self?.noticeError("上传失败", autoClear: true, autoClearTime: 1)
                            row.value = self?.detailsPicArray[indexPath!.row]
                            row.updateCell()
                        })
                    }
                }
                
                $0 <<< ImageRow ("image") {
                    $0.title = "详情图"
                    
                }.onChange { [weak self] row in
                    self?.isChange = true
                    var image = row.baseValue as! UIImage
                    AppLog("照片原尺寸: \(image.size)")
                    image = image.resizeImage(valueMax: 500) ?? image
                    AppLog("照片压缩后尺寸: \(image.size)")
                    
                    var storeNo = "000"
                    if let valueStr = UserData.shared.workerModel?.store?.no?.stringValue {
                        storeNo = valueStr
                    }
                    
                    let type = "company/\(storeNo)/materials/image"
                    
                    YZBSign.shared.upLoadImageRequest(oldUrl: self?.detailsPicUrlArray[0], imageType: type, image: image, success: { (response) in
                        
                        self?.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                        let headStr = response.replacingOccurrences(of: "\"", with: "")
                        self?.detailsPicUrlArray[0] = headStr
                        self?.detailsPicArray[0] = image
                        
                    }, failture: { (error) in
                        
                        self?.noticeError("上传失败", autoClear: true, autoClearTime: 1)
                        row.value = self?.detailsPicArray[0]
                        row.updateCell()
                    })
                }
            }
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                row.title = "添加"
            }
            .onCellSelection { [weak self] (cell, row) in
                
                self?.createCompanyCustom()
            }
    }
    //MARK: -  网络请求
    
    /// 获取规格
    func getSpecifications(specificationsId :NSString){
        
        var parameters: Parameters = [:]
        parameters["yzbSpecification"] = specificationsId
        
        self.pleaseWait()
        let urlStr = APIURL.getSpecification
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                self.specificationData.removeAll()
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<SpecificationModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                var options: Array<String> = ["无"]
                
                for model in modelArray {
                    self.specificationData.append(model)
                    let name = model.name!
                    options.append(name)
                }
                
                let rowsep :PickerInlineRow<String> = self.form.rowBy(tag: "specification")!
                rowsep.options = options
                rowsep.value = "无"
                rowsep.updateCell()
            }
            
        }) { (error) in
            
        }
    }
    
    /// 创建自建主材
    func createCompanyCustom() {
        
        var detailsPicUrl = ""
        for i in 0..<detailsPicUrlArray.count {
            
            let picStr = detailsPicUrlArray[i]
            
            if picStr != "" {
                if i > 0 {
                    detailsPicUrl += "(,)\(picStr)"
                }else {
                    detailsPicUrl = picStr
                }
            }
        }
        
        let brands = self.form.tagToDictionary( "brands")?.id ?? "0"

        if thumbnailPicUrl == "" {
            noticeOnlyText("展示图为空")
            return
        }
        if form.tagToString("name") == "" {
            noticeOnlyText("产品名称为空")
            return
        }
        
        let  purchasePrice = form.tagToString( "purchasePrice")
        if purchasePrice == "" || purchasePrice == "0.0" {
            self.noticeOnlyText("请输入进货价")
            return
        }
        
        let  retailPrice = form.tagToString( "retailPrice")
        if retailPrice == "" || retailPrice == "0.0" {
            self.noticeOnlyText("请输入零售价")
            return
        }
        
        let  marketPrice = form.tagToString( "marketPrice")
        if marketPrice == "" ||  marketPrice == "0.0" {
            self.noticeOnlyText("请输入市场价")
            return
        }
        
        let  count = form.tagToString( "count")
        if count == "" || count == "0.0" {
            self.noticeOnlyText("请输入库存数量")
            return
        }
        if brands == "" {
            noticeOnlyText("请选择品牌")
            return
        }
        if haveB == true && categoryBID == "" {
            self.noticeOnlyText("请选择二级分类")
            return
        }
        if haveC == true && categoryCID == "" {
            self.noticeOnlyText("请选择三级分类")
            return
        }
        if haveD == true && categoryDID == "" {
            self.noticeOnlyText("请选择四级分类")
            return
        }
        if specificationsID == "" && categoryAID == "0c40740b6365439c86bdb732e66420be" {
            self.noticeOnlyText("墙地面类必须选择规格")
            return
        }
        if detailsPicUrl == "" {
            self.noticeOnlyText("详情图为空")
            return
        }
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        var parameters: Parameters = [:]
        parameters["store"] = storeID
        parameters["name"] = self.form.tagToString("name")
        parameters["categorya.id"] = categoryAID
        parameters["categoryb.id"] = categoryBID
        parameters["categoryc.id"] = categoryCID
        parameters["categoryd.id"] = categoryDID
        parameters["priceCustom"] = self.form.tagToString("retailPrice")
        parameters["priceShow"] = self.form.tagToString("marketPrice")
        parameters["priceCost"] = self.form.tagToString( "purchasePrice")
        parameters["thumbnailUrl"] = thumbnailPicUrl
        parameters["images"] = detailsPicUrl
        parameters["merchant"] = self.form.tagToDictionary( "brands")?.id ?? "0"
        parameters["yzbSpecification"] = specificationsID
        parameters["unitType"] = unitTypeID
        
        let materialCount = Int(self.form.tagToString("count") ?? "0")
        parameters["count"] = NSNumber.init(value: materialCount!)
        
        AppLog(parameters)
        
        self.pleaseWait()
        let urlStr =  APIURL.addCompanyMaterial
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                let popup = PopupDialog(title: "添加成功", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

                let sureBtn = AlertButton(title: "确定") {
                    self.navigationController?.popViewController(animated: true)
                }
                popup.addButtons([sureBtn])
                self.present(popup, animated: true, completion: nil)
            }
            
        }) { (error) in
            
        }
    }

    
    //MARK: - 重写删除、添加方法
    override func rowsHaveBeenRemoved(_ rows: [BaseRow], at indexes: [IndexPath]) {
        super.rowsHaveBeenRemoved(rows, at: indexes)
        
        AppLog("删除了\(indexes)")
        
        let indexPath = indexes.first
        
        if indexPath?.section == 1 {
            
            if let row = indexPath?.row {
                detailsPicUrlArray.remove(at: row)
                detailsPicArray.remove(at: row)
            }
        }
        
        print("详情图片数组: \(detailsPicUrlArray)")
    }
    
    override func rowsHaveBeenAdded(_ rows: [BaseRow], at indexes: [IndexPath]) {
        super.rowsHaveBeenAdded(rows, at: indexes)
        
        AppLog("添加了\(indexes)")
        
        let indexPath = indexes.first
        
        if indexPath?.section == 1 {
            
            detailsPicUrlArray.append("")
            detailsPicArray.append(nil)
        }
        
        print("详情图片数组: \(detailsPicUrlArray)")
    }
    
}

