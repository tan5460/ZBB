//
//  PPSRegiestSecondVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/11/4.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import PopupDialog
import Kingfisher
import ObjectMapper
import TLTransitions


class PPSRegiestSecondVC: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    private var pop: TLTransition?
    var scrollView: UIScrollView!
    var companyView: UIView!                   //法人姓名
    var companyTF: UITextField!
    
    var yyzzView: UIView!                  //营业执照号
    var yyzzTF: UITextField!
    
    var mddzView: UIButton!                  //门店地址
    var mddzLabel: UILabel!
    
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
    var regiestId: String?
    var regiestBaseModel: RegisterBaseModel?
    var optionType: Int = 1                     //操作类型 1.营业执照 2.身份证正面 3.身份证反面 4.logo
    var detailImage: UIImage?                   //需查看的详情图
    
    var isChange:Bool = false
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>> 上传界面释放 <<<<<<<<<<<<<<<<<<<")
    }
    
    var viewModel: UploadIDCardViewModel!
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "资质认证"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(back))
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
        
        if let valueStr = regiestBaseModel?.registerRData?.certpicUrl {
            if valueStr != "" {
                addLicenseBtn.isHidden = true
                addLicenseHint.isHidden = true
                licenseImageView.isHidden = true
                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                licenseBackView.kf.setImage(with: imageUrl)
            }
        }
        
        if let valueStr = regiestBaseModel?.registerRData?.logoUrl  {
            if valueStr != "" {
                addLogoBtn.isHidden = true
                addLogoHint.isHidden = true
                logoImageView.isHidden = true

                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                logoBackView.kf.setImage(with: imageUrl)
            }
        }
        
        if let valueStr = regiestBaseModel?.registerRData?.idcardpicUrlF {
            
            if valueStr != "" {
                
                addCardFBtn.isHidden = true
                cardFImageView.isHidden = true
                
                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                idCardBackViewF.kf.setImage(with: imageUrl)
            }
        }
        
        if let valueStr = regiestBaseModel?.registerRData?.idcardpicUrlB {
            
            if valueStr != "" {
                addCardBBtn.isHidden = true
                cardBImageView.isHidden = true
                let imageUrl = URL(string: APIURL.ossPicUrl + valueStr)!
                idCardBackViewB.kf.setImage(with: imageUrl)
            }
        }
        
        if let valueStr = regiestBaseModel?.registerRData?.address {
            mddzLabel.text(valueStr).textColor(.kColor33)
            plot?.lat = regiestBaseModel?.registerRData?.latitude
            plot?.lon = regiestBaseModel?.registerRData?.longitude
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
        
        scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: view.width, height: view.height-PublicSize.kBottomOffset-150))
        view.addSubview(scrollView)
        
        
        let topTipIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_anquan_icon"))
        scrollView.addSubview(topTipIcon)
        topTipIcon.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.left.equalTo(14)
            make.size.equalTo(14)
        }
        let topTipLabel = UILabel().text("为了确保交易安全，我们需要认证您的身份，此信息会完全保密并不对外提供，只用于身份认证").textColor(UIColor.hexColor("#3564F6")).font(10)
        topTipLabel.numberOfLines(0).lineSpace(2)
        scrollView.addSubview(topTipLabel)
        topTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(9.5)
            make.left.equalTo(30)
            make.right.equalToSuperview().offset(-30)
        }
        
        let stepIV = UIImageView().image(#imageLiteral(resourceName: "pps_register_step_2"))
        scrollView.addSubview(stepIV)
        stepIV.snp.makeConstraints { (make) in
            make.top.equalTo(topTipLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(58)
        }
        
        
        companyView = UIView()
        companyView.backgroundColor = .white
        scrollView.addSubview(companyView)
        
        companyView.snp.makeConstraints { (make) in
            make.top.equalTo(stepIV.snp.bottom).offset(10)
            make.width.equalTo(view.width)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        //公司名
        let companyIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_fr_icon"))
        companyView.addSubview(companyIcon)
        companyIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(14)
            make.size.equalTo(17)
        }
       
        companyTF = UITextField()
        companyTF.placeholder = "请填写法人姓名"
        companyTF.textAlignment = .left
        companyTF.font = UIFont.systemFont(ofSize: 14)
        companyTF.placeholderColor = .kColor99
        companyView.addSubview(companyTF)
        companyTF.snp.makeConstraints { (make) in
            make.centerY.top.bottom.equalToSuperview()
            make.right.equalTo(-10)
            make.left.equalTo(companyIcon.snp.right).offset(8)
        }
        companyTF.text = regiestBaseModel?.registerRData?.legalRepresentative
        
        let uploadW = (PublicSize.screenWidth-50)/2
        let uploadH = uploadW*54/86
        
        //营业执照灰色背景
        let backColor = UIColor.init(red: 247.0/255, green: 248.0/255, blue: 249.0/255, alpha: 1)
        //身份证标题
        idCardTitleLabel.attributedText = String.attributedString(strs: ["*", "上传法人身份证"], colors: [UIColor.red, .kColor33], fonts: [.systemFont(ofSize: 14), .systemFont(ofSize: 14)])
        scrollView.addSubview(idCardTitleLabel)
        idCardTitleLabel.isHidden = false
        idCardTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(companyView.snp.bottom).offset(20)
            make.left.equalTo(14)
        }

        //身份证正面背景
        let cardWidth = (PublicSize.screenWidth-50)/2
        idCardBackViewF.isUserInteractionEnabled = true
        idCardBackViewF.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(addCardFAction)))
        idCardBackViewF.backgroundColor = backColor
        idCardBackViewF.layer.cornerRadius = 5
        scrollView.addSubview(idCardBackViewF)

        idCardBackViewF.snp.makeConstraints { (make) in
            make.top.equalTo(idCardTitleLabel.snp.bottom).offset(15)
            make.left.equalTo(14)
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
        addCardFHint.text = "身份证正面"
        addCardFHint.textColor = .kColor99
        addCardFHint.font = UIFont.systemFont(ofSize: 10)
        scrollView.addSubview(addCardFHint)
        addCardFHint.snp.makeConstraints { (make) in
            make.top.equalTo(idCardBackViewF.snp.bottom).offset(5)
            make.centerX.equalTo(idCardBackViewF)
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
        scrollView.addSubview(idCardBackViewB)

        idCardBackViewB.snp.makeConstraints { (make) in
            make.top.width.height.equalTo(idCardBackViewF)
            make.right.equalToSuperview().offset(-14)
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
        addCardBHint.text = "身份证反面"
        addCardBHint.textColor = .kColor99
        addCardBHint.font = UIFont.systemFont(ofSize: 10)
        scrollView.addSubview(addCardBHint)
        addCardBHint.snp.makeConstraints { (make) in
            make.top.equalTo(idCardBackViewB.snp.bottom).offset(5)
            make.centerX.equalTo(idCardBackViewB)
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
        
        //联系人
        yyzzView = UIView()
        yyzzView.backgroundColor = .white
        scrollView.addSubview(yyzzView)
        
        yyzzView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(idCardBackViewF.snp.bottom).offset(20)
        }
        
        
        let yyzzIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_yyzz_icon"))
        yyzzView.addSubview(yyzzIcon)
        yyzzIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(14)
            make.width.equalTo(15.6)
            make.height.equalTo(16.39)
        }
        
        yyzzTF = UITextField()
        yyzzTF.placeholder = "请填写营业执照号"
        yyzzTF.textAlignment = .left
        yyzzTF.font = UIFont.systemFont(ofSize: 14)
        yyzzTF.placeholderColor = .kColor99
        yyzzView.addSubview(yyzzTF)
        
        yyzzTF.snp.makeConstraints { (make) in
            make.centerY.top.bottom.equalToSuperview()
            make.right.equalTo(-10)
            make.left.equalTo(yyzzIcon.snp.right).offset(8.5)
        }
        yyzzTF.text = regiestBaseModel?.registerRData?.certCode
        
    
        
        
        //营业执照标题
        
        licenseTitleLabel.attributedText = String.attributedString(strs: ["*", "上传公司营业执照"], colors: [UIColor.red, .kColor33], fonts: [.systemFont(ofSize: 14), .systemFont(ofSize: 14)])
        scrollView.addSubview(licenseTitleLabel)
        
        licenseTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(yyzzView.snp.bottom).offset(20)
            make.left.equalTo(10)
        }
        
        licenseBackView.isUserInteractionEnabled = true
        licenseBackView.backgroundColor = backColor
        licenseBackView.layer.cornerRadius = 5
        scrollView.addSubview(licenseBackView)
        licenseBackView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(addLicenseAction)))
        licenseBackView.snp.makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(licenseTitleLabel.snp.bottom).offset(15)
            make.width.equalTo(uploadW)
            make.height.equalTo(uploadH)
        }
        
        //添加营业执照按钮
        let addLicenseWidth: CGFloat = 50
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
        
        //logo标题
        
        logoTitleLabel.text = "公司logo（选填）"
        logoTitleLabel.textColor = PublicColor.minorTextColor
        logoTitleLabel.font = UIFont.systemFont(ofSize: 15)
        scrollView.addSubview(logoTitleLabel)
        
        logoTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(licenseTitleLabel)
            make.left.equalTo(uploadW+20)
        }
        
        //logo灰色背景
        
        logoBackView.isUserInteractionEnabled = true
        logoBackView.backgroundColor = backColor
        logoBackView.layer.cornerRadius = 5
        scrollView.addSubview(logoBackView)
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
        
        
        mddzView = UIButton()
        mddzView.backgroundColor = .white
        scrollView.addSubview(mddzView)
        
        mddzView.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-20)
        }
        
        //公司名
        let mddzIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_mddz"))
        mddzView.addSubview(mddzIcon)
        mddzIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(14)
            make.size.equalTo(17)
        }
       
        mddzLabel = UILabel().text("门店地址").textColor(.kColor99).font(14)
        mddzView.addSubview(mddzLabel)
        mddzLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(mddzIcon.snp.right).offset(8)
        }
        
        let mddzArrow = UIImageView().image(#imageLiteral(resourceName: "order_arrow"))
        mddzView.addSubview(mddzArrow)
        mddzArrow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(5)
            make.height.equalTo(12)
            make.right.equalToSuperview().offset(-14)
        }
       // mddzLabel.text = regiestBaseModel?.registerRData?.address
        
        mddzView.tapped { [weak self] (tapBtn) in
            self?.selelctMap()
        }
        
        //提交
        let saveBtn = UIButton.init(type: .custom)
        saveBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        saveBtn.setTitle("提交审核", for: .normal)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.setBackgroundImage(#imageLiteral(resourceName: "regiest_put_btn"), for: .normal)
        saveBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        view.addSubview(saveBtn)
        saveBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(280)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
    }
    var address: String?
    var plot: PlotModel? = PlotModel()
    func selelctMap() {
        let vc = SelectMapPlaceController()
        vc.selectPlaceModel = plot
        vc.isSearchBiotope = true
        vc.onDismissback = {[weak self] (plot) in
            self?.plot = plot
            self?.regiestBaseModel?.registerRData?.latitude = "\(plot?.lat ?? "0")"
            self?.regiestBaseModel?.registerRData?.longitude = "\(plot?.lon ?? "0")"
            
            //获取城市
            var getAreaName = ""
            var getCityName = ""
            var getDistrictName = ""
            //省
            if let areaName = plot?.prov?.name {
                getAreaName = areaName
            }
            //市
            if let cityName = plot?.city?.name {
                getCityName = cityName
            }
            //区
            if let districtName = plot?.dist?.name {
                getDistrictName = districtName
            }
            
            self?.address = (getAreaName + getCityName + getDistrictName + (plot?.name ?? ""))
            self?.regiestBaseModel?.registerRData?.address = self?.address
            self?.mddzLabel.text(self?.address ?? "").textColor(.kColor33)
            
        }
        self.navigationController?.pushViewController(vc, animated: true)
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
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.text = textField.text?.replacingOccurrences(of: " ", with: "")
    }
    
    @objc func saveAction() {
        if companyTF.text == "" {
            self.noticeOnlyText("请填写法人姓名")
            return
        }
        
        if yyzzTF.text == "" {
            self.noticeOnlyText("请填写营业执照号")
            return
        }
        
        if mddzLabel.text == "门店地址" {
            self.noticeOnlyText("请填写门店地址")
            return
        }
        
        if regiestBaseModel?.registerRData?.certpicUrl == nil {
            self.noticeOnlyText("请上传营业执照")
            return
        }
        
        if regiestBaseModel?.registerRData?.idcardpicUrlF == nil {
            self.noticeOnlyText("请上传身份证正面照")
            return
        }
        
        if regiestBaseModel?.registerRData?.idcardpicUrlB == nil {
            self.noticeOnlyText("请上传身份证反面照")
            return
        }
        saveFunc()
    }
    
    //MARK: - 网络请求
    func saveFunc() {
        var parameters: Parameters = [:]
        if regiestBaseModel != nil {
            let regiestModel = regiestBaseModel?.registerRData
            parameters["id"] = regiestModel?.id ?? ""
            if let valueStr = regiestModel?.certpicUrl {
                parameters["certpicUrl"] = valueStr
            }
            if let valueStr = regiestModel?.logoUrl  {
                parameters["logoUrl"] = valueStr
            }
            if let valueStr = regiestModel?.idcardpicUrlF {
                parameters["idcardpicUrlF"] = valueStr
            }
            if let valueStr = regiestModel?.idcardpicUrlB {
                parameters["idcardpicUrlB"] = valueStr
            }
            parameters["longitude"] = regiestBaseModel?.registerRData?.longitude
            parameters["latitude"] = regiestBaseModel?.registerRData?.latitude
            parameters["address"] = regiestBaseModel?.registerRData?.address
        }
        parameters["isCheck"] = "3"
        parameters["legalRepresentative"] = companyTF.text
        parameters["certCode"] = yyzzTF.text
        self.pleaseWait()
        let urlStr = APIURL.serviceRegisterStepTwo
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let vc = ServiceRegiestSuccessVC()
                self.navigationController?.pushViewController(vc)
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
            if self.regiestBaseModel != nil {
                oldUrl = self.regiestBaseModel?.registerRData?.certpicUrl ?? ""
            }
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                if self.regiestBaseModel != nil {
                    self.regiestBaseModel?.registerRData?.certpicUrl = headStr
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
            if self.regiestBaseModel != nil {
                oldUrl = self.regiestBaseModel?.registerRData?.idcardpicUrlF ?? ""
            }
            
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                    if self.regiestBaseModel != nil {
                        self.regiestBaseModel?.registerRData?.idcardpicUrlF = headStr
                    }
                self.addCardFBtn.isHidden = true
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
            if self.regiestBaseModel != nil {
                oldUrl = self.regiestBaseModel?.registerRData?.idcardpicUrlB ?? ""
            }
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                if self.regiestBaseModel != nil {
                    self.regiestBaseModel?.registerRData?.idcardpicUrlB = headStr
                }
                self.addCardBBtn.isHidden = true
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
        if self.regiestBaseModel != nil {
            oldUrl = self.regiestBaseModel?.registerRData?.logoUrl  ?? ""
        }
        YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
            
            let headStr = response.replacingOccurrences(of: "\"", with: "")
            print("头像原路径: \(response)")
            print("头像修改路径: \(headStr)")
            if self.regiestBaseModel != nil {
                self.regiestBaseModel?.registerRData?.logoUrl  = headStr
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
extension PPSRegiestSecondVC: UploadIDCardViewModelDelegate {
    
    func alertInfo(_ text: String) {
        noticeOnlyText(text)
    }
    
    func updateUI() {
        
    }
    
    func alertInfoAutoRelease(_ text: String) {
        self.noticeSuccess(text, autoClear: true, autoClearTime: 1)
    }
    
}
