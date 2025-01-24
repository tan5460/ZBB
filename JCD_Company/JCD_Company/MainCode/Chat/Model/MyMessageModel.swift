//
//  MyMessageModel.swift
//  IMUIChat
//
//  Created by oshumini on 2017/3/5.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit

class MyMessageModel: IMUIMessageModel {
  
    open var myTextMessage: String = ""
    
    var mediaPath = ""
    var mData:Data? //图片data
    var jmModel:JMSGMessage?
    var orderText: NSAttributedString?
//    var orderState: String?
    
    override func mediaFilePath() -> String {
        return mediaPath
    }
    override var resizableBubbleImage: UIImage {
        // return defoult message bubble
        return super.resizableBubbleImage
    }
    
    override func webImageUrl() -> String {
        return ""
    }
    
    override func mediaData() -> Data?{
        // return defoult message bubble
        return self.mData
    }
    
    ///创建
    init(msgId: String, messageStatus: IMUIMessageStatus, fromUser: MessageUser, isOutGoing: Bool, date: Date, type: MessgeType, text: String, mediaPath: String, layout: IMUIMessageCellLayoutProtocol, duration: CGFloat?) {
        
        self.myTextMessage = text
        self.mediaPath = mediaPath
        
        let chatTime = date.conversationDate()//MyMessageModel.formatChatDate(date: date)
        
        super.init(msgId: msgId, messageStatus: messageStatus, fromUser: fromUser, isOutGoing: isOutGoing, time: chatTime, type: type, cellLayout: layout, duration: duration)
    }
    
    func setupJMsgMode(msgModel: JMSGMessage, isNewMsg: Bool) {
        
        self.jmModel = msgModel
        
        if isNewMsg {
            self.isRead = !isNewMsg
        }else {
            self.isRead = msgModel.getUnreadCount() == 0 ? true : false
        }
        
        let userModel = MessageUser()
        userModel.userModel = msgModel.fromUser
        self.fromUser = userModel
    }
    
    ///创建文本消息
    convenience init(msgModel: JMSGMessage, text: String, isOutGoing: Bool, isNeedShowTime:Bool, isNewMsg:Bool = false) {
        
        let myLayout = MyMessageCellLayout(isOutGoingMessage: isOutGoing,
                                           isNeedShowTime: isNeedShowTime,
                                           bubbleContentSize: MyMessageModel.calculateTextContentSize(text: text),
                                           bubbleContentInsets: UIEdgeInsets.zero,
                                           timeLabelContentSize: CGSize(width: 200, height: 10),
                                           type: .text)

        let time = msgModel.timestamp.intValue / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        
        self.init(msgId: msgModel.msgId, messageStatus: .failed, fromUser: MessageUser(), isOutGoing: isOutGoing, date: date, type: .text, text: text, mediaPath: "", layout:  myLayout, duration: nil)
        
        setupJMsgMode(msgModel:msgModel,isNewMsg: isNewMsg)
    }
    
    
    ///创建订单消息
    convenience init(msgModel: JMSGMessage, orderText: String, state: String, isOutGoing: Bool,isNeedShowTime:Bool,  isNewMsg:Bool = false) {
        
        let artStr = NSMutableAttributedString(string: orderText, attributes: [NSAttributedString.Key.font : IMUIOrderView.orderTextFont])
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        //行距
        paragraphStyle.lineSpacing = 6
        
        artStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, orderText.count))
        
        let constraintRect = CGSize(width: IMUIMessageCellLayout.bubbleMaxWidth, height: .greatestFiniteMagnitude)
        let textRect = artStr.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
//        let w = textRect.size.width+20
        let w = IMUIMessageCellLayout.bubbleMaxWidth
        let h = textRect.size.height > 20.0 ? textRect.size.height : 20.0
        
        let myLayout = MyMessageCellLayout(isOutGoingMessage: isOutGoing,
                                           isNeedShowTime: isNeedShowTime,
                                           bubbleContentSize: CGSize(width: w, height: h+30+40),
                                           bubbleContentInsets: UIEdgeInsets.zero,
                                           timeLabelContentSize: CGSize(width: 200, height: 10),
                                           type: .order)
        
        let time = msgModel.timestamp.intValue / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        
        self.init(msgId: msgModel.msgId, messageStatus: .failed, fromUser: MessageUser(), isOutGoing: isOutGoing, date: date, type: .order, text: orderText, mediaPath: "", layout:  myLayout, duration: nil)
        
        setupJMsgMode(msgModel:msgModel,isNewMsg: isNewMsg)
        
        self.orderText = artStr
