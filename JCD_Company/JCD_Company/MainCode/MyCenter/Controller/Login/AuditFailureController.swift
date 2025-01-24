//
//  AuditFailureController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/3/15.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog

class AuditFailureController: BaseViewController {
    
    var workerModel: WorkerModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //图标
        let waitImageView = UIImageView()
        waitImageView.image = UIImage.init(named: "complete_fail")
        view.addSubview(waitImageView)
        
        waitImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(80)
            make.width.height.equalTo(100)
        }
        
        //提示语
        let waitTitleLabel = UILabel()
        waitTitleLabel.numberOfLines = 0
        waitTitleLabel.font = UIFont.systemFont(ofSize: 16)
        waitTitleLabel.textColor = PublicColor.placeholderTextColor
        view.addSubview(waitTitleLabel)
        
        waitTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(waitImageView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
        }
        
        var cityMobile = ""
        if let valueStr = workerModel?.cityMobile {
            cityMobile = valueStr
        }
        
        let titleStr = "您的审核未通过，请修改信息后重新提交！如有疑问请拨打: \(cityMobile)"
        let attributedString = NSMutableAttributedString.init(string: titleStr)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 8
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSMakeRange(0, titleStr.count))
        waitTitleLabel.attributedText = attributedString
        
        //修改信息
        let backRedImg = UIColor.init(red: 240.0/255, green: 70.0/255, blue: 67.0/255, alpha: 1).image()
        let modifyBtn = UIButton.init(type: .custom)
        modifyBtn.layer.cornerRadius = 5
        modifyBtn.layer.masksToBounds = true
        modifyBtn.layer.borderColor = PublicColor.navigationLineColor.cgColor
        modifyBtn.layer.borderWidth = 1
        modifyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        modifyBtn.setTitle("修改信息", for: .normal)
        modifyBtn.setTitleColor(.white, for: .normal)
        modifyBtn.setBackgroundImage(backRedImg, for: .normal)
        modifyBtn.addTarget(self, action: #selector(modifyAction), for: .touchUpInside)
        view.addSubview(modifyBtn)
        
        modifyBtn.snp.makeConstraints { (make) in
            make.top.equalTo(waitTitleLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview().offset(75)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        
        let backWhiteImg = UIColor.white.image()
        let detailBtn = UIButton.init(type: .custom)
        detailBtn.layer.cornerRadius = modifyBtn.layer.cornerRadius
        detailBtn.layer.masksToBounds = true
        detailBtn.layer.borderColor = PublicColor.navigationLineColor.cgColor
        detailBtn.layer.borderWidth = 1
        detailBtn.titleLabel?.font = modifyBtn.titleLabel?.font
        detailBtn.setTitle("查看详情", for: .normal)
        detailBtn.setTitleColor(UIColor.init(red: 240.0/255, green: 70.0/255, blue: 67.0/255, alpha: 1), for: .normal)
        detailBtn.setBackgroundImage(backWhiteImg, for: .normal)
        detailBtn.addTarget(self, action: #selector(detailAction), for: .touchUpInside)
        view.addSubview(detailBtn)
        
        detailBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(-75)
            make.top.width.height.equalTo(modifyBtn)
        }
    }
    
    @objc func modifyAction() {
        
//        let vc = CompleteDataController()
//        vc.title = "修改信息"
//        vc.workerModel = workerModel
//        navigationController?.pushViewController(vc, animated: true)
        let vc = UploadIDCardController()
        vc.isChange = true
        vc.type = "\(workerModel?.yzbRegister?.type ?? 1)"
        vc.workerModel = workerModel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func detailAction() {
        
        var msgStr = "无"
        
        if let valueStr = workerModel?.yzbRegister?.remarks {
            msgStr = valueStr
        }
        
        let popup = PopupDialog(title: "审核详情", message: msgStr)
        let sureBtn = AlertButton(title: "确定") {
            
        }
        popup.addButtons([sureBtn])
        self.present(popup, animated: true, completion: nil)
    }

}
