//
//  IMUILocationContentView.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/15.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class IMUILocationContentView: UIView, IMUIMessageContentViewProtocol {

//    @objc public static var outGoingTextColor = UIColor.white
//    @objc public static var inComingTextColor = PublicColor.commonTextColor
//
//    @objc public static var outGoingTextFont = UIFont.systemFont(ofSize: 15)
//    @objc public static var inComingTextFont = UIFont.systemFont(ofSize: 15)
    
    var textMessageLable = IMUITextView()
    let textBackView = UIView()
    
    var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(textBackView)
        textBackView.backgroundColor = .white
        
        self.addSubview(textMessageLable)
        textMessageLable.font = UIFont.systemFont(ofSize: 15)
        textMessageLable.textColor = PublicColor.commonTextColor
        
        self.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = PublicColor.partingLineColor
        imageView.clipsToBounds = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func layoutContentView(message: IMUIMessageModelProtocol) {
        
        let size = message.layout.bubbleContentSize
        textBackView.frame = CGRect(x: 0, y: 0, width: size.width, height: 40)
        textMessageLable.frame = CGRect(x: 12, y: 4, width: size.width-22, height: 36)
        
//        self.layoutToText(with: message.text(), isOutGoing: message.isOutGoing)
        textMessageLable.text = message.text()
        imageView.image = nil // reset image
        
        imageView.frame = CGRect(x: 0, y: textBackView.height, width: size.width, height: size.height-textBackView.height)
        
        
        if let msg = message as? MyMessageModel {
            if let content = msg.jmModel?.content as? JMSGLocationContent {
                let url = String(format: "https://restapi.amap.com/v3/staticmap?location=%@,%@&zoom=18&size=470*220&markers=mid,,:%@,%@&key=e3584076fd88d1de6f29d7f022d39034", content.longitude,content.latitude,content.longitude,content.latitude)
                
                if let imageUrl = URL(string: url) {
                    
                    self.imageView.kf.setImage(with: imageUrl, placeholder: UIImage())
                }else {
                    self.imageView.image = UIImage()
                }
            }
            
        }
    }

//    func layoutToText(with text: String, isOutGoing: Bool) {
//
//        if isOutGoing {
//            textMessageLable.font = IMUITextMessageContentView.outGoingTextFont
//            textMessageLable.textColor = IMUITextMessageContentView.outGoingTextColor
//        } else {
//            textMessageLable.font = IMUITextMessageContentView.inComingTextFont
//            textMessageLable.textColor = IMUITextMessageContentView.inComingTextColor
//        }
//        textMessageLable.attributedText = IMFindEmotion.findAttrStr(text: text, font: textMessageLable.font!)
//
//    }
}