//        self.orderState = state
       
    }
    
    ///创建语音消息
    convenience init(msgModel: JMSGMessage, voicePath: String, voiceData: Data, duration: CGFloat, isOutGoing: Bool,isNeedShowTime:Bool, isNewMsg:Bool = false) {
        
        let maxDur = Int(duration) > 60 ? 60 : Int(duration)
        let voiceWidth = CGFloat(sqrt(Double(240*(maxDur-1)))) + 70
        
        let time = msgModel.timestamp.intValue / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        
        let myLayout = MyMessageCellLayout(isOutGoingMessage: isOutGoing,
                                           isNeedShowTime: isNeedShowTime,
                                           bubbleContentSize: CGSize(width: voiceWidth, height: 44),
                                           bubbleContentInsets: UIEdgeInsets.zero,
                                           timeLabelContentSize: CGSize(width: 200, height: 10),
                                           type: .voice)

        
        self.init(msgId: msgModel.msgId, messageStatus: .sending, fromUser: MessageUser(), isOutGoing: isOutGoing, date: date, type: .voice, text: "", mediaPath: voicePath, layout:  myLayout, duration: duration)
        
        setupJMsgMode(msgModel:msgModel,isNewMsg: isNewMsg)
        
        self.mData = voiceData
    }
    
    ///创建图片消息
    convenience init(msgModel: JMSGMessage, imagePath: String, imageData:Data?, isOutGoing: Bool,isNeedShowTime:Bool, isNewMsg:Bool = false) {
        
        var isMaterialMessage = false
        var imgType: MessgeType = .image
        var imgSize = CGSize(width: 120, height: 160)
        
        if let ex = msgModel.content?.extras, let isLocal = ex["isLocalImg"] as? Bool {
            
            isMaterialMessage = true
            imgType = .material
            
            if isLocal == true {
                imgSize = CGSize(width: PublicSize.screenWidth - 30, height: 128)
            }else {
                imgSize = CGSize(width: PublicSize.screenWidth - 30, height: 92)
            }
            
        }else {
            
            if imagePath == "" {
                if imageData != nil {
                    if let img = UIImage(data: imageData!) {
                        imgSize = MyMessageModel.converImageSize(with: img.size)
                    }
                }
            }else {
                if let img = UIImage(contentsOfFile: imagePath) {
                    imgSize = MyMessageModel.converImageSize(with: img.size)
                }
            }
        }
        
        let myLayout = MyMessageCellLayout(isOutGoingMessage: isOutGoing,
                                           isMaterialMessage: isMaterialMessage,
                                           isNeedShowTime: isNeedShowTime,
                                           bubbleContentSize: imgSize,
                                           bubbleContentInsets: UIEdgeInsets.zero,
                                           timeLabelContentSize: CGSize(width: 200, height: 10),
                                           type: imgType)
        
        let time = msgModel.timestamp.intValue / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        
        self.init(msgId: msgModel.msgId, messageStatus: .sending, fromUser: MessageUser(), isOutGoing: isOutGoing, date: date, type: imgType, text: "", mediaPath: imagePath, layout: myLayout, duration: nil)
        
        setupJMsgMode(msgModel:msgModel,isNewMsg: isNewMsg)
        
        self.mData = imageData
    }
    
    ///创建视频消息
    convenience init(msgModel: JMSGMessage, videoPath: String, imageData:Data?, duration: CGFloat, isOutGoing: Bool, isNeedShowTime: Bool, isNewMsg: Bool = false) {
        
        var imgSize = CGSize(width: 120, height: 160)

        if imageData != nil {
            if let img = UIImage(data: imageData!) {
                imgSize = MyMessageModel.converImageSize(with: CGSize(width: (img.cgImage?.width)!, height: (img.cgImage?.height)!))
            }
        }
       
        let myLayout = MyMessageCellLayout(isOutGoingMessage: isOutGoing,
                                           isNeedShowTime: isNeedShowTime,
                                           bubbleContentSize: imgSize,
                                           bubbleContentInsets: UIEdgeInsets.zero,
                                           timeLabelContentSize: CGSize(width: 200, height: 10),
                                           type: .video)

        let time = msgModel.timestamp.intValue / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        
        self.init(msgId: msgModel.msgId, messageStatus: .sending, fromUser: MessageUser(), isOutGoing: isOutGoing, date: date, type: .video, text: "", mediaPath: videoPath, layout:  myLayout, duration: duration)
        
        setupJMsgMode(msgModel:msgModel, isNewMsg: isNewMsg)
        self.mData = imageData
        
    }
    
    ///创建地址消息
    convenience init(msgModel: JMSGMessage, addrsess:String,addressImagePath: String, addressImageData:Data?, isOutGoing: Bool,isNeedShowTime:Bool, isNewMsg:Bool = false) {
        
        var imgSize = CGSize(width: 240, height: 110+40)
        if addressImagePath == "" {
            
            if addressImageData != nil {
                if let img = UIImage(data: addressImageData!) {
                    imgSize = MyMessageModel.converImageSize(with: CGSize(width: (img.cgImage?.width)!, height: (img.cgImage?.height)!+40))
                }
            }
        }else {
            
            if let img = UIImage(contentsOfFile: addressImagePath) {
                imgSize = MyMessageModel.converImageSize(with: CGSize(width: (img.cgImage?.width)!, height: (img.cgImage?.height)!+40))
            }
        }
        
        let myLayout = MyMessageCellLayout(isOutGoingMessage: isOutGoing,
                                           isNeedShowTime: isNeedShowTime,
                                           bubbleContentSize: imgSize,
                                           bubbleContentInsets: UIEdgeInsets.zero,
                                           timeLabelContentSize: CGSize(width: 200, height: 10),
                                           type: .location)
        let time = msgModel.timestamp.intValue / 1000
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        
        self.init(msgId: msgModel.msgId, messageStatus: .sending, fromUser: MessageUser(), isOutGoing: isOutGoing, date: date, type: .location , text: addrsess, mediaPath: addressImagePath, layout:  myLayout, duration: nil)
        
        setupJMsgMode(msgModel:msgModel,isNewMsg: isNewMsg)
        self.mData = addressImageData
    }
    
    override func text() -> String {
        return self.myTextMessage
    }
    
    static func calculateTextContentSize(text: String) -> CGSize {
        if let attrStr = IMFindEmotion.findAttrStr(text: text, font: IMUITextMessageContentView.inComingTextFont) {
            
            if attrStr.string != "" {
                let constraintRect = CGSize(width: IMUIMessageCellLayout.bubbleMaxWidth, height: .greatestFiniteMagnitude)
                let textRect = attrStr.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
                let w = textRect.size.width
                let h = textRect.size.height > 20.0 ? textRect.size.height : 20.0
                return CGSize(width: w, height: h)
            }
        }
        
        let textSize  = text.sizeWithConstrainedWidth(with: IMUIMessageCellLayout.bubbleMaxWidth, font: IMUITextMessageContentView.inComingTextFont)
        return textSize
    }
    
    static func calculateNameContentSize(text: String) -> CGSize {
        return text.sizeWithConstrainedWidth(with: 200,
                                             font: IMUIMessageCellLayout.timeStringFont)
    }
    
    static func converImageSize(with size: CGSize) -> CGSize {
        let maxSide = IMUIMessageCellLayout.bubbleMaxWidth
        
        var scale = size.width / size.height
        
        if size.width > size.height {
            scale = scale > 2 ? 2 : scale
            return CGSize(width: CGFloat(maxSide), height: CGFloat(maxSide) / CGFloat(scale))
        } else {
            scale = scale < 0.5 ? 0.5 : scale
            return CGSize(width: CGFloat(maxSide) * CGFloat(scale), height: CGFloat(maxSide))
        }
    }
    
    /// Format chat date.
    static func formatChatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
}


