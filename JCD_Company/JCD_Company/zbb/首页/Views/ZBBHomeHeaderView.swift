//
//  ZBBHomeHeaderView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/20.
//

import UIKit

class ZBBHomeHeaderView: UIView {
    
    var bannerList: [AdvertListModel]? {
        didSet {
            bannerView.imagePaths = bannerList?.map{ APIURL.ossPicUrl + ($0.advertImg ?? "")} ?? []
        }
    }
    
    var model: MaterialsCorrcetModel? {
        didSet {
            subsidyView.isHidden = model?.data4?.isEmpty ?? true
            subsidyView.models = model?.data4
            newView.isHidden = model?.data3?.isEmpty ?? true
            newView.models = model?.data3
            
            newView.snp.remakeConstraints { make in
                if subsidyView.isHidden {
                    make.top.equalTo(subsidyView)
                } else {
                    make.top.equalTo(subsidyView.snp.bottom).offset(15)
                }
                make.left.equalTo(14)
                make.right.equalTo(-14)
                make.height.equalTo(106 + itemWidth)
            }
            
            saleIcon.snp.remakeConstraints { make in
                if newView.isHidden {
                    make.top.equalTo(newView)
                } else {
                    make.top.equalTo(newView.snp.bottom).offset(15)
                }
                make.left.equalTo(14)
                make.right.equalTo(-14)
                make.height.equalTo(42)
                make.bottom.equalTo(0)
            }
            
            saleIcon.isHidden = model?.data2?.isEmpty ?? true
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    private var bannerView: LLCycleScrollView!
    private var itemsView: ZBBHomeHeaderItemsView!
    private var subsidyView: ZBBHomeHeaderSubsidyView!
    private var newView: ZBBHomeHeaderNewView!
    private var saleIcon: UIImageView!
    
    private let itemWidth = (SCREEN_WIDTH - 14.0*2 - 8.0*2 - 5.0*2)/3.0
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {

        bannerView = LLCycleScrollView()
        bannerView.layer.cornerRadius = 10
        bannerView.layer.masksToBounds = true
        bannerView.backgroundColor = PublicColor.backgroundViewColor
        bannerView.delegate = self
        bannerView.pageControlBottom = 15
        bannerView.customPageControlStyle = .pill
        bannerView.customPageControlTintColor = .k27A27D
        bannerView.customPageControlInActiveTintColor = .white
        bannerView.autoScrollTimeInterval = 5
        bannerView.coverImage = UIImage.init(named: "loading")
        bannerView.placeHolderImage = UIImage.init(named: "loading")
        bannerView.imageViewContentMode = .scaleToFill
        addSubview(bannerView)
        bannerView.snp.makeConstraints { make in
            make.top.equalTo(7)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo((SCREEN_WIDTH - 28)*170.0/347.0)
        }
        
        let backView = UIView()
        backView.backgroundColor = .white
        addSubview(backView)
        backView.snp.makeConstraints { make in
            make.top.equalTo(bannerView.snp.bottom)
            make.left.bottom.right.equalTo(0)
        }

        itemsView = ZBBHomeHeaderItemsView()
        addSubview(itemsView)
        itemsView.snp.makeConstraints { make in
            make.top.equalTo(bannerView.snp.bottom)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(210)
        }
        
        

        subsidyView = ZBBHomeHeaderSubsidyView()
        subsidyView.isHidden = true
        addSubview(subsidyView)
        subsidyView.snp.makeConstraints { make in
            make.top.equalTo(itemsView.snp.bottom)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(98 + itemWidth)
        }

        newView = ZBBHomeHeaderNewView()
        newView.isHidden = true
        addSubview(newView)
        newView.snp.makeConstraints { make in
            if subsidyView.isHidden {
                make.top.equalTo(subsidyView)
            } else {
                make.top.equalTo(subsidyView.snp.bottom).offset(15)
            }
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(106 + itemWidth)
        }

        saleIcon = UIImageView(image: UIImage(named: "zbb_new_top_bg"))
        saleIcon.isHidden = true
        addSubview(saleIcon)
        saleIcon.snp.makeConstraints { make in
            if newView.isHidden {
                make.top.equalTo(newView)
            } else {
                make.top.equalTo(newView.snp.bottom).offset(15)
            }
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(42)
            make.bottom.equalTo(0)
        }
        
        let saleLabel = UILabel()
        saleLabel.text = "特惠专区"
        saleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        saleLabel.textColor = .white
        saleIcon.addSubview(saleLabel)
        saleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    
}

extension ZBBHomeHeaderView: LLCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        if let model = bannerList?[index], let advertLink = model.advertLink {
            let vc = UIBaseWebViewController()
            vc.urlStr = advertLink
            vc.isShare = model.whetherCanShare != "2"
            getCurrentVC().navigationController?.pushViewController(vc, animated: true)
        }
    }
}
