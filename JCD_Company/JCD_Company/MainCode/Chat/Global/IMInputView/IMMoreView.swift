//
//  IMMoreVIew.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/8.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
enum IMMoreType: Int {
    case order      // 订单
    case pic        // 照片
    case camera     // 相机
    case location   // 位置
}

protocol IMMoreViewDelegate : NSObjectProtocol {
    func moreView(moreView: IMMoreView, didSeletedType type: IMMoreType)
}
class IMMoreView: UIView {

    // MARK:- 代理
    weak var delegate: IMMoreViewDelegate?
    fileprivate let kMoreCellID = "IMmoreCellID"
    // MARK:- 懒加载
    lazy var collectionView: UICollectionView = {
        let floLayout = UICollectionViewFlowLayout()
        floLayout.itemSize = CGSize(width: PublicSize.screenWidth/4, height: 90)
        floLayout.minimumLineSpacing = 0
        floLayout.minimumInteritemSpacing = 0
    
        let collectionV = UICollectionView(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth, height: 90), collectionViewLayout:floLayout)
        collectionV.backgroundColor = .white
        collectionV.dataSource = self
        collectionV.delegate = self
        // 注册itemID
        collectionV.register(IMMoreCell.self, forCellWithReuseIdentifier: kMoreCellID)
        return collectionV
        }()
    

    var moreDataSouce: [(name: String, icon: UIImage?, type: IMMoreType)] = [
            ("拍摄", UIImage(named: "chat_takePhoto"), IMMoreType.camera),
            ("照片", UIImage(named: "chat_photo"), IMMoreType.pic),
            ("位置", UIImage(named: "chat_loction"), IMMoreType.location),
            ("订单", UIImage(named: "chat_order"), IMMoreType.order)
        ]
    
    var isNoOrder: Bool = false {
        didSet {
            if isNoOrder {
                moreDataSouce = [
                ("拍摄", UIImage(named: "chat_takePhoto"), IMMoreType.camera),
                ("照片", UIImage(named: "chat_photo"), IMMoreType.pic),
                ("位置", UIImage(named: "chat_loction"), IMMoreType.location)
                ]
                collectionView.reloadData()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalToSuperview()
        }
        
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//TODO: - 修改
extension IMMoreView : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moreDataSouce.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let moreModel = moreDataSouce[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kMoreCellID, for: indexPath) as? IMMoreCell
        
        cell?.model = moreModel as? (name: String, icon: UIImage, type: IMMoreType)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let moreModel = moreDataSouce[indexPath.item]
        AppLog(moreModel)
        delegate?.moreView(moreView: self, didSeletedType: moreModel.type)
    }
    
}


