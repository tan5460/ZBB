//
//  HoBrandItemCollectionViewCell.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/11.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class HoBrandItemCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            updateState()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isSelected = false
        
    }
    
    var item: HoStoreModel! {
        didSet {
            self.isSelected = item?.isSelected ?? false
            titleLabel?.text = item?.name
            if item?.isMoreItem ?? false && item?.isOpen ?? false == false{
                titleLabel?.text = "更多分类"
                titleLabel?.numberOfLines = 2
                titleLabel?.textColor = UIColor.init(netHex: 0x1E1E1E)
                titleLabel?.backgroundColor = .white
                titleLabel?.layer.borderColor = UIColor.init(netHex: 0xE6E6E6).cgColor
                titleLabel?.layer.borderWidth = 1
                titleLabel?.layer.cornerRadius = 15
                titleLabel?.layer.masksToBounds = true
            }
        }
    }
    
    var ggItem: HoSpecData! {
        didSet {
            self.isSelected = ggItem?.isSelected ?? false
            titleLabel?.text = ggItem?.name
            if ggItem?.isMoreItem ?? false && ggItem?.isOpen ?? false == false{
                titleLabel?.text = "更多分类"
                titleLabel?.numberOfLines = 2
                titleLabel?.textColor = UIColor.init(netHex: 0x1E1E1E)
                titleLabel?.backgroundColor = .white
                titleLabel?.layer.borderColor = UIColor.init(netHex: 0xE6E6E6).cgColor
                titleLabel?.layer.borderWidth = 1
                titleLabel?.layer.cornerRadius = 15
                titleLabel?.layer.masksToBounds = true
            }
        }
    }
    
    private func updateState() {
        titleLabel?.numberOfLines = 2
        titleLabel?.textColor = textColor
        titleLabel?.backgroundColor = bgColor
        titleLabel?.layer.borderColor = isSelected ? UIColor.init(netHex: 0x23AC38).cgColor : UIColor.init(netHex: 0xF7F7F7).cgColor
        titleLabel?.layer.borderWidth = isSelected ? 1 : 0
        titleLabel?.layer.cornerRadius = 15
        titleLabel?.layer.masksToBounds = true
    }
}
private extension HoBrandItemCollectionViewCell {
    
    var textColor: UIColor! {
        get {
            return isSelected ? UIColor.init(netHex: 0x23AC38) : UIColor.init(netHex: 0x1E1E1E)
        }
    }
    
    var bgColor: UIColor! {
        get {
            return isSelected ? UIColor.init(netHex: 0xEEFAF0) : UIColor.init(netHex: 0xF7F7F7)
        }
    }
}
