//
//  ZBBHomeCollectionViewCell.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/21.
//

import UIKit

class ZBBHomeCollectionViewCell: UICollectionViewCell {
    
    var model: MaterialsModel? {
        didSet {
            coverImageView.kf.setImage(with: URL(string: APIURL.ossPicUrl + (model?.transformImageURL ?? "")), placeholder: UIImage(named: "loading"))
            subsidyIcon.isHidden = (model?.productTypeIdentification ?? -1) != 0
            
            let style = NSMutableParagraphStyle()
            style.minimumLineHeight = 20
            style.maximumLineHeight = 20
            style.lineBreakMode = .byCharWrapping
            titleLabel.attributedText = NSAttributedString(string: model?.name ?? "", attributes: [.paragraphStyle : style, .baselineOffset : 1])
            oldPriceLabel.attributedText = ("市场价：¥" + (model?.priceShow?.doubleValue ?? (model?.priceShowMin?.doubleValue ?? 0)).notRoundingString(afterPoint: 2)).addUnderline()
            
            let price = "¥" + (model?.priceSell?.doubleValue ?? (model?.priceSellMin?.doubleValue ?? 0)).notRoundingString(afterPoint: 2) + "销售价"
            let attrPrice = NSMutableAttributedString(string: price)
            attrPrice.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .medium), range: NSMakeRange(0, price.length))
            attrPrice.addAttribute(.font, value: UIFont.systemFont(ofSize: 10, weight: .medium), range: NSMakeRange(0, 1))
            attrPrice.addAttribute(.font, value: UIFont.systemFont(ofSize: 12), range: NSMakeRange(price.length - 3, 3))
            attrPrice.addAttribute(.baselineOffset, value: 1, range: NSMakeRange(0, price.length))
            priceLabel.attributedText = attrPrice
        }
    }
    
    
    private var coverImageView: UIImageView!
    private var subsidyIcon: UIImageView!
    private var titleLabel: UILabel!
    private var oldPriceLabel: UILabel!
    private var priceLabel: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        layer.cornerRadius = 10
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.hexColor("#B4D4C4").cgColor
        layer.masksToBounds = true
        backgroundColor = .white
        
        coverImageView = UIImageView()
        coverImageView.clipsToBounds = true
        coverImageView.contentMode = .scaleAspectFill
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(coverImageView.snp.width)
        }
        
        subsidyIcon = UIImageView(image: UIImage(named: "zbbt_subsidy4"))
        contentView.addSubview(subsidyIcon)
        subsidyIcon.snp.makeConstraints { make in
            make.top.right.equalTo(0)
            make.width.equalTo(50)
            make.height.equalTo(22)
        }
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(coverImageView.snp.bottom).offset(5)
            make.left.equalTo(5)
            make.right.equalTo(-5)
            make.height.greaterThanOrEqualTo(20)
        }
        
        oldPriceLabel = UILabel()
        oldPriceLabel.font = .systemFont(ofSize: 10)
        oldPriceLabel.textColor = .hexColor("#666666")
        contentView.addSubview(oldPriceLabel)
        oldPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.left.equalTo(5)
            make.height.equalTo(14)
        }
        
        priceLabel = UILabel()
        priceLabel.textColor = .hexColor("#FF3C2F")
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(oldPriceLabel.snp.bottom).offset(5)
            make.left.equalTo(5)
            make.height.equalTo(25)
        }
        
        

    }
    
    static func cellHeight(model: MaterialsModel, width: CGFloat) -> CGFloat {
        //
        var height = width
        
        //
        height += 5
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = 20
        style.maximumLineHeight = 20
        style.lineBreakMode = .byCharWrapping
        let attrName = NSAttributedString(string: model.name ?? "",
                                          attributes: [.paragraphStyle : style,
                                                       .baselineOffset : 1,
                                                       .font : UIFont.systemFont(ofSize: 14, weight: .medium)])
        let rect = attrName.boundingRect(with: CGSizeMake(width - 10, 40), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        if rect.height <= 20 {
            height += 20
        } else {
            height += 40
        }
        
        //
        height += 5
        height += 14
        
        //
        height += 5
        height += 25
        
        //
        height += 10
        
        return height
    }
}
