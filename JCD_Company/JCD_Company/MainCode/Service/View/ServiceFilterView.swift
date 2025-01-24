//
//  ServiceFilterView.swift
//  YZB_Company
//
//  Created by xuewen yu on 2017/11/2.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit

class ServiceFilterView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var opacityView: UIView!
    var menuView: UIView!                           //弹出菜单
    let menuWidth: CGFloat = PublicSize.screenWidth   //弹出菜单宽
    var collectionView: UICollectionView!
    
    var normalCategoryIndex: String?       //默认选中类别
    var categoryIndex: String?             //选中类别
    var categorySection = Utils.getFieldArrInDirArr(arr: AppData.serviceCategoryList, field: "label")            //类别分组
    var categoryValues = Utils.getFieldArrInDirArr(arr: AppData.serviceCategoryList, field: "value")            //类别value分组

    var selectedBlock: ((_ categoryIndex: String?)->())?
    
    var identifier = "filterCell"
    
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
            make.height.equalTo(300)
            make.left.right.top.equalToSuperview()
        }
        
        let resetBtn = UIButton()
        resetBtn.backgroundColor = UIColor.white
        resetBtn.setTitle("重置", for: .normal)
        resetBtn.setTitleColor(.black, for: .normal)
        resetBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        resetBtn.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        menuView.addSubview(resetBtn)
        
        resetBtn.snp.makeConstraints { (make) in
            make.left.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        let sureBtn = UIButton()
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        sureBtn.setBackgroundImage(backgroundImg, for: .normal)
        sureBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        menuView.addSubview(sureBtn)
        
        sureBtn.snp.makeConstraints { (make) in
            make.right.bottom.equalToSuperview()
            make.width.equalTo(resetBtn.snp.width)
            make.left.equalTo(resetBtn.snp.right)
            make.height.equalTo(40)
        }
        
        let titleLine = UIView()
        titleLine.backgroundColor = PublicColor.partingLineColor
        menuView.addSubview(titleLine)
        titleLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalTo(resetBtn.snp.top)
        }

        
        //collectionView
        let cellWidth = (PublicSize.screenWidth-46-15*2)/3
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = IS_iPad ? CGSize(width: 180, height: 35) : CGSize(width: cellWidth, height: 35)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 23, bottom: 10, right: 23)
        layout.headerReferenceSize = CGSize(width: 0, height: 40)
        
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
            make.bottom.equalTo(resetBtn.snp.top)
            make.left.right.top.equalToSuperview()
        }
        self.menuView.transform = CGAffineTransform.identity
            .translatedBy(x: 0, y: -150)
            .scaledBy(x: 1, y: 0.01)
    }
    
    //弹出菜单
    func showMenu() {
        
        categoryIndex = normalCategoryIndex
        collectionView.reloadData()
        self.isHidden = false
        opacityView.alpha = 0

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
                .translatedBy(x: 0, y: -150)
                .scaledBy(x: 1, y: 0.01)
            self.opacityView.alpha = 0
  
        }) { (finished) in
            self.isHidden = true
        }
    }
    
    //重置
    @objc func resetAction() {
        
        categoryIndex = nil
        collectionView.reloadData()
        
    }
    //确定
    @objc func sureAction() {
        
        if selectedBlock != nil {
            normalCategoryIndex = categoryIndex
            selectedBlock!(categoryIndex)
        }
        hiddenMenu()
 
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
       return categorySection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FilterCell
        let titleStr = categorySection[indexPath.row]
        cell.titleLable.text = titleStr
        
        if self.categoryValues.count > 0 {
            if categoryIndex == self.categoryValues[indexPath.row] {
                cell.isSelect = true
            }else {
                cell.isSelect = false
            }
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.categoryValues.count > 0 {
            if categoryIndex == self.categoryValues[indexPath.row] {
                categoryIndex = nil
            }else {
                categoryIndex = self.categoryValues[indexPath.row]
            }
        }

        collectionView.reloadData()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var header: UICollectionReusableView?
        
        if kind == UICollectionView.elementKindSectionHeader {
            //头视图
            header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "collectionHeader", for: indexPath)
            
            var titleLabel = header?.viewWithTag(101) as? UILabel
            if titleLabel == nil {
                titleLabel = UILabel()
                titleLabel?.tag = 101
                titleLabel?.text = "分类"
                titleLabel?.font = UIFont.systemFont(ofSize: 12)
                titleLabel?.textColor = UIColor.colorFromRGB(rgbValue: 0x949494)
                header?.addSubview(titleLabel!)
                
                titleLabel?.snp.makeConstraints({ (make) in
                    make.left.equalTo(23)
                    make.centerY.equalToSuperview()
                })
            }
        }
       
        
        return header!
    }

}
