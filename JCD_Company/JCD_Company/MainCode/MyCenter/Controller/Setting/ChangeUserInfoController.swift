//
//  ChangeUserInfoController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/10/23.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import Alamofire

class ChangeUserInfoController: BaseViewController, UITextViewDelegate {

    var textView: UITextView!
    var placeholderLabel: UILabel!
    var countLabel: UILabel!
    var userModel: CustomModel?             //用户Model
    
    var modifyUserModel: ((_ userModel: CustomModel?)->())?        //修改用户信息
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "简介"
        view.backgroundColor = PublicColor.backgroundViewColor
        prepareNavigationItem()
        prepareTopView()
    }

    func prepareNavigationItem() {
        
        //完成
        let finishBtn = UIButton(type: .custom)
        finishBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 40)
        finishBtn.setTitle("完成", for: .normal)
        finishBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        finishBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        finishBtn.addTarget(self, action: #selector(finishAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: finishBtn)
      
      
    }
    func prepareTopView() {
        
        let topView = UIView()
        topView.backgroundColor = .white
        topView.isUserInteractionEnabled = true
        view.addSubview(topView)
        
        topView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            } else {
                make.top.equalTo(64+16)
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(150)
        }
        
        textView = UITextView()
        textView.delegate = self
        textView.textColor = PublicColor.minorTextColor
        textView.font = UIFont.systemFont(ofSize: 15)
        topView.addSubview(textView)
        
        textView.snp.makeConstraints { (make) in
            make.left.top.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-35)
        }
        
        //提示
        placeholderLabel = UILabel()
        placeholderLabel.text = "介绍一下自己吧"
        placeholderLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xB2B2B2)
        placeholderLabel.font = textView.font
        placeholderLabel.sizeToFit()
        textView.addSubview(placeholderLabel)
        textView.setValue(placeholderLabel, forKey: "_placeholderLabel")
        
        if let intro = userModel?.intro {
            if intro.count > 0 {
                
                textView.text = intro
                placeholderLabel.isHidden = true
            }
        }
        //提示
        countLabel = UILabel()
        countLabel.text = "\(textView.text.count)" + "/200"
        countLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xB2B2B2)
        countLabel.font = UIFont.systemFont(ofSize: 13)
        countLabel.sizeToFit()
        topView.addSubview(countLabel)
        
        countLabel.snp.makeConstraints { (make) in
            
            make.right.bottom.equalTo(-16)
        }
    }
    //MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
       

        //如果在变化中是高亮部分在变，就不要计算字符了
        if let range = textView.markedTextRange {
            if textView.position(from: range.start, offset: 0) != nil {
                return
            }
        }
       
        let nsTextContent = textView.text
        let existTextNum = nsTextContent?.count
        
        if (existTextNum! > 200)
        {
            countLabel.text = "200/200"
            //截取到最大位置的字符
            textView.text = String(textView.text.prefix(200))
        }else {
            countLabel.text = "\(existTextNum!)" + "/200"
        }
        

    
//        print(textView.text,textView.text.count)
    }
    //MARK: - 按钮事件
    @objc func finishAction() {
        
        if textView.text.count == 0 {
            self.noticeSuccess("介绍一下自己吧", autoClear: true, autoClearTime: 1)
            return
        }
        
        var parameters: Parameters = [:]
        
        var urlStr = ""
        urlStr = APIURL.addUpdateCustomInfo
        parameters["operType"] = "update"
        parameters["id"] = self.userModel?.id
        if textView.text.count > 0 {
            parameters["intro"]  = textView.text
        }
        
        
        
        AppLog(parameters)
        
        self.pleaseWait()
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                self.userModel?.intro = self.textView.text
                UserData.shared.workerModel?.intro = self.textView.text
                if self.modifyUserModel != nil {
                    self.modifyUserModel!(self.userModel)
                }
                self.navigationController?.popViewController(animated: true)
                self.noticeSuccess("修改简介成功", autoClear: true, autoClearTime: 1)
              
            }
            
            
        }) { (error) in
            
            
        }
    }
    
}
