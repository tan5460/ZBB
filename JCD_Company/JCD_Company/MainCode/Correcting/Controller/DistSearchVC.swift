//
//  DistSearchVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/12.
//

import UIKit
import TLTransitions

class DistSearchVC: BaseViewController,UISearchBarDelegate{
    
    var latitude: String?  // 经度
    var longitude: String? // 纬度
    
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
    
    private var pop: TLTransition?
    
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
      //  searchBar.becomeFirstResponder()
    }
    
    private var brandBtn = UIButton()
    private var brandTitle = UILabel().text("产品").textColor(.kColor33).font(12)
    private var brandArrow = UIImageView().image(#imageLiteral(resourceName: "search_arrow_down"))
    
    
    
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
        
        
        let bgV = UIView(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth-100, height: 40))
        navigationItem.titleView = bgV
        
        brandBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 40)
        bgV.addSubview(brandBtn)
                
        brandTitle.frame = CGRect(x: 10, y: 10, width: 25, height: 16.5)
        brandArrow.frame = CGRect(x: 44, y: 17, width: 6, height: 3)
        brandTitle.isUserInteractionEnabled = false
        brandArrow.isUserInteractionEnabled = false
        brandBtn.addSubview(brandTitle)
        brandBtn.addSubview(brandArrow)
        
        //搜索栏
        searchBar = UISearchBar(frame: CGRect.init(x: 60, y: 0, width: PublicSize.screenWidth-180, height: 40))
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        bgV.addSubview(searchBar)
        searchBar.placeholder = "请输入品牌名或产品名称"
        
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
        
        
        brandBtn.tapped { [weak self] (tapBtn) in
            self?.searchTypePopView()
        }
        
        if let string = searchString {
            searchBar.text = string
        }
    }
    private var currentType = 0 // 0: 产品 1: 品牌
    func searchTypePopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 70, height: 77)).backgroundColor(.clear)
        let arrow = UIImageView().image(#imageLiteral(resourceName: "search_arrow_up"))
        let content = UIView().backgroundColor(.black).cornerRadius(4).masksToBounds().alpha(0.9)
        v.sv(arrow, content)
        v.layout(
            0,
            arrow.width(7).height(3).centerHorizontally(),
            0,
            content.width(70).height(74).centerHorizontally(),
            0
        )
        pop = TLTransition.show(v, to: CGPoint(x: 48, y: PublicSize.kNavBarHeight))
        pop?.cornerRadius = 4
        
        let cpBtn = UIButton().image(#imageLiteral(resourceName: "search_cp")).text(" 产品").textColor(.white).font(12)
        let line = UIView().backgroundColor(.white).alpha(0.5)
        let ppBtn = UIButton().image(#imageLiteral(resourceName: "search_pp")).text(" 品牌").textColor(.white).font(12)
        content.sv(cpBtn, line, ppBtn)
        content.layout(
            0,
            |cpBtn.width(70).height(38)|,
            0,
            |-10.5-line.height(0.5)-9.5-|,
            |ppBtn.width(70).height(36)|,
            0
        )
        cpBtn.tapped { [weak self] (tapBtn) in
            self?.currentType = 0
            self?.brandTitle.text("产品")
            self?.pop?.dismiss()
        }
        ppBtn.tapped { [weak self] (tapBtn) in
            self?.currentType = 1
            self?.brandTitle.text("品牌")
            self?.pop?.dismiss()
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
            }else {
                let vc = DistDetailSearchVC()
                vc.latitude = latitude
                vc.longitude = longitude
                vc.searchType = currentType
                vc.searchName = searchStr
                navigationController?.pushViewController(vc)
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

