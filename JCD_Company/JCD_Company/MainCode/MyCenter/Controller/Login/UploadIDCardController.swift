//
//  UploadIDCardController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/3/16.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog
import Kingfisher
import ObjectMapper
import TLTransitions


class UploadIDCardController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AliPayBack {
    func finish(_ result: String?) {
        self.authSuccessPopView()
        let resultArr = result?.components(separatedBy: "&")
        resultArr?.forEach({ (str) in
            if str.length > 15 && str.hasPrefix("alipay_open_id=") {
                self.openId = str.subString(from: 15)
                self.authLoginType = 2
                self.wechatAuthLabel.isHidden = true
                self.zfbAuthLabel.isHidden = false
            }
        })
    }
    
    func failed() {
        
    }
    
    
    
    private var authLoginType = 0  //  1.微信 2.支付宝
    private var openId = "" // 支付宝 微信授权 openid
    private var pop: TLTransition?
    
    var isThirdLogin: Bool = false
    var type: String = "2"                 //1公司注册2个人注册
    var companyView: UIView!                   //公司名
    var companyTF: UITextField!
    
    var contactsView: UIView!                  //联系人
    var contactsTF: UITextField!
    
    var addLicenseBtn: UIButton!                //添加营业执照按钮
    var addLicenseHint: UILabel!                //添加营业执照提示
    var licenseImageView: UIImageView!          //营业执照
    
    var addLogoBtn: UIButton!                //添加Logo按钮
    var addLogoHint: UILabel!                //添加Logo提示
    var logoImageView: UIImageView!          //Logo
    
    var addCardFBtn: UIButton!                  //添加身份证正面按钮
    var addCardFHint: UILabel!                  //添加营业执照提示
    var cardFImageView: UIImageView!            //身份证正面
    var addCardBBtn: UIButton!                  //添加身份证背面按钮
    var addCardBHint: UILabel!                  //添加营业执照提示
    var cardBImageView: UIImageView!            //身份证背面
    
    var cameraPicker: UIImagePickerController!
    var photoPicker: UIImagePickerController!
    
    var workerModel: WorkerModel?
    var regiestBaseModel: RegisterBaseModel?
    var optionType: Int = 1                     //操作类型 1.营业执照 2.身份证正面 3.身份证反面 4.logo
    var detailImage: UIImage?                   //需查看的详情图
    
