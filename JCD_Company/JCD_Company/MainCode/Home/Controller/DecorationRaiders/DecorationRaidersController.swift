//
//  DecorationRaidersController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/12/7.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import MJRefresh
import Alamofire
import ObjectMapper
import Kingfisher

class DecorationRaidersController: BaseViewController, UITableViewDataSource, UITableViewDelegate{
    
    var topBarView: UIView!                             //顶部条
    var topScrollerView: UIScrollView!                  //顶部滚动视图
    var followView: UIView!                             //跟随条
    var contentScrollerView: UIScrollView!              //内容h滚动视图
    var isClickButton = false                           //是否是点击按钮改变按钮状态

    var selectModel:DecorationRaiderModel?

    let identifier = "DecorationRaidersCell"
    
    lazy var rowsData:Array<DecorationRaiderModel> = {

        return Mapper<DecorationRaiderModel>().mapArray(JSONObject: AppData.yzbStrategyList) ?? []
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "工艺展示"

        prepareScrollerView()
        prepareContentView()
    }
    
    func prepareScrollerView() {
        
        //顶部条
        topBarView = UIView()
        topBarView.backgroundColor = .white
        topBarView.layer.shadowColor = UIColor.colorFromRGB(rgbValue: 0x000000,alpha:0.12).cgColor
        topBarView.layer.shadowOffset = CGSize(width: 0, height: 1)
        topBarView.layer.shadowOpacity = 0.8
        topBarView.layer.shadowRadius = 2
        view.addSubview(topBarView)
        
        topBarView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        //滚动视图
        topScrollerView = UIScrollView()
        topScrollerView.delegate = self
        topScrollerView.showsVerticalScrollIndicator = false
        topScrollerView.showsHorizontalScrollIndicator = false
        topScrollerView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        topBarView.addSubview(topScrollerView)
        
        topScrollerView.snp.makeConstraints { (make) in
            make.left.top.bottom.right.equalToSuperview()
        }
        
        //跟随条
        followView = UIView()
        followView.backgroundColor = PublicColor.emphasizeTextColor
        
        //列表滚动视图
        contentScrollerView = UIScrollView()
        contentScrollerView.delegate = self
        contentScrollerView.showsVerticalScrollIndicator = false
        contentScrollerView.showsHorizontalScrollIndicator = false
        contentScrollerView.isPagingEnabled = true
        view.insertSubview(contentScrollerView, at: 0)
        
        contentScrollerView.snp.makeConstraints { (make) in
            make.top.equalTo(topBarView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    func prepareContentView() {
        
        topScrollerView.addSubview(followView)
        topScrollerView.contentOffset = CGPoint(x: -10, y: 0)
        contentScrollerView.contentOffset = CGPoint.zero
        
        //循环创建
        var sumWidth: CGFloat = 0
        for (i, model) in rowsData.enumerated() {
            
            let topFont = UIFont.systemFont(ofSize: 14)
            let topWidth = model.label!.getLabWidth(font: topFont) + 30
            //房间按钮
            let topBtn = UIButton.init(frame: CGRect(x: sumWidth, y: 0, width: topWidth, height: 44))
            topBtn.tag = 100+i
            topBtn.titleLabel?.font = topFont
            topBtn.setTitle(model.label, for: .normal)
            topBtn.setTitleColor(PublicColor.commonTextColor, for: .normal)
            topBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .selected)
            topBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0xB3B3B3), for: .highlighted)
            topBtn.addTarget(self, action: #selector(topBtnAction), for: .touchUpInside)
            topScrollerView.addSubview(topBtn)
            
            model.button = topBtn
            sumWidth += topWidth
           
            //内容列表
            let bgView = UIView()
            contentScrollerView.addSubview(bgView)
            
            bgView.snp.makeConstraints { (make) in
                make.top.height.bottom.equalToSuperview()
                make.width.equalTo(PublicSize.screenWidth)
                make.left.equalToSuperview().offset(PublicSize.screenWidth*CGFloat(i))
                if i == rowsData.count - 1 {
                    make.right.equalToSuperview()
                }
            }
            
            let tableView = UITableView()
            tableView.backgroundColor = UIColor.clear
            tableView.rowHeight = 100
            tableView.separatorStyle = .none
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(DecorationRaidersCell.self, forCellReuseIdentifier: identifier)
            bgView.insertSubview(tableView, at: 0)
            
            tableView.snp.makeConstraints { (make) in
                make.right.top.left.bottom.equalToSuperview()
                
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
            
            model.tableview = tableView
            
            if i == 0 {
                topBtn.isSelected = true
                followView.frame = CGRect(x: 0, y: topBtn.bottom-2, width: topWidth-14, height: 2)
                followView.centerX = topBtn.centerX
                selectModel = model
            }
            
            if i == rowsData.count-1 {
                topScrollerView.contentSize = CGSize(width: topBtn.right, height: 0)
            }
        }
        selectModel?.tableview?.mj_header?.beginRefreshing()
    }
    //MARK: - 按钮的点击
    @objc func topBtnAction(_ sender: UIButton) {
    
        isClickButton = true
        
        switchRoomScrollerBtn(switchTag: sender.tag-100, isClick: true)
    }
    //切换房间按钮动画
    func switchRoomScrollerBtn(switchTag: Int, isClick: Bool=false) {
        
        if let btn = selectModel?.button {
            
            if btn.tag-100 == switchTag {return}
        }
        
        if let oldRoomBtn = selectModel?.button {
            
            oldRoomBtn.isSelected = false
            selectModel = rowsData[switchTag]
            
            let newRoomBtn = selectModel?.button
            newRoomBtn?.isSelected = true
        
            //选中项初始化值
            if  let raiders = selectModel?.raiders {
                
                if raiders.count <= 0 {
                    selectModel?.tableview?.mj_header?.beginRefreshing()
                }
            }
           //右边滑动上限
            let rightOffset = topScrollerView.contentSize.width - newRoomBtn!.centerX
            
            //需要偏移量
            let btnOffset = newRoomBtn!.centerX - PublicSize.screenWidth/2
            
            UIView.animate(withDuration: 0.3, animations: {
                self.followView.width = newRoomBtn!.width-14
                self.followView.centerX = newRoomBtn!.centerX
                
                if btnOffset < 0 || self.topScrollerView.contentSize.width <= self.topScrollerView.width {
                    //左上限
                    self.topScrollerView.contentOffset = CGPoint(x: -10, y: 0)
                }
                else if rightOffset > PublicSize.screenWidth/2 {
                    //中间
                    self.topScrollerView.contentOffset = CGPoint(x: btnOffset, y: 0)
                }
                else {
                    //右上限
                    self.topScrollerView.contentOffset = CGPoint(x: self.topScrollerView.contentSize.width-self.topScrollerView.width, y: 0)
                }
                
                if isClick {
                    self.contentScrollerView.contentOffset = CGPoint(x: CGFloat(switchTag)*PublicSize.screenWidth, y: 0)
                }
                
            }) { (finish) in
                self.isClickButton = false
            }
        }
    }
    //MARK: - 网络请求
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        if let model = selectModel {
            
            model.page = 1
            loadData(model)
        }
        
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        
        if let model = selectModel {
            if model.raiders.count > 0 {
                model.page += 1
            }
            else {
                model.page = 1
            }
            loadData(model)
        }
       
    }
    
    func loadData(_ model:DecorationRaiderModel) {
        
        var storeId = ""
        
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeId = valueStr
        }
        
        AppLog("店铺id: "+storeId)
        
        let pageSize = 20
        
        var category = "0"
        if let varlue = model.value {
           category = varlue
        }
        
        let parameters: Parameters = ["store.id": storeId, "pageSize": "\(pageSize)", "pageNo": "\(model.page)","category":category]
        
        let urlStr = APIURL.raidersList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            // 结束刷新
            model.tableview!.mj_header?.endRefreshing()
            model.tableview!.mj_footer?.endRefreshing()
            model.tableview!.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" || errorCode == "015" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<DecorationModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                if model.page > 1 {
                    for i in modelArray {
                        model.raiders.append(i)
                    }
                }
                else {
                    model.raiders = modelArray
                }
               
            }else if errorCode == "008" {
                model.raiders.removeAll()
                
            }
            if model.raiders.count < pageSize {
                model.tableview!.mj_footer?.endRefreshingWithNoMoreData()
            }else {
                model.tableview!.mj_footer?.resetNoMoreData()
            }
            model.tableview!.reloadData()

        }) { (error) in
            
            // 结束刷新
            model.tableview!.mj_header?.endRefreshing()
            model.tableview!.mj_footer?.endRefreshing()

        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let model = selectModel {
           return model.raiders.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DecorationRaidersCell
        if let model = selectModel {
            
            cell.drModel = model.raiders[indexPath.row]
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let model = selectModel {
            
            let model = model.raiders[indexPath.row]
            if let idStr = model.id {
                
                let urlStr = APIURL.raidersDetail + idStr
                let vc = BrandDetailController()
                vc.title = model.title
//                vc.isShare = true
                if let imgUrl = model.imgUrl {
                   vc.shareImgUrl = APIURL.ossPicUrl + "/" + imgUrl
                }
                vc.detailUrl = urlStr
                navigationController?.pushViewController(vc, animated: true)
                
            }
           
        }
        
    }
    
    //MARK: - scrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == contentScrollerView {
            
            //滑动偏移量
            let offsetX = scrollView.contentOffset.x
            if offsetX<=0 {return}
            
            //点击按钮不计算偏移量
            if isClickButton == true {return}
            
            //计算需要下一个按钮tag
            var tag = 0
            if offsetX >= PublicSize.screenWidth/2 {
                tag = Int((offsetX - PublicSize.screenWidth/2) / PublicSize.screenWidth + 1)
            }
            if tag >= rowsData.count {return}
            
            switchRoomScrollerBtn(switchTag: tag)
        }
    }
}
