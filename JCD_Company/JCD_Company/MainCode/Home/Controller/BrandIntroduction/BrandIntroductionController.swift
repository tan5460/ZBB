//
//  BrandIntroductionController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/12/6.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper

class BrandIntroductionController: BaseViewController, UITableViewDataSource, UITableViewDelegate{
    var isFz: Int?
    var sortArray:Array<String> = []
    var nomorlSorts = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "#"]
    var rowData:[String:Array<MerchantModel>] = [:]
    var tableView: UITableView!
    
    let identifier = "BrandIntroductionCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "品牌馆"
        prepareTableView()
        tableView.mj_header?.beginRefreshing()
    }
    
    //tabview
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(BrandIntroductionCell.self, forCellReuseIdentifier: identifier)
        view.insertSubview(tableView, at: 0)
        
        tableView.snp.makeConstraints { (make) in
            make.right.top.left.bottom.equalToSuperview()

        }
        
        // 下拉刷新
        tableView.refreshHeader { [weak self] in
            self?.loadMerchantData()
        }
        
        let indexViewConfiguration = SCIndexViewConfiguration(
            indexViewStyle: .centerToast,
            indicatorBackgroundColor: UIColor(white: 0, alpha: 0.3),
            indicatorTextColor: .white,
            indicatorTextFont: UIFont.systemFont(ofSize: 40),
            indicatorHeight: 60,
            indicatorRightMargin: 40,
            indicatorCornerRadius: 5,
            indexItemBackgroundColor: .clear,
            indexItemTextColor: PublicColor.minorTextColor,
            indexItemSelectedBackgroundColor: .clear,
            indexItemSelectedTextColor: PublicColor.emphasizeTextColor,
            indexItemHeight: 15,
            indexItemRightMargin: 5,
            indexItemsSpace: 0)
        tableView.sc_indexViewConfiguration = indexViewConfiguration
        tableView.sc_indexViewDataSource = nomorlSorts
    }
    
    //MARK: - 网络请求
    
    /// 获取材料商  系统品牌
    @objc func loadMerchantData() {
        
        
        var substationId = ""
        if let valueStr = UserData.shared.substationModel?.id {
            substationId = valueStr
            
        }
        var parameters: Parameters = ["substationId":substationId]
        parameters["isFz"] = isFz
        self.clearAllNotice()
        self.pleaseWait()
        let urlStr = APIURL.getMerchant
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<MerchantModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.rowData.removeAll()
                self.sortArray.removeAll()
                self.dealwithData(modelArray)
              
            }else {
                self.tableView.mj_header?.endRefreshing()
            }
            
        }) { (error) in
            self.tableView.mj_header?.endRefreshing()
        }
    }
    //处理数据
    func dealwithData(_ array:Array<MerchantModel>) {
        for model in array {
            if let name = model.brandName {
                if name.count > 0 {
                    let str = NSMutableString.init(string: name) as CFMutableString
                    // 转换为带音标的拼音
                    CFStringTransform(str,nil, kCFStringTransformToLatin, false)
                    // 去掉音标
                    if CFStringTransform(str, nil, kCFStringTransformStripCombiningMarks, false) {
                        
                        //字符串截取第一位，并转换成大写字母
                        var firstStr =  ((str as NSString).substring(to: 1)).uppercased()
                        
                        //判断字母
                        let ZIMU = "^[A-Za-z]+$"
                        let regextest = NSPredicate(format: "SELF MATCHES %@", ZIMU)
                        //如果不是字母开头的，转为＃
                        if !regextest.evaluate(with: firstStr) {
                            firstStr = "#"
                        }
                        //如果还没有索引
                        if sortArray.count <= 0 {
                            //保存当前这个做索引
                            sortArray.append(firstStr)
                            //用这个字母做字典的key，将当前的model保存到key对应的数组里面去
                            let arr = [model]
                            rowData[firstStr] = arr
                        }else {
                            //如果索引里面包含了当前这个字母，直接保存数据
                            if sortArray.contains(firstStr) {
                                //取索引对应的数组，保存当前model到数组里面
                                if var arr = rowData[firstStr] {
                                    
                                    arr.append(model)
                                    //重新保存数据
                                    rowData[firstStr] = arr
                                }
                    
                            } else {
                                //如果没有包含，说明是新的索引
                                sortArray.append(firstStr)
                                //用这个字母做字典的key，将当前的model保存到key对应的数组里面去
                                let arr = [model]
                                rowData[firstStr] = arr
                            }
                        }
                        
                    }
                }
            }
        }
    
        //字母排序
        sortArray.sort()
        
        //刷新数据
//        tableView.sc_indexViewDataSource = self.sortArray
        tableView.reloadData()
        tableView.mj_header?.endRefreshing()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
//        let str = self.sortArray[section]
        let str = nomorlSorts[section]
        if let arr = rowData[str] {
            if arr.count <= 0 {
                return 1
            }
            return arr.count
        }
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let str = nomorlSorts[indexPath.section]
        if let arr = rowData[str] {
            if arr.count <= 0 {
                return 0
            }
            return 60
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BrandIntroductionCell
//        let str = self.sortArray[indexPath.section]
        let str = nomorlSorts[indexPath.section]
        if let arr = rowData[str] {
            cell.bImageView.isHidden = false
            cell.titleLabel.isHidden = false
            cell.merchantModel = arr[indexPath.row]
          
        }else {
            cell.bImageView.isHidden = true
            cell.titleLabel.isHidden = true
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let str = nomorlSorts[indexPath.section]
        if let model = rowData[str]?[indexPath.row], let idStr = model.id, let url = model.url {
            let urlStr = APIURL.ossPicUrl + url
            let vc = BrandDetailController()
            vc.title = "品牌介绍"
            vc.brandId = idStr
            vc.detailUrl = urlStr
            vc.brandName = model.brandName
            vc.brandType = model.brandType
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            noticeOnlyText("该品牌无详情介绍")
        }
    }
    
    // section分组
    func numberOfSections(in tableView: UITableView) -> Int {
        return nomorlSorts.count
    }
    
    // section分组标题（通常与索引值数组相同）
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView()
        headView.backgroundColor = PublicColor.backgroundViewColor
        
        let titleLabel = UILabel(frame: CGRect(x: 14, y: 0, width: 100, height: 15))
        titleLabel.text = nomorlSorts[section]
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        titleLabel.textColor = PublicColor.minorTextColor
        headView.addSubview(titleLabel)
        
        return headView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let str = nomorlSorts[section]
        if let arr = rowData[str] {
            if arr.count <= 0 {
                return 0
            }
            return 15
        }
        return 0
    }
}
