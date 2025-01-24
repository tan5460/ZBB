//
//  CorrectingHomeCell.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Then
import Kingfisher
import Alamofire

class CorrectingHomeCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    var collectionView: UICollectionView!
    var itemsData: Array<MaterialsModel> = []
    var original = "销售价"
    var isStart = true
    private var noDataView: UIButton!
    
    static let cellWidth = IS_iPad ? (PublicSize.screenWidth-40)/3 : (PublicSize.screenWidth-28-11)/2
    static let cellHeight = CGFloat(230)
    
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
        
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CorrectingHomeCell.cellWidth, height: CorrectingHomeCell.cellHeight)
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bounces = true
        collectionView.alwaysBounceVertical = true
        collectionView.isScrollEnabled = false
        collectionView.register(NewRecomMaterialCell.self, forCellWithReuseIdentifier: NewRecomMaterialCell.description())
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            
            make.edges.equalToSuperview()
        }
        
        // 无数据图片
        noDataView = UIButton().text("暂无推荐~").textColor(.kColor99).font(14).image(#imageLiteral(resourceName: "home_nodata_image"))
        collectionView.sv(noDataView)
        noDataView.centerInContainer()
        noDataView.layoutButton(imageTitleSpace: 10)
        noDataView.isHidden = true
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if itemsData.count > 0 {
            noDataView.isHidden = true
        } else {
            noDataView.isHidden = false
        }
        return itemsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewRecomMaterialCell.description(), for: indexPath) as! NewRecomMaterialCell
        cell.configView(model: itemsData[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MaterialsDetailVC()
        vc.hidesBottomBarWhenPushed = true
        vc.isMainPageEnter = true
        vc.materialsModel = itemsData[indexPath.item]
        self.viewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}



class NewRecomMaterialCell: UICollectionViewCell {
    private var model: MaterialsModel?
    private let icon = UIImageView().image("loading")
    private let comBuy = UIImageView().image("comBuy").then {
        $0.isHidden = true
    }
    private let title = UILabel().text("现代简约ins意式轻奢布艺沙发").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(12, weight: .medium).numberOfLines(2)
    private let price1Des = UILabel().text("市场价: ￥1270").textColor(.kColor66).font(8.8)
    private let price2Des = UILabel().text("销售价:").textColor(.kColor33).font(12)
    private let price2 = UILabel().text("￥1270").textColor(#colorLiteral(red: 0.8745098039, green: 0.1843137255, blue: 0.1843137255, alpha: 1)).font(12)
    private let addBtn = UIButton().image(#imageLiteral(resourceName: "home_car"))
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShadowColor()
        backgroundColor = .white
        sv(icon, title, price1Des, price2Des, price2, addBtn)
        layout(
            0,
            |icon| ~ 137,
            11.38,
            |-9-title-12-|,
            >=0,
            |-9-price1Des.height(8.8),
            6.18,
            |-9-price2Des.height(12)-5-price2.height(12),
            11
        )
        layout(
            >=0,
            addBtn-10-|,
            10
        )
        icon.contentMode = .scaleAspectFit
        icon.corner(byRoundingCorners: [.topLeft, .topRight], radii: 5)
        icon.masksToBounds()
        icon.sv(comBuy)
        icon.layout(
            10,
            comBuy-10-|,
            >=0
        )
        configAddBtn()
    }
    
    private func configAddBtn() {
        addBtn.addTarget(self, action: #selector(addBtnClick))
    }
    
    func configView(model: MaterialsModel) {
        self.model = model
        if let imgStr = model.transformImageURL, !imgStr.isEmpty, let url = URL.init(string: APIURL.ossPicUrl + imgStr) {
//            icon.kf.setImage(with: ImageResource.init(downloadURL: url), placeholder: UIImage.init(named: "loading"))
            icon.kf.setImage(with: url, placeholder: UIImage.init(named: "loading"))
        } else {
            icon.image = UIImage.init(named: "loading")
        }
        title.text = model.name ?? ""
        price1Des.text = "市场价: ￥\(model.priceShow ?? 0)"
        price1Des.setLabelUnderline()
        if model.isOneSell == 2 {
            comBuy.isHidden = false
            price2Des.isHidden = true
            price2.isHidden = true
        } else {
            comBuy.isHidden = true
            price2Des.isHidden = false
            price2.isHidden = false
            price2.text = "￥\(model.priceSellMin ?? 0)"
        }
        addBtn.isHidden = false
        addBtn.isUserInteractionEnabled = false
    }
    
    @objc func addBtnClick() {
        addCart()
    }
    
    func addCart() {
        let parameters: Parameters = ["skuId": model?.id ?? "", "num": "1"]
        self.clearAllNotice()
        self.pleaseWait()
        let urlStr = APIURL.saveCartList
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.noticeSuccess("添加购物车成功", autoClear: true, autoClearTime: 0.8)
            }
        }) { (error) in
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
