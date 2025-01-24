//
//  WholeHouseController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/31.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import ObjectMapper
import Kingfisher

class WholeHouseController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate  {

    var searchBar: UISearchBar!                 //搜索
    var maskBtn: UIButton!                      //搜索时遮罩按钮
    let spinner = UIActivityIndicatorView(style: .gray)        //活动指示器
    var searchName: String = ""                 //搜索类容
    var topView: UIView!
    var communityBtn: UIButton!                 //小区
    var topSelectBtnTag: Int!                  //选择的按钮
    var screenView: WholeHouseScreenView!          //筛选
    var tableView: UITableView!
    var rowsData: Array<HouseCaseModel> = []
    var curPage = 1
    
    let identifier = "WholeHouseCaseCell"
    
    var communityView:CaseVillageView!              //选小区
    
    var screenType : Int = 1                   //筛选类型1:风格；2：户型；3:面积
    
    var communityId : String?                 //小区id
    var communityName: String?                 // 小区名
    var caseStyle : String?                   //风格
    var houseArea : String?                   //面积
    var houseType : String?                   //户型
    
    var userId: String?    // 从公司详情页面进来
    var citySubstation: String? // 从公司详情页面进来
        
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>>> 全屋列表界面释放 <<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareNavigationItem()
        prepareNoDateView("暂无案例")
        prepareTopView()
        prepareTableView()
        
