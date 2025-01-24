//
//  ZBBHomeHeaderNewView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/20.
//

import UIKit

class ZBBHomeHeaderNewView: UIView {
    
    var models: [MaterialsModel]? {
        didSet {
            leftGoodsView.isHidden = true
            centerGoodsView.isHidden = true
            rightGoodsView.isHidden = true
            if let models = models {
                if models.count > 0 {
                    refreshGoodsView(view: leftGoodsView, model: models[0])
                }
                if models.count > 1 {
                    refreshGoodsView(view: centerGoodsView, model: models[1])
                }
                if models.count > 2 {
                    refreshGoodsView(view: rightGoodsView, model: models[2])
                }
            }
        }
    }
    
    private var leftGoodsView: ZBBHomeHeaderGoodsView!
    private var centerGoodsView: ZBBHomeHeaderGoodsView!
    private var rightGoodsView: ZBBHomeHeaderGoodsView!

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = .hexColor("#D9FFF4")
        
        let imageView = UIImageView(image: UIImage(named: "zbb_new_top_bg"))
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(42)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "新品专区"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.height.equalTo(22)
        }
        
        let moreIcon = UIImageView(image: UIImage(named: "zbb_more_arrow"))
        addSubview(moreIcon)
        moreIcon.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.centerY.equalTo(titleLabel)
            make.width.height.equalTo(24)
        }
        
        let moreBtn = UIButton(type: .custom)
        moreBtn.addTarget(self, action: #selector(moreBtnAction(_:)), for: .touchUpInside)
        addSubview(moreBtn)
        moreBtn.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(40)
        }
        
        let width = (SCREEN_WIDTH - 14*2 - 8*2 - 5*2)/3.0
        
        leftGoodsView = ZBBHomeHeaderGoodsView()
        leftGoodsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(leftGoodsViewTapGesture(_:))))
        addSubview(leftGoodsView)
        leftGoodsView.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.left.equalTo(8)
            make.width.equalTo(width)
            make.bottom.equalTo(-8)
        }
        
        centerGoodsView = ZBBHomeHeaderGoodsView()
        centerGoodsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(centerGoodsViewTapGesture(_:))))
        addSubview(centerGoodsView)
        centerGoodsView.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(width)
            make.bottom.equalTo(-8)
        }
        
        rightGoodsView = ZBBHomeHeaderGoodsView()
        rightGoodsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rightGoodsViewTapGesture(_:))))
        addSubview(rightGoodsView)
        rightGoodsView.snp.makeConstraints { make in
            make.top.equalTo(50)
            make.right.equalTo(-8)
            make.width.equalTo(width)
            make.bottom.equalTo(-8)
        }
    }
    
    private func refreshGoodsView(view: ZBBHomeHeaderGoodsView, model: MaterialsModel) {
        view.isHidden = false
        view.coverImageView.kf.setImage(with: URL(string: APIURL.ossPicUrl + (model.transformImageURL ?? "")), placeholder: UIImage(named: "loading"))
        view.typeIcon.image = UIImage(named: "zbb_new_right")
        view.titleLabel.text = model.name
        view.descLabel.text = "¥" + (model.priceSell?.doubleValue ?? (model.priceSellMin?.doubleValue ?? 0)).notRoundingString(afterPoint: 2)
    }
    
    //MARK: - Action
    
    @objc private func moreBtnAction(_ sender: UIButton) {
        let vc = MaterialsVC()
        vc.type = 1
        getCurrentVC().navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func leftGoodsViewTapGesture(_ sender: UITapGestureRecognizer) {
        if let model = models?[0] {
            jumpGoodsDetailVC(model)
        }
    }
    
    @objc private func centerGoodsViewTapGesture(_ sender: UITapGestureRecognizer) {
        if let model = models?[1] {
            jumpGoodsDetailVC(model)
        }
    }
    
    @objc private func rightGoodsViewTapGesture(_ sender: UITapGestureRecognizer) {
        if let model = models?[2] {
            jumpGoodsDetailVC(model)
        }
    }
    
    private func jumpGoodsDetailVC(_ model: MaterialsModel) {
        let vc = MaterialsDetailVC()
        vc.materialsModel = model
        getCurrentVC().navigationController?.pushViewController(vc, animated: true)
    }
}
