//
//  ServiceRegiestDesignVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/22.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import TLTransitions

class ServiceRegiestDesignVC: BaseViewController, CompanyTypePickerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public var regiestId: String?
    private var pop: TLTransition?
    private let userNameTF = UITextField().placeholder("请填写姓名").font(14).then {
        $0.setPlaceHolderTextColor(.kColor99)
    }
    private var companyTypePickerView: CompanyTypePicker!   //性别选择器
    private var companyTypes = ["男", "女"]
    private var companyTypeNum = 0
    private let sexLabel = UILabel().text("请选择性别").textColor(.kColor99).font(14)
    
    private let idCardTF = UITextField().placeholder("请输入身份证号码").font(14).then {
        $0.setPlaceHolderTextColor(.kColor99)
        $0.keyboardType = .phonePad
    }
    private let yearTF = UITextField().placeholder("请输入您的从业年数").font(14).then {
        $0.setPlaceHolderTextColor(.kColor99)
        $0.keyboardType = .phonePad
    }
    private let workTypeLabel = UILabel().text("请选择擅长设计类型(可多选)").textColor(.kColor99).font(14)
    private let workTypeTitles = ["住宅设计", "工装设计", "软装设计", "平面设计", "园林设计", "灯光设计", "图纸深化", "3D设计"]
    private var workTypeStr = ""
    private var isShowWorkType = false
    private let designStyleLabel = UILabel().text("请选择擅长设计风格(可多选)").textColor(.kColor99).font(14)
    private var designStyleTitles = ["现代", "中式", "港式", "新古典", "现代简约", "简欧", "北欧", "混搭", "工业", "后现代", "日式"]
    private var designStyleStr = ""
    private var isShowDesignType = false
    private var tagTitles = ["设计新颖", "专业过硬", "服务极好", "免费量房"]
    private let sureBtn = UIButton().text("提交").textColor(.white).font(14).backgroundImage(#imageLiteral(resourceName: "regiest_next_btn"))
    private var userNameText = ""
    private var idCardText = ""
    private var yearText = ""
    private var sexText = ""
    private var workTypeText = ""
    private var workTypeBtns: [UIButton] = []
    private var currentWorkTypeIndexs: [Int] = []
    
    private var designStyleText = ""
    private var designStyleBtns: [UIButton] = []
    private var currentDesignStyleIndexs: [Int] = []
    private var tagBtns: [UIButton] = []
    private var currentTagIndexs: [Int] = []
    private var tagTF = UITextField()
    private var tagText = ""
    private var tagTextNumLabel = UILabel().text("0/4").textColor(.kColor99).font(12)
    private let idcardFaceBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_idcard_face_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    private let idcardBackBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_idcard_back_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    private let zzBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_zz_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    private let avatarBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "regiest_avatar_back_bg")).image(#imageLiteral(resourceName: "regiest_avatar_bg"))
    
    private var idcardFaceUrlStr: String?
    private var idcardBackUrlStr: String?
    private var zzUrlStr: String?
    private var avatarUrlstr: String?
    private var optionType: Int = 1  //操作类型  1.身份证正面 2.身份证反面 3.营业执照 4.logo
    private var cameraPicker = UIImagePickerController()
    private var photoPicker = UIImagePickerController()
    private var detailImage: UIImage?                   //需查看的详情图
    var regiestModel: RegisterModel? {
        didSet {
            idcardFaceUrlStr = regiestModel?.idcardpicUrlF
            idcardBackUrlStr = regiestModel?.idcardpicUrlB
            zzUrlStr = regiestModel?.relatedQualifications
            avatarUrlstr = regiestModel?.headUrl
            idcardFaceBtn.addImage(regiestModel?.idcardpicUrlF)
            idcardBackBtn.addImage(regiestModel?.idcardpicUrlB)
            zzBtn.addImage(regiestModel?.relatedQualifications)
            avatarBtn.addImage(regiestModel?.headUrl)
        }
    }
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    
    
    @objc func back() {
        navigationController?.popToRootViewController(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "资质认证"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(back))
        [userNameTF, idCardTF, yearTF].forEach {
            $0.delegate = self
        }
        
        if regiestModel != nil {
            userNameText = regiestModel?.name ?? ""
            if regiestModel?.sex == 1 {
                sexText = "男"
            } else if regiestModel?.sex == 2 {
                sexText = "女"
            }
            idCardText = regiestModel?.idCard ?? ""
            if regiestModel?.workingYears != nil {
                yearText = "\(regiestModel?.workingYears ?? 0)"
            }
            workTypeTitles.enumerated().forEach { (item) in
                let index = item.offset
                let tagTitle = item.element
                regiestModel?.designType?.components(separatedBy: ",").forEach({ (str) in
                    if str == tagTitle {
                        currentWorkTypeIndexs.append(index)
                        
                        if workTypeText != "" {
                            workTypeText.append(";")
                        }
                        workTypeText.append("\(tagTitle)")
                        if workTypeStr != "" {
                            workTypeStr.append(",")
                        }
                        workTypeStr.append("\(index)")
                    }
                })
            }
            isShowWorkType = true
            
            designStyleTitles.enumerated().forEach { (item) in
                let index = item.offset
                let tagTitle = item.element
                regiestModel?.designStyle?.components(separatedBy: ",").forEach({ (str) in
                    if str == tagTitle {
                        currentDesignStyleIndexs.append(index)
                        if designStyleText != "" {
                            designStyleText.append(";")
                        }
                        designStyleText.append("\(tagTitle)")
                        if designStyleStr != "" {
                            designStyleStr.append(",")
                        }
                        designStyleStr.append("\(index)")
                    }
                })
            }
            isShowDesignType = true
            regiestModel?.individualLabels?.components(separatedBy: ",").forEach({ (individualLabel) in
                if !tagTitles.contains(individualLabel) {
                    tagTitles.append(individualLabel)
                }
            })
            tagTitles.enumerated().forEach { (item) in
                let index = item.offset
                let tagTitle = item.element
                regiestModel?.individualLabels?.components(separatedBy: ",").forEach({ (str) in
                    if str == tagTitle {
                        currentTagIndexs.append(index)
                        if tagText != "" {
                            tagText.append(",")
                        }
                        tagText.append("\(index)")
                    }
                })
            }
        }
        
        self.avatarBtn.imageView?.contentMode = .scaleToFill
        self.zzBtn.imageView?.contentMode = .scaleToFill
        self.idcardBackBtn.imageView?.contentMode = .scaleToFill
        self.idcardFaceBtn.imageView?.contentMode = .scaleToFill
        //相机
        cameraPicker.delegate = self
        if Utils.isSimulator == false {
            cameraPicker.sourceType = .camera
        }
        
        //相册
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
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        companyTypePickerView = CompanyTypePicker()
        companyTypePickerView.delegate = self
        companyTypePickerView.companyTypes = companyTypes
        view.addSubview(companyTypePickerView)
        
        companyTypePickerView.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    func pickerViewSelectCompanyType(pickerView: CompanyTypePicker, selectIndex: Int, component: Int) {
        sexText = companyTypes[selectIndex]
        companyTypeNum = selectIndex
        sexLabel.text(sexText).textColor(.kColor33)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case userNameTF:
            userNameText = userNameTF.text ?? ""
        case idCardTF:
            idCardText = idCardTF.text ?? ""
        case yearTF:
            yearText = yearTF.text ?? ""
        default:
            break
        }
    }
}


