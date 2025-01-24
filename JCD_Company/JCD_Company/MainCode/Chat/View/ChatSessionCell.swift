//
//  ChatSessionCell.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/4.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

class ChatSessionCell: UITableViewCell {
 
    // MARK:- 懒加载
    lazy var avatarView: UIImageView = {
        let avatarView = UIImageView()
        avatarView.image = UIImage(named: "headerImage_man")
        avatarView.layer.cornerRadius = 45/2
        avatarView.layer.masksToBounds = true
        return avatarView
    }()
    
    lazy var nameLabel: UILabel = {
        let nameL = UILabel()
        nameL.textColor = PublicColor.commonTextColor
        nameL.font = UIFont.systemFont(ofSize: 15.0)
        return nameL
    }()
    
    lazy var detailNameLabel: UILabel = {
        let nameL = UILabel()
        nameL.textColor = PublicColor.placeholderTextColor
        nameL.font = UIFont.systemFont(ofSize: 11.0)
        return nameL
    }()
    
    lazy var detailLabel: UILabel = {
        let detailL = UILabel()
        detailL.font = UIFont.systemFont(ofSize: 13.0)
        detailL.textColor = PublicColor.minorTextColor
        return detailL
    }()
    
    lazy var timeLabel: UILabel = {
        let timeL = UILabel()
        timeL.font = UIFont.systemFont(ofSize: 13.0)
        timeL.textColor = PublicColor.placeholderTextColor
        timeL.textAlignment = .right
        return timeL
    }()
    
    lazy var badgeLabel: UILabel = {
        let badgeL = UILabel()
        badgeL.backgroundColor = PublicColor.unreadMsgColor
        badgeL.font = UIFont.systemFont(ofSize: 9.0)
        badgeL.isHidden = true
        badgeL.textColor = .white
        badgeL.textAlignment = .center
        badgeL.layer.cornerRadius = 7.5
        badgeL.layer.masksToBounds = true
        return badgeL
    }()
    
