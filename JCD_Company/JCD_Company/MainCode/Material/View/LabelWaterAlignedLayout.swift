//
//  LabelWaterAlignedLayout.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/20.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
protocol LabelWaterAlignedLayoutDelegate: NSObjectProtocol {
    func leftWaterAligned(_ waterFlow: LabelWaterAlignedLayout?, widthForItemAt indexPath: IndexPath?) -> CGFloat
}

class LabelWaterAlignedLayout: UICollectionViewLayout{

    //每一行的高度
    var columnHeight: CGFloat = 30
    //每一列之间的间隙
    var columnMargin: CGFloat = 10
    //每一行之间的间隙
    var rowMargin: CGFloat = 10
    //边缘的间隙
    var edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

    //存放所有的布局属性
    var attrsArray: [UICollectionViewLayoutAttributes] = []
    //多少行总的高度
    var sumHeight: CGFloat = 0.0
    
    weak var delegate: LabelWaterAlignedLayoutDelegate?
    
    override func prepare() {
        super.prepare()
        
        //清除之前的所有布局属性
        attrsArray.removeAll()
        
        //开始创建每一个cell对应的布局属性
        let count: Int = (self.collectionView?.numberOfItems(inSection: 0))!
        for i in 0..<count {
            //创建位置
            let indexPath = IndexPath(item: i, section: 0)
            //创建布局属性
            let layoutAtt: UICollectionViewLayoutAttributes? = layoutAttributesForItem(at: indexPath)
            if let anAtt = layoutAtt {
                attrsArray.append(anAtt)
            }
        }
    }
    
    // MARK: - UICollectionViewLayout
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return attrsArray
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let currentItemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        //collectionView 的宽度
        let collectionViewW: CGFloat = collectionView!.frame.size.width
        //计算布局属性的frame
        
        var x: CGFloat = edgeInsets.left
        var y = edgeInsets.top
        var w: CGFloat = 0
        
        //判断获得前一个cell的x和y
        let row = indexPath.row - 1
        if row >= 0 {
            if attrsArray.count > row {
                let layoutAtt = attrsArray[row]
                x = layoutAtt.frame.origin.x
                y = layoutAtt.frame.origin.y
            }
            let index = IndexPath.init(item: row, section: indexPath.section)
            if delegate != nil {
                w = (delegate?.leftWaterAligned(self, widthForItemAt: index))!
            }
            x += w + columnMargin
        }
        
        if delegate != nil {
            w = (delegate?.leftWaterAligned(self, widthForItemAt: indexPath))!
        }
        
        w = min(w, collectionViewW - edgeInsets.right-edgeInsets.left)
        
        if x + w > collectionViewW - edgeInsets.right {
            //超出范围，换行
            x = edgeInsets.left
            y += columnHeight + rowMargin
        }
        sumHeight = y + columnHeight + edgeInsets.bottom
        currentItemAttributes.frame = CGRect(x: x, y: y, width: w, height: columnHeight)
        return currentItemAttributes
    }
    
    override var collectionViewContentSize: CGSize {
        
        return CGSize(width: 0, height: sumHeight)
    }
}
