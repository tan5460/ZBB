//
//  MemberCell.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/20.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class MemberCell: UITableViewCell {

    var mallImageView: UIImageView!
    var mallTitleLabel: UILabel!
    var mallCountLabel: UILabel!
    var mallPriceLabel: UILabel!
    var gradeNameLabel: UILabel!
    
    var exchangeBlock: (()->())?
    
    var mallModel: IntegralMallModel? {
    
        didSet {
            mallTitleLabel.text = "商品名"
            mallCountLabel.text = "库存0件"
            mallPriceLabel.text = "0积分"
            gradeNameLabel.text = "(黄金以上会员专享)"
            gradeNameLabel.isHidden = true
            mallImageView.image = UIImage.init(named: "loading")
            
            if let imagestr = mallModel?.goodsUrl {
                
                if imagestr != "" {
                    
                    let imageUrl = URL(string: APIURL.ossPicUrl + imagestr)!
                    mallImageView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading"))
                }
            }
            
            if let valueStr = mallModel?.goodsName {
                mallTitleLabel.text = valueStr
            }
            
            if let valueStr = mallModel?.goodsCount {
                mallCountLabel.text = "库存\(valueStr)件"
            }
            
            if let valueStr = mallModel?.integration {
                mallPriceLabel.text = "\(valueStr)积分"
            }
            
            if let valueStr = mallModel?.needLv {
                
                if let lvValue = Int(valueStr) {
                    
                    if lvValue > 1 {
                        let gradeStr = AppData.gradeNameList[lvValue-1]
                        gradeNameLabel.text = "(\(gradeStr)以上会员专享)"
                        gradeNameLabel.isHidden = false
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .white
        self.selectionStyle = .none
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //商品图片
        mallImageView = UIImageView()
        mallImageView.image = UIImage.init(named: "loading")
        mallImageView.contentMode = .scaleAspectFit
        contentView.addSubview(mallImageView)
        
        mallImageView.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        //商品标题
        mallTitleLabel = UILabel()
        mallTitleLabel.text = "MUJI日式风懒人沙发"
        mallTitleLabel.textColor = .black
        mallTitleLabel.font = UIFont.systemFont(ofSize: 14)
        contentView.addSubview(mallTitleLabel)
        
        mallTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(mallImageView.snp.right).offset(15)
            make.top.equalTo(mallImageView)
            make.right.equalTo(-90)
        }
        
        //库存
        mallCountLabel = UILabel()
        mallCountLabel.text = "库存20件"
        mallCountLabel.textColor = PublicColor.placeholderTextColor
        mallCountLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(mallCountLabel)
        
        mallCountLabel.snp.makeConstraints { (make) in
            make.left.equalTo(mallTitleLabel)
            make.centerY.equalTo(mallImageView)
        }
        
        //积分
        mallPriceLabel = UILabel()
        mallPriceLabel.text = "325积分"
        mallPriceLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xFD873A)
        mallPriceLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(mallPriceLabel)
        
        mallPriceLabel.snp.makeConstraints { (make) in
            make.left.equalTo(mallTitleLabel)
            make.bottom.equalTo(mallImageView)
        }
        
        //兑换所需等级
        gradeNameLabel = UILabel()
        gradeNameLabel.text = "(黄金以上会员专享)"
        gradeNameLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xFD873A)
        gradeNameLabel.font = UIFont.systemFont(ofSize: 13)
        contentView.addSubview(gradeNameLabel)
        
        gradeNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(mallPriceLabel.snp.right)
            make.centerY.equalTo(mallPriceLabel)
        }
        
        //兑换
        let exchangeImage = PublicColor.gradualColorImage
        let exchangeImageHig = PublicColor.gradualHightColorImage
        let exchangeBtn = UIButton(type: .custom)
        exchangeBtn.layer.cornerRadius = 4
        exchangeBtn.layer.masksToBounds = true
        exchangeBtn.setTitle("兑换", for: .normal)
        exchangeBtn.setTitleColor(.white, for: .normal)
        exchangeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        exchangeBtn.setBackgroundImage(exchangeImage, for: .normal)
        exchangeBtn.setBackgroundImage(exchangeImageHig, for: .highlighted)
        exchangeBtn.addTarget(self, action: #selector(exchangeAction), for: .touchUpInside)
        contentView.addSubview(exchangeBtn)
        
        exchangeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-15)
            make.width.equalTo(60)
            make.height.equalTo(24)
            make.centerY.equalToSuperview()
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = Color.black.withAlphaComponent(0.1)
        contentView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    @objc func exchangeAction() {
        
        if let block = exchangeBlock {
            block()
        }
    }
}
