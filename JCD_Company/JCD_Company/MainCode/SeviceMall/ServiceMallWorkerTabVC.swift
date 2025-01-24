//
//  ServiceMallWorkerTabVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/3.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh

protocol ServiceMallWorkerTabVCDelegate: NSObjectProtocol {
    func waterfallViewController(_ viewController: ServiceMallWorkerTabVC, scrollViewDidScroll scrollView: UIScrollView)
}

class ServiceMallWorkerTabVC: ZFMultiTabChildPageViewController {
    
    var collectionViewTopPadding: CGFloat = 0
    var beginPoint: CGPoint = CGPoint.zero // 记录开始滑动的起始点
    weak var delegate: ServiceMallWorkerTabVCDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 14, bottom: 10, right: 14)
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 10.0
        let viewHeight: CGFloat = UIScreen.main.bounds.size.height - ServiceMallVC.Constants.titleBarHeight - ServiceMallVC.Constants.tabViewHeight
        let frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: viewHeight)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        return collectionView
    }()

    //MARK: - Private Property
    private var toIndex: Int = 0
    public var index: Int = 0
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configSubviews()
        if index == 0 {
            loadData()
        }
    }
    
    deinit {
        print("ServiceMallWorkerTabVC")
    }
    
    //MARK: - Public Mehtods
    
    //MARK: - Override FCCommonTabChildViewController
    override var offsetY: CGFloat {
        set {
            collectionView.contentOffset = CGPoint(x: 0, y: newValue)
        }
        get {
            return collectionView.contentOffset.y
        }
    }
    
    override var isCanScroll: Bool {
        didSet{
            if isCanScroll {
                collectionView.setContentOffset(CGPoint(x: 0, y: offsetY), animated: false)
            }
        }
    }
    
    override func getScrollView() -> UIScrollView? {
        return collectionView
    }
    private var current: Int = 1
    private var size: Int = 20
    var dataSource = [WorkTeamModel?]()
    //MARK: - Data
    public func loadData() {
        let workTypes = AppData.workTypes
        let workType = workTypes[index]
        var parameters = Parameters()
        parameters["serviceType"] = "5"
        parameters["workType"] = Utils.getReadString(dir: workType, field: "value")
        parameters["current"] = current
        parameters["size"] = size
        parameters["sortType"] = 3
        YZBSign.shared.request(APIURL.getServiceWorkerPage, method: .get, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let pageModel = BasePageModel.deserialize(from: model?.data as? [String: Any])
                let teamModels = [WorkTeamModel].deserialize(from:pageModel?.records) ?? [WorkTeamModel]()
                if self.current == 1 {
                    self.dataSource = teamModels
                } else {
                    self.dataSource.append(contentsOf: teamModels)
                }
                self.collectionView.mj_header?.endRefreshing()
                if pageModel?.pages ?? 0 > pageModel?.current ?? 0 {
                    self.collectionView.mj_footer?.endRefreshing()
                } else {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }
                self.noDataView.isHidden = self.dataSource.count > 0
                self.collectionView.mj_footer?.isHidden = self.dataSource.count == 0
                self.collectionView.reloadData()
            } else {
                self.collectionView.mj_header?.endRefreshing()
                self.collectionView.mj_footer?.endRefreshing()
            }
            
        }) { (error) in
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
        }
    }
    
    @objc func headerRefresh() {
        collectionView.mj_footer?.resetNoMoreData()
        current = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        current += 1
        loadData()
    }
    
    private func loadMoreData() {
        
    }
    
    //MARK: - Private Mehtods
    private func configSubviews() {
        
        
        self.view.backgroundColor = .white
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ServiceMallWorkerTabItem.self, forCellWithReuseIdentifier: NSStringFromClass(ServiceMallWorkerTabItem.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.mj_header = MJRefreshGifCustomHeader()
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        collectionView.mj_footer = MJRefreshAutoNormalFooter()
        collectionView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        prepareNoDateView("暂无数据")
        noDataView.isHidden = true
    }
    
}
extension ServiceMallWorkerTabVC: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.commonTabChildViewController(self, scrollViewDidScroll: scrollView)
        delegate?.waterfallViewController(self, scrollViewDidScroll: scrollView)
    }
}

extension ServiceMallWorkerTabVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = dataSource[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ServiceMallWorkerTabItem.self), for: indexPath) as? ServiceMallWorkerTabItem {
            cell.model = model
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        let vc = ServiceMallWorkerDetailVC()
        vc.id = model?.id
        vc.detailType = .worker
        navigationController?.pushViewController(vc)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: view.width, height: 100)
        return size
    }
}


class ServiceMallWorkerTabItem: UICollectionViewCell {
    
    var model: WorkTeamModel? {
        didSet {
            configViews()
        }
    }
    
    private var avatarIV = UIImageView().image(#imageLiteral(resourceName: "img_buyer")).cornerRadius(60/2).masksToBounds()
    private var nameLabel = UILabel().text("严结阳").textColor(.kColor33).font(14)
    private var tipLabel1 = UILabel().text("水暖工、从业8年").textColor(.kColor66).font(10)
    private var messageBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_wechat"))
    private var phoneBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_phone"))
    private var line = UIView().backgroundColor(.kColor220)
    
    func configViews() {
        avatarIV.addImage(model?.headUrl)
        nameLabel.text(model?.name ?? "未知")
        var workTypeStr = ""
        let workTypeArr = model?.workType?.components(separatedBy: ",")
        workTypeArr?.forEach({ (tmpWorkType) in
            AppData.workTypes.forEach { (dic) in
                if tmpWorkType == Utils.getReadString(dir: dic, field: "value") {
                    let workTypeLabel = Utils.getReadString(dir: dic, field: "label")
                    if workTypeStr == "" {
                        workTypeStr += workTypeLabel
                    } else {
                        workTypeStr += "、\(workTypeLabel)"
                    }
                }
            }
        })
        tipLabel1.text("\(workTypeStr)、从业\(model?.workingYears ?? 0)年")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func initViews() {
        contentView.backgroundColor = .clear
        contentView.sv(avatarIV, nameLabel, tipLabel1, messageBtn, phoneBtn, line)
        |-26-avatarIV.size(60).centerVertically()
        tipLabel1.numberOfLines(0).lineSpace(2)
        contentView.layout(
            33,
            |-101-nameLabel.height(14),
            10,
            |-101-tipLabel1-95-|,
            >=0,
            |line| ~ 0.6,
            0
        )
        messageBtn.size(30).centerVertically()-15-phoneBtn.size(30).centerVertically()-15-|
        messageBtn.addTarget(self, action: #selector(messageBtnClick(btn:)))
        phoneBtn.addTarget(self, action: #selector(phoneBtnClick(btn:)))
    }
    
    
    
    @objc private func messageBtnClick(btn: UIButton) {
        let vc = parentController as? BaseViewController
        vc?.updConsultNumRequest(id: model?.id ?? "")
        vc?.messageBtnClick(userId: model?.id, userName: model?.userName, storeName: model?.name, headUrl: model?.headUrl, nickname: model?.userName, tel1: model?.mobile, tel2: "")
    }
    
    @objc private func phoneBtnClick(btn: UIButton) {
        let vc = parentController as? BaseViewController
        vc?.houseListCallTel(name: model?.name ?? "", phone: model?.mobile ?? "")
    }
}
