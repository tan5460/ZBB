//
//  LeftSelctItemView.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class SelctItemView: UIView,UICollectionViewDelegate, UICollectionViewDataSource {

    var itemsData: Array<String> = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var collectionView: UICollectionView!
    
    var scrollDirection: UICollectionView.ScrollDirection = .vertical
    
    var seletIndexPath = IndexPath(item: 0, section: 0)
    
    var selectedBlock: ((_ indexPath: IndexPath)->())?
    
    init(frame: CGRect,scrollDirection:UICollectionView.ScrollDirection = .vertical) {
        super.init(frame: frame)
        self.scrollDirection = scrollDirection
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        if scrollDirection == .vertical {
            
            layout.itemSize = CGSize(width: 95, height: 60)
        }else {
            layout.itemSize = CGSize(width: 90, height: 50)
        }
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SelctItemCollectCell.self, forCellWithReuseIdentifier: SelctItemCollectCell.description())
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
        
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelctItemCollectCell.description(), for: indexPath) as! SelctItemCollectCell
        
        cell.titleLabel.text = itemsData[indexPath.item]
        
        if self.scrollDirection == .vertical {
            cell.leftLine.isHidden = true
            if seletIndexPath == indexPath {
                cell.leftLine.isHidden = false
                cell.contentView.backgroundColor = .white
                cell.titleLabel.textColor = #colorLiteral(red: 0.1870816946, green: 0.6070418954, blue: 0.8648062348, alpha: 1)
            }else {
                cell.contentView.backgroundColor = PublicColor.backgroundViewColor
                cell.titleLabel.textColor = PublicColor.commonTextColor
            }
        }else {
            cell.leftLine.isHidden = true
            cell.contentView.backgroundColor = .white
            if seletIndexPath == indexPath {
                cell.titleLabel.textColor = PublicColor.emphasizeTextColor
            }else {
                cell.titleLabel.textColor = PublicColor.commonTextColor
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        seletIndexPath = indexPath
        collectionView.reloadData()
        if let block = selectedBlock {
            block(indexPath)
        }
    }
}