        prepareVillageView()
        prepareMenuView()
        prepareMaskBtn()
        //开始刷新
        tableView.mj_header?.beginRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //设置导航栏分割线
        let shadImage = PublicColor.navigationLineColor.image()
        navigationController?.navigationBar.shadowImage = shadImage
    }
    //MARK: - 自定义视图
    func prepareNavigationItem() {
       
        //搜索栏
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth-150, height: 30))
//        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.placeholder = "请按案例名称搜索"
        navigationItem.titleView = searchBar
        
        searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
        
        let textfield = searchBar.textField
        textfield?.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xF0F0F0)
        textfield?.layer.cornerRadius = 18
        textfield?.layer.masksToBounds = true
        textfield?.font = UIFont.systemFont(ofSize: 13)
        // Add spinner to search bar
        spinner.stopAnimating()
        
        if let textField = searchBar.subviews.first?.subviews.last {
            textField.addSubview(spinner)
            
            spinner.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(5)
                make.width.height.equalTo(20)
            }
        }
    }
    //搜索时按钮
    func prepareMaskBtn() {
        //搜索时蒙版遮罩
        maskBtn = UIButton(type: .custom)
        maskBtn.isHidden = true
        maskBtn.backgroundColor = Color.init(white: 0.1, alpha: 0.1)
        maskBtn.addTarget(self, action: #selector(cancelSearchAction), for: .touchUpInside)
        self.view.addSubview(maskBtn)
        
        maskBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    //筛选
    func prepareMenuView() {
        
        //筛选
        screenView = WholeHouseScreenView()
        view.insertSubview(screenView, belowSubview: topView)
        
        screenView?.snp.makeConstraints({ (make) in
            make.top.equalTo(topView.snp.bottom)
            make.right.left.bottom.equalToSuperview()
        })
        
        screenView.selectedBlock = { [weak self] (categoryType,title) in
            
            switch self?.screenType {
            case 1:
                self?.caseStyle = categoryType
            case 2:
                self?.houseType = categoryType
            case 3:
                self?.houseArea = categoryType
            default: break
                
            }
            self?.changeBtnNormalStatus(title!)
            self?.headerRefresh()
        }
        
        screenView.hiddeBlock = { [weak self] in
            let btn = self?.topView.viewWithTag((self?.topSelectBtnTag)!) as! UIButton
            if btn.isSelected == true {
                btn.isSelected = false
            }

        }
    }
    
    func prepareVillageView() {
        
        //筛选
        communityView = CaseVillageView()
        view.insertSubview(communityView, belowSubview: topView)
        communityView?.snp.makeConstraints({ (make) in
            make.top.equalTo(topView.snp.bottom)
            make.right.left.bottom.equalToSuperview()
        })

        communityView.selectedBlock = { [weak self] (community) in
            
            if community != nil {
                self?.communityId = community?.communityId
                self?.communityName = community?.communityName
                if let nameStr = community?.communityName {
                    self?.communityBtn.set(image: UIImage.init(named: "wholeHouse_down_o"), title: nameStr, imagePosition: .right, additionalSpacing: 5, state: .normal)
                }
                self?.communityBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
                self?.communityBtn.setImage(UIImage.init(named: "wholeHouse_down_o"), for: .normal)
            }else {
                self?.communityId = nil
                self?.communityName = nil
                self?.communityBtn.set(image: UIImage.init(named: "wholeHouse_down"), title: "小区", imagePosition: .right, additionalSpacing: 5, state: .normal)
                self?.communityBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
                
            }
          
            self?.headerRefresh()
        }
        
        communityView.hiddeBlock = { [weak self] in
           self?.communityBtn.isSelected = false
        }
    }
    
    func prepareTopView() {
        topView = UIView()
        topView.backgroundColor = .white
        view.addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            make.right.left.top.equalToSuperview()
            make.height.equalTo(44)
        }
        
        
        let titels = ["风格","户型","面积"]
        let w = (PublicSize.screenWidth-15)/CGFloat(titels.count)
        
        //小区按钮
        communityBtn = UIButton(type: .custom)
        communityBtn.tag = 2000
        communityBtn.frame = CGRect(x:7.5, y: 0, width: w, height: 44)
        communityBtn.addTarget(self, action: #selector(communityClickAction(_:)), for: .touchUpInside)
        communityBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        communityBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
        communityBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
        communityBtn.setImage(UIImage.init(named: "wholeHouse_up_o"), for: .selected)
        communityBtn.titleLabel?.lineBreakMode = .byTruncatingTail
        topView.addSubview(communityBtn)
        communityBtn.isHidden = true
        
        communityBtn.set(image: UIImage.init(named: "wholeHouse_down"), title: "小区", imagePosition: .right, additionalSpacing: 5, state: .normal)
        
        
        for (i,titel) in titels.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = 1000 + i
            btn.frame = CGRect(x:7.5 + w * CGFloat(i), y: 0, width: w, height: 44)
            btn.addTarget(self, action: #selector(topClickAction(_:)), for: .touchUpInside)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.setTitleColor(PublicColor.commonTextColor, for: .normal)
            btn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
            btn.setImage(UIImage.init(named: "wholeHouse_up_o"), for: .selected)
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            topView.addSubview(btn)
            
            btn.set(image: UIImage.init(named: "wholeHouse_down"), title: titel, imagePosition: .right, additionalSpacing: 5, state: .normal)
            
            if i == 0 {
                topSelectBtnTag = btn.tag
            }
        }
        
        let line = UIView()
        line.backgroundColor = PublicColor.navigationLineColor
        topView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    //tabview
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 246*PublicSize.RateWidth
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WholeHouseCaseCell.self, forCellReuseIdentifier: identifier)
        view.insertSubview(tableView, at: 0)
        
        tableView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        tableView.mj_footer = footer
        tableView.mj_footer?.isHidden = true
    }
    
    
    //MARK: 按钮点击
    @objc func topClickAction(_ sender:UIButton) {
        
        if communityView.isHidden == false {
            communityView?.isHidden = true
            communityView!.animateIsHidden(true)
            communityView!.opacityView.alpha = 0
        }
        
        if topSelectBtnTag == sender.tag {
            if screenView?.isHidden == false {
                screenView.hiddenMenu()
                sender.isSelected = false
            }else {
                screenView.showMenu()
                sender.isSelected = true
            }
        }else {
            
            let btn = topView.viewWithTag(topSelectBtnTag) as! UIButton
            btn.isSelected = false
            
            if screenView?.isHidden == false {
                screenView?.isHidden = true
                screenView.animateIsHidden(true)
                screenView!.opacityView.alpha = 0
            }
            sender.isSelected = true
            screenView.showMenu()
        }
        self.screenType = sender.tag - 1000 + 1
        switch self.screenType {
        case 1:
            screenView.categoryIndex = caseStyle
        case 2:
            screenView.categoryIndex = houseType
        case 3:
            screenView.categoryIndex = houseArea
        default: break
            
        }
        screenView.screenType = self.screenType
        topSelectBtnTag = sender.tag
      
        if communityBtn.isSelected == true {
            communityBtn.isSelected = false
        }
    }
    //改变按钮显示状态
    func changeBtnNormalStatus(_ title : String) {
        let btn = topView.viewWithTag(topSelectBtnTag) as! UIButton
        btn.set(image: UIImage.init(named: "wholeHouse_down"), title: title, imagePosition: .right, additionalSpacing: 5, state: .normal)
        if self.topSelectBtnTag == 1000 {
            if self.caseStyle != nil {
                btn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
                btn.setImage(UIImage.init(named: "wholeHouse_down_o"), for: .normal)
            }else {
                btn.setTitle("风格", for: .normal)
                btn.setTitleColor(PublicColor.commonTextColor, for: .normal)
                btn.setImage(UIImage.init(named: "wholeHouse_down"), for: .normal)
            }
        }else if self.topSelectBtnTag == 1001 {
            if self.houseType != nil {
                btn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
                btn.setImage(UIImage.init(named: "wholeHouse_down_o"), for: .normal)
            }else {
                btn.setTitle("户型", for: .normal)
                btn.setTitleColor(PublicColor.commonTextColor, for: .normal)
                btn.setImage(UIImage.init(named: "wholeHouse_down"), for: .normal)
            }
        }else if self.topSelectBtnTag == 1002 {
            if self.houseArea != nil {
                btn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
                btn.setImage(UIImage.init(named: "wholeHouse_down_o"), for: .normal)
            }else {
                btn.setTitle("面积", for: .normal)
                btn.setTitleColor(PublicColor.commonTextColor, for: .normal)
                btn.setImage(UIImage.init(named: "wholeHouse_down"), for: .normal)
            }
        }
    }
    
    //小区选择按钮
    @objc func communityClickAction(_ sender:UIButton) {
        if screenView.isHidden == false {
            let btn = self.topView.viewWithTag((self.topSelectBtnTag)!) as! UIButton
            if btn.isSelected == true {
                btn.isSelected = false
            }
            screenView?.isHidden = true
            screenView.animateIsHidden(true)
            screenView!.opacityView.alpha = 0
        }
        
        sender.isSelected = !sender.isSelected
        
        if communityView.isHidden == true {
            communityView.showMenu()
        }else {
            communityView.hiddenMenu()
        }
    }
    //取消搜索
    @objc func cancelSearchAction() {
        
        AppLog("点击了取消搜索")
        maskBtn.isHidden = true
        searchBar.resignFirstResponder()
    }
    
    //MARK: 加载数据
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        curPage = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        
        if rowsData.count > 0 {
            curPage += 1
        }
        else {
            curPage = 1
        }
        loadData()
    }
    
    func loadData() {
        
        var storeId = ""
        
        if let valueStr = UserData.shared.storeModel?.id {
            storeId = valueStr
        }
        AppLog("店铺id: "+storeId)
        
        let pageSize = 20
        
        var parameters: Parameters = ["userId": storeId, "size": "\(pageSize)", "current": "\(self.curPage)","caseRemarks": searchName]

        if communityId != nil {
            parameters["communityId"] = communityId
        }
        if communityName != nil {
            parameters["communityName"] = communityName
        }
        if caseStyle != nil {
            parameters["caseStyle"] = caseStyle
        }
        if houseType != nil {
            parameters["houseType"] = houseType
        }
        if houseArea != nil {
            parameters["houseArea"] = houseArea
        }
        if citySubstation != nil {
            parameters["citySubstation"] = citySubstation
            parameters["userId"] = userId
        } else {
           parameters["citySubstation"] = UserData.shared.substationModel?.id
        }
        
        let urlStr = APIURL.getHouseCase
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            self.spinnerStop()
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            self.tableView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<HouseCaseModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if self.curPage > 1 {
                    self.rowsData += modelArray
                }
                else {
                    self.rowsData = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.tableView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.rowsData.removeAll()
                
            }
            
            self.tableView.reloadData()
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.noDataView.isHidden = true
            }
            
        }) { (error) in
            self.spinnerStop()
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            
            if self.rowsData.count <= 0 {
                self.tableView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                
                self.tableView.mj_footer?.isHidden = false
                self.noDataView.isHidden = true
            }
        }
    }
    
    //MARK: - tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! WholeHouseCaseCell
        
        if indexPath.row < rowsData.count {
            let caseModel = rowsData[indexPath.row]
            cell.setModelWithTableView(caseModel, tableView)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let caseModel = rowsData[indexPath.row]
        let image = UIImage.init(named: "loading_vr")
        let width = PublicSize.screenWidth
        let height = image!.size.height * (width / image!.size.width)
        if let mainImgUrl = caseModel.mainImgUrl1 {
            let imgUrlStr = APIURL.ossPicUrl + "/" + mainImgUrl
            let imageUrl = URL(string: imgUrlStr)
            if let url = imageUrl {
                return XHWebImageAutoSize.imageHeight(for: url, layoutWidth: width-20, estimateHeight: height)+76+10
            }
        }
        //图片尺寸处理
        return height + 76 + 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = WholeHouseDetailController()
        if let url = rowsData[indexPath.row].url {
            vc.detailUrl = url
        }
        vc.caseModel = self.rowsData[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
        
       
    }

    //MARK: - SearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        AppLog("searchBar: \(searchText)")
        performSearch(with: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        maskBtn.isHidden = false
        
        if screenView?.isHidden == false {
            screenView.hiddenMenu()
        }
        if communityView.isHidden == false {
             communityView.hiddenMenu()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        maskBtn.isHidden = true
    }
    
    // 搜索触发事件，点击虚拟键盘上的search按钮时触发此方法
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        performSearch(with: searchBar.text!)
    }
    
    // 取消按钮触发事件
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // 搜索内容置空
        spinnerStop()
        searchName = ""
        searchBar.text = ""
        headerRefresh()
        searchBar.resignFirstResponder()
    }
    
    //搜索框输入文字的时候自动搜索
    let intervalGuard = ActionIntervalGuard()
    
    func performSearch(with searchText: String) {
        
        if searchText.count >= 0 {
            
            searchName = searchText
            intervalGuard.perform(interval: 0.6) {[weak self] in
                guard let this = self else { return }
                this.spinnerStart()
                this.headerRefresh()
            }
            
        }else{
            spinnerStop()
        }
    }
    
    //活动指示器动画
    func spinnerStart() {
        spinner.startAnimating()
        searchBar.setImage(UIImage(), for: .search, state: .normal)
    }
    
    func spinnerStop() {
        spinner.stopAnimating()
        searchBar.setImage(UIImage(named: "icon_searchBar"), for: .search, state: .normal)
    }
}
