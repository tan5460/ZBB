//
//  BrandView.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/19.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class BrandFiltrateView: UIView,UITableViewDelegate,UITableViewDataSource {
    
    var opacityView: UIView!
    var menuView: UIView!
    
    var tableView1: UITableView!               //全部品牌table
    var merchantData : Array<BrandListItem>! {
        didSet {
            selectMercant = BrandListItem()
            selectMercant.id = ""
            selectMercant.brandId = ""
            selectMercant.brandName = "全部品牌"
            merchantData.insert(selectMercant, at: 0)
        }
    }     //品牌model
    var normalSelectMercant : BrandListItem!     //默认选择的品牌
    var selectMercant : BrandListItem!          //选择的品牌
 
    var isReset : Bool = false         //是否重置
    
    var selectedBlock: ((_ merchantModel: BrandListItem?)->())?
    
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
            make.edges.equalToSuperview()
        }
        
        self.menuView.transform = CGAffineTransform.identity
            .translatedBy(x: 0, y: -130)
            .scaledBy(x: 1, y: 0.01)
    }
    
    //弹出菜单
    func showMenu() {
        
        self.isHidden = false
        opacityView.alpha = 0
        
//        selectMercant = normalSelectMercant
        self.scrolltoSelectMercant()
       
        
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
        
    }
    
    //重置
    @objc func resetAction() {
        
        selectMercant = BrandListItem()
        selectMercant.id = ""
        selectMercant.brandId = ""
        selectMercant.brandName = "全部品牌"
        
        isReset = true
    
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
            
            
        }else {
            if self.merchantData.count > 0 {
                
                self.tableView1.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .middle, animated: true)
            }
            
        }
        
        
        
        isReset = false
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
        
        if let block = selectedBlock {
            block(selectMercant)
        }
        hiddenMenu()
    }
    
    
}
