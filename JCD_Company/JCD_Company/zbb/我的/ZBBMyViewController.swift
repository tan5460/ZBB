//
//  ZBBMyViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/22.
//

import UIKit
import ObjectMapper

class ZBBMyViewController: BaseViewController {
    
    private var backImageView: UIImageView!
    private var scrollView: UIScrollView!
    
    private var avatarImageView: UIImageView!
    private var nameLabel: UILabel!
    private var subsidyGradientLayer: CAGradientLayer!
    private var subsidyLabel: UILabel!
    private var msgBtn: UIButton!
    private var setBtn: UIButton!
    
    private var orderTitleLabel: UILabel!
    private var goodsOrderItemView: ZBBMyOrderItemView!
    
    private var toolsTitleLabel: UILabel!
    private var addressItemView: ZBBMyToolsItemView!
    
    private var subsidedAmount: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func createViews() {
        view.backgroundColor = .white
        
        backImageView = UIImageView(image: UIImage(named: "purchase_top_bg"))
        view.addSubview(backImageView)
        backImageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(156.0/375.0*SCREEN_WIDTH)
        }
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.mj_header = MJRefreshGifCustomHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(kStatusBarHeight)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        avatarImageView = UIImageView()
        avatarImageView.layer.cornerRadius = 30
        avatarImageView.layer.masksToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarImageViewGesture(_:))))
        scrollView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.left.equalTo(25)
            make.width.height.equalTo(60)
        }

        nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .hexColor("#131313")
        scrollView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(5)
            make.height.equalTo(25)
            make.left.equalTo(avatarImageView.snp.right).offset(10)
            make.right.lessThanOrEqualTo(-88)
        }
        
        subsidyGradientLayer = CAGradientLayer()
        subsidyGradientLayer.isHidden = true
        subsidyGradientLayer.cornerRadius = 10
        subsidyGradientLayer.masksToBounds = true
        subsidyGradientLayer.colors = [UIColor.hexColor("#F56C41").cgColor, UIColor.hexColor("#F5414F").cgColor]
        subsidyGradientLayer.startPoint = .zero
        subsidyGradientLayer.endPoint = CGPointMake(1, 0)
        scrollView.layer.addSublayer(subsidyGradientLayer)
        
        subsidyLabel = UILabel()
        subsidyLabel.font = .systemFont(ofSize: 12, weight: .bold)
        subsidyLabel.textColor = .white
        scrollView.addSubview(subsidyLabel)
        subsidyLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(7)
            make.left.equalTo(avatarImageView.snp.right).offset(15)
            make.height.equalTo(20)
        }

        msgBtn = UIButton(type: .custom)
        msgBtn.setImage(UIImage(named: "zbbt_my_msg"), for: .normal)
        msgBtn.addTarget(self, action: #selector(msgBtnAction(_:)), for: .touchUpInside)
        scrollView.addSubview(msgBtn)
        msgBtn.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.right.equalTo(-44)
            make.width.height.equalTo(36)
        }

        setBtn = UIButton(type: .custom)
        setBtn.setImage(UIImage(named: "zbbt_my_set"), for: .normal)
        setBtn.addTarget(self, action: #selector(setBtnAction(_:)), for: .touchUpInside)
        scrollView.addSubview(setBtn)
        setBtn.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.right.equalTo(-8)
            make.width.height.equalTo(36)
        }


        orderTitleLabel = UILabel()
        orderTitleLabel.text = "订单管理"
        orderTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        orderTitleLabel.textColor = .hexColor("#01884D")
        scrollView.addSubview(orderTitleLabel)
        orderTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(60)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }

        goodsOrderItemView = ZBBMyOrderItemView()
        goodsOrderItemView.titleLabel.text = "商品订单"
        goodsOrderItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goodsOrderItemViewGesture(_:))))
        scrollView.addSubview(goodsOrderItemView)
        goodsOrderItemView.snp.makeConstraints { make in
            make.top.equalTo(orderTitleLabel.snp.bottom).offset(5)
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.width.equalTo(SCREEN_WIDTH - 50)
        }
        
        
        toolsTitleLabel = UILabel()
        toolsTitleLabel.text = "工具与服务"
        toolsTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        toolsTitleLabel.textColor = .hexColor("#01884D")
        scrollView.addSubview(toolsTitleLabel)
        toolsTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(goodsOrderItemView.snp.bottom).offset(25)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }

        addressItemView = ZBBMyToolsItemView()
        addressItemView.imageView.image = UIImage(named: "purchase_address")
        addressItemView.titleLabel.text = "地址管理"
        addressItemView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addressItemViewGesture(_:))))
        scrollView.addSubview(addressItemView)
        addressItemView.snp.makeConstraints { make in
            make.top.equalTo(toolsTitleLabel.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.width.equalTo(55)
            make.bottom.equalTo(0)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        subsidyGradientLayer.isHidden = false
        subsidyGradientLayer.frame = CGRectMake(subsidyLabel.x - 8, subsidyLabel.y, subsidyLabel.width + 16, 20)
        CATransaction.commit()
    }
    
    private func refreshViews() {
        let placeImage = UserData.shared.userInfoModel?.worker?.sex?.intValue == 2 ? UIImage(named: "headerImage_woman") : UIImage(named: "headerImage_man")
        avatarImageView.kf.setImage(with: URL(string: APIURL.ossPicUrl + (UserData.shared.userInfoModel?.worker?.headUrl ?? "")), placeholder: placeImage)
        nameLabel.text = UserData.shared.userInfoModel?.worker?.realName
        subsidyLabel.text = String(format: "已获补贴%@元", subsidedAmount.notRoundingString(afterPoint: 2))
        
    }

}

