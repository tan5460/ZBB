//
//  WholeHouseScreenView.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/2.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit

class WholeHouseScreenView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var opacityView: UIView!
    var menuView: UIView!                           //弹出菜单
    var menuViewHeight = 18 * 2 + 35
    var collectionView: UICollectionView!
    
    var categoryIndex: String?             //选中类别
    var categorySection = Utils.getFieldArrInDirArr(arr: AppData.styleTypeList, field: "label")            //类别分组
    var categoryValues = Utils.getFieldArrInDirArr(arr: AppData.styleTypeList, field: "value")            //类别Value分组
    
    var selectedBlock: ((_ categoryIndex: String? ,_ title: String?)->())?
    
    var identifier = "filterCell"
    
    var screenType: Int = 0 { //筛选类型1:风格；2：户型；3:面积
        didSet {
            categorySection.removeAll()
            categoryValues.removeAll()
            categorySection = ["不限"]
            categoryValues = ["0"]
            switch screenType {
            case 1:
                categorySection.append(contentsOf: Utils.getFieldArrInDirArr(arr: AppData.styleTypeList, field: "label"))
                categoryValues.append(contentsOf: Utils.getFieldArrInDirArr(arr: AppData.styleTypeList, field: "value"))
            case 2:
                categorySection.append(contentsOf: Utils.getFieldArrInDirArr(arr: AppData.houseTypesList, field: "label"))
                categoryValues.append(contentsOf: Utils.getFieldArrInDirArr(arr: AppData.houseTypesList, field: "value"))
            case 3:
                categorySection.append(contentsOf: Utils.getFieldArrInDirArr(arr: AppData.houseAreaList, field: "label"))
                categoryValues.append(contentsOf: Utils.getFieldArrInDirArr(arr: AppData.houseAreaList, field: "value"))
            default:
                categorySection = ["不限"]
                categoryValues = ["0"]
            }
            if categorySection.count > 0 {
                var cout = categorySection.count/3 + (categorySection.count%3>0 ?1:0)
                if cout > 6 {
                    cout = 6
                }
                self.menuViewHeight = 18 * 2 + 35*cout + 15*(cout-1)

                self.menuView.snp.updateConstraints({ (make) in
                    make.height.equalTo(self.menuViewHeight)
                })
            }
            collectionView.reloadData()
        }
    }
    
    var hiddeBlock: (()->())?
    
    deinit {
        AppLog(">>>>>>>>>>>> 筛选弹窗释放 <<<<<<<<<<<<")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
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
            make.height.equalTo(175)
            make.left.right.top.equalToSuperview()
        }
        
        
        //collectionView
        let cellWidth = (PublicSize.screenWidth-32-20*2)/3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = IS_iPad ? CGSize(width: 180, height: 35) : CGSize(width: cellWidth, height: 35)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 18, left: 16, bottom: 18, right: 16)
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "collectionHeader")
        menuView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            
            make.left.right.top.bottom.equalToSuperview()
        }
        self.animateIsHidden(true)
    }
    
    //弹出菜单
    func showMenu() {
        
        collectionView.reloadData()
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
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return categorySection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FilterCell
        
        let titleStr = categorySection[indexPath.row]
        cell.titleLable.text = titleStr
        
        if indexPath.row == 0 {
            if categoryIndex != nil {
                cell.isSelect = false
            }else {
                cell.isSelect = true
            }
        }else {
            
            if categoryIndex == categoryValues[indexPath.row] {
                cell.isSelect = true
            }else {
                cell.isSelect = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let titleStr = categorySection[indexPath.row]
        if indexPath.row == 0 {
            categoryIndex = nil
        }else {
           categoryIndex = categoryValues[indexPath.row]
        }
        if selectedBlock != nil {
            
            selectedBlock!(categoryIndex,titleStr)
        }
        hiddenMenu()
        
        collectionView.reloadData()
        
    }
    
}