    var isChange:Bool = false
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>> 上传界面释放 <<<<<<<<<<<<<<<<<<<")
    }
    
    var viewModel: UploadIDCardViewModel!
    @objc func back() {
//        navigationController?.viewControllers.forEach({ (vc) in
//            if vc.isKind(of: LoginViewController.classForCoder()) {
//                navigationController?.popToViewController(vc, animated: true)
//            }
//        })
        navigationController?.popViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(back))
        
        title = "身份认证"
        view.backgroundColor(.kBackgroundColor)
        viewModel = UploadIDCardViewModel()
        viewModel.delegate = self
        
        //相机
        cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        if Utils.isSimulator == false {
            cameraPicker.sourceType = .camera
        }
        
        //相册
        photoPicker =  UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        
        createSubView()
        
        if let valueStr = workerModel?.yzbRegister?.licenseUrl {

            if valueStr != "" {

                addLicenseBtn.isHidden = true
                addLicenseHint.isHidden = true
                licenseImageView.isHidden = true

                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                licenseBackView.kf.setImage(with: imageUrl)
            }
        } else if let valueStr = regiestBaseModel?.registerRData?.licenseUrl {
            if valueStr != "" {
                addLicenseBtn.isHidden = true
                addLicenseHint.isHidden = true
                licenseImageView.isHidden = true
                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                licenseBackView.kf.setImage(with: imageUrl)
            }
        }
        
        if let valueStr = workerModel?.yzbRegister?.storeLogo {

            if valueStr != "" {
                addLogoBtn.isHidden = true
                addLogoHint.isHidden = true
                logoImageView.isHidden = true

                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                logoBackView.kf.setImage(with: imageUrl)
            }
        } else if let valueStr = regiestBaseModel?.registerRData?.storeLogo {
            if valueStr != "" {
                addLogoBtn.isHidden = true
                addLogoHint.isHidden = true
                logoImageView.isHidden = true

                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                logoBackView.kf.setImage(with: imageUrl)
            }
        }
        
        if let valueStr = workerModel?.yzbRegister?.idcardpicUrlF {
            
            if valueStr != "" {
                
                addCardFBtn.isHidden = true
                addCardFHint.isHidden = true
                cardFImageView.isHidden = true
                
                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                idCardBackViewF.kf.setImage(with: imageUrl)
            }
        } else if let valueStr = regiestBaseModel?.registerRData?.idcardpicUrlF {
            
            if valueStr != "" {
                
                addCardFBtn.isHidden = true
                addCardFHint.isHidden = true
                cardFImageView.isHidden = true
                
                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                idCardBackViewF.kf.setImage(with: imageUrl)
            }
        }
        
        if let valueStr = workerModel?.yzbRegister?.idcardpicUrlB {
            
            if valueStr != "" {
                addCardBBtn.isHidden = true
                addCardBHint.isHidden = true
                cardBImageView.isHidden = true
                
                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                idCardBackViewB.kf.setImage(with: imageUrl)
            }
        } else if let valueStr = regiestBaseModel?.registerRData?.idcardpicUrlB {
            
            if valueStr != "" {
                addCardBBtn.isHidden = true
                addCardBHint.isHidden = true
                cardBImageView.isHidden = true
                
                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                idCardBackViewB.kf.setImage(with: imageUrl)
            }
        }
    }
    private let licenseTitleLabel = UILabel()
    private let licenseBackView = UIImageView().image(#imageLiteral(resourceName: "regiest_com_photo_bg"))
    private let logoTitleLabel = UILabel()
    private let  logoBackView = UIImageView().image(#imageLiteral(resourceName: "regiest_com_logo_bg"))
    private let idCardTitleLabel = UILabel()
    private let idCardBackViewF = UIImageView().image(#imageLiteral(resourceName: "regiest_id_face_bg"))
    private let idCardBackViewB = UIImageView().image(#imageLiteral(resourceName: "regiest_id_back_bg"))
    private let zfbBtn = UIButton().text("支付宝").textColor(.kColor66).font(14).image(#imageLiteral(resourceName: "login_zfb"))
    private let wechatBtn = UIButton().text("微信").textColor(.kColor66).font(14).image(#imageLiteral(resourceName: "login_wechat"))
    private let zfbAuthLabel = UILabel().text("（授权成功）").textColor(UIColor.hexColor("#1DC597")).font(12)
    private let wechatAuthLabel = UILabel().text("（授权成功）").textColor(UIColor.hexColor("#1DC597")).font(12)
    func createSubView() {
        
        let topTipIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_anquan_icon"))
        view.addSubview(topTipIcon)
        topTipIcon.snp.makeConstraints { (make) in
            make.top.equalTo(22)
            make.left.equalTo(14)
            make.size.equalTo(14)
        }
        let topTipLabel = UILabel().text("为了确保交易安全，我们需要认证您的身份，此信息会完全保密并不对外提供，只用于账号审核").textColor(.blue).font(12)
        if type == "1" {
            topTipLabel.text("身份证及营业执照只用于账号审核使用，不会泄露个人信息")
        }
        topTipLabel.numberOfLines(0).lineSpace(2)
        view.addSubview(topTipLabel)
        topTipLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(topTipIcon)
            make.left.equalTo(30)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(35)
        }
        companyView = UIView()
        companyView.backgroundColor = .white
        if type == "2" {
            companyView.isHidden = true
        }
        view.addSubview(companyView)
        
        companyView.snp.makeConstraints { (make) in
            make.top.equalTo(topTipLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        //公司名
        let companyIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_com_icon"))
        companyView.addSubview(companyIcon)
        companyIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(14)
            make.size.equalTo(17)
        }
        
//        let companyLabel = UILabel()
//        companyLabel.text = "公司名称"
//        companyLabel.textColor = PublicColor.minorTextColor
//        companyLabel.font = UIFont.systemFont(ofSize: 15)
//        companyView.addSubview(companyLabel)
//
//        companyLabel.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalTo(10)
//            make.width.equalTo(120)
//        }
       
        companyTF = UITextField()
        companyTF.placeholder = "请填写公司名称"
        companyTF.textAlignment = .left
        companyTF.font = UIFont.systemFont(ofSize: 15)
        companyView.addSubview(companyTF)
        companyTF.snp.makeConstraints { (make) in
            make.centerY.top.bottom.equalToSuperview()
            make.right.equalTo(-10)
            make.left.equalTo(companyIcon.snp.right).offset(8)
        }
        if workerModel != nil {
            companyTF.text = workerModel?.yzbRegister?.comName
        } else if regiestBaseModel != nil {
            companyTF.text = regiestBaseModel?.registerRData?.comName
        }
        
        let line = UIView()
        if type == "2" {
            line.isHidden = true
        }
        line.backgroundColor = PublicColor.backgroundViewColor
        view.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(companyView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }
        
        //联系人
        contactsView = UIView()
        if type == "2" {
            contactsView.isHidden = true
        }
        contactsView.backgroundColor = .white
        view.addSubview(contactsView)
        
        contactsView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            if type == "1" {
                make.top.equalTo(companyView.snp.bottom).offset(1)
            } else {
                make.top.equalTo(topTipLabel.snp.bottom).offset(10)
            }
        }
        
        //联系人
        
        //公司名
        let contactsIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_person_icon1"))
        contactsView.addSubview(contactsIcon)
        contactsIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(14)
            make.width.equalTo(15.6)
            make.height.equalTo(16.39)
        }
        
//        let contactsLabel = UILabel()
//        contactsLabel.text = "姓名"
//        contactsLabel.textColor = PublicColor.minorTextColor
//        contactsLabel.font = UIFont.systemFont(ofSize: 15)
//        contactsView.addSubview(contactsLabel)
//
//        contactsLabel.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalTo(10)
//            make.width.equalTo(120)
//        }
        
        contactsTF = UITextField()
        contactsTF.placeholder = "请填写法人姓名"
        if type == "2" {
            contactsTF.placeholder = "请填写姓名"
        }
        contactsTF.textAlignment = .left
        contactsTF.font = UIFont.systemFont(ofSize: 15)
        contactsView.addSubview(contactsTF)
        
        contactsTF.snp.makeConstraints { (make) in
            make.centerY.top.bottom.equalToSuperview()
            make.right.equalTo(-10)
            make.left.equalTo(contactsIcon.snp.right).offset(8.5)
        }
        if workerModel != nil {
            contactsTF.text = workerModel?.yzbRegister?.contacts
        } else if regiestBaseModel != nil {
            contactsTF.text = regiestBaseModel?.registerRData?.contacts
        }
        
    
        let uploadW = (PublicSize.screenWidth-50)/2
        let uploadH = uploadW*54/86
        //营业执照标题
        
        licenseTitleLabel.attributedText = String.attributedString(strs: ["*", "上传公司营业执照"], colors: [UIColor.red, PublicColor.minorTextColor], fonts: [.systemFont(ofSize: 15), .systemFont(ofSize: 15)])
        view.addSubview(licenseTitleLabel)
        
        licenseTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contactsView.snp.bottom).offset(15)
            make.left.equalTo(10)
        }
        
        //营业执照灰色背景
        let backColor = UIColor.init(red: 247.0/255, green: 248.0/255, blue: 249.0/255, alpha: 1)
        
        licenseBackView.isUserInteractionEnabled = true
        licenseBackView.backgroundColor = backColor
        licenseBackView.layer.cornerRadius = 5
        view.addSubview(licenseBackView)
        licenseBackView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(addLicenseAction)))
        licenseBackView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(licenseTitleLabel.snp.bottom).offset(15)
            make.width.equalTo(uploadW)
            make.height.equalTo(uploadH)
        }
        
        //添加营业执照按钮
        let addLicenseWidth: CGFloat = 50
        let addBtnColor = UIColor.init(red: 241.0/255, green: 90.0/255, blue: 90.0/255, alpha: 1)
        addLicenseBtn = UIButton(type: .custom)
        addLicenseBtn.setImage(#imageLiteral(resourceName: "regiest_avatar_bg"), for: .normal)
        addLicenseBtn.addTarget(self, action: #selector(addLicenseAction), for: .touchUpInside)
        licenseBackView.addSubview(addLicenseBtn)
        
        addLicenseBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(addLicenseWidth)
        }
        
        //添加营业执照标题
        addLicenseHint = UILabel()
        addLicenseHint.text = "请添加公司营业执照"
        addLicenseHint.textColor = PublicColor.minorTextColor
        addLicenseHint.font = UIFont.systemFont(ofSize: 14)
        licenseBackView.addSubview(addLicenseHint)
        addLicenseHint.snp.makeConstraints { (make) in
            make.top.equalTo(addLicenseBtn.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        addLicenseHint.isHidden = true
        //营业执照
        licenseImageView = UIImageView()
        licenseImageView.isHidden = true
        licenseImageView.isUserInteractionEnabled = true
        licenseImageView.contentMode = .scaleAspectFit
        licenseBackView.addSubview(licenseImageView)
        licenseImageView.isHidden = true
        licenseImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let licenseTapOne = UITapGestureRecognizer(target: self, action: #selector(switchLicenseAction))
        licenseTapOne.numberOfTapsRequired = 1
        licenseImageView.addGestureRecognizer(licenseTapOne)
        
        if type == "2" {
            
            licenseBackView.isHidden = true
            licenseBackView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(licenseTitleLabel.snp.bottom).offset(15)
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(0)
            }
            
            licenseTitleLabel.isHidden = true
            addLicenseBtn.isHidden = true
            addLicenseHint.isHidden = true
            licenseImageView.isHidden = true
        }
        
        
        //logo标题
        
        logoTitleLabel.text = "公司logo（选填）"
        logoTitleLabel.textColor = PublicColor.minorTextColor
        logoTitleLabel.font = UIFont.systemFont(ofSize: 15)
        view.addSubview(logoTitleLabel)
        
        logoTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(licenseTitleLabel)
            make.left.equalTo(uploadW+20)
        }
        
        //logo灰色背景
        
        logoBackView.isUserInteractionEnabled = true
        logoBackView.backgroundColor = backColor
        logoBackView.layer.cornerRadius = 5
        view.addSubview(logoBackView)
        logoBackView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(addLogoAction)))
        logoBackView.snp.makeConstraints { (make) in
            make.left.equalTo(uploadW+30)
            make.top.equalTo(logoTitleLabel.snp.bottom).offset(15)
            make.width.equalTo(uploadW)
            make.height.equalTo(uploadH)
        }
        
        //添加营业执照按钮
        let addLogoWidth: CGFloat = 50
        addLogoBtn = UIButton(type: .custom)
        addLogoBtn.setImage(#imageLiteral(resourceName: "regiest_avatar_bg"), for: .normal)
        addLogoBtn.addTarget(self, action: #selector(addLogoAction), for: .touchUpInside)
        logoBackView.addSubview(addLogoBtn)
        
        addLogoBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(addLogoWidth)
        }
        
        //添加营业执照标题
        addLogoHint = UILabel()
        addLogoHint.text = "请添加公司Logo"
        addLogoHint.textColor = PublicColor.minorTextColor
        addLogoHint.font = UIFont.systemFont(ofSize: 14)
        logoBackView.addSubview(addLogoHint)
        
        addLogoHint.snp.makeConstraints { (make) in
            make.top.equalTo(addLogoBtn.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        addLogoHint.isHidden = true
        //营业执照
        logoImageView = UIImageView()
        logoImageView.isHidden = true
        logoImageView.isUserInteractionEnabled = true
        logoImageView.contentMode = .scaleAspectFit
        logoBackView.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        logoImageView.isHidden = true
        let logoTapOne = UITapGestureRecognizer(target: self, action: #selector(switchLogoAction))
        logoTapOne.numberOfTapsRequired = 1
        logoImageView.addGestureRecognizer(logoTapOne)
        
        if type == "2" {
            
            logoBackView.isHidden = true
            logoBackView.snp.remakeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.top.equalTo(logoTitleLabel.snp.bottom).offset(15)
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(0)
            }
            
            logoTitleLabel.isHidden = true
            addLogoBtn.isHidden = true
            addLogoHint.isHidden = true
            logoImageView.isHidden = true
        }
        
        if isThirdLogin == false {
            //身份证标题
            idCardTitleLabel.attributedText = String.attributedString(strs: ["*", "上传法人身份证"], colors: [UIColor.red, PublicColor.minorTextColor], fonts: [.systemFont(ofSize: 15), .systemFont(ofSize: 15)])
            if type == "2" {
                idCardTitleLabel.attributedText = String.attributedString(strs: ["*", "上传身份证"], colors: [UIColor.red, PublicColor.minorTextColor], fonts: [.systemFont(ofSize: 15), .systemFont(ofSize: 15)])
            }
            view.addSubview(idCardTitleLabel)
            idCardTitleLabel.isHidden = false
            idCardTitleLabel.snp.makeConstraints { (make) in
                if type == "1" {
                    make.top.equalTo(licenseBackView.snp.bottom).offset(20)
                } else {
                    make.top.equalTo(contactsView.snp.bottom).offset(20)
                }
                make.left.equalTo(licenseTitleLabel)
            }

            //身份证正面背景
            let cardWidth = (PublicSize.screenWidth-50)/2
            idCardBackViewF.isUserInteractionEnabled = true
            idCardBackViewF.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(addCardFAction)))
            idCardBackViewF.backgroundColor = backColor
            idCardBackViewF.layer.cornerRadius = 5
            view.addSubview(idCardBackViewF)

            idCardBackViewF.snp.makeConstraints { (make) in
                make.top.equalTo(idCardTitleLabel.snp.bottom).offset(15)
                make.left.equalTo(licenseBackView)
                make.width.equalTo(cardWidth)
                make.height.equalTo(cardWidth*54/86)
            }

            //添加身份证正面按钮
            let addCardFWidth: CGFloat = 50
            addCardFBtn = UIButton(type: .custom)
            addCardFBtn.setImage(#imageLiteral(resourceName: "regiest_avatar_bg"), for: .normal)
            addCardFBtn.addTarget(self, action: #selector(addCardFAction), for: .touchUpInside)
            idCardBackViewF.addSubview(addCardFBtn)

            addCardFBtn.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.height.equalTo(addCardFWidth)
            }

            //添加身份证正面标题
            addCardFHint = UILabel()
            addCardFHint.text = "身份证正面照片"
            addCardFHint.textColor = PublicColor.minorTextColor
            addCardFHint.font = UIFont.systemFont(ofSize: 14)
            idCardBackViewF.addSubview(addCardFHint)
            addCardFHint.isHidden = true
            addCardFHint.snp.makeConstraints { (make) in
                make.top.equalTo(addCardFBtn.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
            }

            //身份证正面
            cardFImageView = UIImageView()
            cardFImageView.isHidden = true
            cardFImageView.isUserInteractionEnabled = true
            cardFImageView.contentMode = .scaleAspectFit
            idCardBackViewF.addSubview(cardFImageView)

            cardFImageView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            let cardFTapOne = UITapGestureRecognizer(target: self, action: #selector(switchCardFAction))
            cardFTapOne.numberOfTapsRequired = 1
            cardFImageView.addGestureRecognizer(cardFTapOne)

            //身份证背面背景
            idCardBackViewB.isUserInteractionEnabled = true
            idCardBackViewB.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(addCardBAction)))
            idCardBackViewB.backgroundColor = backColor
            idCardBackViewB.layer.cornerRadius = 5
            view.addSubview(idCardBackViewB)

            idCardBackViewB.snp.makeConstraints { (make) in
                make.top.width.height.equalTo(idCardBackViewF)
                make.right.equalTo(logoBackView.snp.right)
            }

            //添加身份证正面按钮
            addCardBBtn = UIButton(type: .custom)
            addCardBBtn.setImage(#imageLiteral(resourceName: "regiest_avatar_bg"), for: .normal)
            addCardBBtn.addTarget(self, action: #selector(addCardBAction), for: .touchUpInside)
            idCardBackViewB.addSubview(addCardBBtn)

            addCardBBtn.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
                make.width.height.equalTo(addCardFWidth)
            }

            //添加身份证背面提示
            addCardBHint = UILabel()
            addCardBHint.text = "身份证背面照片"
            addCardBHint.textColor = PublicColor.minorTextColor
            addCardBHint.font = UIFont.systemFont(ofSize: 14)
            idCardBackViewB.addSubview(addCardBHint)
            addCardBHint.isHidden = true
            addCardBHint.snp.makeConstraints { (make) in
                make.top.equalTo(addCardBBtn.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
            }

            //身份证背面
            cardBImageView = UIImageView()
            cardBImageView.isHidden = true
            cardBImageView.isUserInteractionEnabled = true
            cardBImageView.contentMode = .scaleAspectFit
            idCardBackViewB.addSubview(cardBImageView)

            cardBImageView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }

            let cardBTapOne = UITapGestureRecognizer(target: self, action: #selector(switchCardBAction))
            cardBTapOne.numberOfTapsRequired = 1
            cardBImageView.addGestureRecognizer(cardBTapOne)
        }
        
        
        let btnW: CGFloat = (view.width-90)/2
        let btnH: CGFloat = 90
        view.addSubview(zfbBtn)
        view.addSubview(wechatBtn)
        view.addSubview(zfbAuthLabel)
        view.addSubview(wechatAuthLabel)
        wechatBtn.snp.makeConstraints { (make) in
            make.top.equalTo(contactsView.snp.bottom).offset(50)
            make.left.equalTo(45)
            make.width.equalTo(btnW)
            make.height.equalTo(btnH)
        }
        
        wechatAuthLabel.snp.makeConstraints { (make) in
            make.top.equalTo(wechatBtn.snp.bottom).offset(2)
            make.centerX.equalTo(wechatBtn)
            make.height.equalTo(16.5)
        }
        
        zfbBtn.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(wechatBtn)
            make.left.equalTo(wechatBtn.snp.right)
        }
        
        zfbAuthLabel.snp.makeConstraints { (make) in
            make.top.equalTo(zfbBtn.snp.bottom).offset(2)
            make.centerX.equalTo(zfbBtn)
            make.height.equalTo(16.5)
        }
        
        zfbBtn.layoutButton(imageTitleSpace: 15)
        wechatBtn.layoutButton(imageTitleSpace: 15)
        zfbBtn.isHidden = true
        wechatBtn.isHidden = true
        zfbAuthLabel.isHidden = true
        wechatAuthLabel.isHidden = true
        //提交
        let backRedImg = PublicColor.gradualColorImage
        let saveBtn = UIButton.init(type: .custom)
        saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        saveBtn.setTitle("提交审核", for: .normal)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.setBackgroundImage(#imageLiteral(resourceName: "regiest_put_btn"), for: .normal)
        saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        view.addSubview(saveBtn)
        saveBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-80)
            make.width.equalTo(280)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        if type == "2" { // 个人登录的时候有切换身份授权按钮
            let switchBtn = UIButton().text("不想上传身份证？授权认证").textColor(UIColor.hexColor("#1DC597")).font(14)
            let switchIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_switch_btn"))
            view.addSubview(switchBtn)
            switchBtn.snp.makeConstraints { (make) in
                make.bottom.equalTo(saveBtn.snp.top).offset(-25)
                make.height.centerX.equalTo(saveBtn)
            }
            view.addSubview(switchIcon)
            switchIcon.snp.makeConstraints { (make) in
                make.centerY.equalTo(switchBtn)
                make.left.equalTo(switchBtn.snp.right).offset(5.5)
                make.size.equalTo(16)
            }
            switchBtn.tapped { [weak self] (btn) in
                if btn.titleLabel?.text == "使用身份证认证" {
                    btn.text("不想上传身份证？授权认证")
                    self?.idCardTitleLabel.isHidden = false
                    self?.idCardBackViewF.isHidden = false
                    self?.idCardBackViewB.isHidden = false
                    self?.zfbBtn.isHidden = true
                    self?.wechatBtn.isHidden = true
                    self?.zfbAuthLabel.isHidden = true
                    self?.wechatAuthLabel.isHidden = true
                } else {
                    btn.text("使用身份证认证")
                    self?.idCardTitleLabel.isHidden = true
                    self?.idCardBackViewF.isHidden = true
                    self?.idCardBackViewB.isHidden = true
                    self?.zfbBtn.isHidden = false
                    self?.wechatBtn.isHidden = false
                    if self?.openId == "" {
                        self?.zfbAuthLabel.isHidden = true
                        self?.wechatAuthLabel.isHidden = true
                    } else {
                        if self?.authLoginType == 1 {
                            self?.wechatAuthLabel.isHidden = false
                            self?.zfbAuthLabel.isHidden = true
                        } else {
                            self?.wechatAuthLabel.isHidden = true
                            self?.zfbAuthLabel.isHidden = false
                        }
                    }
                    
                }
            }
        }
        
        wechatBtn.tapped { [weak self] (btn) in
            LDWechatShare.login({ (response) in
                self?.authSuccessPopView()
                debugPrint(response)
                self?.authLoginType = 1
                self?.openId = Utils.getReadString(dir: response as NSDictionary, field: "openid")
                self?.wechatAuthLabel.isHidden = false
                self?.zfbAuthLabel.isHidden = true
            }) { (errorStr) in
                self?.noticeOnlyText(errorStr)
            }
        }
        
        zfbBtn.tapped { [weak self] (btn) in
            self?.doAPAuth()
        }
    }
    
    //MARK: - 点击支付宝授权登录
        func doAPAuth() {
            // 重要说明
            // 这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
            // 真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
            // 防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
            /*============================================================================*/
            /*=======================需要填写商户app申请的===================================*/
            /*============================================================================*/
            let pid = "2088531043674722"
            let appID = "2021002100637061"
            // 如下私钥，rsa2PrivateKey 或者 rsaPrivateKey 只需要填入一个
            // 如果商户两个都设置了，优先使用 rsa2PrivateKey
            // rsa2PrivateKey 可以保证商户交易在更加安全的环境下进行，建议使用 rsa2PrivateKey
            // 获取 rsa2PrivateKey，建议使用支付宝提供的公私钥生成工具生成，
            // 工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
            let rsaPrivateKey = "MIIEpQIBAAKCAQEA7EiqnhjjW33atw9N3N/ayX4YBpSkmNi7ROYexV6awbLqDy/vXKwfaIjDsGysIMKPgjgpPPZ+dAygBhe7s/QuzQqA7Sv79Is2urLz47u1eWXO8hxtILTjWkNq/noSgWzKBIAiiXoZghnfpKLC+v1XtbCZTDWlZZBh0U1Qyk7ANfcBYzq39jg9oPhHBa2qow+mWlCavM1zshLwCTMdfi4IUDYTv38XcJ9yJxHA4VJA+qfMwncAImKlGW6uor2xqkqd+9DTU5hu+S4ZJOWQ1E+2A3pby6EYtklD2p7ALAoTLL6Niy/glmKaGYg4UAqG+2ad4hn3sL1WAvFVCmkbFOONtQIDAQABAoIBAQC1vfsGWexfDkHx9mKUltapj0SZozGro2D/0OUwOOFeRejEv8EkDfymojOq+xu2oxBRQDNwAcUoLCHWLeEhvJtW+VJLmz5UTdRN7KGttE8UzltMXNMPijMp1Ztxm6GqTWxh49Es327JZG9iKhNBjSYuyWRQex76LQEgRZDz23j6x8WbQgRLXYQ4SQXcMtM5Z6cOOCk/RWXoBQ4uT2jA6gDge+ErTQqDfQ+5NlueDBBRN8pkGqOxjtdOtvsE0LpwzTZgfscacc4b0rRlg3xpWTTK7xonOf+MMQRmTaH73pG3n9WnE/T2XKlShQVBEhurlojHASktHnf1p3k4OS+o10mBAoGBAPysfgfbhMgVcSmyDV3kZICa9GwuYNnnqp5/fhVegTt24/MsomH3GBY6VT9F9xo7xkDsAG2Y8C9ojdDAZvLsPJ/Mn+c0QWOxU7k+WLioHUJ3c+OZU3X+hFRkWxJWT1Sw42TAkcYzbVjiCtqM8/WeR3MrT66Lh4kqgj/h4IHoDb3hAoGBAO9k8LQo+PHZ+Td0RvUYMoLsMQ2gG/WBZ6Rdn4Yt+NsyunITsky0FJhSS4GhVHdcEaV0OvuZWu6SFhM5Zm+sVnJE68lId0EAo4Vky9FT5bcTE8ZOfOmBaWNbGC47IiDbjoylAi3Qq3yWjTefVDI8UaZjESjmms9wni0DbaXGT8JVAoGBAKbm4dEa5disoTVjkYTFysVQlcen0v3dE0zi9kvzQvYekHAeuZxwdY6pNYo4EwNXHJvhyF6cuXr3W0Xa8aXg+iKsLauxTsglaCJi1oQTOFChSwG6U/ELECoWqDmynXBZ77qroR8E9WPS3EyE8tj5lkSzBU1MiVjHpYXBFGV6/SjBAoGADJZsKaz12hGyDv5oNL7++O9ebO78SV5yiqv5lV6ZdT0nnJP4jhvx8Uhye/B1toj6zI5eA5i+tUitLHmaL0kKipuhIkZTLvHPp1XzeaBFteik44qA+u45EmZZ0SR+2OdyiWarxKjyO2zXJBOWo8WULYGMB3CIt1uelZNWkp7o1rkCgYEA558QtbY9bLxRp9NxP8poc2TbAgVaACIUeY1Dtnpl1gVcl0YIi+PCB+6zgzua3Vq2BL+uk2xPd3HFOVEnoZB58BGjhpzO4e0nGfY565QCRF7T894ilmMnV9SbL/QmEv8Oww5S3G0YoS3RC6KdsR3nEXsVC1JnPhl7zTkQKbmHQGU="
            let authInfo = APAuthInfo()
            authInfo.pid = pid
            authInfo.appID = appID
            let authType = UserDefaults.standard.object(forKey: "authType")
            if (authType != nil) {
                authInfo.authType = authType as? String
            }
            var authInfoStr = authInfo.description
             // 获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
            var signedString: String?
            let signer = APRSASigner.init(privateKey: rsaPrivateKey)
            signedString = signer?.sign(authInfoStr, withRSA2: false)
            if signedString != nil {
                authInfoStr = "\(authInfoStr)&sign=\(signedString ?? "")&sign_type=RSA"
                debugPrint("authInfoStr =" + authInfoStr)
                
    //            AlipaySDK.defaultService()?.auth_V2(withInfo: authInfoStr, fromScheme: "aliauth", callback: { (resp) in
    //
    //            })
                AliPayUtils.login(signStr: authInfoStr, aliAuthBack: self)
            } else {
                self.noticeOnlyText("支付宝签名失败")
            }
            
        }
    
    func authSuccessPopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 272, height: 200)).backgroundColor(.white)
        let successIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_auth_success"))
        let lab1 = UILabel().text("授权成功").textColor(UIColor.hexColor("#1DC597")).font(16)
        let lab2 = UILabel().text("授权成功啦，赶紧提交审核吧！").textColor(.kColor99).font(12)
        let sureBtn = UIButton().text("提交审核").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_put_btn")).cornerRadius(15).masksToBounds()
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "unallow_icon"))
        v.sv(closeBtn, successIcon, lab1, lab2, sureBtn)
        v.layout(
            20,
            successIcon.size(50).centerHorizontally(),
            10,
            lab1.height(22.5).centerHorizontally(),
            6,
            lab2.height(16.5).centerHorizontally(),
            20,
            sureBtn.width(130).height(30).centerHorizontally(),
            >=0
        )
        v.layout(
            0,
            closeBtn.size(32)-0-|,
            >=0
        )
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
        
        sureBtn.tapped { [weak self] (btn) in
            self?.saveAction()
            self?.pop?.dismiss()
        }
        closeBtn.tapped { [weak self] (btn) in
            self?.pop?.dismiss()
        }
    }
    
    
    
    @objc func addLicenseAction() {
        
        optionType = 1
        presentAddPhoto()
    }
    
    @objc func addLogoAction() {
        optionType = 4
        presentAddPhoto()
    }
    
    @objc func switchLicenseAction() {
        
        optionType = 1
        detailImage = licenseImageView.image
        presentAddPhoto(isSwitch: true)
    }
    
    @objc func switchLogoAction() {
        
        optionType = 4
        detailImage = logoImageView.image
        presentAddPhoto(isSwitch: true)
    }
    
    
    
    @objc func addCardFAction() {
        
        optionType = 2
        presentAddPhoto()
    }
    
    @objc func switchCardFAction() {
        
        optionType = 2
        detailImage = cardFImageView.image
        presentAddPhoto(isSwitch: true)
    }
    
    @objc func addCardBAction() {
        
        optionType = 3
        presentAddPhoto()
    }
    
    @objc func switchCardBAction() {
        
        optionType = 3
        detailImage = cardBImageView.image
        presentAddPhoto(isSwitch: true)
    }
    
    @objc func saveAction() {
        /// 注。微信支付宝注册不需要传入身份证信息，原生注册需要传入身份证信息，需要根据是否三方登录来走不同的逻辑
        if type == "2" {
//            if contactsTF.text!.length < 2 {
//                self.noticeOnlyText("请输入姓名")
//                return
//            }
            if workerModel != nil {
                if zfbBtn.isHidden == false {
                    if openId == "" {
                        self.noticeOnlyText("请先使用微信或者支付宝授权身份信息")
                    } else {
                        saveFunc()
                    }
                    
                } else {
                    if workerModel?.yzbRegister?.idcardpicUrlF == nil || workerModel?.yzbRegister?.idcardpicUrlB == nil {
                        self.noticeOnlyText("照片添加不完全")
                    }
                    else {
                        saveFunc()
                    }
                }
                
            } else if regiestBaseModel != nil {
                if zfbBtn.isHidden == false {
                    if openId == "" {
                        self.noticeOnlyText("请先使用微信或者支付宝授权身份信息")
                    } else {
                        saveFunc()
                    }
                    
                }  else {
                    if regiestBaseModel?.registerRData?.idcardpicUrlF == nil || regiestBaseModel?.registerRData?.idcardpicUrlB == nil {
                        self.noticeOnlyText("照片添加不完全")
                    }
                    else {
                        saveFunc()
                    }
                }
            }
            
        }else {
            if companyTF.text == "" {
                self.noticeOnlyText("请输入公司名称")
                return
            }
            if contactsTF.text!.length < 2 {
                self.noticeOnlyText("请输入姓名")
                return
            }
            if workerModel != nil {
                if isThirdLogin {
                    saveFunc()
                } else {
                if workerModel?.yzbRegister?.licenseUrl == nil ||
                workerModel?.yzbRegister?.idcardpicUrlF == nil ||
                workerModel?.yzbRegister?.idcardpicUrlB == nil {
                    self.noticeOnlyText("照片添加不完全")
                }else {
                    saveFunc()
                }
                }
            } else if regiestBaseModel != nil {
                if isThirdLogin {
                    saveFunc()
                } else {
                    if regiestBaseModel?.registerRData?.licenseUrl == nil ||
                    regiestBaseModel?.registerRData?.idcardpicUrlF == nil ||
                    regiestBaseModel?.registerRData?.idcardpicUrlB == nil {
                        self.noticeOnlyText("照片添加不完全")
                    }else {
                        saveFunc()
                    }
                }
            }
            
        }

    }
    
    //MARK: - 网络请求
    func saveFunc() {
        
        var parameters: Parameters = [:]
        if workerModel != nil {
            parameters["id"] = workerModel?.yzbRegister?.id ?? ""
            parameters["comName"] = contactsTF?.text ?? ""
            parameters["idcardNo"] = workerModel?.yzbRegister?.idcardNo ?? ""
            parameters["licenseNo"] = workerModel?.yzbRegister?.licenseNo ?? ""
            parameters["setUpTime"] = workerModel?.yzbRegister?.setUpTime ?? ""
            parameters["output"] = workerModel?.yzbRegister?.output ?? ""
            parameters["size"] = workerModel?.yzbRegister?.size ?? ""
            parameters["comAddress"] = workerModel?.yzbRegister?.comAddress ?? ""
            if let valueStr = workerModel?.yzbRegister?.licenseUrl {
                parameters["licenseUrl"] = valueStr
            }
            if let valueStr = workerModel?.yzbRegister?.storeLogo {
                parameters["storeLogo"] = valueStr
            }
            if openId == "" || type == "1" {
                if let valueStr = workerModel?.yzbRegister?.idcardpicUrlF {
                    parameters["idcardpicUrlF"] = valueStr
                }
                if let valueStr = workerModel?.yzbRegister?.idcardpicUrlB {
                    parameters["idcardpicUrlB"] = valueStr
                }
            } else {
                parameters["openId"] = openId
                parameters["authLoginType"] = authLoginType
            }
            
        } else if regiestBaseModel != nil {
            let regiestModel = regiestBaseModel?.registerRData
            parameters["id"] = regiestModel?.id ?? ""
            parameters["comName"] = contactsTF?.text ?? ""
            parameters["idcardNo"] = regiestModel?.idcardNo ?? ""
            parameters["licenseNo"] = regiestModel?.licenseNo ?? ""
            parameters["setUpTime"] = regiestModel?.setUpTime ?? ""
            parameters["output"] = regiestModel?.output ?? ""
            parameters["size"] = regiestModel?.size ?? ""
            parameters["comAddress"] = regiestModel?.comAddress ?? ""
            if let valueStr = regiestModel?.licenseUrl {
                parameters["licenseUrl"] = valueStr
            }
            if let valueStr = regiestModel?.storeLogo {
                parameters["storeLogo"] = valueStr
            }
            if openId == "" || type == "1" {
                if let valueStr = regiestModel?.idcardpicUrlF {
                    parameters["idcardpicUrlF"] = valueStr
                }
                if let valueStr = regiestModel?.idcardpicUrlB {
                    parameters["idcardpicUrlB"] = valueStr
                }
            } else {
                parameters["openId"] = openId
                parameters["authLoginType"] = authLoginType
            }
        }
        parameters["isCheck"] = "3"
        if type == "1" {
            parameters["comName"] = companyTF.text
            parameters["contacts"] = contactsTF.text //workerModel?.yzbRegister?.contacts ?? ""
        }
        self.pleaseWait()
        let urlStr = APIURL.companyRegister
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let vc = ServiceRegiestSuccessVC()
                self.navigationController?.pushViewController(vc)
//                let popup = PopupDialog(title: "提示", message: "提交成功", tapGestureDismissal: false, panGestureDismissal: false)
//                let sureBtn = AlertButton(title: "确定") {
//                    self.navigationController?.popToRootViewController(animated: true)
//                }
//                popup.addButtons([sureBtn])
//                self.present(popup, animated: true, completion: nil)
            }
        }) { (error) in
            
        }
    }
    
    //添加照片弹窗
    func presentAddPhoto(isSwitch: Bool = false) {
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
            
            DispatchQueue.main.async {
                if granted {
                    
                    let sourceActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let cameraOption = UIAlertAction.init(title: "相机", style: .default) { [weak self] _ in
                        
                        self?.present(self!.cameraPicker, animated: true, completion: nil)
                    }
                    let photoOption = UIAlertAction.init(title: "相册", style: .default) { [weak self] _ in
                        
                        self?.present(self!.photoPicker, animated: true, completion: nil)
                    }
                    let lookPhotoOption = UIAlertAction.init(title: "查看大图", style: .default) { [weak self] _ in
                        
                        let vc = PictureBrowseController()
                        vc.showImage = self?.detailImage
                        self?.present(vc, animated: true, completion: nil)
                    }
                    let cancelOption = UIAlertAction(title: "取消", style: .cancel, handler:nil)
                    
                    sourceActionSheet.addAction(cameraOption)
                    sourceActionSheet.addAction(photoOption)
                    if isSwitch {
                        sourceActionSheet.addAction(lookPhotoOption)
                    }
                    sourceActionSheet.addAction(cancelOption)
                    
                    if IS_iPad {
                        
                        let popPresenter = sourceActionSheet.popoverPresentationController
                        
                        switch self.optionType {
                        case 1:
                            popPresenter?.sourceView = self.addLicenseBtn
                            popPresenter?.sourceRect = self.addLicenseBtn.bounds
                            break
                        case 2:
                            popPresenter?.sourceView = self.addCardFBtn
                            popPresenter?.sourceRect = self.addCardFBtn.bounds
                            break
                        case 3:
                            popPresenter?.sourceView = self.addCardBBtn
                            popPresenter?.sourceRect = self.addCardBBtn.bounds
                            break
                        case 4:
                            popPresenter?.sourceView = self.addLogoBtn
                            popPresenter?.sourceRect = self.addLogoBtn.bounds
                        break
                        default:
                            break
                        }
                    }
                    
                    self.present(sourceActionSheet, animated: true, completion: nil)
                }
                else {
                    let modifyAlert = UIAlertController.init(title: "请在iPhone的“设置-隐私-相机”选项中，允许App访问你的相机", message: nil, preferredStyle: .alert)
                    
                    let sure = UIAlertAction.init(title: "去设置", style: .default, handler: { (sureAction) in
                        
                        let settingUrl = URL(string: UIApplication.openSettingsURLString)!
                        if UIApplication.shared.canOpenURL(settingUrl) {
                            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
                        }
                    })
                    
                    let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (sureAction) in
                    })
                    
                    modifyAlert.addAction(sure)
                    modifyAlert.addAction(cancel)
                    self.present(modifyAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    //MARK: - 获得照片
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        AppLog("照片原尺寸: \(image.size)")
        image = image.resizeImage(valueMax: 800) ?? image
        AppLog("照片压缩后尺寸: \(image.size)")
        
        switch optionType {
        case 1:
            
            let type = "register/company"
            var oldUrl: String = ""
            if self.workerModel != nil {
                oldUrl = self.workerModel?.yzbRegister?.licenseUrl ?? ""
            } else if self.regiestBaseModel != nil {
                oldUrl = self.regiestBaseModel?.registerRData?.licenseUrl ?? ""
            }
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                if self.workerModel != nil {
                    self.workerModel?.yzbRegister?.licenseUrl = headStr
                } else if self.regiestBaseModel != nil {
                    self.regiestBaseModel?.registerRData?.licenseUrl = headStr
                }
                self.addLicenseBtn.isHidden = true
                self.addLicenseHint.isHidden = true
                self.licenseImageView.isHidden = true
                self.licenseBackView.image = image
                
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
            
            break
        case 2:
            
            let type = "register/company"
            var oldUrl: String = ""
            if self.workerModel != nil {
                oldUrl = self.workerModel?.yzbRegister?.idcardpicUrlF ?? ""
            } else if self.regiestBaseModel != nil {
                oldUrl = self.regiestBaseModel?.registerRData?.idcardpicUrlF ?? ""
            }
            
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
              	  if self.workerModel != nil {
                    self.workerModel?.yzbRegister?.idcardpicUrlF = headStr
                } else if self.regiestBaseModel != nil {
                    self.regiestBaseModel?.registerRData?.idcardpicUrlF = headStr
                }
                self.addCardFBtn.isHidden = true
                self.addCardFHint.isHidden = true
                self.cardFImageView.isHidden = true
                self.idCardBackViewF.image = image
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
            
            break
        case 3:
            
            let type = "register/company"
            var oldUrl: String = ""
            if self.workerModel != nil {
                oldUrl = self.workerModel?.yzbRegister?.idcardpicUrlB ?? ""
            } else if self.regiestBaseModel != nil {
                oldUrl = self.regiestBaseModel?.registerRData?.idcardpicUrlB ?? ""
            }
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                if self.workerModel != nil {
                    self.workerModel?.yzbRegister?.idcardpicUrlB = headStr
                } else if self.regiestBaseModel != nil {
                    self.regiestBaseModel?.registerRData?.idcardpicUrlB = headStr
                }
                self.addCardBBtn.isHidden = true
                self.addCardBHint.isHidden = true
                self.cardBImageView.isHidden = true
                self.idCardBackViewB.image = image
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
            break
        case 4:
        
        let type = "register/company"
        var oldUrl: String = ""
        if self.workerModel != nil {
            oldUrl = self.workerModel?.yzbRegister?.storeLogo ?? ""
        } else if self.regiestBaseModel != nil {
            oldUrl = self.regiestBaseModel?.registerRData?.storeLogo ?? ""
        }
        YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
            
            let headStr = response.replacingOccurrences(of: "\"", with: "")
            print("头像原路径: \(response)")
            print("头像修改路径: \(headStr)")
            if self.workerModel != nil {
                self.workerModel?.yzbRegister?.storeLogo = headStr
            } else if self.regiestBaseModel != nil {
                self.regiestBaseModel?.registerRData?.storeLogo = headStr
            }
            self.addLogoBtn.isHidden = true
            self.addLogoHint.isHidden = true
            self.logoImageView.isHidden = true
            self.logoBackView.image = image
            self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
            
        }, failture: { (error) in
            
            self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
        })
        
        break
        default:
            break
        }
    }
}
//MARK: - UploadIDCardViewModelDelegate
extension UploadIDCardController: UploadIDCardViewModelDelegate {
    
    func alertInfo(_ text: String) {
        noticeOnlyText(text)
    }
    
    func updateUI() {
        
    }
    
    func alertInfoAutoRelease(_ text: String) {
        self.noticeSuccess(text, autoClear: true, autoClearTime: 1)
    }
    
}
