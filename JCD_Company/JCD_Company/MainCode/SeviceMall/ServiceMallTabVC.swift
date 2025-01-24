//
//  ServiceMallTabVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/2.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import MJRefresh

protocol ServiceMallTabVCDelegate: NSObjectProtocol {
    func waterfallViewController(_ viewController: ServiceMallTabVC, scrollViewDidScroll scrollView: UIScrollView)
}

class ServiceMallTabVC: ZFMultiTabChildPageViewController {
    
    var collectionViewTopPadding: CGFloat = 0
    var beginPoint: CGPoint = CGPoint.zero // 记录开始滑动的起始点
    weak var delegate: ServiceMallTabVCDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 14, bottom: 10, right: 14)
        layout.minimumLineSpacing = 10.0
      //  layout.minimumInteritemSpacing = 10.0
        let viewHeight: CGFloat = UIScreen.main.bounds.size.height - ServiceMallVC.Constants.titleBarHeight - ServiceMallVC.Constants.tabViewHeight-PublicSize.kTabBarHeight
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
        print("ServiceMallTabVC")
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
    var dataSource = [ServiceTypeModel?]()
    //MARK: - Data
    public func loadData() {
        
        var serviceType = ""
        AppData.serviceTypes.forEach { (dic) in
            if title == Utils.getReadString(dir: dic, field: "label") {
                serviceType = Utils.getReadString(dir: dic, field: "value")
            }
        }
        var parameters = Parameters()
        parameters["serviceType"] = serviceType
        parameters["current"] = current
        parameters["size"] = size
        if index == 0 {
            parameters["sortType"] = 3
        } else if index == 1 {
            parameters["sortType"] = 1
        }
        YZBSign.shared.request(APIURL.getServiceMerchantPage, method: .get, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                let pageModel = BasePageModel.deserialize(from: model?.data as? [String: Any])
                let serviceTypeModels = [ServiceTypeModel].deserialize(from:pageModel?.records) ?? [ServiceTypeModel]()
                if self.current == 1 {
                    self.dataSource = serviceTypeModels
                } else {
                    self.dataSource.append(contentsOf: serviceTypeModels)
                }
                self.collectionView.mj_header?.endRefreshing()
                if pageModel?.pages ?? 0 > pageModel?.current ?? 0 {
                    self.collectionView.mj_footer?.endRefreshing()
                } else {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }
                self.noDataBtn.isHidden = self.dataSource.count > 0
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

    private func loadMoreData() {
        
    }
    private let noDataBtn = UIButton()
    //MARK: - Private Mehtods
    private func configSubviews() {
        
        
        self.view.backgroundColor = .white
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ServiceMallTabItem.self, forCellWithReuseIdentifier: NSStringFromClass(ServiceMallTabItem.self))
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        collectionView.mj_header = MJRefreshGifCustomHeader()
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        collectionView.mj_footer = MJRefreshAutoNormalFooter()
        collectionView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        
        noDataBtn.image(#imageLiteral(resourceName: "icon_empty")).text("暂无数据～").textColor(.kColor66).font(14)
        collectionView.sv(noDataBtn)
        noDataBtn.width(200).height(200)
        noDataBtn.centerInContainer()
        noDataBtn.layoutButton(imageTitleSpace: 20)
        noDataBtn.isHidden = true
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
    
}
extension ServiceMallTabVC: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        beginPoint = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.commonTabChildViewController(self, scrollViewDidScroll: scrollView)
        delegate?.waterfallViewController(self, scrollViewDidScroll: scrollView)
    }
}

extension ServiceMallTabVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = dataSource[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ServiceMallTabItem.self), for: indexPath) as? ServiceMallTabItem {
            cell.model = model
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        switch title {
        case "装饰公司", "仓储物流", "安装":
            noticeOnlyText("开发中，敬请期待～")
        case "工人":
            let vc = ServiceMallWorkerDetailVC()
            vc.id = model?.id
            vc.detailType = .worker
            navigationController?.pushViewController(vc)
        case "设计师":
            let vc = ServiceMallWorkerDetailVC()
            vc.id = model?.id
            vc.detailType = .design
            navigationController?.pushViewController(vc)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: (UIScreen.main.bounds.size.width - 28), height: 95)
        return size
    }
}


