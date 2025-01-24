//
//  AddMaterialsController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/9/2.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Eureka
import Alamofire
import ObjectMapper


class AddPackageController: BaseFormController {
    
    var isPortrait: Bool = true                         //是否竖屏 默认竖屏
    var isFreeAdd: Bool = false                         //是否自由开单添加
    
    var packageModel: PackageModel?                     //主材包
    var categoryAData: Array<CategoryModel> = []        //一级分类
    var categoryBData: Array<CategoryModel> = []        //二级分类
    var categoryCData: Array<CategoryModel> = []        //三级分类
    var categoryDData: Array<CategoryModel> = []        //四级分类
    var categorya: CategoryModel?                       //一级分类
    var categoryb: CategoryModel?                       //二级分类
    var categoryc: CategoryModel?                       //三级分类
    var categoryd: CategoryModel?                       //四级分类
    
    var addMaterialBlock: ((_ packageModel: PackageModel)->())?      //添加主材包block
    
    
    deinit {
        AppLog(">>>>>>>>>>>>>> 添加小区界面释放 <<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if packageModel == nil {
            
            packageModel = PackageModel()
            categorya = CategoryModel()
            categoryb = CategoryModel()
            categoryc = CategoryModel()
            categoryd = CategoryModel()
            
            loadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
    }
    
    override func backAction() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func loadData() {
        
//        self.pleaseWait()
//        
//        let parameters: Parameters = ["parent": "", "pageSize": "500"]
//        let urlStr =  APIURL.getMaterialsCategory
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
            +++ Section()
            
            <<< TextRow ("name") {
                $0.title = "产品包名"
                $0.placeholder = "请输入产品包名"
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
            
            <<< PickerInlineRow<String>("categoryA") {
                $0.title = "一级分类"
                
                var options: Array<String> = []
                for model in self.categoryAData {
                    let name = model.name
                    options.append(name!)
                }
                
                $0.options = options
                $0.value = options[0]
                
                self.categorya?.id = self.categoryAData[0].id
                self.categorya?.name = self.categoryAData[0].name
            }
            .onChange({ [weak self] row in
                
                if let rowB: PickerInlineRow<String> = self?.form.rowBy(tag: "categoryB") {
                    
                    var options: Array<String> = ["无"]
                    
                    var categoryId = ""
                    let categoryName = row.baseValue as? String
                    
                    for categoryModel in self!.categoryAData {
                        if categoryModel.name == categoryName {
                            categoryId = categoryModel.id!
                        }
                    }
                    
                    self?.categorya?.id = categoryId
                    self?.categorya?.name = categoryName
                    
                    for categoryBModel in self!.categoryBData {
                        if categoryBModel.parentId == categoryId {
                            let name = categoryBModel.name
                            options.append(name!)
                        }
                    }
                    
                    rowB.options = options
                    rowB.value = options[0]
                    rowB.updateCell()
                }
            })
            
            <<< PickerInlineRow<String>("categoryB") {
                $0.title = "二级分类"
                
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
                
                if let rowC: PickerInlineRow<String> = self?.form.rowBy(tag: "categoryC") {
                    
                    var options: Array<String> = ["无"]
                    
                    var categoryId = ""
                    let categoryName = row.baseValue as? String
                    
                    for categoryModel in self!.categoryBData {
                        if categoryModel.name == categoryName {
                            categoryId = categoryModel.id!
                        }
                    }
                    
                    self?.categoryb?.id = categoryId
                    self?.categoryb?.name = categoryName
                    
                    for categoryCModel in self!.categoryCData {
                        if categoryCModel.parentId == categoryId {
                            let name = categoryCModel.name
                            options.append(name!)
                        }
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
                
                if let rowD: PickerInlineRow<String> = self?.form.rowBy(tag: "categoryD") {
                    
                    var options: Array<String> = ["无"]
                    
                    var categoryId = ""
                    let categoryName = row.baseValue as? String
                    
                    for categoryModel in self!.categoryCData {
                        if categoryModel.name == categoryName {
                            categoryId = categoryModel.id!
                        }
                    }
                    
                    self?.categoryc?.id = categoryId
                    self?.categoryc?.name = categoryName
                    
                    for categoryDModel in self!.categoryDData {
                        if categoryDModel.parentId == categoryId {
                            let name = categoryDModel.name
                            options.append(name!)
                        }
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
                
                var categoryId = ""
                let categoryName = row.baseValue as? String
                
                for categoryModel in self!.categoryDData {
                    if categoryModel.name == categoryName {
                        categoryId = categoryModel.id!
                    }
                }
                
                self?.categoryd?.id = categoryId
                self?.categoryd?.name = categoryName
            })
            
            +++ Section()
            <<< ButtonRow() { (row: ButtonRow) -> Void in
                
                row.title = "添加"
            }
            .onCellSelection { [weak self] (cell, row) in
                
                if self?.form.tagToString("name") == "" {
                    self?.noticeOnlyText("产品包名为空")
                    return
                }
                
                //随机数id
                let strAll = "0123456789abcdefghijklmnopqrstuvwxyz"
                var arcID = ""
                
                for _ in 0..<32 {
                    let index: Int = Int(arc4random() % UInt32(strAll.count-1))
                    let startIndex = strAll.index(strAll.startIndex, offsetBy: index)
                    let tempStr = strAll[startIndex]
                    
                    arcID = arcID.appending("\(tempStr)")
                }
                
                self?.packageModel?.id = "A001"
                AppLog("随机id: \(arcID)")
                
                //主材包名
                self?.packageModel?.name = self?.form.tagToString("name")
                
                //房屋类型
                let array = Utils.getFieldArrInDirArr(arr: AppData.roomTypeList, field: "label")
                let str = self?.form.rowBy(tag: "roomType")?.baseValue as! String
                let index = array.firstIndex(of: str)
                self?.packageModel?.roomType = NSNumber.init(value: index!+1)
                
                //分类
                if self?.form.tagToString("categoryD") != "无" {
                    self?.packageModel?.category?.name = self?.categoryd?.name
                    self?.packageModel?.category?.id = self?.categoryd?.id
                }
                else if self?.form.tagToString("categoryC") != "无" {
                    self?.packageModel?.category?.name = self?.categoryc?.name
                    self?.packageModel?.category?.id = self?.categoryc?.id
                }
                else if self?.form.tagToString("categoryB") != "无" {
                    self?.packageModel?.category?.name = self?.categoryb?.name
                    self?.packageModel?.category?.id = self?.categoryb?.id
                }
                else if self?.form.tagToString("categoryA") != "无" {
                    self?.packageModel?.category?.name = self?.categorya?.name
                    self?.packageModel?.category?.id = self?.categorya?.id
                }
                
                self?.packageModel?.packageType = 2
                
                self?.addMaterialBlock!((self?.packageModel)!)
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
