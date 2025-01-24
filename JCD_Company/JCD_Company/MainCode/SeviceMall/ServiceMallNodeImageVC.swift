//
//  ServiceMallNodeImageVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/15.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import MJRefresh
import Alamofire

class ServiceMallNodeImageVC: BaseViewController {

    var nodeModel: NodeDataListModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "节点图片"
        configCollectionViews()
    }
    
    private var collectionView: UICollectionView!
    func configCollectionViews() {
        let layout = UICollectionViewFlowLayout.init()
        let w: CGFloat = (view.width-39)/2
        layout.itemSize = CGSize(width: w, height: 120)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 14, bottom: 15, right: 14)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 10.0
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout).backgroundColor(.kBackgroundColor)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: ServiceMallNodeImageCell.self)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.sv(collectionView)
        view.layout(
            0,
            |collectionView|,
            0
        )
        prepareNoDateView("暂无数据")
        noDataView.isHidden = true
    }
}

extension ServiceMallNodeImageVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let fileUrls = nodeModel?.fileUrls
        let fileUrlArr = fileUrls?.components(separatedBy: ",")
        return fileUrlArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fileUrls = nodeModel?.fileUrls
        let fileUrlArr = fileUrls?.components(separatedBy: ",")
        let cell = collectionView.dequeueReusableCell(withClass: ServiceMallNodeImageCell.self, for: indexPath)
        cell.imageStr = fileUrlArr?[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let phoneVC = IMUIImageBrowserController()
        let fileUrls = nodeModel?.fileUrls
        let fileUrlArr = fileUrls?.components(separatedBy: ",")
        let urlStr = APIURL.ossPicUrl + (fileUrlArr?[indexPath.row] ?? "")
        let url = URL.init(string: urlStr)
        if let url1 = url {
            phoneVC.imageArr = [url1]
            phoneVC.imgCurrentIndex = 0
            phoneVC.title = "查看大图"
            phoneVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(phoneVC)
        }
    }
}


class ServiceMallNodeImageCell: UICollectionViewCell {
    
    var imageStr: String? {
        didSet {
            if !iv.addImage(imageStr) {
                iv.image(#imageLiteral(resourceName: "loading_rectangle"))
            }
        }
    }
    private let iv = UIImageView().image(#imageLiteral(resourceName: "loading_rectangle"))
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sv(iv)
        layout(
            0,
            |iv|,
            0
        )
        iv.contentMode = .scaleAspectFit
        iv.cornerRadius(3).masksToBounds()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
