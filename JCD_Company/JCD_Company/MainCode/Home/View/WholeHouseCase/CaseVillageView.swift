//
//  CaseVillageView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/6.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class CaseVillageView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    var opacityView: UIView!
    var menuView: UIView!
    var menuViewHeight = 44 * 3
    
    var tableView: UITableView!
    var rowData : Array<HouseCaseModel>!          //小区model
    var selectVillage : HouseCaseModel!          //选择的小区
   
    
    var selectedBlock: ((_ plotModel: HouseCaseModel?)->())?
    
    var hiddeBlock: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isHidden = true
    
        rowData = []
        loadVillageList()
        
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
            make.height.equalTo(menuViewHeight)
            make.left.right.top.equalToSuperview()
        }
        
        tableView = UITableView()
        tableView.estimatedRowHeight = 44
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = PublicColor.partingLineColor
        tableView.tableFooterView = UIView()
        tableView.showsVerticalScrollIndicator = false
        menuView.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.left.top.bottom.right.equalToSuperview()
        }
        self.animateIsHidden(true)
    }
    
    //弹出菜单
    func showMenu() {
        
        self.isHidden = false
        opacityView.alpha = 0

        UIView.animate(withDuration: 0.2, animations: {
            
            self.opacityView.alpha = 1
 
            self.animateIsHidden(false)
        }) { (finished) in
            
        }
        
        
    }
    
    //隐藏菜单
    @objc func hiddenMenu() {
        
        if hiddeBlock != nil {
            self.hiddeBlock!()
        }
        UIView.animate(withDuration: 0.2, animations: {
            
            self.animateIsHidden(true)
            self.opacityView.alpha = 0
            
        }) { (finished) in
            self.isHidden = true
        }
    }
    
    func animateIsHidden(_ isHid:Bool) {
        if isHid == false {
            self.menuView.transform = CGAffineTransform.identity
        }else {
            self.menuView.transform = CGAffineTransform.identity
                .translatedBy(x: 0, y: CGFloat(-self.menuViewHeight))
            
        }
    }
   
    
    //MARK: - 网络请求
    
    /// 获取小区
    func loadVillageList() {
        
        var storeID = ""
        if let valueStr = UserData.shared.storeModel?.id {
            storeID = valueStr
        }
        
        let parameters: Parameters = ["userId": storeID, "pageSize": "500"]
        
        self.clearAllNotice()
//        self.pleaseWait()
        let urlStr = APIURL.getCaseCommunityList
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<HouseCaseModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                
                self.rowData = modelArray
                if self.rowData.count > 0 {
                    var cout = self.rowData.count + 1
                    if cout > 7 {
                        cout = 7
                    }
                    self.menuViewHeight = cout * 44
            
                    self.menuView.snp.updateConstraints({ (make) in
                        make.height.equalTo(self.menuViewHeight)
                    })
                }
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
            
            self.tableView.reloadData()
        }
    }
    
   
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowData!.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "tableViewCell")
        cell.selectionStyle = .none
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.textColor = PublicColor.commonTextColor
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "不限"
            if selectVillage == nil {
               cell.textLabel?.textColor = PublicColor.emphasizeTextColor
            }
        }else if indexPath.row < rowData.count+1 {
            
            let model = rowData[indexPath.row-1]
            cell.textLabel?.text = ""
            
            if let name = model.communityName {
                cell.textLabel?.text = name
            }
            if selectVillage != nil {
                
                if model.communityId == selectVillage.communityId {
                    
                    cell.textLabel?.textColor = PublicColor.emphasizeTextColor
                }
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            selectVillage = nil
        }else {
            
            selectVillage = self.rowData[indexPath.row-1]
        }
        
        if selectedBlock != nil {
            
            selectedBlock!(selectVillage)
        }
        hiddenMenu()
        
        tableView.reloadData()
        
    }

}
