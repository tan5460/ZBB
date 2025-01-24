//
//  RemarksView.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/8/10.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit

class RemarksView: UIView, UITextViewDelegate {
    
    var opacityView: UIView!                //蒙版
    var popupView: UIView!                  //弹窗
    var remarkField: UITextView!            //备注输入框
    var placeholderLabel: UILabel!          //文本提示语
    var remarkStr: String?                  //备注
    
    var doneBlock: ((_ remarks: String?)->())?                //完成
    
    deinit {
        AppLog("备注弹窗释放")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //半透明蒙版
        opacityView = UIView()
        opacityView.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        self.addSubview(opacityView)
        
        opacityView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        //内容弹窗
        popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 5
        self.addSubview(popupView)
        
        popupView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            make.width.equalTo(300)
            make.height.equalTo(236)
        }
        
        //标题
        let titleLabel = UILabel()
        titleLabel.text = "备注"
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = .black
        popupView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(8)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xE6E6E6)
        popupView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        //输入框
        remarkField = UITextView()
        remarkField.delegate = self
        remarkField.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xF7F7F7)
        remarkField.layer.cornerRadius = 10
        remarkField.font = UIFont.systemFont(ofSize: 14)
        popupView.addSubview(remarkField)
        
        remarkField.snp.makeConstraints { (make) in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(135)
        }
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "请输入备注"
        placeholderLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x808080)
        placeholderLabel.font = remarkField.font
        popupView.addSubview(placeholderLabel)
        
        placeholderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(remarkField).offset(8)
            make.left.equalTo(13)
        }
        
        //返回
        let redBtnImg = PublicColor.gradualColorImage
        let redHighLightedImg = PublicColor.gradualHightColorImage
        let doneBtn = UIButton.init(type: .custom)
        doneBtn.layer.cornerRadius = 17
        doneBtn.layer.masksToBounds = true
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.setBackgroundImage(redBtnImg, for: .normal)
        doneBtn.setBackgroundImage(redHighLightedImg, for: .highlighted)
        doneBtn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        popupView.addSubview(doneBtn)
        
        doneBtn.snp.makeConstraints { (make) in
            make.right.equalTo(remarkField)
            make.bottom.equalTo(-12)
            make.width.equalTo(120)
            make.height.equalTo(34)
        }
        
        //返回
        let btnNormalImg = UIColor.white.image()
        let btnHighLightedImg = UIColor.init(red: 242.0/255, green: 242.0/255, blue: 242.0/255, alpha: 1).image()
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.layer.cornerRadius = 17
        cancelBtn.layer.masksToBounds = true
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = PublicColor.partingLineColor.cgColor
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        cancelBtn.setTitle("返回", for: .normal)
        cancelBtn.setTitleColor(PublicColor.emphasizeTextColor, for: .normal)
        cancelBtn.setBackgroundImage(btnNormalImg, for: .normal)
        cancelBtn.setBackgroundImage(btnHighLightedImg, for: .highlighted)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        popupView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(remarkField)
            make.centerY.width.height.equalTo(doneBtn)
        }
        
        
    }
    
    @objc func doneAction() {
        
        if let valueStr = remarkField.text {
            
            if let block = doneBlock {
                
                if valueStr.count <= 0 {
                    block(nil)
                }else {
                    block(valueStr)
                }
            }
        }
        
        hiddenView()
    }
    
    @objc func cancelAction() {
        
        hiddenView()
    }
    
    func hiddenView() {
        
        self.endEditing(true)
        
        popupView.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.bottom)
            make.width.equalTo(300)
            make.height.equalTo(236)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0.1
            self.layoutIfNeeded()
        }) { (finish) in
            self.isHidden = true
        }
    }
    
    func showView() {
        
        remarkField.text = ""
        placeholderLabel.isHidden = false
        
        if remarkStr != nil {
            remarkField.text = remarkStr!
            placeholderLabel.isHidden = true
        }
        
        self.alpha = 0
        self.isHidden = false
        
        popupView.snp.remakeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(236)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .allowUserInteraction, animations: {
            
            self.layoutIfNeeded()
            
        }) { (isFinish) in
            
        }
    }
    
    
    //MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        
        if textView.text.count > 0 {
            placeholderLabel.isHidden = true
        }else {
            placeholderLabel.isHidden = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        popupView.snp.remakeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-80)
            make.width.equalTo(300)
            make.height.equalTo(236)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }

}
