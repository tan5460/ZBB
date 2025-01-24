//
//  CollectionWaterLayout.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/29.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
protocol CollectionWaterLayoutDelegate: NSObjectProtocol {
    func collectionWaterLayout(_ waterFlow: CollectionWaterLayout, heightForItemAt indexPath: IndexPath, itemWidth:CGFloat) -> CGFloat
}
class CollectionWaterLayout: UICollectionViewLayout {
    
    //多少列
    var columnCount: Int = 2
    //每一列之间的间隙
    var columnMargin: CGFloat = 10
    //每一行之间的间隙
    var rowMargin: CGFloat = 10
    //边缘的间隙
    var edgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    //存放所有的布局属性
    var attrsArray: [UICollectionViewLayoutAttributes] = []
    //存放所有列的高度
    var columnHeights: [CGFloat] = []
    //内容的高度
    var contentHeight: CGFloat = 0.0
    
    weak var delegate: CollectionWaterLayoutDelegate?
    
    override func prepare() {
        super.prepare()
        
        self.contentHeight = 0
        //清除之前的计算的所有高度
        columnHeights.removeAll()
        for _ in 0..<columnCount {
            columnHeights.append(edgeInsets.top)
        }
        
        //清除之前的所有布局属性
        attrsArray.removeAll()
        
        //开始创建每一个cell对应的布局属性(self.collectionView?.numberOfItems(inSection: 0))!
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
        
        //创建布局属性
        let layoutAtt = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        //collectionView 的宽度
        let collectionViewW: CGFloat = collectionView!.frame.size.width
        //计算布局属性的frame
        let w = (collectionViewW - edgeInsets.left - edgeInsets.right - columnMargin * CGFloat((columnCount - 1))) / CGFloat(columnCount)
        var h: CGFloat = 0
        
        if delegate != nil {
            h = delegate!.collectionWaterLayout(self, heightForItemAt: indexPath, itemWidth: w)
        }
        
        //找出高度最短的那一列
        var destColumn: Int = 0
        var minHeight = columnHeights[0]
        for i in 1..<columnCount {
            let columnHeight = columnHeights[i]
            if columnHeight < minHeight {
                minHeight = columnHeight
                destColumn = i
            }
        }
        
        let x: CGFloat = edgeInsets.left + CGFloat(destColumn) * (w + columnMargin)
        var y: CGFloat = minHeight
        if y != edgeInsets.top {
            y += rowMargin
        }
        layoutAtt.frame = CGRect(x: x, y: y, width: w, height: h)
        
        //更新最短那列的高度
        columnHeights[destColumn] = layoutAtt.frame.maxY
        
        if contentHeight < columnHeights[destColumn] {
            contentHeight = columnHeights[destColumn]
        }

        return layoutAtt
    }
    
    override var collectionViewContentSize: CGSize {
        
        return CGSize(width: 0, height: self.contentHeight+self.edgeInsets.bottom)
    }
}
