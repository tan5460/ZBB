//
//  MemberAuthVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/19.
//

import UIKit

class MemberAuthVC: BaseViewController {
    var isEdit = false
    private let personalBtn = UIButton().text("个人").textColor(.k2FD4A7).font(12)
    private let enterpriseBtn = UIButton().text("企业").textColor(.kColor99).font(12)
    private let personalView = PersonalAuthView().backgroundColor(.red)
    private let enterpriseView = EnterpriseAuthView().backgroundColor(.blue)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "会员认证"
        let switchView = UIView().backgroundColor(.white)
        
        
        view.sv(switchView)
        view.layout(
            0,
            |switchView.height(37)|,
            >=0
        )
        
        view.sv(personalView, enterpriseView)
        view.layout(
            37,
            |personalView|,
            0
        )
        view.layout(
            37,
            |enterpriseView|,
            0
        )
        enterpriseView.isHidden = true
        
        switchView.sv(personalBtn, enterpriseBtn)
        switchView.layout(
            0,
            |-50-personalBtn.height(37)-0-enterpriseBtn.height(37)-50-|,
            0
        )
        equal(widths: personalBtn, enterpriseBtn)
        
        personalBtn.tapped { [weak self] (tapBtn) in
            self?.toolBtnClick(isPersonal: true)
        }
        
        enterpriseBtn.tapped { [weak self] (tapBtn) in
            self?.toolBtnClick(isPersonal: false)
        }
        let registerModel = UserData.shared.userInfoModel?.register
        if registerModel?.type == 1 {
            toolBtnClick(isPersonal: false)
            if isEdit {
                enterpriseBtn.isEnabled = true
                personalBtn.isEnabled = false
            }
        } else if registerModel?.type == 2 {
            toolBtnClick(isPersonal: true)
            if isEdit {
                enterpriseBtn.isEnabled = false
                personalBtn.isEnabled = true
            }
        }
    }
    
    private func toolBtnClick(isPersonal: Bool) {
        if isPersonal {
            personalBtn.textColor(.k27A27D)
            enterpriseBtn.textColor(.kColor99)
        } else {
            personalBtn.textColor(.kColor99)
            enterpriseBtn.textColor(.k2FD4A7)
        }
        personalView.isHidden = !isPersonal
        enterpriseView.isHidden = isPersonal
    }
}



