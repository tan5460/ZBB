//
//  FiltrateView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/9.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class FiltrateView: UIView,UITableViewDelegate,UITableViewDataSource,FiltrateTableViewDelegate {
    
    var opacityView: UIView!
    var menuView: UIView!
    
    var tableView1: UITableView!               //全部品牌table
    var merchantData : [BrandListItem]!     //品牌model
    var normalSelectMercant : BrandListItem!     //默认选择的品牌
    var selectMercant : BrandListItem!          //选择的品牌
    var isSelfMercant : Bool = false           //是否是自建
    
    var allCategoryData : [BrandHouseModel]!  //全部分类
    
    var tableView2: FiltrateTableView!  //类别table
    var tableView3: FiltrateTableView!  //类别table
    var tableView4: FiltrateTableView!  //类别table
    
    var line2: UIView!                //分割线
    var line3: UIView!                //分割线
    var line4: UIView!                //分割线
    
    var isReset : Bool = false         //是否重置
    
    var selectedBlock: ((_ merchantModel: BrandListItem?, _ categoryModel: BrandHouseModel?)->())?
    
    var hiddeBlock: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isHidden = true
        
        selectMercant = BrandListItem()
        selectMercant.id = ""
        selectMercant.brandId = ""
        selectMercant.brandName = "全部品牌"
    
        normalSelectMercant = selectMercant
        
        merchantData = [selectMercant]
        allCategoryData = []
        
        loadCategoryData()
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func createSubView() {
        
        //半透明蒙版
        opacityView = UIView()
        opacityView.backgroundColor = UIColor.init(white: 0, alpha: 0.168)
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(hiddenMenu))
        tapOne.numberOfTapsRequired = 1
        opacityView.addGestureRecognizer(tapOne)
        self.addSubview(opacityView)
        
        opacityView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //菜单
        menuView = UIView()
        menuView.backgroundColor = .white
        self.addSubview(menuView)
        
        menuView.snp.makeConstraints { (make) in
            make.height.equalTo(260)
            make.left.right.top.equalToSuperview()
        }
        
       
        tableView1 = FiltrateTableView()
        tableView1.backgroundColor = .white
        tableView1.dataSource = self
        tableView1.delegate = self
        tableView1.separatorStyle = .none
        tableView1.bounces = false
        tableView1.showsVerticalScrollIndicator = false
        menuView.addSubview(tableView1)
        
        tableView1.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
        }
        
        tableView2 = FiltrateTableView()
        tableView2.normalRowBgColor = .white
        tableView2.selectRowBgColor = .white
        tableView2.filtrateTBDelegata = self
        menuView.addSubview(tableView2)
        
        tableView2.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(tableView1.snp.width)
            make.left.equalTo(tableView1.snp.right)
        }
        
        line2 = UIView()
        line2.backgroundColor = PublicColor.partingLineColor
        menuView.addSubview(line2)
        line2.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(1)
            make.left.equalTo(tableView2.snp.left)
        }
        
        
        tableView3 = FiltrateTableView()
        tableView3.normalRowBgColor = tableView2.selectRowBgColor
        tableView3.selectRowBgColor = .white
        tableView3.filtrateTBDelegata = self
        menuView.addSubview(tableView3)
        
        tableView3.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(0)
            make.left.equalTo(tableView2.snp.right)
        }
        
        line3 = UIView()
        line3.backgroundColor = PublicColor.partingLineColor
        menuView.addSubview(line3)
        line3.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(1)
            make.left.equalTo(tableView3.snp.left)
        }
        
        tableView4 = FiltrateTableView()
        tableView4.normalRowBgColor = tableView3.selectRowBgColor
        tableView4.selectRowBgColor = .white
        tableView4.filtrateTBDelegata = self
        menuView.addSubview(tableView4)
        
        tableView4.snp.makeConstraints { (make) in
            make.top.right.bottom.equalToSuperview()
            make.width.equalTo(0)
            make.left.equalTo(tableView3.snp.right)
        }
        
        line4 = UIView()
        line4.backgroundColor = PublicColor.partingLineColor
        menuView.addSubview(line4)
        line4.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(1)
            make.left.equalTo(tableView4.snp.left)
        }
        
        self.menuView.transform = CGAffineTransform.identity
            .translatedBy(x: 0, y: -130)
            .scaledBy(x: 1, y: 0.01)
    }
    
    //弹出菜单
    func showMenu() {
        
        self.isHidden = false
        opacityView.alpha = 0

        selectMercant = normalSelectMercant
        self.scrolltoSelectMercant()
        
//        if merchantData.count <= 1 {
//            if isSelfMercant {
//                loadSelfMerchantData()
//            }else {
//                loadMerchantData()
//            }
//        }else {
//
//            self.scrolltoSelectMercant()
//        }
        
        UIView.animate(withDuration: 0.2, animations: {
            
            self.opacityView.alpha = 1
            
            self.menuView.transform = CGAffineTransform.identity
        }) { (finished) in
            
        }
        

    }
    
    //隐藏菜单
    @objc func hiddenMenu() {

        if hiddeBlock != nil {
            self.hiddeBlock!()
        }
        UIView.animate(withDuration: 0.2, animations: {
       
            self.menuView.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: -130)
                .scaledBy(x: 1, y: 0.01)
            self.opacityView.alpha = 0
            
        }) { (finished) in
            self.isHidden = true
        }
    }
    
    //清空原来选择的数据
    func emptyNormalSelcetData() {
        selectMercant = BrandListItem()
        selectMercant.id = ""
        selectMercant.brandId = ""
        selectMercant.brandName = "全部品牌"
        
        normalSelectMercant = selectMercant
        tableView4.normalSelectCategory = nil
        tableView3.normalSelectCategory = nil
        tableView2.normalSelectCategory = nil
        
        self.tableView3.snp.updateConstraints { (make) in
            make.width.equalTo(0)
        }
        self.tableView4.snp.updateConstraints { (make) in
            make.width.equalTo(0)
        }
    }
    
    //重置
    @objc func resetAction() {
     
        selectMercant = BrandListItem()
        selectMercant.id = ""
        selectMercant.brandId = ""
        selectMercant.brandName = "全部品牌"
        
        isReset = true
        if isSelfMercant {
            loadSelfMerchantData()
        }else {
            loadMerchantData()
        }
    
    }
    //确定
    @objc func sureAction() {
        var sureCategory = BrandHouseModel()
        
        if tableView4.selectCategory != nil {
            tableView4.normalSelectCategory = tableView4.selectCategory
            tableView3.normalSelectCategory = tableView3.selectCategory
            tableView2.normalSelectCategory = tableView2.selectCategory
            if tableView4.selectCategory?.categoryId == "" {
                sureCategory = tableView3.selectCategory!
            }else {
                sureCategory = tableView4.selectCategory!
            }
        }else if tableView3.selectCategory != nil {
            tableView4.normalSelectCategory = nil
            tableView3.normalSelectCategory = tableView3.selectCategory
            tableView2.normalSelectCategory = tableView2.selectCategory
            sureCategory = tableView3.selectCategory!
            if tableView3.selectCategory?.categoryId == "" {
                sureCategory = tableView2.selectCategory!
            }else {
                sureCategory = tableView3.selectCategory!
            }
        }else if tableView2.selectCategory != nil {
            tableView4.normalSelectCategory = nil
            tableView3.normalSelectCategory = nil
            tableView2.normalSelectCategory = tableView2.selectCategory
            if tableView2.selectCategory?.categoryId == "" {
                sureCategory.categoryId = "0"
            }else {
                sureCategory = tableView2.selectCategory!
            }
        }else {
            tableView4.normalSelectCategory = nil
            tableView3.normalSelectCategory = nil
            tableView2.normalSelectCategory = nil
            sureCategory.categoryId = "0"
        }
        
        if selectedBlock != nil {
            normalSelectMercant = selectMercant
            self.selectedBlock!(normalSelectMercant, sureCategory)
        }
        hiddenMenu()
    }
    
    func scrolltoSelectMercant() {
        tableView1.reloadData()
        
        let oldSelMerchant = merchantData.filter{$0.brandId == normalSelectMercant.brandId}
        if oldSelMerchant.first == nil {
            normalSelectMercant = BrandListItem()
            normalSelectMercant.id = ""
            normalSelectMercant.brandId = ""
            normalSelectMercant.brandName = "全部品牌"
        }
        
        if self.selectMercant.brandId != "" {
            
            if self.merchantData.count > 5 {
                
                var i = 0
                for (index, model) in self.merchantData.enumerated() {
                    if self.selectMercant.brandId == model.brandId {
                        i = index
                        break
                    }
                }
                self.tableView1.scrollToRow(at: IndexPath.init(row: i, section: 0), at: .middle, animated: true)
            }
            self.tableView2.selectCategory = isReset ? nil : self.tableView2.normalSelectCategory
            self.tableView2.rowData = allCategoryData.filter{$0.categoryId == selectMercant.categoryId}

        }else {
            if self.merchantData.count > 0 {
                
                self.tableView1.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .middle, animated: true)
            }
            self.tableView2.selectCategory = isReset ? nil : self.tableView2.normalSelectCategory
            self.tableView2.rowData = allCategoryData.filter{$0.categoryId == "0"}
        }
        
        if self.tableView2.selectCategory != nil {
            
            if self.tableView2.rowData.count > 5 {
                
                var i = 0
                
                for (index, model) in self.tableView2.rowData.enumerated() {
                    if self.tableView2.selectCategory?.categoryId == model.categoryId {
                        i = index
                        break
                    }
                }
                self.tableView2.scrollToRow(at: IndexPath.init(row: i, section: 0), at: .middle, animated: true)
            }
            self.tableView3.selectCategory = isReset ? nil : self.tableView3.normalSelectCategory
            self.tableView3.rowData = allCategoryData.filter{$0.categoryId == self.tableView2.selectCategory?.categoryId}
        }else {
            self.tableView3.selectCategory = nil
            self.tableView3.rowData = []
            self.tableView3.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
            self.tableView4.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
        }
        if self.tableView3.selectCategory != nil {
            if self.tableView3.rowData.count > 5 {
                
                var i = 0
                
                for (index, model) in self.tableView3.rowData.enumerated() {
                    if self.tableView3.selectCategory?.categoryId == model.categoryId {
                        i = index
                        break
                    }
                }
                self.tableView3.scrollToRow(at: IndexPath.init(row: i, section: 0), at: .middle, animated: true)
            }
            self.tableView4.selectCategory = isReset ? nil : self.tableView4.normalSelectCategory
            self.tableView4.rowData = allCategoryData.filter{$0.categoryId == self.tableView3.selectCategory?.categoryId}
        }else {
            self.tableView4.selectCategory = nil
            self.tableView4.rowData = []
            self.tableView3.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
            self.tableView4.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
        }
        if self.tableView4.rowData.count > 5 {
            var i = 0
            
            for (index, model) in self.tableView4.rowData.enumerated() {
                if self.tableView4.selectCategory?.categoryId == model.categoryId {
                    i = index
                    break
                }
            }
            self.tableView4.scrollToRow(at: IndexPath.init(row: i, section: 0), at: .middle, animated: true)
        }
        
        isReset = false
    }
    
    //MARK: - 网络请求
    
    /// 获取材料商  系统品牌
    func loadMerchantData() {
        
        var cityID = ""
        if let valueStr = UserData.shared.workerModel?.store?.city?.id {
            cityID = valueStr
        }
        var substationId = ""
        if let valueStr = UserData.shared.workerModel?.substation?.id {
            substationId = valueStr
        }
        
        let parameters: Parameters = ["id": "", "category.id": "", "city.id": cityID, "substationId":substationId, "isshow": "", "pageSize": "500"]
        
//        self.clearAllNotice()
//        self.pleaseWait()
        let urlStr = APIURL.getMerchant
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<BrandListItem>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                
                if self.merchantData.count <= 1 {
                    self.merchantData += modelArray
                    self.scrolltoSelectMercant()
                   
                }else {
                    let merchant = BrandListItem()
                    merchant.id = ""
                    merchant.brandId = ""
                    merchant.brandName = "全部品牌"
                    self.merchantData = [merchant]
                    
                    self.merchantData.append(contentsOf: modelArray)
                    
                    self.scrolltoSelectMercant()
                }

            }else {
                self.tableView1.reloadData()
            }
            
        }) { (error) in

           self.tableView1.reloadData()
        }
    }
    
    /// 获取材料商   自建品牌
    func loadSelfMerchantData() {
        
//        var storeID = ""
//        if let valueStr = UserData.shared.workerModel?.store?.id {
//            storeID = valueStr
//        }
//
//        let parameters: Parameters = ["id": "", "store": storeID, "category.id": "", "pageSize": "500"]
//
////        self.clearAllNotice()
////        self.pleaseWait()
//        let urlStr = APIURL.getComMerchant
//
//        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
//
//            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
//            if errorCode == "000" {
//
//                let dataArray = Utils.getReqArr(data: response as AnyObject)
//                let modelArray = Mapper<BrandListItem>().mapArray(JSONArray: dataArray as! [[String : Any]])
//
//                _ = modelArray.map { $0.brandId = $0.id }
//
//                if self.merchantData.count <= 1 {
//                    self.merchantData.append(contentsOf: modelArray)
//                   self.scrolltoSelectMercant()
//                }else {
//                    let merchant = BrandListItem()
//                    merchant.id = ""
//                    merchant.brandId = ""
//                    merchant.brandName = "全部品牌"
//                    self.merchantData = [merchant]
//
//                    self.merchantData.append(contentsOf: modelArray)
//                    self.scrolltoSelectMercant()
//                }
//            }else {
//                self.tableView1.reloadData()
//            }
//
//        }) { (error) in
//            self.tableView1.reloadData()
//        }
    }
    func loadCategoryData() {
        
//        let parameters: Parameters = ["parent.id": "", "pageSize": "500"]
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
//                let modelArray = Mapper<BrandHouseModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
//                self.allCategoryData = modelArray
//                self.tableView2.selectCategory = nil
//                self.tableView3.selectCategory = nil
//                self.tableView4.selectCategory = nil
//                if self.selectMercant.brandId == "" {
//                    self.tableView2.rowData = self.allCategoryData.filter{$0.categoryId == "0"}
//                }else {
//                    self.tableView2.rowData = self.allCategoryData.filter{$0.categoryId == self.selectMercant.categoryId}
//                }
//
//                self.tableView3.rowData = []
//                self.tableView4.rowData = []
//                self.tableView3.snp.updateConstraints { (make) in
//                    make.width.equalTo(0)
//                }
//                self.tableView4.snp.updateConstraints { (make) in
//                    make.width.equalTo(0)
//                }
//            }
//            
//        }) { (error) in
//            
//        }
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return merchantData!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "tableViewCell")
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .white
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.textColor = PublicColor.commonTextColor
        cell.textLabel?.numberOfLines = 2
        
        let model = merchantData[indexPath.row]
        cell.textLabel?.text = "品牌名空"
        
        if let name = model.brandName {
            cell.textLabel?.text = name
        }
        
        if model.brandId == selectMercant.brandId {
            cell.contentView.backgroundColor = .white
            cell.textLabel?.textColor = PublicColor.emphasizeTextColor
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectMercant = self.merchantData[indexPath.row]
        tableView.reloadData()
        
        if allCategoryData.count > 0 {
            self.tableView2.selectCategory = nil
            self.tableView3.selectCategory = nil
            self.tableView4.selectCategory = nil
            if selectMercant.brandId == "" {
                self.tableView2.rowData = allCategoryData.filter{$0.categoryId == "0"}
             }else {
                self.tableView2.rowData = allCategoryData.filter{$0.categoryId == selectMercant.categoryId}
            }
            self.tableView3.rowData = []
            self.tableView4.rowData = []
            self.tableView3.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
            self.tableView4.snp.updateConstraints { (make) in
                make.width.equalTo(0)
            }
        }else {
            loadCategoryData()
        }
    }
    
    //MARK: - filtrateTabelViewDelegate
    func filtrateTabelView(_ fTabelView: FiltrateTableView, didSelectRowAt indexPath: IndexPath, didSelectModelAt selectModel: BrandHouseModel?) {
        
        if fTabelView == tableView2 {
            self.tableView3.selectCategory = nil
            self.tableView4.selectCategory = nil
            if selectModel!.categoryId != "" {
                
                self.tableView3.rowData = allCategoryData.filter{$0.categoryId == selectModel?.categoryId}
                self.tableView4.rowData = []
                if self.tableView3.rowData.count > 1 {
                    
                    self.tableView3.snp.updateConstraints { (make) in
                        make.width.equalTo(PublicSize.screenWidth/3)
                    }
                }else {
                    self.tableView3.snp.updateConstraints { (make) in
                        make.width.equalTo(0)
                    }
                    sureAction()
                }
                self.tableView4.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
                
            }else {
                self.tableView3.rowData = []
                self.tableView4.rowData = []
                self.tableView3.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
                self.tableView4.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
                sureAction()
            }
        }else if fTabelView == tableView3 {
            self.tableView4.selectCategory = nil
            if selectModel!.categoryId != "" {
                self.tableView4.rowData = allCategoryData.filter{$0.categoryId == selectModel?.categoryId}
                if self.tableView4.rowData.count > 1 {
                    
                    self.tableView3.snp.updateConstraints { (make) in
                        make.width.equalTo(PublicSize.screenWidth/4)
                    }
                    self.tableView4.snp.updateConstraints { (make) in
                        make.width.equalTo(PublicSize.screenWidth/4)
                    }
                }else {
                    self.tableView3.snp.updateConstraints { (make) in
                        make.width.equalTo(PublicSize.screenWidth/3)
                    }
                    self.tableView4.snp.updateConstraints { (make) in
                        make.width.equalTo(0)
                    }
                    sureAction()
                }
            }else {
                self.tableView4.rowData = []
                self.tableView3.snp.updateConstraints { (make) in
                    make.width.equalTo(PublicSize.screenWidth/3)
                }
                self.tableView4.snp.updateConstraints { (make) in
                    make.width.equalTo(0)
                }
                sureAction()
            }
        }else if fTabelView == tableView4 {
            sureAction()
        }
        
    }
}
