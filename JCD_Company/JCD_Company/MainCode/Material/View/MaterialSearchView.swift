//
//  MaterialSearchView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/20.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog

class MaterialSearchView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, LabelWaterAlignedLayoutDelegate {
   
    var collectionView: UICollectionView!
    
    var searchString: String! = ""                  //搜索
    var searchData:Array<String> = []
    var deleteBtn: UIButton!
    var searchHistoryKey = "MaterialSearchHistory"     //历史搜索缓存key
    
    var searchBlock: ((_ searchString: String)->())?
    
    var identifier = "filterCell"
    
    
    deinit {
        debugPrint("\(type(of: self).className) 释放了")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    init(frame: CGRect, searchType: SearchType) {
        super.init(frame: frame)
        
        //读取历史记录数据
        var data: Array<String> = []
        
        switch searchType {
        case .material:
            searchHistoryKey = "MaterialSearchHistory"
        case .purchMaterial:
            searchHistoryKey = "purchMaterialSearchHistory"
        case .cgMaterial:
            searchHistoryKey = "cgMaterialSearchHistory"
        case .jzPurchase:
            searchHistoryKey = "jzPurchaseSearchHistory"
        case .gysPurchase:
            searchHistoryKey = "gysPurchaseSearchHistory"
        case .yysPurchase:
            searchHistoryKey = "yysPurchaseSearchHistory"
        case .brand:
            searchHistoryKey = "jzBrandSearchHistory"
        case .newMaterial:
            searchHistoryKey = "newMaterialSearchHistory"
        case .distProduction:
            searchHistoryKey = "distProductionHistory"
        }
        
        if let dataArray = UserDefaults.standard.object(forKey: searchHistoryKey) as? Array<String> {
            data = dataArray
        }
        
        searchData = data
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        self.backgroundColor = .white
   
        let titleLabel = UILabel()
        titleLabel.text = "搜索历史"
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = PublicColor.commonTextColor
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints({ (make) in
            make.top.left.equalTo(16)
            make.height.equalTo(14)
        })
       
        //删除
        deleteBtn = UIButton()
        deleteBtn.setImage(UIImage(named: "delete_icon"), for: .normal)
        deleteBtn.addTarget(self, action: #selector(deleteHistory), for: .touchUpInside)
        self.addSubview(deleteBtn)
        
        deleteBtn.snp.makeConstraints({ (make) in
            make.right.equalTo(0)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(60)
        })
        if searchData.count > 0 {
            deleteBtn.isHidden = false
        }else {
            deleteBtn.isHidden = true
        }
        
        //collectionView
        let layout = LabelWaterAlignedLayout()
        layout.delegate = self
        layout.edgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.alpha = 0
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "collectionHeader")
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.collectionView.reloadData()
            self.collectionView.alpha = 1
        }
    }
    
    /// 更新本地缓存
    func updateHistory(_ searchString: String) {
        
        //缓存到历史记录
        if let index = searchData.firstIndex(of: searchString) {
            searchData.remove(at: index)
        }

        searchData.insert(searchString, at: 0)
        UserDefaults.standard.set(searchData, forKey: searchHistoryKey)
        collectionView.reloadData()
    }
    
    /// 删除记录
    @objc func deleteHistory() {
        if searchData.count == 0 {return}
        if let vc = self.viewController() {
            
            let popup = PopupDialog(title: "", message: "确定删除全部历史记录",buttonAlignment: .horizontal)
            let sureBtn = DestructiveButton(title: "确定") {
                self.searchData.removeAll()
                UserDefaults.standard.set(self.searchData, forKey: self.searchHistoryKey)
                self.collectionView.reloadData()
                self.deleteBtn.isHidden = true
            }
            let cancelBtn = CancelButton(title: "取消") {
            }
            popup.addButtons([cancelBtn,sureBtn])
            vc.present(popup, animated: true, completion: nil)
        }else {
            searchData.removeAll()
            UserDefaults.standard.set(searchData, forKey: searchHistoryKey)
            collectionView.reloadData()
        }
        
    }
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return searchData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FilterCell
        cell.titleLable.textColor = PublicColor.minorTextColor
        let titleStr = searchData[indexPath.row]
        cell.titleLable.text = titleStr
        
//        if searchString == titleStr {
//            cell.isSelect = true
//        }else {
//            cell.isSelect = false
//        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        searchString = searchData[indexPath.row]
        
        collectionView.reloadData()
        
        if searchBlock != nil {
            searchBlock!(searchString)
        }
    }
    
    func leftWaterAligned(_ waterFlow: LabelWaterAlignedLayout?, widthForItemAt indexPath: IndexPath?) -> CGFloat {
        let titleStr = searchData[indexPath!.row]
        return titleStr.getLabWidth(font: UIFont.systemFont(ofSize: 13)) + 20
    }


}
