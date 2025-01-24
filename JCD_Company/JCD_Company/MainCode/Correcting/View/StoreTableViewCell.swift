//
//  StoreTableViewCell.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/6.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import SkeletonView

class StoreTableViewCell: UITableViewCell {
    @IBOutlet weak var selectedBar: UIView!
    @IBOutlet weak var displayTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            selectedBar.backgroundColor = UIColor.init(netHex: 0x23AC38)
            backgroundColor = .white
        }
        else {
            selectedBar.backgroundColor = .clear
            backgroundColor = .clear
        }
    }
    
    var model: HoStoreModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
       
        hideSkeleton()
        displayTitle?.text = model?.name
        
    }
    
}