    lazy var msgView: UIView = {
        let msgV = UIView()
        msgV.backgroundColor = PublicColor.unreadMsgColor
        msgV.isHidden = true
        msgV.layer.cornerRadius = 5
        return msgV
    }()

    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = PublicColor.partingLineColor
        return line
    }()
    
    //设置数据
    var conversation: JMSGConversation? {
        didSet {
            if let conver = conversation {
                
                if let count = conver.unreadCount?.intValue {
                    if count <= 0 {
                        badgeLabel.isHidden = true
                        badgeLabel.text = "0"
                    }else if count >= 99 {
                        badgeLabel.isHidden = false
                        badgeLabel.text = "99"
                    }else {
                        badgeLabel.isHidden = false
                        badgeLabel.text = "\(count)"
                    }
                }
                
                if let latestMessage = conver.latestMessage {
                    let time = latestMessage.timestamp.intValue / 1000
                    let date = Date(timeIntervalSince1970: TimeInterval(time))
                    timeLabel.text = date.conversationDate()
                }else {
                    timeLabel.text = ""
                }
                detailNameLabel.text = ""
                self.avatarView.image = UIImage(named: "headerImage_man")
                let isGroup = conver.ex.isGroup
                if !isGroup {
//                    nameLabel.text = conver.title
                    if let user = conver.target as? JMSGUser {
                        
                        nameLabel.text = user.displayName()

                        if let exdic = user.extras {
                            
                            if let detailTitle = exdic["detailTitle"] as? String {
                                
                                detailNameLabel.text = detailTitle
                            }
                            if let headUrl = exdic["headUrl"] as? String {

                                if let imageUrl = URL(string: APIURL.ossPicUrl + headUrl) {
                                    self.avatarView.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "headerImage_man"))
                                }
                            }
                        }
                    }
                }else {
                    if let group = conver.target as? JMSGGroup {
                        nameLabel.text = group.displayName()
                        group.thumbAvatarData({ (data, _, error) in
                            if let data = data {
                                self.avatarView.image = UIImage(data: data)
                            }
                        })
                    }
                }
                
                let textStr = conver.latestMessageContentText()
                if textStr == "" {
                    detailLabel.text = ""
                    return
                }
                detailLabel.attributedText = IMFindEmotion.findAttrStr(text: textStr, font: detailLabel.font!)
                
                if !isGroup {//单聊
                    if let count = conver.latestMessage?.getUnreadCount() {
                        if conver.latestMessage?.isReceived == false {
                            
                            if conver.latestMessage?.contentType != .prompt {
                                if count > 0 {
                                    if conver.latestMessage?.status == .sendFailed || conver.latestMessage?.status == .sendUploadFailed {
                                        detailLabel.attributedText = getAttributString(attributString: "[失败] ",stringColor:PublicColor.redLabelColor, string: detailLabel.attributedText!)
                                    }else if conver.latestMessage?.status == .sending {
                                        detailLabel.attributedText = getAttributString(attributString: "[发送中] ",stringColor:PublicColor.emphasizeColor, string: detailLabel.attributedText!)
                                    }else {
                                        detailLabel.attributedText = getAttributString(attributString: "[未读] ",stringColor:PublicColor.emphasizeColor, string: detailLabel.attributedText!)
                                    }
                                }else {
                                    detailLabel.attributedText = getAttributString(attributString: "[已读] ",stringColor:PublicColor.placeholderTextColor, string: detailLabel.attributedText!)
                                }
                            }
                        }
                    }
                }else {//群聊
                    if let latestMessage = conver.latestMessage {
                        let fromUser = latestMessage.fromUser
                        if !fromUser.isEqual(to: JMSGUser.myInfo()) &&
                            latestMessage.contentType != .eventNotification &&
                            latestMessage.contentType != .prompt {
                            detailLabel.attributedText = NSAttributedString(string: "\(fromUser.displayName()):\(detailLabel.attributedText!)")
                        }
                        if conver.unreadCount != nil &&
                            conver.unreadCount!.intValue > 0 &&
                            latestMessage.contentType != .prompt {
                            if latestMessage.isAtAll() {
                                detailLabel.attributedText = getAttributString(attributString: "[@所有人] ",stringColor:UIColor.colorFromRGB(rgbValue: 0xFE954F), string: detailLabel.attributedText!)
                            } else if latestMessage.isAtMe() {
                                detailLabel.attributedText = getAttributString(attributString: "[有人@我] ",stringColor:UIColor.colorFromRGB(rgbValue: 0xFE954F), string: detailLabel.attributedText!)
                            }
                        }
                    }
                    
                }
                
                if let draft = JCDraft.getDraft(conver) {
                    if !draft.isEmpty {
                        detailLabel.attributedText = IMFindEmotion.findAttrStr(text: draft, font: detailLabel.font!)
                        detailLabel.attributedText = getAttributString(attributString: "[草稿] ",stringColor:PublicColor.emphasizeColor, string: detailLabel.attributedText!)
                    }
                }
                
            }
        }
    }
    
    func getAttributString(attributString: String, stringColor:UIColor,string: NSAttributedString) -> NSMutableAttributedString {
        let attr = NSMutableAttributedString(string: "")
        var attrSearchString: NSAttributedString!
        attrSearchString = NSAttributedString(string: attributString, attributes: [ NSAttributedString.Key.foregroundColor : stringColor, NSAttributedString.Key.font : detailLabel.font])
        attr.append(attrSearchString)
        attr.append(string)
        return attr
    }
    
    // MARK:- init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.white
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK:- 初始化
    func createSubView() {
        self.addSubview(avatarView)
        self.addSubview(nameLabel)
        self.addSubview(detailNameLabel)
        self.addSubview(detailLabel)
        self.addSubview(timeLabel)
        self.addSubview(badgeLabel)
        self.addSubview(msgView)
        self.addSubview(lineView)
        
        let margin: CGFloat = 10
        // 布局
        avatarView.snp.makeConstraints { (make) in
            make.left.top.equalTo(self).offset(margin)
            make.bottom.equalTo(self.snp.bottom).offset(-margin)
            make.height.width.equalTo(45)
        }
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarView.snp.right).offset(margin)
            make.top.equalTo(avatarView.snp.top).offset(2)
            
        }
        detailNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(margin/2)
            make.right.lessThanOrEqualTo(timeLabel.snp.left).offset(-10)
            make.bottom.equalTo(nameLabel.snp.bottom)
        }
        detailLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.bottom.equalTo(avatarView.snp.bottom).offset(-2)
            make.right.equalTo(self.snp.right).offset(-15)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-margin)
            make.centerY.equalTo(nameLabel.snp.centerY)
            make.width.greaterThanOrEqualTo(60)
        }
        badgeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(avatarView.snp.right)
            make.centerY.equalTo(avatarView.snp.top)
            make.height.width.equalTo(15)
        }
        msgView.snp.makeConstraints { (make) in
            make.center.equalTo(badgeLabel)
            make.height.width.equalTo(10)
        }
        lineView.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.left)
            make.right.equalTo(timeLabel.snp.right)
            make.bottom.equalTo(-0.5)
            make.height.equalTo(0.5)
        }
    }
}

