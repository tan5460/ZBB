//
//  HoTableCollectionView.swift
//  HoStoreViewController
//
//  Created by HOA on 2019/11/6.
//  Copyright © 2019 HOA. All rights reserved.
//

import Foundation
import UIKit

protocol UITableViewCellFromNib {}
extension UITableViewCellFromNib {
    static var identifier: String { return "\(self)ID" }
    static var nib: UINib? { return UINib(nibName: "\(self)", bundle: nil) }
    static func hw_getNibPath() -> String? {
        return Bundle.main.path(forResource: "\(self)", ofType: "nib")
    }
}
extension UITableViewCell : UITableViewCellFromNib{}

extension UITableView {
    /// 注册 cell 的方法 注意:identifier是传入的 T+ID
    func hw_registerCell<T: UITableViewCell>(cell: T.Type) {
        if T.hw_getNibPath() != nil {
            register(T.nib, forCellReuseIdentifier: T.identifier)
        } else {
            register(cell, forCellReuseIdentifier: T.identifier)
        }
    }
    
    /// 从缓存池池出队已经存在的 cell
    func hw_dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        if T.identifier == UITableViewCell.identifier {
            //print("获取cell 后方必须固定添加(as 你的cell名称)")
            register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.identifier)
            return dequeueReusableCell(withIdentifier: UITableViewCell.identifier, for: indexPath) as! T
        }
        /// 如果这里报错 检查你是否注册cell
        return dequeueReusableCell(withIdentifier: T.identifier, for: indexPath) as! T
    }
    
}


protocol UICollectionViewCellFromNib {}
extension UICollectionViewCellFromNib {
    static var identifier: String { return "\(self)ID" }
    static var nib: UINib? { return UINib(nibName: "\(self)", bundle: nil) }
    static func hw_getNibPath() -> String? {
        return Bundle.main.path(forResource: "\(self)", ofType: "nib")
    }
}

//extension UICollectionViewCell : UICollectionViewCellFromNib{}
extension UICollectionReusableView : UICollectionViewCellFromNib{}

extension UICollectionView {
    /// 注册 cell 的方法 注意:identifier是传入的 T+ID
    func hw_registerCell<T: UICollectionViewCell>(cell: T.Type) {
        if T.hw_getNibPath() != nil {
            register(T.nib, forCellWithReuseIdentifier: T.identifier)
        } else {
            register(cell, forCellWithReuseIdentifier: T.identifier)
        }
    }
    /// 从缓存池池出队已经存在的 cell
    func hw_dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        if T.identifier == UICollectionViewCell.identifier {
            //print("获取cell 后方必须固定添加(as 你的cell名称)")
            register(UICollectionViewCell.self, forCellWithReuseIdentifier: UICollectionViewCell.identifier)
            return dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.identifier, for: indexPath) as! T
        }
        /// 如果这里报错 检查你是否注册cell
        return dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
    
    /// 注册头部
    func hw_registerCollectionHeaderView<T: UICollectionReusableView>(reusableView: T.Type) {
        // T 遵守了 RegisterCellOrNib 协议，所以通过 T 就能取出 identifier 这个属性
        if T.hw_getNibPath() != nil {
            register(T.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier)
        } else {
            register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier)
        }
    }
    /// 获取可重用的头部
    func hw_dequeueCollectionHeaderView<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        if T.identifier == UICollectionReusableView.identifier {
            //print("获取view 后方必须固定添加(as 你的view名称)")
            register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UICollectionReusableView.identifier)
            return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: UICollectionReusableView.identifier, for: indexPath) as! T
        }
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
    /// 注册尾部
    func hw_registerCollectionFooterView<T: UICollectionReusableView>(reusableView: T.Type) {
        // T 遵守了 RegisterCellOrNib 协议，所以通过 T 就能取出 identifier 这个属性
        if T.hw_getNibPath() != nil {
            register(T.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier)
        } else {
            register(reusableView, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier)
        }
    }
    /// 获取可重用的尾部
    func hw_dequeueCollectionFooterView<T: UICollectionReusableView>(indexPath: IndexPath) -> T {
        if T.identifier == UICollectionReusableView.identifier {
            //print("获取view 后方必须固定添加(as 你的view名称)")
            register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: UICollectionReusableView.identifier)
            return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: UICollectionReusableView.identifier, for: indexPath) as! T
        }
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.identifier, for: indexPath) as! T
    }
}