class ServiceMallTabItem: UICollectionViewCell {
    var model: ServiceTypeModel? {
        didSet {
            configViews()
        }
    }
    private var avatarIV = UIImageView().image(#imageLiteral(resourceName: "img_buyer")).cornerRadius(65/2).masksToBounds()
    private var nameLabel = UILabel().textColor(.kColor33).font(14)
    private var starsView = UIView()
    private var tipsView = UIView()
    private var messageBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_wechat"))
    private var phoneBtn = UIButton().image(#imageLiteral(resourceName: "service_mall_phone"))
    
    func configViews() {
        if !avatarIV.addImage(model?.headUrl) {
            avatarIV.image(#imageLiteral(resourceName: "img_buyer"))
        }
        nameLabel.text(model?.name ?? "未知")
//        if model?.serviceType == "5" {
//            [phoneBtn, messageBtn].forEach {
//                $0.isHidden = true
//            }
//        }
        [tipLabel1, tipLabel2, tipLabel3].forEach {
            $0.isHidden = true
        }
        let labels = model?.individualLabels?.components(separatedBy: ",")
        labels?.enumerated().forEach({ (item) in
            let index = item.offset
            let label = item.element
            if index == 0 {
                if !label.isEmpty {
                    tipLabel1.isHidden = false
                    tipLabel1.text(label)
                }
            }
            if index == 1 {
                tipLabel2.isHidden = false
                tipLabel2.text(label)
            }
            if index == 2 {
                tipLabel3.isHidden = false
                tipLabel3.text(label)
            }
        })
        
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
    let tipLabel1 = UILabel().text("").textColor(.white).font(10).textAligment(.center).backgroundColor(.kFFAB3D).cornerRadius(2).masksToBounds()
    let tipLabel2 = UILabel().text("").textColor(.white).font(10).textAligment(.center).backgroundColor(.kFFAB3D).cornerRadius(2).masksToBounds()
    let tipLabel3 = UILabel().text("").textColor(.white).font(10).textAligment(.center).backgroundColor(.kFFAB3D).cornerRadius(2).masksToBounds()
    private func initViews() {
        contentView.backgroundColor = .kF6F6F6
        contentView.cornerRadius(5).masksToBounds()
        contentView.sv(avatarIV, nameLabel, starsView, tipsView, messageBtn, phoneBtn)
        |-15-avatarIV.size(65).centerVertically()
        contentView.layout(
            15,
            |-95-nameLabel.height(14),
            11.5,
            |-95-starsView.height(12)|,
            11.5,
            |-95-tipsView.height(16)|,
            >=0
        )
        let starIV = UIImageView().image(#imageLiteral(resourceName: "service_mall_star"))
        let starLabel = UILabel().text("5.0").textColor(.kColor66).font(10)
        starsView.sv(starIV, starLabel)
        starsView.layout(
            0,
            |starIV-8-starLabel.height(10).centerVertically(),
            0
        )
        
        tipsView.sv(tipLabel1, tipLabel2, tipLabel3)
        tipsView.layout(
            0,
            |tipLabel1.width(50).height(16)-5-tipLabel2.width(50).height(16)-5-tipLabel3.width(50).height(16),
            0
        )
        tipLabel1.isHidden = true
        tipLabel2.isHidden = true
        tipLabel3.isHidden = true
        messageBtn.size(30).centerVertically()-15-phoneBtn.size(30).centerVertically()-15-|
        messageBtn.addTarget(self, action: #selector(messageBtnClick(btn:)))
        phoneBtn.addTarget(self, action: #selector(phoneBtnClick(btn:)))
    }
    
    @objc private func messageBtnClick(btn: UIButton) {
        let userId = model?.id ?? ""
        let userName = model?.userName ?? ""
        let storeName = model?.name ?? ""
        let headUrl = model?.headUrl ?? ""
        let nickname = model?.userName ?? ""
        let tel1 = model?.servicephone ?? ""
        let tel2 = ""
        let storeType = "2"
        
        let ex: NSDictionary = ["detailTitle": storeName, "headUrl":headUrl, "tel1": tel1, "tel2": tel2, "storeType": storeType, "userId": userId]
        
        let user = JMSGUserInfo()
        user.nickname = nickname
        user.extras = ex as! [AnyHashable : Any]
        
        let vc = parentController as? BaseViewController
        vc?.updConsultNumRequest(id: userId)
        YZBChatRequest.shared.createSingleMessageConversation(username: userName) { (conversation, error) in
            
            if error == nil {
                
                if let userInfo = conversation?.target as? JMSGUser {
                    
                    let userName = userInfo.username
                    self.pleaseWait()
                    
                    YZBChatRequest.shared.getUserInfo(with: userName) { (user, error) in
                        self.clearAllNotice()
                        if error == nil {
                            let vc = ChatMessageController(conversation: conversation!)
                            vc.convenUser = user
                           // vc.materialModel = self.materialsModel
                            self.parentController?.navigationController?.pushViewController(vc)
                        }
                    }
                }
                
            }else {
                if error!._code == 898002 {
                    
                    YZBChatRequest.shared.register(with: userName, pwd: YZBSign.shared.passwordMd5(password: userName), userInfo: user, errorBlock: { (error) in
                        if error == nil {
                            self.messageBtnClick(btn: UIButton())
                        }
                    })
                }
            }
        }
    }
    
    @objc private func phoneBtnClick(btn: UIButton) {
        let vc = parentController as? BaseViewController
        vc?.houseListCallTel(name: model?.name ?? "未知", phone: model?.servicephone ?? "")
    }
}

