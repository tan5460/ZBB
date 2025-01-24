//
//  CGYCollectionViewCell.swift
//  YZB_Company
//
//  Created by Mac on 17.09.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher
import Alamofire

@objc protocol CGYCollectionViewCellDelegate {
    func addPurchase(_ model: MaterialsModel!)
}

class CGYCollectionViewCell: UICollectionViewCell {

    @objc weak var delegate: CGYCollectionViewCellDelegate!
    
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var displayTitle: UILabel!
    @IBOutlet private weak var displayBrand: UILabel!
    @IBOutlet private weak var displayUnit: UILabel!
    @IBOutlet private weak var displaySale: UILabel!
    @IBOutlet private weak var displayResult: UILabel!
    @IBOutlet weak var addShopCarButton: UIButton!
    @IBOutlet weak var jsPriceLabel: UILabel!
    @IBOutlet weak var xsPriceLabel: UILabel!
    @IBOutlet weak var comBuyIcon: UIImageView!
    @IBAction private func addCar(_ sender: UIButton) {
        delegate?.addPurchase(model)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var sjsFlag = false
    var model: MaterialsModel! {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        icon.image = UIImage.init(named: "loading")
        displayTitle.text = model?.name ?? ""
        displayBrand.text = "品牌: 无"
        displaySale.text = "￥未定价"
        if let valueStr = model?.brandName {
            displayBrand.text = "品牌: \(valueStr)"
        }
        
        if let valueStr = model?.unitTypeName {
            displayUnit.text = "单位: \(valueStr)"
        } else {
            displayUnit.text = "单位: 未知"
        }
        
        
        
        if let priceSupply = model?.priceSellMin?.doubleValue {
            let value = priceSupply.notRoundingString(afterPoint: 2)
            displaySale.text = String.init(format: "￥%@", value)
        } else {
            displaySale.text = String.init(format: "￥%@", "0")
        }
        if model.isOneSell == 2 {
            comBuyIcon.isHidden = false
            displayResult.text = "***"
        } else {
            comBuyIcon.isHidden = true
            if let priceSupply = model?.priceSupplyMin1?.doubleValue {
                let value = priceSupply.notRoundingString(afterPoint: 2)
                displayResult.text = String.init(format: "￥%@", value)
            } else {
                displayResult.text = String.init(format: "￥%@", "0")
            }
        }
        
        if UserData.shared.userInfoModel?.yzbVip?.vipType == 1 {
            jsPriceLabel.text("市场价")
            displayResult.text("¥\(model.priceShow?.doubleValue ?? 0)").textColor(.kColor99)
            jsPriceLabel.setLabelUnderline()
            displayResult.setLabelUnderline()
        }
        
        if let imageStr = model?.transformImageURL, let imageUrl = URL(string: APIURL.ossPicUrl + imageStr) {
            icon.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading"))
        } else {
            icon.image = UIImage(named: "loading")
        }
        addShopCarButton?.isHidden = true
    }
    
}
