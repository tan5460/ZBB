//
//  FiltrateTableView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/9.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

protocol FiltrateTableViewDelegate {
    func filtrateTabelView(_ fTabelView : FiltrateTableView, didSelectRowAt indexPath: IndexPath, didSelectModelAt selectModel: BrandHouseModel?)
}

class FiltrateTableView: UITableView,UITableViewDataSource,UITableViewDelegate {

    var selectRowBgColor : UIColor!
    var normalRowBgColor : UIColor!
 
    var normalSelectCategory : BrandHouseModel?
    var selectCategory : BrandHouseModel?
    var rowData : [BrandHouseModel]! {
        didSet {
            let cate = BrandHouseModel()
            cate.categoryName = "全部"
            cate.categoryId = ""
            rowData.insert(cate, at: 0)
            self.reloadData()
        }
    }
    
    var filtrateTBDelegata : FiltrateTableViewDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.dataSource = self
        self.delegate = self
        self.separatorStyle = .none
        self.bounces = false
        self.showsVerticalScrollIndicator = false
        
        self.rowData = []
        
        self.selectRowBgColor = UIColor.colorFromRGB(rgbValue: 0xEDEDED)
        self.normalRowBgColor = UIColor.colorFromRGB(rgbValue: 0xE5E3E3)
        
        self.backgroundColor = UIColor.white
  
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowData!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "tableViewCell")
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = normalRowBgColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
        cell.textLabel?.textColor = PublicColor.commonTextColor
        cell.textLabel?.numberOfLines = 2
        
        let cellModel = rowData[indexPath.row]
        cell.textLabel?.text = cellModel.categoryName
        
        if cellModel.categoryId == selectCategory?.categoryId {
            cell.contentView.backgroundColor = selectRowBgColor
            cell.textLabel?.textColor = PublicColor.emphasizeTextColor
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 
        let cellModel = self.rowData[indexPath.row]
        selectCategory = cellModel
   
        if filtrateTBDelegata != nil {
            filtrateTBDelegata?.filtrateTabelView(self, didSelectRowAt: indexPath, didSelectModelAt: selectCategory)
        }
        tableView.reloadData()
    }
    
}
