//
//  PlusOrderEditController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/26.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog

class PlusOrderEditController: BaseViewController,UITableViewDelegate,UITableViewDataSource,UIViewControllerTransitioningDelegate {
    
    var popupView: UIView!                  //弹窗
    var alrtLabel: UILabel!                 //提示文字
    var noImgView: UIImageView!
    var deleteBtn: UIButton!                //删除项
    var deleteRoomBtn: UIButton!            //删除房间
    var tableView: UITableView!
    let identifier = "PlusOrderEditCell"
    let sectionHeaderId = "PlusOrderEditHeadView"
    
    /// delType: 删除类型，1：删除房间，2：删除项
    var delBlock: ((_ rowsData:Array<PlusDataModel>, _ delType: Int)->())?
    /// 关闭block
    var doneBlock: (()->())?
    
    var rowsData: Array<PlusDataModel> = [] {
        
        didSet {
            _ = rowsData.map { $0.isShow = true }
            
            if rowsData.count > 0  {
                alrtLabel.text = "只包含自增项"
                tableView.reloadData()
                tableView.isHidden = false
                noImgView.isHidden = true
                deleteBtn.isHidden = false
                deleteRoomBtn.isHidden = false
                popupView.snp.updateConstraints { (make) in
                    make.height.equalTo(421)
                }
                
                getCheckCount()
            }else {
                alrtLabel.text = "哎呀，没有东西了~"
                tableView.isHidden = true
                noImgView.isHidden = false
                deleteBtn.isHidden = true
                deleteRoomBtn.isHidden = true
                popupView.snp.updateConstraints { (make) in
                    make.height.equalTo(195)
                }
            }
        }
    }
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>>> 编辑界面释放 <<<<<<<<<<<<<<<<<<<<<")
    }
    
    
    init(){
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSubView()
    }
    
    func createSubView() {
        
        //内容弹窗
        popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 5
        self.view.addSubview(popupView)
        
        popupView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(195)
        }
        
        //返回
        
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.setImage(UIImage(named: "plus_close_icon"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        popupView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        //标题
        let titleLabel = UILabel()
        titleLabel.text = "编辑"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = PublicColor.commonTextColor
        popupView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(16)
        }
        
        alrtLabel = UILabel()
        alrtLabel.text = "哎呀，没有东西了~"
        alrtLabel.font = UIFont.systemFont(ofSize: 13)
        alrtLabel.textColor = PublicColor.minorTextColor
        popupView.addSubview(alrtLabel)
        
        alrtLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6)
        popupView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(alrtLabel.snp.bottom).offset(10)
        }
        
        noImgView = UIImageView()
        noImgView.image = UIImage(named: "icon_empty")
        noImgView.contentMode = .scaleAspectFit
        popupView.addSubview(noImgView)
        
        noImgView.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(99)
            make.height.equalTo(89)
        }
        
        
        //删除项
        let backgroundImg = PublicColor.buttonColorImage
        let backgroundHImg = PublicColor.buttonHightColorImage
        deleteBtn = UIButton.init(type: .custom)
        deleteBtn.isHidden = true
        deleteBtn.layer.cornerRadius = 2
        deleteBtn.layer.masksToBounds = true
        deleteBtn.layer.borderColor = PublicColor.partingLineColor.cgColor
        deleteBtn.layer.borderWidth = 1
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        deleteBtn.setTitle("删除项(0)", for: .normal)
        deleteBtn.setTitleColor(PublicColor.placeholderTextColor, for: .normal)
        deleteBtn.setBackgroundImage(backgroundImg, for: .normal)
        deleteBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        deleteBtn.addTarget(self, action: #selector(delCellAction), for: .touchUpInside)
        popupView.addSubview(deleteBtn)
        
        deleteBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(-50)
            make.bottom.equalTo(-20)
            make.width.equalTo(80)
            make.height.equalTo(25)
        }
        
        //删除房间
        deleteRoomBtn = UIButton.init(type: .custom)
        deleteRoomBtn.isHidden = true
        deleteRoomBtn.layer.cornerRadius = 2
        deleteRoomBtn.layer.masksToBounds = true
        deleteRoomBtn.layer.borderColor = PublicColor.partingLineColor.cgColor
        deleteRoomBtn.layer.borderWidth = 1
        deleteRoomBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        deleteRoomBtn.setTitle("删除房间(0)", for: .normal)
        deleteRoomBtn.setTitleColor(PublicColor.placeholderTextColor, for: .normal)
        deleteRoomBtn.setBackgroundImage(backgroundImg, for: .normal)
        deleteRoomBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        deleteRoomBtn.addTarget(self, action: #selector(delRoomAction), for: .touchUpInside)
        popupView.addSubview(deleteRoomBtn)
        
        deleteRoomBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(50)
            make.bottom.equalTo(-20)
            make.width.equalTo(80)
            make.height.equalTo(25)
        }
        
        
        tableView = UITableView.init(frame: CGRect.zero, style: UITableView.Style.grouped)
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 33
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(PlusOrderEditCell.self, forCellReuseIdentifier: identifier)
        popupView.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(deleteBtn.snp.top).offset(-12)
        }
       
        //--注册组头
        tableView.register(PlusOrderEditHeadView.self, forHeaderFooterViewReuseIdentifier: sectionHeaderId)
  
    }
    
    //MARK: 按钮点击
    //删除项
    @objc func delCellAction() {
        
        let popup = PopupDialog(title: "是否删除所有选中项?", message: nil,buttonAlignment: .horizontal)
        let sureBtn = DestructiveButton(title: "删除") {
            
            for sectionModel in self.rowsData {
                
                for packageModel in sectionModel.packageList {
                    
                    if let index = sectionModel.packageList.firstIndex(of: packageModel) {
                        if packageModel.isEditCheck == true {
                            
                            sectionModel.packageList.remove(at: index)
                        }
                    }
                }
                for serviceModel in sectionModel.serviceList {
                    
                    if let index = sectionModel.serviceList.firstIndex(of: serviceModel) {
                        if serviceModel.isCheck == true {
                            
                            sectionModel.serviceList.remove(at: index)
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
            self.getCheckCount()
            
            if let block = self.delBlock {
                block(self.rowsData, 2)
            }
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
     
    }
    
    //删除房间
    @objc func delRoomAction() {
        
        let popup = PopupDialog(title: "是否删除所有选中房间?", message: nil,buttonAlignment: .horizontal)
        let sureBtn = DestructiveButton(title: "删除") {
            
            for model in self.rowsData  {
                
                if let index = self.rowsData.firstIndex(of: model) {
                    if model.isCheck == true {
                        
                        self.rowsData.remove(at: index)
                    }
                }
            }
            
            self.tableView.reloadData()
            self.getCheckCount()
            
            if let block = self.delBlock {
                block(self.rowsData, 1)
            }
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
   
    }
    
    @objc func cancelAction() {
        
        if let block = doneBlock {
            block()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    //获取所有选中数
    func getCheckCount() {
        
        var cellCheckCount: Int = 0
        var roomCheckCount: Int = 0
        
        for sectionModel in rowsData {
            
            var cellCount: Int = 0
            var packageCount = 0
            var serviceCount = 0
            
            for packageModel in sectionModel.packageList {
                
                if packageModel.packageType != 1 {
                    packageCount += 1
                    
                    if packageModel.isEditCheck {
                        cellCheckCount += 1
                        cellCount += 1
                    }
                }
            }
            
            for serviceModel in sectionModel.serviceList {
                
                if serviceModel.serviceType != 1 {
                    serviceCount += 1
                    
                    if serviceModel.isCheck {
                        cellCheckCount += 1
                        cellCount += 1
                    }
                }
            }
            
            if packageCount <= 0 && serviceCount <= 0 {
                //没有新增主材施工
                if sectionModel.isCheck {
                    roomCheckCount += 1
                }
            }else {
                if cellCount == packageCount + serviceCount {
                    sectionModel.isCheck = true
                    roomCheckCount += 1
                }else {
                    sectionModel.isCheck = false
                }
            }
        }
        updateDeleteButtonCount(cellCheckCount,roomCheckCount)
        
    }
    
    func updateDeleteButtonCount(_ cellCheckCount:Int,_ roomCheckCount:Int) {
        deleteBtn.setTitle("删除项(\(cellCheckCount))", for: .normal)
        deleteRoomBtn.setTitle("删除房间(\(roomCheckCount))", for: .normal)
        
        if cellCheckCount == 0 {
            deleteBtn.isEnabled = false
            deleteBtn.layer.borderColor = PublicColor.partingLineColor.cgColor
            
            deleteBtn.setTitleColor(PublicColor.placeholderTextColor, for: .normal)
            deleteBtn.setTitleColor(PublicColor.placeholderTextColor, for: .normal)
        }else {
            deleteBtn.isEnabled = true
            deleteBtn.layer.borderColor = PublicColor.navigationLineColor.cgColor
            deleteBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            deleteBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        }
        
        if roomCheckCount == 0 {
            deleteRoomBtn.isEnabled = false
            deleteRoomBtn.layer.borderColor = PublicColor.partingLineColor.cgColor
            
            deleteRoomBtn.setTitleColor(PublicColor.placeholderTextColor, for: .normal)
            deleteRoomBtn.setTitleColor(PublicColor.placeholderTextColor, for: .normal)
        }else {
            deleteRoomBtn.isEnabled = true
            deleteRoomBtn.layer.borderColor = PublicColor.navigationLineColor.cgColor
            
            deleteRoomBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            deleteRoomBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        }
    }
    //刷新组选按钮状态
    func updateSectionAllSelected(sectionModel:PlusDataModel,isCheck:Bool) {
        
        sectionModel.isCheck = isCheck
        
        for packageModel in sectionModel.packageList {
            if packageModel.packageType != 1 {
                packageModel.isEditCheck = isCheck
            }
        }
        for serviceModel in sectionModel.serviceList {
            if serviceModel.serviceType != 1 {
                serviceModel.isCheck = isCheck
            }
        }

        getCheckCount()
    }
    
  
    //MARK: - tableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let model = rowsData[section]
        var packageCount = 0
        var serviceCount = 0
        
        for packageModel in model.packageList {
            if packageModel.packageType != 1 {
                packageCount += 1
            }
        }
        
        for serviceModel in model.serviceList {
            if serviceModel.serviceType != 1 {
                serviceCount += 1
            }
        }
        
        return model.isShow ? packageCount+serviceCount : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PlusOrderEditCell
       
        
        let sectionModel = rowsData[indexPath.section]
        
        let pArray = sectionModel.packageList.filter { $0.packageType != 1 }
        
        if indexPath.row < pArray.count {
            
            let model = pArray[indexPath.row]
            cell.titleLabel.text = model.name
            cell.iconImgView.image = UIImage(named: "plus_material_icon")
            cell.selectedBtn.isSelected = model.isEditCheck
            
        }
        else {
            let sArray = sectionModel.serviceList.filter { $0.serviceType != 1 }
            
            let serviceModel = sArray[indexPath.row-pArray.count]
            cell.titleLabel.text = serviceModel.name
            cell.iconImgView.image = UIImage(named: "plus_work_icon")
            cell.selectedBtn.isSelected = serviceModel.isCheck
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeaderId) as! PlusOrderEditHeadView
        
        let sectionModel = rowsData[section]
        
        let pArray = sectionModel.packageList.filter { $0.packageType != 1 }
        let sArray = sectionModel.serviceList.filter { $0.serviceType != 1 }
        
        if pArray.count + sArray.count > 0 {
            
            header.titleLabel.isUserInteractionEnabled = true
            header.upOrDownBtn.isHidden = false
            header.upOrDownBtn.isSelected = sectionModel.isShow
            header.upOrDownBlock = {() in
                sectionModel.isShow = !sectionModel.isShow
                tableView.reloadSections([section], with: .fade)
            }
        }else {
            header.titleLabel.isUserInteractionEnabled = false
            header.upOrDownBtn.isHidden = true
        }
        
        var sectionTitle = ""
        if let valueStr = sectionModel.roomType?.intValue {
            
            sectionTitle = Utils.getFieldValInDirArr(arr: AppData.roomTypeList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
            
            var index = 0
            var sumCount = 0
            for dataModel in rowsData {
                
                if sectionModel == dataModel {
                    break
                }
                if dataModel.roomType?.intValue == valueStr {
                    index += 1
                }
            }
            
            for dataModel in rowsData {
                
                if dataModel.roomType?.intValue == valueStr {
                    sumCount += 1
                }
            }
            
            if index >= 0 && sumCount > 1 && index < LetterPrefixArray.count {
                sectionTitle += LetterPrefixArray[index]
            }
        }
        
        header.titleLabel.text = sectionTitle
       
        header.selectedBtn.isSelected = sectionModel.isCheck
        header.selectedBlock = { [weak self] isCheck in
            
            self?.updateSectionAllSelected(sectionModel: sectionModel, isCheck: isCheck)
            tableView.reloadSections([section], with: .fade)
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! PlusOrderEditCell
        cell.selectedBtn.isSelected = !cell.selectedBtn.isSelected
        
        let sectionModel = rowsData[indexPath.section]
        let pArray = sectionModel.packageList.filter { $0.packageType != 1 }
        if indexPath.row < pArray.count {
            
            let model = pArray[indexPath.row]
            model.isEditCheck = cell.selectedBtn.isSelected
            self.getCheckCount()
            tableView.reloadData()
        }
        else {
            let sArray = sectionModel.serviceList.filter { $0.serviceType != 1 }
            
            let serviceModel = sArray[indexPath.row-pArray.count]
            serviceModel.isCheck = cell.selectedBtn.isSelected
            self.getCheckCount()
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 33
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }

    //MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresnetTransitionUpAnimated(transitionType: 1)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresnetTransitionUpAnimated(transitionType: 2)
    }
    
}
