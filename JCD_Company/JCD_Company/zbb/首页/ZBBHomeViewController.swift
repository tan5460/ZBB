//
//  ZBBHomeViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/20.
//

import UIKit
import MJRefresh
import ObjectMapper

class ZBBHomeViewController: BaseViewController {
    
    private var backImageView: UIImageView!
    
    private var logoIcon: UIImageView!
    private var searchBtn: UIButton!
    private var scanBtn: UIButton!
    
    private var layout: CollectionWaterLayout!
    private var collectionView: UICollectionView!
    private var headerView: ZBBHomeHeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        refreshData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func createViews() {
        view.backgroundColor = .white

        backImageView = UIImageView(image: UIImage(named: "home_top_bg"))
        view.addSubview(backImageView)
        backImageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(156.5)
        }

        logoIcon = UIImageView(image: UIImage(named: "zbb_logo"))
        view.addSubview(logoIcon)
        logoIcon.snp.makeConstraints { make in
            make.top.equalTo(PublicSize.kStatusBarHeight + 6.5)
            make.left.equalTo(14)
            make.width.height.equalTo(31)
        }

        searchBtn = UIButton(type: .custom)
        searchBtn.layer.cornerRadius = 15.5
        searchBtn.layer.masksToBounds = true
        searchBtn.backgroundColor = .white
        searchBtn.addTarget(self, action: #selector(searchBtnAction(_:)), for: .touchUpInside)
        view.addSubview(searchBtn)
        searchBtn.snp.makeConstraints { make in
            make.top.equalTo(PublicSize.kStatusBarHeight + 6.5)
            make.left.equalTo(logoIcon.snp.right).offset(10)
            make.height.equalTo(31)
            make.right.equalTo(-46)
        }
        
        let searchIcon = UIImageView(image: UIImage(named: "item_search"))
        searchBtn.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(13)
        }
        
        let searchLabel = UILabel()
        searchLabel.text = "搜索你想要的内容"
        searchLabel.font = .systemFont(ofSize: 11)
        searchLabel.textColor = .hexColor("#999999")
        searchBtn.addSubview(searchLabel)
        searchLabel.snp.makeConstraints { make in
            make.left.equalTo(searchIcon.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }

        let scanImage = UIImage(named: "scan_icon")?.withRenderingMode(.alwaysTemplate)
        scanBtn = UIButton(type: .custom)
        scanBtn.tintColor = .white
        scanBtn.setImage(scanImage, for: .normal)
        scanBtn.addTarget(self, action: #selector(scanBtnAction(_:)), for: .touchUpInside)
        view.addSubview(scanBtn)
        scanBtn.snp.makeConstraints { make in
            make.top.bottom.equalTo(searchBtn)
            make.left.equalTo(searchBtn.snp.right)
            make.right.equalTo(-4)
        }

        layout = CollectionWaterLayout()
        layout.delegate = self
        layout.edgeInsets = UIEdgeInsets(top: 160, left: 10, bottom: 10, right: 10)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
        collectionView.register(ZBBHomeCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(PublicSize.kNavBarHeight)
            make.left.bottom.right.equalTo(0)
        }

        headerView = ZBBHomeHeaderView()
        collectionView.addSubview(headerView)
        headerView.snp.makeConstraints { make in
            make.top.left.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layout.edgeInsets = UIEdgeInsets(top: headerView.height + 10, left: 14, bottom: 10, right: 14)
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: - Action
    
    @objc private func searchBtnAction(_ sender: UIButton) {
        let vc = CurrencySearchController()
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc private func scanBtnAction(_ sender: UIButton) {
        let vc = ScanCodeController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Request
    
    private func refreshData() {
        requestBannerDataList {[weak self] model in
            self?.headerView.bannerList = model?.carouselList
        }
        requestHomeData {[weak self] model in
            self?.collectionView.mj_header?.endRefreshing()
            self?.headerView.model = model
            self?.collectionView.reloadData()
        }
    }
    
    ///请求banner数据
    private func requestBannerDataList(complete: ((_ model: AdvertModel?) -> Void)?) {
        YZBSign.shared.request(APIURL.advertList, method: .get, parameters: Parameters()) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let model = Mapper<AdvertModel>().map(JSON: dataDic as! [String : Any])
                complete?(model)
            }
        } failure: { (error) in
            
        }
    }
    
    private func requestHomeData(complete: ((_ model: MaterialsCorrcetModel?) -> Void)?) {
        YZBSign.shared.request(APIURL.getMaterialsList, success: {[weak self] response in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let model = Mapper<MaterialsCorrcetModel>().map(JSON: dataDic as! [String : Any])
                complete?(model)
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
                complete?(nil)
            }
        }) { error in
            complete?(nil)
        }
    }

}

extension ZBBHomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, CollectionWaterLayoutDelegate {
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        headerView.model?.data2?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ZBBHomeCollectionViewCell
        cell.model = headerView.model?.data2?[indexPath.row]
        return cell
    }
    
    func collectionWaterLayout(_ waterFlow: CollectionWaterLayout, heightForItemAt indexPath: IndexPath, itemWidth: CGFloat) -> CGFloat {
        ZBBHomeCollectionViewCell.cellHeight(model: headerView.model!.data2![indexPath.row], width: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = MaterialsDetailVC()
        vc.materialsModel = headerView.model!.data2![indexPath.row]
        navigationController?.pushViewController(vc)
    }
}
