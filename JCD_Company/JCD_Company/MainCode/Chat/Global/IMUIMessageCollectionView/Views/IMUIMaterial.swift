//
//  IMUIMaterial.swift
//  YZB_Company
//
//  Created by yzb_ios on 12.04.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class IMUIMaterial: UIView, IMUIMessageContentViewProtocol {
    
    var bgView = UIView()
    var imageView = UIImageView()
    var titleLabel = UILabel()
    var specLabel = UILabel()
    var lineView = UIView()
    var sendBtn = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        self.addSubview(bgView)
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(specLabel)
        self.addSubview(lineView)
        self.addSubview(sendBtn)
        
//        bgView.backgroundColor = .white
        
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = PublicColor.buttonHightColor
        imageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(15)
            make.width.height.equalTo(60)
        }
        
        titleLabel.textColor = PublicColor.commonTextColor
        titleLabel.font = UIFont.boldSystemFont(ofSize: 13)
        titleLabel.numberOfLines = 0
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageView.snp.right).offset(17)
            make.right.equalTo(-20)
            make.top.equalTo(imageView)
            make.height.lessThanOrEqualTo(36)
        }
        
        specLabel.textColor = PublicColor.minorTextColor
        specLabel.font = UIFont.boldSystemFont(ofSize: 11)
        specLabel.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.bottom.equalTo(imageView).offset(-3)
        }
        
        lineView.backgroundColor = PublicColor.buttonHightColor
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(0.5)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(imageView.snp.bottom).offset(15)
        }
        
        sendBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        sendBtn.setTitle("发送链接>", for: .normal)
        sendBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0x23AC38), for: .normal)
        sendBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        sendBtn.addTarget(self, action: #selector(sendClickAction), for: .touchUpInside)
        sendBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.top.equalTo(lineView)
            make.height.equalTo(34)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func layoutContentView(message: IMUIMessageModelProtocol) {
        
        bgView.frame = CGRect(origin: CGPoint.zero, size: message.layout.bubbleContentSize)
        imageView.image = nil // reset image
        
        if message.webImageUrl?() == nil || message.webImageUrl?() == "" {
            self.imageView.image = UIImage.imuiImage(with: "image-broken")
        }
        
        let urlString = message.mediaFilePath()
        if urlString == "" {
            if let imageData = message.mediaData?() {
                let image = UIImage(data: imageData)
                self.imageView.image = image
            }else {
                self.imageView.image = UIImage.imuiImage(with: "image-broken")
            }
        }else {
            imageView.image = UIImage(contentsOfFile: urlString)
        }
        
        if let msg = message as? MyMessageModel {
            
            if let ex = msg.jmModel?.content?.extras {
                
                let titleStr = (ex["materialName"] as? String) ?? ""
                titleLabel.attributedText = titleStr.changeLineSpaceForLabel()
                
                let specStr = (ex["materialSpe"] as? String) ?? ""
                specLabel.text = "\(specStr)"
                
                if let isLocal = ex["isLocalImg"] as? Bool, isLocal == true {
                    lineView.isHidden = false
                    sendBtn.isHidden = false
                }else {
                    lineView.isHidden = true
                    sendBtn.isHidden = true
                }
            }
        }
    }
    
    @objc func sendClickAction() {
        AppLog("点击了发送按钮")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SendingMaterial"), object: nil)
    }
}
