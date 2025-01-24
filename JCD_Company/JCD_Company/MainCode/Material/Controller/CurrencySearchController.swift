//
//  CurrencySearchController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/28.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

enum SearchType {
    case material           //主材搜索
    case purchMaterial      //采购订单搜索
    case cgMaterial         //采购主材搜索
    case jzPurchase         //家装公司采购搜索
    case gysPurchase        //供应商采购搜索
    case yysPurchase        //运营商采购搜索
    case brand              //品牌搜索
    case newMaterial        //主材搜索
    case distProduction     //区域产品
}

class CurrencySearchController: BaseViewController,UISearchBarDelegate{
    var isAddMaterial: Bool = false             //是否添加主材
    var addMaterialBlock: ((_ materialModel: MaterialsModel)->())?
    
    var searchType: SearchType = .material
    var isSecondSearch = false                  //是否第二次搜索
    var isSendOrder = false                     //送否发送订单进来
    var searchBar: UISearchBar!                 //搜索
    var searchBtn: UIButton!
    var searchString: String?
    var searchView: MaterialSearchView!         //搜索时历史记录
    var brandId = ""                            //品牌id
    var merchantId = ""                         //供应商id
    var sjsFlag = false
    
    /// 主材搜索
    var selectedModel: HoStoreModel!
    var sectionModel: HoStoreModel! // 组
    var selectedBrand: HoBrandModel!
    var selectedSpesub: HoSpecSubModel!
    
    /// 品牌搜索
    var brandName: String?
    var brandType: String?
    var categoryId: String?
    
    var searchBlock: ((_ searchString: String)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        prepareNavigationItem()
        prepareSearchView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    //MARK: - 自定义导航栏
    func prepareNavigationItem() {
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        //搜索按钮
        searchBtn = UIButton(type: .custom)
        searchBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        searchBtn.setTitle("搜索", for: .normal)
        searchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        searchBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        searchBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        searchBtn.addTarget(self, action: #selector(searchAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: searchBtn)
        
        //搜索栏
        searchBar = UISearchBar(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth-100, height: 40))
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        
        switch searchType {
        case .material, .cgMaterial, .purchMaterial, .newMaterial:
            searchBar.placeholder = "请输入产品名/品牌名"
        case .jzPurchase:
            searchBar.placeholder = "订单号/供应商/地址"
        case .gysPurchase:
            searchBar.placeholder = "订单号/采购单位/地址"
        case .yysPurchase:
            searchBar.placeholder = "订单号/采购单位/供应商/地址"
        case .brand:
            searchBar.placeholder = "请输入产品名称"
        case .distProduction:
            searchBar.placeholder = "请输入品牌名或产品名称"
        }
        
        searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
        
        searchBar.backgroundImage = UIColor.white.image()
        searchBar.backgroundColor = .white
        let textfield = searchBar.textField
        textfield?.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xF0F0F0)
        textfield?.layer.cornerRadius = 18
        textfield?.layer.masksToBounds = true
        textfield?.font = UIFont.systemFont(ofSize: 13)
        textfield?.textColor = PublicColor.commonTextColor
        
        //让UISearchBar 支持空搜索
        textfield?.enablesReturnKeyAutomatically = false
        
       
        if let string = searchString {
            searchBar.text = string
        }
    }
    func prepareSearchView() {
        //搜索时蒙版遮罩
        searchView = MaterialSearchView.init(frame: CGRect.zero, searchType: searchType)
        self.view.addSubview(searchView)
        
        searchView.searchBlock = {[weak self](string) in
            self?.searchBar.text = string
            self?.searchAction()
        }
        
        searchView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
            } else {
                 make.top.equalTo(64)
            }
            make.right.left.bottom.equalToSuperview()
        }
    }
    //搜索
    @objc func searchAction() {
    
        if let searchStr = searchBar.text {
            //去掉空格
            let set = CharacterSet.whitespacesAndNewlines
            let trimedString = searchStr.trimmingCharacters(in: set)
            
            //判断string全部是空格
            if trimedString.count == 0 {
                
                if searchType == .cgMaterial || searchType == .purchMaterial || isSendOrder {
                    searchBar.text = ""
                    backAction()
                }
                return
            }
            searchView.updateHistory(searchStr)
            
            if isSecondSearch {
                if let block = searchBlock {
                    block(searchStr)
                    navigationController?.popViewController(animated: false)
                }
//                let vc = MaterialSearchController()
//                vc.isSecondSearch = true
//                vc.searchStr = searchBar.text!
//                vc.isAddMaterial = isAddMaterial
//                vc.merchantId = merchantId
//                vc.addMaterialBlock = addMaterialBlock
//                vc.sjsFlag = sjsFlag
//                navigationController?.pushViewController(vc, animated: true)
            }else {
                
                switch searchType {
                case .newMaterial:
                    let vc = StoreDetailVC()
                    vc.categoryId = categoryId
                    vc.searchName = searchBar.text
                    navigationController?.pushViewController(vc, animated: true)
                case .brand:
                    let vc = HoBrandViewController()
                    vc.isSecond = true
                    vc.brandType = brandType
                    vc.brandName = brandName
                    vc.brandId = brandId
                    vc.categoryId = categoryId
                    vc.searchText = searchBar.text
                    navigationController?.pushViewController(vc, animated: true)
                case .cgMaterial, .purchMaterial:
                    break
                case .material:
                    let vc = MaterialSearchController()
                    vc.isSecondSearch = true
                    vc.searchStr = searchBar.text!
                    vc.isAddMaterial = isAddMaterial
                    vc.merchantId = merchantId
                    vc.addMaterialBlock = addMaterialBlock
                    vc.sjsFlag = sjsFlag
                    navigationController?.pushViewController(vc, animated: true)
                    
                case .jzPurchase, .gysPurchase, .yysPurchase:
                    let vc = PurchaseViewController()
                    vc.searchStr = searchBar.text!
                    vc.isSecondSearch = true
                    navigationController?.pushViewController(vc, animated: true)
                case .distProduction:
                    break
                }
            }
            
            
        }
    }

    //返回
    @objc func backAction() {
        if searchType == .cgMaterial || searchType == .purchMaterial || isSendOrder {
            if let searchStr = searchBar.text {
                if searchStr == "" {
                    if let block = searchBlock {
                        block(searchStr)
                    }
                }
            }
        }
        self.navigationController?.popViewController(animated: false)
    }
    
    // 搜索触发事件，点击虚拟键盘上的search按钮时触发此方法
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchAction()
    }
}