//MARK: - 个人认证
class PersonalAuthView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private var registerModel: RegisterModel?
    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.kBackgroundColor)
    private let nameTF = UITextField().placeholder("请填写真实姓名")
    private let idcardTF = UITextField().placeholder("身份证号码")
    private var optionType: Int = 1                     //操作类型  1.身份证正面 2.身份证反面
    private var cameraPicker: UIImagePickerController!
    private var photoPicker: UIImagePickerController!
    private var detailImage: UIImage?                   //需查看的详情图
    private let faceBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_id_face_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    private let backBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_id_back_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerModel = UserData.shared.userInfoModel?.register
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        sv(tableView)
        layout(
            0,
            |tableView|,
            0
        )
        nameTF.addTarget(self, action: #selector(textFieldChange(textField:)), for: .editingChanged)
        idcardTF.addTarget(self, action: #selector(textFieldChange(textField:)), for: .editingChanged)
        
        if registerModel?.type == 2 {
            registerModel?.idcardpicUrlFGR = registerModel?.idcardpicUrlF
            registerModel?.idcardpicUrlBGR = registerModel?.idcardpicUrlB
        }
    }
    
    @objc func textFieldChange(textField: UITextField) {
        if textField == nameTF {
            
        } else if textField == idcardTF {
            
        }
    }
    
    //添加照片弹窗
    func presentAddPhoto(isSwitch: Bool = false) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
            DispatchQueue.main.async {
                if granted {
                    let sourceActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let cameraOption = UIAlertAction.init(title: "相机", style: .default) { [weak self] _ in
                        
                        self?.parentController?.present(self!.cameraPicker, animated: true, completion: nil)
                    }
                    let photoOption = UIAlertAction.init(title: "相册", style: .default) { [weak self] _ in
                        
                        self?.parentController?.present(self!.photoPicker, animated: true, completion: nil)
                    }
                    let lookPhotoOption = UIAlertAction.init(title: "查看大图", style: .default) { [weak self] _ in
                        
                        let vc = PictureBrowseController()
                        vc.showImage = self?.detailImage
                        self?.parentController?.present(vc, animated: true, completion: nil)
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
                            popPresenter?.sourceView = self.faceBtn
                            popPresenter?.sourceRect = self.faceBtn.bounds
                            break
                        case 2:
                            popPresenter?.sourceView = self.backBtn
                            popPresenter?.sourceRect = self.backBtn.bounds
                            break
                        default:
                            break
                        }
                    }
                    
                    self.parentController?.present(sourceActionSheet, animated: true, completion: nil)
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
                    self.parentController?.present(modifyAlert, animated: true, completion: nil)
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
            let oldUrl: String = self.registerModel?.idcardpicUrlFGR ?? ""
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.registerModel?.idcardpicUrlFGR = headStr
                self.faceBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        case 2:
            let type = "register/company"
            let oldUrl: String = self.registerModel?.idcardpicUrlBGR ?? ""
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.registerModel?.idcardpicUrlBGR = headStr
                self.backBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension PersonalAuthView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            configSection0(cell: cell)
        } else if indexPath.section == 1 {
            configSection1(cell: cell)
        } else if indexPath.section == 2 {
            configSection2(cell: cell)
        } else if indexPath.section == 3 {
            configSection3(cell: cell)
        } else if indexPath.section == 4 {
            configSection4(cell: cell)
        }
        return cell
    }
    
    func configSection0(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let topTipIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_anquan_icon"))
        let topTipLabel = UILabel().text("为了确保交易安全，我们需要认证您的身份，此信息会完全保密并不对外提供，只用于身份认证").textColor(.blue).font(12)
        cell.sv(topTipIcon, topTipLabel)
        cell.layout(
            10,
            |-14-topTipIcon.size(14),
            29
        )
        cell.layout(
            10,
            |-30-topTipLabel-30-|,
            >=10
        )
        topTipLabel.numberOfLines(0).lineSpace(2)
    }
    
    func configSection1(cell: UITableViewCell) {
        cell.backgroundColor(.white)
        let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let icon = UIImageView().image(#imageLiteral(resourceName: "auth_icon_name"))
        if registerModel?.isCheck == 2  && registerModel?.type == 2 {
            nameTF.text(registerModel?.contacts ?? "")
        }
        nameTF.font = .systemFont(ofSize: 14)
        nameTF.placeholderColor = .kColor99
        cell.sv(starLabel, icon, nameTF)
        cell.layout(
            12,
            |-14-starLabel.width(7).height(22)-1-icon.size(17)-8-nameTF.height(44)-14-|,
            12
        )
    }
    
    func configSection2(cell: UITableViewCell) {
        cell.backgroundColor(.white)
        let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let icon = UIImageView().image(#imageLiteral(resourceName: "auth_icon_idcard"))
        idcardTF.text(registerModel?.idcardNo ?? "")
        idcardTF.font = .systemFont(ofSize: 14)
        idcardTF.placeholderColor = .kColor99
        cell.sv(starLabel, icon, idcardTF)
        cell.layout(
            12,
            |-14-starLabel.width(7).height(22)-1-icon.size(17)-8-idcardTF.height(44)-14-|,
            12
        )
    }
    
    func configSection3(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let titleLable = UILabel().text("上传身份证").textColor(.kColor33).font(14)
        cell.sv(starLabel, titleLable, faceBtn, backBtn)
        cell.layout(
            20,
            |-14-starLabel.height(20)-1-titleLable,
            15,
            |-14-faceBtn.height(101)-21-backBtn.height(101)-14-|,
            20
        )
        equal(widths: faceBtn, backBtn)
        if !faceBtn.addImage(registerModel?.idcardpicUrlFGR) {
            faceBtn.image(#imageLiteral(resourceName: "regiest_avatar_bg"))
        }
        if !backBtn.addImage(registerModel?.idcardpicUrlBGR) {
            backBtn.image(#imageLiteral(resourceName: "regiest_avatar_bg"))
        }
        faceBtn.tapped { [weak self] (tapBtn) in
            self?.optionType = 1
            if let idcardpicUrlF = self?.registerModel?.idcardpicUrlFGR, !idcardpicUrlF.isEmpty {
                self?.detailImage = self?.faceBtn.imageView?.image
                self?.presentAddPhoto(isSwitch: true)
            } else {
                self?.presentAddPhoto()
            }
        }
        backBtn.tapped { [weak self] (tapBtn) in
            self?.optionType = 2
            if let idcardpicUrlB = self?.registerModel?.idcardpicUrlBGR, !idcardpicUrlB.isEmpty {
                self?.detailImage = self?.backBtn.imageView?.image
                self?.presentAddPhoto(isSwitch: true)
            }
            else {
                self?.presentAddPhoto()
            }
        }
    }
    
    func configSection4(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let reviewBtn = UIButton().text("提交审核").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_next_btn"))
        cell.sv(reviewBtn)
        cell.layout(
            100,
            reviewBtn.width(280).height(40).centerHorizontally(),
            100
        )
        reviewBtn.tapped { [weak self] (tapBtn) in
            self?.reviewRequest()
        }
    }
    //MARK: - 提交审核
    func reviewRequest() {
        guard let name = nameTF.text, !name.isEmpty else {
            noticeOnlyText(nameTF.placeholder ?? "")
            return
        }
        guard let idcard = idcardTF.text, !idcard.isEmpty else {
            noticeOnlyText(idcardTF.placeholder ?? "")
            return
        }
        guard let face = registerModel?.idcardpicUrlFGR, !face.isEmpty else {
            noticeOnlyText("请上传身份证正面照")
            return
        }
        guard let back = registerModel?.idcardpicUrlBGR, !back.isEmpty else {
            noticeOnlyText("请上传身份证背面照")
            return
        }
        guard let id = registerModel?.id, !id.isEmpty else {
            noticeOnlyText("用户信息不完整")
            return
        }
        pleaseWait()
        var parameters = Parameters()
        parameters["id"] = id
        parameters["contacts"] = name
        parameters["idcardNo"] = idcard
        parameters["idcardpicUrlF"] = face
        parameters["idcardpicUrlB"] = back
        parameters["type"] = "2"
        YZBSign.shared.request(APIURL.authFile, method: .post, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let vc = MemberAuthSuccessVC()
                self.parentController?.navigationController?.pushViewController(vc)
            }
        } failure: { (error) in
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 {
            return 5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

//MARK: - 企业认证
class EnterpriseAuthView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CompanyTypePickerDelegate  {
    
    private var registerModel: RegisterModel?
    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.kBackgroundColor)
    private let nameTF = UITextField().placeholder("请填写公司名称")
    private let frNameTF = UITextField().placeholder("请填写法人名称")
    private let yyzzTF = UITextField().placeholder("营业执照号")
    private var optionType: Int = 1                     //操作类型  1.身份证正面 2.身份证反面
    private var cameraPicker: UIImagePickerController!
    private var photoPicker: UIImagePickerController!
    private var detailImage: UIImage?                   //需查看的详情图
    private let yyzzBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_com_photo_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    private let logoBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_com_logo_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    private let faceBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_id_face_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    private let backBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_id_back_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    private var companyTypePickerView1: CompanyTypePicker!   //公司类型选择器
    private var companyTypes1 = ["家装公司",  "工装公司", "家装/工装公司"]
    private var companyTypeNum1 = 1
    private let companyTypeLabel = UILabel().text("请选择公司类型").textColor(.kColor99).font(14)
    private var companyTypeText = ""
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        registerModel = UserData.shared.userInfoModel?.register
        if registerModel?.type == 1 {
            registerModel?.idcardpicUrlFQY = registerModel?.idcardpicUrlF
            registerModel?.idcardpicUrlBQY = registerModel?.idcardpicUrlB
        }
        if let storeType = registerModel?.storeType {
            let index = storeType - 1
            if index >= 0 {
                companyTypeText = companyTypes1[index]
                companyTypeNum1 = index + 1
            }
        }
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        sv(tableView)
        layout(
            0,
            |tableView|,
            0
        )
        
        nameTF.addTarget(self, action: #selector(textFieldChange(textField:)), for: .editingChanged)
        frNameTF.addTarget(self, action: #selector(textFieldChange(textField:)), for: .editingChanged)
        yyzzTF.addTarget(self, action: #selector(textFieldChange(textField:)), for: .editingChanged)
        
        companyTypePickerView1 = CompanyTypePicker()
        companyTypePickerView1.delegate = self
        addSubview(companyTypePickerView1)
        
        companyTypePickerView1.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
        
        
    }
    
    func pickerViewSelectCompanyType(pickerView: CompanyTypePicker, selectIndex: Int, component: Int) {
        companyTypeText = companyTypes1[selectIndex]
        companyTypeLabel.text(companyTypeText).textColor(.kColor33)
        companyTypeNum1 = selectIndex + 1
    }
    
    @objc func textFieldChange(textField: UITextField) {
        if textField == nameTF {
            registerModel?.comName = textField.text
        } else if textField == frNameTF {
            registerModel?.contacts = textField.text
        } else if textField == yyzzTF {
            registerModel?.licenseNo = textField.text
        }
    }
    
    //添加照片弹窗
    func presentAddPhoto(isSwitch: Bool = false) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
            DispatchQueue.main.async {
                if granted {
                    let sourceActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let cameraOption = UIAlertAction.init(title: "相机", style: .default) { [weak self] _ in
                        
                        self?.parentController?.present(self!.cameraPicker, animated: true, completion: nil)
                    }
                    let photoOption = UIAlertAction.init(title: "相册", style: .default) { [weak self] _ in
                        
                        self?.parentController?.present(self!.photoPicker, animated: true, completion: nil)
                    }
                    let lookPhotoOption = UIAlertAction.init(title: "查看大图", style: .default) { [weak self] _ in
                        
                        let vc = PictureBrowseController()
                        vc.showImage = self?.detailImage
                        self?.parentController?.present(vc, animated: true, completion: nil)
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
                            popPresenter?.sourceView = self.faceBtn
                            popPresenter?.sourceRect = self.faceBtn.bounds
                        case 2:
                            popPresenter?.sourceView = self.backBtn
                            popPresenter?.sourceRect = self.backBtn.bounds
                        case 3:
                            popPresenter?.sourceView = self.yyzzBtn
                            popPresenter?.sourceRect = self.yyzzBtn.bounds
                        case 4:
                            popPresenter?.sourceView = self.logoBtn
                            popPresenter?.sourceRect = self.logoBtn.bounds
                        default:
                            break
                        }
                    }
                    
                    self.parentController?.present(sourceActionSheet, animated: true, completion: nil)
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
                    self.parentController?.present(modifyAlert, animated: true, completion: nil)
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
            let oldUrl: String = self.registerModel?.idcardpicUrlFQY ?? ""
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.registerModel?.idcardpicUrlFQY = headStr
                self.faceBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        case 2:
            let type = "register/company"
            let oldUrl: String = self.registerModel?.idcardpicUrlBQY ?? ""
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.registerModel?.idcardpicUrlBQY = headStr
                self.backBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        case 3:
            let type = "register/company"
            let oldUrl: String = self.registerModel?.licenseUrl ?? ""
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.registerModel?.licenseUrl = headStr
                self.yyzzBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        case 4:
            let type = "register/company"
            let oldUrl: String = self.registerModel?.storeLogo ?? ""
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.registerModel?.storeLogo = headStr
                self.logoBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension EnterpriseAuthView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        if indexPath.section == 0 {
            configSection0(cell: cell)
        } else if indexPath.section == 1 {
            configSection1(cell: cell)
        } else if indexPath.section == 2 {
            configSection2(cell: cell)
        } else if indexPath.section == 3 {
            configSection3(cell: cell)
        } else if indexPath.section == 4 {
            configSection4(cell: cell)
        } else if indexPath.section == 5 {
            configSection5(cell: cell)
        } else if indexPath.section == 6 {
            configSection6(cell: cell)
        } else if indexPath.section == 7 {
            configSection7(cell: cell)
        }
        return cell
    }
    
    func configSection0(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let topTipIcon = UIImageView().image(#imageLiteral(resourceName: "regiest_anquan_icon"))
        let topTipLabel = UILabel().text("为了确保交易安全，我们需要认证您的身份，此信息会完全保密并不对外提供，只用于身份认证").textColor(.blue).font(12)
        cell.sv(topTipIcon, topTipLabel)
        cell.layout(
            10,
            |-14-topTipIcon.size(14),
            29
        )
        cell.layout(
            10,
            |-30-topTipLabel-30-|,
            >=10
        )
        topTipLabel.numberOfLines(0).lineSpace(2)
    }
    
    
    
    func configSection1(cell: UITableViewCell) {
        cell.backgroundColor(.white)
        let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_com_icon"))
        if registerModel?.isCheck == 2 {
            nameTF.text(registerModel?.comName ?? "")
        }
        nameTF.font = .systemFont(ofSize: 14)
        nameTF.placeholderColor = .kColor99
        cell.sv(starLabel, icon, nameTF)
        cell.layout(
            12,
            |-14-starLabel.width(7).height(22)-1-icon.size(17)-8-nameTF.height(44)-14-|,
            12
        )
    }
    
    func configSection2(cell: UITableViewCell) {
        let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let icon = UIImageView().image(#imageLiteral(resourceName: "login_companyType"))
        let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
        arrow.isUserInteractionEnabled = false
        cell.sv(starLabel, icon, companyTypeLabel, arrow)
        if !companyTypeText.isEmpty {
            companyTypeLabel.text(companyTypeText).textColor(.kColor33)
        } else {
            companyTypeLabel.textColor(.kColor99)
        }
        cell.layout(
            14.5,
            |-14-starLabel.width(7).height(22)-1-icon.size(17).centerVertically()-8-companyTypeLabel.height(44)-0.5-arrow.size(44)-0.5-|,
            14.5
        )
        
    }
    
    func configSection3(cell: UITableViewCell) {
        cell.backgroundColor(.white)
        let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_fr_icon"))
        if registerModel?.isCheck == 2 {
            frNameTF.text(registerModel?.contacts ?? "")
        }
        frNameTF.font = .systemFont(ofSize: 14)
        frNameTF.placeholderColor = .kColor99
        cell.sv(starLabel, icon, frNameTF)
        cell.layout(
            12,
            |-14-starLabel.width(7).height(22)-1-icon.size(17)-8-frNameTF.height(44)-14-|,
            12
        )
    }
    
    func configSection4(cell: UITableViewCell) {
        cell.backgroundColor(.white)
        let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let icon = UIImageView().image(#imageLiteral(resourceName: "auth_icon_yyzz"))
        yyzzTF.text(registerModel?.licenseNo ?? "")
        yyzzTF.font = .systemFont(ofSize: 14)
        yyzzTF.placeholderColor = .kColor99
        cell.sv(starLabel, icon, yyzzTF)
        cell.layout(
            12,
            |-14-starLabel.width(7).height(22)-1-icon.size(17)-8-yyzzTF.height(44)-14-|,
            12
        )
    }
    
    func configSection5(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let titleLable = UILabel().text("上传公司营业执照").textColor(.kColor33).font(14)
        let logoLable = UILabel().text("公司LOGO（选填）").textColor(.kColor33).font(14)
        cell.sv(starLabel, titleLable, logoLable, yyzzBtn, logoBtn)
        cell.layout(
            20,
            |-14-starLabel.height(20)-1-titleLable-(>=0)-logoLable,
            15,
            |-14-yyzzBtn.height(101)-21-logoBtn.height(101)-14-|,
            20
        )
        equal(widths: yyzzBtn, logoBtn)
        logoLable.Left == logoBtn.Left
        
        if !yyzzBtn.addImage(registerModel?.licenseUrl) {
            yyzzBtn.image(#imageLiteral(resourceName: "regiest_avatar_bg"))
        }
        if !logoBtn.addImage(registerModel?.storeLogo) {
            logoBtn.image(#imageLiteral(resourceName: "regiest_avatar_bg"))
        }
        yyzzBtn.tapped { [weak self] (tapBtn) in
            self?.optionType = 3
            if let licenseUrl = self?.registerModel?.licenseUrl, !licenseUrl.isEmpty {
                self?.detailImage = self?.yyzzBtn.imageView?.image
                self?.presentAddPhoto(isSwitch: true)
            } else {
                self?.presentAddPhoto()
            }
        }
        logoBtn.tapped { [weak self] (tapBtn) in
            self?.optionType = 4
            if let storeLogo = self?.registerModel?.storeLogo, !storeLogo.isEmpty {
                self?.detailImage = self?.logoBtn.imageView?.image
                self?.presentAddPhoto(isSwitch: true)
            } else {
                self?.presentAddPhoto()
            }
        }
    }
    
    func configSection6(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
        let titleLable = UILabel().text("上传身份证").textColor(.kColor33).font(14)
        cell.sv(starLabel, titleLable, faceBtn, backBtn)
        cell.layout(
            0,
            |-14-starLabel.height(20)-1-titleLable,
            15,
            |-14-faceBtn.height(101)-21-backBtn.height(101)-14-|,
            20
        )
        equal(widths: faceBtn, backBtn)
        
        if !faceBtn.addImage(registerModel?.idcardpicUrlF) {
            faceBtn.image(#imageLiteral(resourceName: "regiest_avatar_bg"))
        }
        if !backBtn.addImage(registerModel?.idcardpicUrlB) {
            backBtn.image(#imageLiteral(resourceName: "regiest_avatar_bg"))
        }
        faceBtn.tapped { [weak self] (tapBtn) in
            self?.optionType = 1
            if let idcardpicUrlF = self?.registerModel?.idcardpicUrlFQY, !idcardpicUrlF.isEmpty {
                self?.detailImage = self?.faceBtn.imageView?.image
                self?.presentAddPhoto(isSwitch: true)
            } else {
                self?.presentAddPhoto()
            }
        }
        backBtn.tapped { [weak self] (tapBtn) in
            self?.optionType = 2
            if let idcardpicUrlB = self?.registerModel?.idcardpicUrlBQY, !idcardpicUrlB.isEmpty {
                self?.detailImage = self?.backBtn.imageView?.image
                self?.presentAddPhoto(isSwitch: true)
            }
            else {
                self?.presentAddPhoto()
            }
        }
    }
    
    func configSection7(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let reviewBtn = UIButton().text("提交审核").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_next_btn"))
        cell.sv(reviewBtn)
        cell.layout(
            40,
            reviewBtn.width(280).height(40).centerHorizontally(),
            100
        )
        reviewBtn.tapped { [weak self] (tapBtn) in
            self?.reviewRequest()
        }
    }
    
    //MARK: - 提交审核
    func reviewRequest() {
        if companyTypeText.isEmpty {
            noticeOnlyText("请选择公司类型")
            return
        }
        guard let name = nameTF.text, !name.isEmpty else {
            noticeOnlyText(nameTF.placeholder ?? "")
            return
        }
        guard let frName = frNameTF.text, !frName.isEmpty else {
            noticeOnlyText(frNameTF.placeholder ?? "")
            return
        }
        guard let yyzz = yyzzTF.text, !yyzz.isEmpty else {
            noticeOnlyText(yyzzTF.placeholder ?? "")
            return
        }
        guard let licenseUrl = registerModel?.licenseUrl, !licenseUrl.isEmpty else {
            noticeOnlyText("请上传公司营业执照")
            return
        }
        guard let face = registerModel?.idcardpicUrlFQY, !face.isEmpty else {
            noticeOnlyText("请上传身份证正面照")
            return
        }
        guard let back = registerModel?.idcardpicUrlBQY, !back.isEmpty else {
            noticeOnlyText("请上传身份证背面照")
            return
        }
        guard let id = registerModel?.id, !id.isEmpty else {
            noticeOnlyText("用户信息不完整")
            return
        }
        
        pleaseWait()
        var parameters = Parameters()
        parameters["id"] = id
        parameters["comName"] = name
        parameters["contacts"] = frName
        parameters["licenseNo"] = yyzz
        parameters["licenseUrl"] = licenseUrl
        parameters["storeLogo"] = registerModel?.storeLogo
        parameters["idcardpicUrlF"] = face
        parameters["idcardpicUrlB"] = back
        parameters["storeType"] = companyTypeNum1
        parameters["type"] = "1"
        YZBSign.shared.request(APIURL.authFile, method: .post, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let vc = MemberAuthSuccessVC()
                self.parentController?.navigationController?.pushViewController(vc)
            }
        } failure: { (error) in
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2 {
            self.companyTypePickerView1.companyTypes = companyTypes1
            self.companyTypePickerView1.picker.reloadAllComponents()
            self.companyTypePickerView1.showPicker()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 1 || section == 2 || section == 3 {
            return 5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
