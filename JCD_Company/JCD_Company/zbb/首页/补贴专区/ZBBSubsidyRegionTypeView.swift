//
//  ZBBSubsidyRegionTypeView.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/7.
//

import UIKit
import ObjectMapper

class ZBBSubsidyRegionTypeView: UIView {
    
    var selectedClosure: ((_ typeId: String?) -> Void)?

    private var collectionView: UICollectionView!
    private var dataList = [HoStoreModel]()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        refreshData()
    }
    
    private func createViews() {
        backgroundColor = .white
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSizeMake(70, 110)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ZBBSubsidyRegionTypeViewCollectionCell.self, forCellWithReuseIdentifier: "Cell")
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    private func refreshData() {
        var parameters = [String: Any]()
        parameters["type"] = 1
        parameters["categoryType"] = "1"
        YZBSign.shared.request(APIURL.getNewCategory, method: .get, parameters: parameters) {[weak self] response in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                self?.dataList = Mapper<HoStoreModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self?.collectionView.reloadData()
                self?.collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                self?.selectedClosure?(self?.dataList.first?.id)
            }
        } failure: { error in
            
        }
    }

}

extension ZBBSubsidyRegionTypeView: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ZBBSubsidyRegionTypeViewCollectionCell
        let model = dataList[indexPath.row]
        cell.imageView.kf.cancelDownloadTask()
        cell.imageView.kf.setImage(with: URL(string: APIURL.ossPicUrl + (model.logoUrl ?? "")), placeholder: UIImage(named: "loading"))
        cell.label.text = model.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataList[indexPath.row]
        selectedClosure?(model.id)
    }
}


fileprivate class ZBBSubsidyRegionTypeViewCollectionCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var label: UILabel!
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        
        imageView = UIImageView()
        imageView.layer.cornerRadius = 4
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.hexColor("#007E41").cgColor
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.right.equalTo(0)
            make.height.equalTo(70)
        }
        
        label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .hexColor("#6F7A75")
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.left.right.equalTo(0)
            make.height.equalTo(16)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            imageView.layer.borderWidth = isSelected ? 1 : 0
            label.font = isSelected ? .systemFont(ofSize: 12, weight: .medium) : .systemFont(ofSize: 12)
            label.textColor = isSelected ? .hexColor("#007E41") : .hexColor("#6F7A75")
        }
    }
    
}
