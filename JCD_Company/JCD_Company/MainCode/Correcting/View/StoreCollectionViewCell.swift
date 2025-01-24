//
//  StoreCollectionViewCell.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/6.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import SkeletonView
import Kingfisher

class StoreCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var displayImageView: UIImageView!
    @IBOutlet weak var displayTitle: UILabel!
  
    var model: HoStoreModel? {
        didSet { setupUI() }
    }
    
    private func setupUI() {
        
        if model?.isMoreItem ?? false && model?.isOpen ?? false == false {
            displayTitle?.text = "更多"
            displayImageView.image = UIImage(named: "img_more")
        }
        else {
            displayTitle?.text = model?.name
            if let logoUrl = model?.logoUrl, !logoUrl.isEmpty {
                if let imageUrl = URL(string: APIURL.ossPicUrl + logoUrl) {
//                   displayImageView?.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading"))
                    displayImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading"))
                }
            } else {
                displayImageView.image = UIImage(named: "loading")
            }
        }
    }
}