//MARK - IMUIMessageCellLayoutProtocol
class MyMessageCellLayout: IMUIMessageCellLayout {
    
    var type: MessgeType
    
    init(isOutGoingMessage: Bool, isMaterialMessage: Bool = false, isNeedShowTime: Bool, bubbleContentSize: CGSize, bubbleContentInsets: UIEdgeInsets, timeLabelContentSize: CGSize,type: MessgeType) {
        self.type = type
        super.init(isOutGoingMessage: isOutGoingMessage,
                   isMaterialMessage: isMaterialMessage,
                   isNeedShowTime: isNeedShowTime,
                   bubbleContentSize: bubbleContentSize,
                   bubbleContentInsets: UIEdgeInsets.zero,
                   timeLabelContentSize: timeLabelContentSize)
    }
    
    override var bubbleContentInset: UIEdgeInsets {
        if type != .text { return UIEdgeInsets.zero }
        if isOutGoingMessage {
            return UIEdgeInsets(top: 11, left: 15, bottom: 14, right: 18)
        } else {
            return UIEdgeInsets(top: 11, left: 15, bottom: 14, right: 18)
        }
    }
    
    override var bubbleContentView: IMUIMessageContentViewProtocol {
        switch type {
        case .text:
            return IMUITextMessageContentView()
        case .image:
            return IMUIImageMessageContentView()
        case .voice:
            return IMUIVoiceMessageContentView()
        case .video:
            return IMUIVideoMessageContentView()
        case .location:
            return IMUILocationContentView()
        case .order:
            return IMUIOrderView()
        case .material:
            return IMUIMaterial()
        default:
            return IMUIDefaultContentView()
        }
    }
    
    override var bubbleContentType: MessgeType {
        return type
    }
    
}