extension ServiceRegiestDesignVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            companyTypePickerView.showPicker()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_name"))
            cell.sv(star, icon, userNameTF)
            userNameTF.text(userNameText)
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-userNameTF.height(44)-45-|
        case 1:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_idcard"))
            let showBtn = UIButton().then {
                $0.setImage(#imageLiteral(resourceName: "regiest_unshow"), for: .normal)
                $0.setImage(#imageLiteral(resourceName: "regiest_show"), for: .selected)
            }
            showBtn.isHidden = true
            cell.sv(star, icon, idCardTF, showBtn)
            idCardTF.text(idCardText)
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-idCardTF.height(44)-0.5-showBtn.size(44)-0.5-|
            showBtn.addTarget(self, action: #selector(idCardShowBtnClick(btn:)))
        case 2:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_workyear"))
            let showBtn = UIButton().then {
                $0.setImage(#imageLiteral(resourceName: "regiest_unshow"), for: .normal)
                $0.setImage(#imageLiteral(resourceName: "regiest_show"), for: .selected)
            }
            showBtn.isHidden = true
            cell.sv(star, icon, yearTF, showBtn)
            yearTF.text(yearText)
            |-14-star.width(7).height(20).centerVertically()-0-icon.size(17).centerVertically()-8-yearTF.height(44)-0.5-showBtn.size(44)-0.5-|
            showBtn.addTarget(self, action: #selector(yearShowBtnClick(btn:)))
        case 3:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_worktype"))
            let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
            cell.sv(star, icon, workTypeLabel, arrow)
            if !workTypeText.isEmpty {
                workTypeLabel.text(workTypeText).textColor(.kColor33)
            } else {
                workTypeLabel.text("请选择擅长设计类型(可多选)").textColor(.kColor33)
            }
            if isShowWorkType {
                let arrowImage = #imageLiteral(resourceName: "regiest_arrow_down").rotated(by: .pi)
                arrow.image(arrowImage)
                cell.layout(
                    13.5,
                    |-14.5-star.width(7).height(20).centerVertically()-0-icon.size(16.64)-8-workTypeLabel.height(44)-0.5-arrow.size(44)-0.5-|,
                    >=0
                )
                let btnW: CGFloat = (view.width - 63)/4
                let btnH: CGFloat = 30
                
                workTypeTitles.enumerated().forEach { (item) in
                    let index = item.offset
                    let title = item.element
                    let offsetX: CGFloat = CGFloat(btnW + 10) * CGFloat(index % 4) + 14
                    let offsetY: CGFloat = CGFloat(btnH + 15) * CGFloat(index / 4) + 44
                    let btn = UIButton().text(title).textColor(.kColor99).font(12).borderColor(.kColor99).borderWidth(0.5).cornerRadius(15).masksToBounds()
                    cell.sv(btn)
                    cell.layout(
                        offsetY,
                        |-offsetX-btn.width(btnW).height(btnH),
                        >=20
                    )
                    btn.tag = index
                    workTypeBtns.append(btn)
                    btn.addTarget(self, action: #selector(workTypeBtnClick(btn:)))
                    currentWorkTypeIndexs.forEach { (workTypeIndex) in
                        if workTypeIndex == index {
                            btn.textColor(.white).backgroundColor(.k2FD4A7).borderColor(.k2FD4A7)
                        }
                    }
                }
            } else {
                arrow.image(#imageLiteral(resourceName: "regiest_arrow_down"))
                cell.layout(
                    13.5,
                    |-14.5-star.width(7).height(20).centerVertically()-0-icon.size(16.64)-8-workTypeLabel.height(44)-0.5-arrow.size(44)-0.5-|,
                    13.5
                )
            }
            arrow.tag = indexPath.section
            arrow.addTarget(self, action: #selector(arrowBtnClick(btn:)))
            
        case 4:
            let star = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_design_style"))
            let arrow = UIButton().image(#imageLiteral(resourceName: "regiest_arrow_down"))
            cell.sv(star, icon, designStyleLabel, arrow)
            if !designStyleText.isEmpty {
                designStyleLabel.text(designStyleText).textColor(.kColor33)
            } else {
                designStyleLabel.text("请选择擅长设计风格(可多选)").textColor(.kColor33)
            }
            if isShowDesignType {
                let arrowImage = #imageLiteral(resourceName: "regiest_arrow_down").rotated(by: .pi)
                arrow.image(arrowImage)
                cell.layout(
                    13.5,
                    |-14.5-star.width(7).height(20).centerVertically()-0-icon.size(16.64)-8-designStyleLabel.height(44)-0.5-arrow.size(44)-0.5-|,
                    >=0
                )
                let btnW: CGFloat = (view.width - 63)/4
                let btnH: CGFloat = 30
                
                designStyleTitles.enumerated().forEach { (item) in
                    let index = item.offset
                    let title = item.element
                    let offsetX: CGFloat = CGFloat(btnW + 10) * CGFloat(index % 4) + 14
                    let offsetY: CGFloat = CGFloat(btnH + 15) * CGFloat(index / 4) + 44
                    let btn = UIButton().text(title).textColor(.kColor99).font(12).borderColor(.kColor99).borderWidth(0.5).cornerRadius(15).masksToBounds()
                    cell.sv(btn)
                    cell.layout(
                        offsetY,
                        |-offsetX-btn.width(btnW).height(btnH),
                        >=20
                    )
                    btn.tag = index
                    designStyleBtns.append(btn)
                    btn.addTarget(self, action: #selector(designStyleBtnClick(btn:)))
                    currentDesignStyleIndexs.forEach { (designStyleIndex) in
                        if designStyleIndex == index {
                            btn.textColor(.white).backgroundColor(.k2FD4A7).borderColor(.k2FD4A7)
                        }
                    }
                }
            } else {
                arrow.image(#imageLiteral(resourceName: "regiest_arrow_down"))
                cell.layout(
                    13.5,
                    |-14.5-star.width(7).height(20).centerVertically()-0-icon.size(16.64)-8-designStyleLabel.height(44)-0.5-arrow.size(44)-0.5-|,
                    >=13.5
                )
            }
            arrow.tag = indexPath.section
            arrow.addTarget(self, action: #selector(arrowBtnClick(btn:)))
        case 5:
            let starLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let titleLabel = UILabel().text("为自己添加标签").textColor(.kColor33).font(14)
            cell.sv(starLabel, titleLabel)
            cell.layout(
                15,
                |-14-starLabel.height(20)-0-titleLabel.height(20),
                >=15
            )
            let btnW: CGFloat = (view.width - 63)/4
            let btnH: CGFloat = 30
            tagTitles.append("添加")
            tagTitles.enumerated().forEach { (item) in
                let index = item.offset
                let title = item.element
                let offsetX: CGFloat = CGFloat(btnW + 10) * CGFloat(index % 4) + 14
                let offsetY: CGFloat = CGFloat(btnH + 15) * CGFloat(index / 4) + 44
                let btn = UIButton().text(title).textColor(.kColor99).font(12).borderColor(.kColor99).borderWidth(0.5).cornerRadius(15).masksToBounds()
                cell.sv(btn)
                cell.layout(
                    offsetY,
                    |-offsetX-btn.width(btnW).height(btnH),
                    >=20
                )
                btn.tag = index
                
                if index == tagTitles.count - 1 { // 最后一个是添加新的标签按钮
                    btn.backgroundImage(#imageLiteral(resourceName: "regiest_tag_add")).text(title).textColor(.k2FD4A7).borderColor(.clear)
                    btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
                    btn.addTarget(self, action: #selector(addTaqBtnClick(btn:)))
                } else {
                    tagBtns.append(btn)
                    btn.addTarget(self, action: #selector(tagBtnClick(btn:)))
                }
                
                currentTagIndexs.forEach { (tagIndex) in
                    if tagIndex == index {
                        btn.textColor(.white).backgroundColor(.k2FD4A7).borderColor(.k2FD4A7)
                    }
                }
            }
            tagTitles.removeLast()
        default:
            break
        }
        return cell
    }
    
    @objc private func arrowBtnClick(btn: UIButton) {
        if btn.tag == 3 {
            isShowWorkType = !isShowWorkType
        } else if btn.tag == 4 {
            isShowDesignType = !isShowDesignType
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 120.5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 120.5)).backgroundColor(.kBackgroundColor)
            let icon = UIImageView().image(#imageLiteral(resourceName: "regiest_anquan_icon"))
            let tipLabel = UILabel().text("为了确保交易安全，我们需要认证您的身份，此信息会完全保密并不对外提供，只用于身份认证").textColor(UIColor.hexColor("#3564F6")).font(12)
            tipLabel.numberOfLines(2).lineSpace(2)
            let stepIV = UIImageView().image(#imageLiteral(resourceName: "pps_register_step_2"))
            v.sv(icon, tipLabel, stepIV)
            v.layout(
                10,
                |-14-icon.size(14),
                >=0
            )
            v.layout(
                9.5,
                |-30-tipLabel-30-|,
                10,
                stepIV.height(58).centerHorizontally(),
                10
            )
            
            return v
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 5 {
            return 451
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 5 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 451)).backgroundColor(.white)
            let line = UIView().backgroundColor(.kBackgroundColor)
            let btnW: CGFloat = (view.width - 49)/2
            let btnH: CGFloat = 101
            
            let idcardStarLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let idcardTitleLabel = UILabel().text("上传身份证").textColor(.kColor33).font(14)
            
            let idcardFaceTipLabel = UILabel().text("身份证正面").textColor(.kColor99).font(10).textAligment(.center)
            let idcardBackTipLabel = UILabel().text("身份证反面").textColor(.kColor99).font(10).textAligment(.center)
            let zzStarLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let zzTitleLabel = UILabel().text("相关资质").textColor(.kColor33).font(14)
            
            let avatarStarLabel = UILabel().text("*").textColor(.kDF2F2F).font(14)
            let avatarTitleLabel = UILabel().text("头像").textColor(.kColor33).font(14)
            
            v.sv(line, idcardStarLabel, idcardTitleLabel, idcardFaceBtn, idcardBackBtn, idcardFaceTipLabel, idcardBackTipLabel, zzStarLabel, zzTitleLabel, zzBtn, avatarStarLabel, avatarTitleLabel, avatarBtn, sureBtn)
            v.layout(
                0,
                |line.height(5)|,
                15,
                |-14-idcardStarLabel.height(20)-0-idcardTitleLabel.height(20),
                15,
                |-14-idcardFaceBtn.width(btnW).height(btnH)-21-idcardBackBtn.width(btnW).height(btnH),
                5,
                |-14-idcardFaceTipLabel.width(btnW).height(14)-21-idcardBackTipLabel.width(btnW).height(14),
                15,
                |-14-zzStarLabel.height(20)-0-zzTitleLabel.width(btnW).height(20)-18-avatarStarLabel.height(20)-0-avatarTitleLabel.height(20),
                15,
                |-14-zzBtn.width(btnW).height(btnH)-52-avatarBtn.size(btnH),
                50,
                sureBtn.width(280).height(40).centerHorizontally(),
                >=0
            )
            idcardFaceBtn.addTarget(self, action: #selector(idcardFaceBtnClick(btn:)))
            idcardBackBtn.addTarget(self, action: #selector(idcardBackBtnClick(btn:)))
            zzBtn.addTarget(self, action: #selector(zzBtnClick(btn:)))
            avatarBtn.addTarget(self, action: #selector(avatarBtnClick(btn:)))
            sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
            return v
        }
        return UIView()
    }
}
// MARK: - 按钮点击方法
extension ServiceRegiestDesignVC {
    @objc private func workTypeBtnClick(btn: UIButton) {
        if currentWorkTypeIndexs.contains(btn.tag) {
            currentWorkTypeIndexs.removeAll(btn.tag)
        } else {
            currentWorkTypeIndexs.append(btn.tag)
        }
        workTypeText = ""
        workTypeStr = ""
        currentWorkTypeIndexs.forEach { (index) in
            workTypeText.append(workTypeTitles[index])
            workTypeText.append(";")
            if !workTypeStr.isEmpty {
                workTypeStr.append(",")
            }
            workTypeStr.append(workTypeTitles[index])
        }
        tableView.reloadData()
    }
    
    @objc private func designStyleBtnClick(btn: UIButton) {
        if currentDesignStyleIndexs.contains(btn.tag) {
            currentDesignStyleIndexs.removeAll(btn.tag)
        } else {
            currentDesignStyleIndexs.append(btn.tag)
        }
        designStyleText = ""
        designStyleStr = ""
        currentDesignStyleIndexs.forEach { (index) in
            designStyleText.append(designStyleTitles[index])
            designStyleText.append(";")
            if !designStyleStr.isEmpty {
                designStyleStr.append(",")
            }
            designStyleStr.append(designStyleTitles[index])
        }
        tableView.reloadData()
    }
    
    @objc private func tagBtnClick(btn: UIButton) {
        if currentTagIndexs.contains(btn.tag) {
            currentTagIndexs.removeAll(btn.tag)
        } else {
            currentTagIndexs.append(btn.tag)
        }
        tagText = ""
        currentTagIndexs.forEach { (index) in
            if !tagText.isEmpty {
                tagText.append(",")
            }
            tagText.append(tagTitles[index])
        }
        tableView.reloadData()
    }
    
    @objc private func addTaqBtnClick(btn: UIButton) {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 272, height: 164)).backgroundColor(.white)
        let titleLab = UILabel().text("添加标签").textColor(.kColor33).fontBold(14)
        let tagTFBgView = UIView().backgroundColor(.kColorEE)
        let tagCancelBtn = UIButton().text("取消").textColor(.kColor33).font(14).borderColor(.kF0F0F0).borderWidth(0.5)
        let tagSureBtn = UIButton().text("确认").textColor(.kColor33).font(14).borderColor(.kF0F0F0).borderWidth(0.5)
        v.sv(titleLab, tagTFBgView, tagCancelBtn, tagSureBtn)
        v.layout(
            25,
            titleLab.height(20).centerHorizontally(),
            17,
            tagTFBgView.width(180).height(30).centerHorizontally(),
            23,
            |tagCancelBtn-0-tagSureBtn|,
            0
        )
        equal(widths: tagCancelBtn, tagSureBtn)
        equal(heights: tagCancelBtn, tagSureBtn)
        tagTF.font(12)
        tagTFBgView.sv(tagTF, tagTextNumLabel)
        tagTF.addTarget(self, action: #selector(tagTFValueChage(textField:)), for: .editingChanged)
        |-5-tagTF.height(30)-5-tagTextNumLabel.height(30)-5-|
        
        pop = TLTransition.show(v, popType: TLPopTypeAlert)
        pop?.cornerRadius = 5
        
        tagCancelBtn.addTarget(self, action: #selector(tagCancelBtnClick(btn:)))
        tagSureBtn.addTarget(self, action: #selector(tagSureBtnClick(btn:)))
    }
    
    @objc private func tagTFValueChage(textField: UITextField) {
        guard let _: UITextRange = textField.markedTextRange else{
            if (textField.text! as NSString).length > 4 {
                textField.text = (textField.text! as NSString).substring(to:4)
            }
            tagTextNumLabel.text("\((textField.text! as NSString).length)/4")
            return
        }
    }
    
    @objc private func tagCancelBtnClick(btn: UIButton) {
        pop?.dismiss()
    }
    
    @objc private func tagSureBtnClick(btn: UIButton) {
        if let text = tagTF.text, !text.isEmpty, text.length == 4 {
            if tagTitles.contains(text) {
                noticeOnlyText("该标签已存在")
            } else {
                tagTitles.append(text)
                tableView.reloadData()
                tagTF.text = ""
                pop?.dismiss()
            }
        } else {
            noticeOnlyText("标签需要输入4位字符")
        }
    }
    
    @objc private func idCardShowBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        idCardTF.isSecureTextEntry = !btn.isSelected
    }
    
    @objc private func yearShowBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        yearTF.isSecureTextEntry = !btn.isSelected
    }
    
    @objc private func idcardFaceBtnClick(btn: UIButton) {
        optionType = 1
        presentAddPhoto()
    }
    
    @objc private func idcardBackBtnClick(btn: UIButton) {
        optionType = 2
        presentAddPhoto()
    }
    
    @objc private func zzBtnClick(btn: UIButton) {
        optionType = 3
        presentAddPhoto()
    }
    
    @objc private func avatarBtnClick(btn: UIButton) {
        optionType = 4
        presentAddPhoto()
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
                            popPresenter?.sourceView = self.idcardFaceBtn
                            popPresenter?.sourceRect = self.idcardFaceBtn.bounds
                            break
                        case 2:
                            popPresenter?.sourceView = self.idcardBackBtn
                            popPresenter?.sourceRect = self.idcardBackBtn.bounds
                            break
                        case 3:
                            popPresenter?.sourceView = self.zzBtn
                            popPresenter?.sourceRect = self.zzBtn.bounds
                            break
                        case 4:
                            popPresenter?.sourceView = self.avatarBtn
                            popPresenter?.sourceRect = self.avatarBtn.bounds
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
            if self.regiestModel != nil {
                oldUrl = self.regiestModel?.idcardpicUrlF ?? ""
            }
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                if self.regiestModel != nil {
                    self.regiestModel?.idcardpicUrlF = headStr
                }
                self.idcardFaceUrlStr = headStr
                self.idcardFaceBtn.imageView?.contentMode = .scaleToFill
                self.idcardFaceBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        case 2:
            
            let type = "register/company"
            var oldUrl: String = ""
            if self.regiestModel != nil {
                oldUrl = self.regiestModel?.idcardpicUrlB ?? ""
            }
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                if self.regiestModel != nil {
                    self.regiestModel?.idcardpicUrlB = headStr
                }
                self.idcardBackUrlStr = headStr
                self.idcardBackBtn.imageView?.contentMode = .scaleToFill
                self.idcardBackBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        case 3:
            let type = "register/company"
            var oldUrl: String = ""
            if self.regiestModel != nil {
                oldUrl = self.regiestModel?.relatedQualifications ?? ""
            }
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                if self.regiestModel != nil {
                    self.regiestModel?.relatedQualifications = headStr
                }
                self.zzUrlStr = headStr
                self.zzBtn.imageView?.contentMode = .scaleToFill
                self.zzBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
                
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        case 4:
            
            let type = "register/company"
            var oldUrl: String = ""
            if self.regiestModel != nil {
                oldUrl = self.regiestModel?.headUrl ?? ""
            }
            YZBSign.shared.upLoadImageRequest(oldUrl: oldUrl, imageType: type, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                if self.regiestModel != nil {
                    self.regiestModel?.headUrl = headStr
                }
                self.avatarUrlstr = headStr
                self.avatarBtn.imageView?.contentMode = .scaleToFill
                self.avatarBtn.image(image)
                self.noticeSuccess("上传成功", autoClear: true, autoClearTime: 1)
            }, failture: { (error) in
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
            })
        default:
            break
        }
    }
    
    
    @objc private func sureBtnClick(btn: UIButton) {
        var parameters = Parameters()
        if userNameText == "" {
            noticeOnlyText("请输入用户名")
            return
        }
        if idCardText == "" {
            noticeOnlyText("请输入身份证号码")
            return
        }
        if yearText == "" {
            noticeOnlyText("请输入您的从业年数")
            return
        }
        if currentWorkTypeIndexs.count == 0 {
            noticeOnlyText("请选择设计类型")
            return
        }
        if currentDesignStyleIndexs.count == 0 {
            noticeOnlyText("请选择设计风格")
            return
        }
        if currentTagIndexs.count == 0 {
            noticeOnlyText("请为自己添加标签")
            return
        }
        if idcardFaceUrlStr == nil {
            noticeOnlyText("请添加身份证正面照")
            return
        }
        if idcardBackUrlStr == nil {
            noticeOnlyText("请添加身份证反面照")
            return
        }
        if zzUrlStr == nil {
            noticeOnlyText("请添加相关资质照片")
            return
        }
        if avatarUrlstr == nil {
            noticeOnlyText("请添加头像照片")
            return
        }
        if regiestModel == nil {
            parameters["id"] = regiestId
        } else {
            parameters["id"] = regiestModel?.id
        }
        
        parameters["name"] = userNameText
        parameters["sex"] = "1"
        parameters["idCard"] = idCardText
        parameters["workingYears"] = yearText
        parameters["individualLabels"] = tagText
        parameters["designType"] = workTypeStr
        parameters["designStyle"] = designStyleStr
        parameters["headUrl"] = avatarUrlstr
        parameters["idcardpicUrlF"] = idcardFaceUrlStr
        parameters["idcardpicUrlB"] = idcardBackUrlStr
        parameters["relatedQualifications"] = zzUrlStr
        parameters["serviceType"] = 6
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
    
    
    
}
