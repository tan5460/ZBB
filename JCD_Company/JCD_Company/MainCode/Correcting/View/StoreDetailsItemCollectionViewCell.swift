//
//  StoreDetailsCollectionViewCell.swift
//  YZB_Company
//
//  Created by HOA on 2019/11/8.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class StoreDetailsItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var shadowV: UIImageView! {
        didSet {
            shadowV.image = UIColor.white.image()?.setImageRadius(radius: 2)
        }
    }
    
    @IBOutlet weak var showImageView: UIImageView!
    @IBOutlet weak var displayTitle: UILabel!
    @IBOutlet weak var displayBrand: UILabel!
    @IBOutlet weak var leftPrice: UILabel!
    @IBOutlet weak var rigthPrice: UILabel!
    @IBOutlet weak var rightPriceLine: UIView!
    @IBOutlet weak var defaultTitle: UILabel!
    private var combinationBtn: UIButton!
    // ￥
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        combinationBtn = UIButton()
        combinationBtn.setBackgroundImage(UIImage.init(named: "comBuy"), for: .normal)
        showImageView.addSubview(combinationBtn)
        combinationBtn.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.width.equalTo(54)
            make.height.equalTo(22)
        }
        combinationBtn.isHidden = true
    }
    
    var sjsFlag = false
    
    var model: MaterialsModel? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        if let imageStr = model?.transformImageURL, let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
            showImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading"))
        } else {
            showImageView.image = UIImage.init(named: "loading")
        }
        
        if model?.isOneSell == 2 {
            combinationBtn.isHidden = false
        } else {
            combinationBtn.isHidden = true
        }
        
        displayTitle?.text = model?.name ?? "未知标题"
        displayBrand?.text = model?.brandName ?? "未知"
        
        if let valueStr = model?.priceShow?.doubleValue {
            let value = valueStr.notRoundingString(afterPoint: 2)
            rigthPrice.text = String.init(format: "￥%@", value)
        }
        if model?.isOneSell == 2 {
            if let customValueStr = model?.priceShow?.doubleValue {
                let customValue = customValueStr.notRoundingString(afterPoint: 2)
                leftPrice?.text = String.init(format: "￥%@", customValue)
            }
            leftPrice.setLabelUnderline()
            rigthPrice.isHidden = true
            rightPriceLine.isHidden = true
            defaultTitle.text = "市场价"
        } else {
            leftPrice.removeLabelUnderline()
            if let customValueStr = model?.priceSellMin?.doubleValue {
                let customValue = customValueStr.notRoundingString(afterPoint: 2)
                leftPrice?.text = String.init(format: "￥%@", customValue)
            } else {
                leftPrice?.text = "￥0"
            }
            rigthPrice.isHidden = false
            rightPriceLine.isHidden = false
            defaultTitle.text = "销售价"
        }
        
        
    }
}
