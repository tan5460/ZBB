//
//  IMUITextMessageContentView.swift
//  sample
//
//  Created by oshumini on 2017/6/11.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

@objc open class IMUITextMessageContentView: UIView, IMUIMessageContentViewProtocol {
    @objc public static var outGoingTextColor = UIColor.white
    @objc public static var inComingTextColor = PublicColor.commonTextColor
    
    @objc public static var outGoingTextFont = UIFont.systemFont(ofSize: 15)
    @objc public static var inComingTextFont = UIFont.systemFont(ofSize: 15)
    
    var textMessageLable = IMUITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(textMessageLable)
        textMessageLable.numberOfLines = 0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func layoutContentView(message: IMUIMessageModelProtocol) {
        
        textMessageLable.frame = CGRect(origin: CGPoint.zero, size: message.layout.bubbleContentSize)
        
        self.layoutToText(with: message.text(), isOutGoing: message.isOutGoing)
    }
    
    func layoutToText(with text: String, isOutGoing: Bool) {
        
        if isOutGoing {
            textMessageLable.font = IMUITextMessageContentView.outGoingTextFont
            textMessageLable.textColor = IMUITextMessageContentView.outGoingTextColor
            textMessageLable.ll_x = 2
        } else {
            textMessageLable.font = IMUITextMessageContentView.inComingTextFont
            textMessageLable.textColor = IMUITextMessageContentView.inComingTextColor
            textMessageLable.ll_x = -2
        }
        textMessageLable.attributedText = IMFindEmotion.findAttrStr(text: text, font: textMessageLable.font!)
        
    }
}