//MARK: -
fileprivate extension ZBBMyViewController {
    
    @objc func avatarImageViewGesture(_ sender: UIButton) {
        let vc = UserInfoController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func msgBtnAction(_ sender: UIButton) {
        let vc = MessageNotiVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func setBtnAction(_ sender: UIButton) {
        let vc = MoreViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func goodsOrderItemViewGesture(_ sender: UIButton) {
        let vc = PurchaseViewController()
        vc.orderDetailType = .cg
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addressItemViewGesture(_ sender: UIButton) {
        let vc = HouseViewController()
        vc.title = "我的工地"
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: -
fileprivate extension ZBBMyViewController {
    
    func refreshData() {
        requestUserInfo {[weak self] model in
            if let model = model {
                UserData.shared.userInfoModel = model
            }
            self?.scrollView.mj_header?.endRefreshing()
            self?.refreshViews()
        }
        
        requestSubsidyInfo {[weak self] subsidedAmount in
            self?.subsidedAmount = subsidedAmount
            self?.refreshViews()
        }
    }
    
    func requestUserInfo(complete: ((_ model: BaseUserInfoModel?) -> Void)?) {
        YZBSign.shared.request(APIURL.getUserInfo, success: { response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let infoModel = Mapper<BaseUserInfoModel>().map(JSON: dataDic as! [String: Any])
                UserData.shared.userInfoModel = infoModel
                complete?(infoModel)
            } else {
                complete?(nil)
            }
        }) { error in
            complete?(nil)
        }
    }
    
    func requestSubsidyInfo(complete: ((_ subsidedAmount: Double) -> Void)?) {
        YZBSign.shared.request(APIURL.zbbSubsidedAmount, success: { response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let amount = dataDic["subsidedAmount"] as? Double ?? 0
                complete?(amount)
            }
        }) { error in
           
        }
    }
}

//MARK: - 

fileprivate class ZBBMyOrderItemView: UIView {
    
    var titleLabel: UILabel!
    private var moreIcon: UIImageView!
    private var separatorLine: UIView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .hexColor("#333333")
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(0)
            make.height.equalTo(20)
            make.bottom.equalTo(-15)
        }
        
        moreIcon = UIImageView(image: UIImage(named: "purchase_arrow"))
        addSubview(moreIcon)
        moreIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(0)
        }
        
        separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#C1F8E0")
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
}


//MARK: -

fileprivate class ZBBMyToolsItemView: UIView {
    
    var imageView: UIImageView!
    var titleLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        
        imageView = UIImageView()
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(45)
        }
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .hexColor("#333333")
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.left.right.equalTo(0)
            make.height.equalTo(16)
            make.bottom.equalTo(0)
        }
    }
}
