//
//  IMUIMessageCellLayout.swift
//  IMUIChat
//
//  Created by oshumini on 2017/4/6.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import Foundation
import UIKit

/**
 *  The 'IMUIMessageCellLayout' is a concrete layout object comfort
 *  'IMUIMessageCellLayoutProtocol' protocol.
 *  each IMUIMessageBaseCell need IMUIMessageCellLayoutProtocol to layout cell's items
 */
@objc open class IMUIMessageCellLayout: NSObject, IMUIMessageCellLayoutProtocol {
    
    public var avatarSize: CGSize = CGSize(width: 45, height: 45)
    
    public var avatarPadding: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
    
    @objc public static var timeLabelPadding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    @objc public static var nameLabelSize: CGSize = CGSize(width: 200, height: 18)
    
    @objc public static var nameLabelPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    @objc public static var bubblePadding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 0, right: 8)
    
    @objc public static var cellWidth: CGFloat = 0
    @objc public static var cellContentInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    
    public var statusViewSize: CGSize = CGSize(width: 30, height: 30)
    @objc public static var statusViewOffsetToBubble: UIOffset = UIOffset(horizontal: 0, vertical: 0)
    
    public var readLabelSize: CGSize = CGSize(width: 30, height: 25)
    
    @objc public static var bubbleMaxWidth: CGFloat = 240.0
    @objc public static var isNeedShowInComingName = false
    @objc public static var isNeedShowOutGoingName = false
    
    @objc public static var isNeedShowInComingAvatar = true
    @objc public static var isNeedShowOutGoingAvatar = true
    
    @objc public static var nameLabelTextColor: UIColor = UIColor(netHex: 0x7587A8)
    @objc public static var nameLabelTextFont: UIFont = UIFont.systemFont(ofSize: 12)
    @objc public static var nameLablePadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)//
    
    @objc public static var readLabelTextFont: UIFont = UIFont.systemFont(ofSize: 11)
    
    @objc public static var timeStringColor: UIColor = UIColor(netHex: 0x90A6C4)
    @objc public static var timeStringFont: UIFont = UIFont.systemFont(ofSize: 12)
    @objc public static var timeStringBackgroundColor: UIColor = UIColor.clear
    //  @objc public static var timeStringPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)//
    @objc public static var timeStringCornerRadius: CGFloat = 0.0//
    
    
    @objc public init(isOutGoingMessage: Bool,
                      isMaterialMessage: Bool,
                      isNeedShowTime: Bool,
                      bubbleContentSize: CGSize,
                      bubbleContentInsets: UIEdgeInsets,
                      timeLabelContentSize: CGSize) {
        self.isOutGoingMessage = isOutGoingMessage
        self.isNeedShowTime = isNeedShowTime
        self.bubbleContentSize = bubbleContentSize
        self.bubbleContentInsets = bubbleContentInsets
        self.timeLabelContentSize = timeLabelContentSize
        
        if isMaterialMessage {
            avatarSize = CGSize(width: 0, height: 0)
            avatarPadding = UIEdgeInsets(top: 16, left: 7, bottom: 0, right: 7)
            statusViewSize = CGSize(width: 0, height: 0)
            readLabelSize = CGSize(width: 0, height: 0)
        }else {
            avatarSize = CGSize(width: 45, height: 45)
            avatarPadding = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
            statusViewSize = CGSize(width: 30, height: 30)
            readLabelSize = CGSize(width: 30, height: 25)
        }
    }
    
    open var isOutGoingMessage: Bool
    open var isNeedShowTime: Bool
    
    open var timeLabelContentSize: CGSize
    open var bubbleContentSize: CGSize
    open var bubbleContentInsets: UIEdgeInsets
    
    open var bubbleSize: CGSize {
        let bubbleWidth = bubbleContentSize.width +
            bubbleContentInset.left +
            bubbleContentInset.right
        
        let bubbleHeight = bubbleContentSize.height +
            bubbleContentInset.top +
            bubbleContentInset.bottom
        
        return CGSize(width: bubbleWidth, height: bubbleHeight)
    }
    
    open var bubbleContentFrame: CGRect {
        let bubbleContentPostion = CGPoint(x: bubbleContentInset.left,
                                           y: bubbleContentInset.top)
        return CGRect(origin: bubbleContentPostion, size: self.bubbleContentSize)
    }
    
    public var relativeStatusViewOffsetToBubble: UIOffset {
        if self.isOutGoingMessage {
            return UIOffset(horizontal: -IMUIMessageCellLayout.statusViewOffsetToBubble.horizontal, vertical: IMUIMessageCellLayout.statusViewOffsetToBubble.vertical)
        } else {
            return IMUIMessageCellLayout.statusViewOffsetToBubble
        }
    }
    
    // MARK - IMUIMessageCellLayoutProtocol
    open var bubbleContentInset: UIEdgeInsets {
        return bubbleContentInsets
    }
    
    open var nameLabelFrame: CGRect {
        var nameLabelX: CGFloat
        let nameLabelY = avatarFrame.top +
            IMUIMessageCellLayout.nameLabelPadding.top
        if isOutGoingMessage {
            
            nameLabelX = avatarFrame.left -
                avatarPadding.left -
                IMUIMessageCellLayout.nameLabelPadding.right -
                IMUIMessageCellLayout.nameLabelSize.width
            
            if !IMUIMessageCellLayout.isNeedShowOutGoingName {
                return CGRect(x: nameLabelX,
                              y: nameLabelY,
                              width: 0,
                              height: 0)
            }
            
        } else {
            nameLabelX = avatarFrame.right +
                avatarPadding.right +
                IMUIMessageCellLayout.nameLabelPadding.left
            
            if !IMUIMessageCellLayout.isNeedShowInComingName {
                return CGRect(x: nameLabelX,
                              y: nameLabelY,
                              width: 0,
                              height: 0)
            }
        }
        
        return CGRect(x: nameLabelX,
                      y: nameLabelY,
                      width: IMUIMessageCellLayout.nameLabelSize.width,
                      height: IMUIMessageCellLayout.nameLabelSize.height)
    }
    
    open var avatarFrame: CGRect {
        
        var avatarX: CGFloat
        if self.isOutGoingMessage {
            
            avatarX = IMUIMessageCellLayout.cellWidth -
                avatarPadding.right -
                avatarSize.width -
                cellContentInset.right
            
        } else {
            avatarX = avatarPadding.left +
                cellContentInset.left
        }
        
        let avatarY = avatarPadding.top +
            self.timeLabelFrame.bottom +
            cellContentInset.top
        
        if isOutGoingMessage {
            if !IMUIMessageCellLayout.isNeedShowOutGoingAvatar {
                return CGRect(x: avatarX, y: avatarY, width: 0, height: 0)
            }
        } else {
            if !IMUIMessageCellLayout.isNeedShowInComingAvatar {
                return CGRect(x: avatarX, y: avatarY, width: 0, height: 0)
            }
        }
        
        return CGRect(x: avatarX,
                      y: avatarY,
                      width: avatarSize.width,
                      height: avatarSize.height)
    }
    
    open var timeLabelFrame: CGRect {
        if self.isNeedShowTime {
            let timeWidth = (IMUIMessageCellLayout.timeLabelPadding.left +
                timeLabelContentSize.width +
                IMUIMessageCellLayout.timeLabelPadding.right + 0.5).rounded()
            
            let timeHeight = (IMUIMessageCellLayout.timeLabelPadding.top +
                timeLabelContentSize.height +
                IMUIMessageCellLayout.timeLabelPadding.bottom + 0.5).rounded()
            
            let timeX = (IMUIMessageCellLayout.cellWidth - timeWidth)/2
            
            return CGRect(x: timeX,
                          y: cellContentInset.top + 8,
                          width: timeWidth,
                          height: timeHeight)
        } else {
            return CGRect.zero
        }
    }
    
    open var cellHeight: CGFloat {
        let cellHeight = self.bubbleFrame.bottom +
            IMUIMessageCellLayout.bubblePadding.bottom +
            cellContentInset.bottom
        
        return cellHeight
    }
    
    open var bubbleFrame: CGRect {
        var bubbleX:CGFloat
        
        if self.isOutGoingMessage {
            bubbleX = IMUIMessageCellLayout.cellWidth -
                avatarPadding.right -
                avatarFrame.width -
                IMUIMessageCellLayout.bubblePadding.right -
                cellContentInset.right -
                self.bubbleSize.width
        } else {
            bubbleX = avatarPadding.left +
                avatarFrame.width +
                IMUIMessageCellLayout.bubblePadding.left +
                cellContentInset.left
        }
        let bubbleY = self.nameLabelFrame.bottom +
            IMUIMessageCellLayout.nameLabelPadding.bottom +
            IMUIMessageCellLayout.bubblePadding.top
        
        
        return CGRect(x: bubbleX,
                      y: bubbleY,
                      width: bubbleSize.width,
                      height: bubbleSize.height)
    }
    
    open var cellContentInset: UIEdgeInsets {
        return IMUIMessageCellLayout.cellContentInset
    }
    
    open var statusView: IMUIMessageStatusViewProtocol {
        return IMUIMessageDefaultStatusView()
    }
    
    open var statusViewFrame: CGRect {
        
        var statusViewX: CGFloat = 0.0
        let statusViewY: CGFloat = bubbleFrame.origin.y +
            bubbleFrame.size.height/2 -
            statusViewSize.height/2 -
            IMUIMessageCellLayout.statusViewOffsetToBubble.vertical
        
        if isOutGoingMessage {
            statusViewX = bubbleFrame.origin.x -
                IMUIMessageCellLayout.statusViewOffsetToBubble.horizontal -
                statusViewSize.width
        } else {
            statusViewX = bubbleFrame.origin.x +
                bubbleFrame.size.width +
                IMUIMessageCellLayout.statusViewOffsetToBubble.horizontal
        }
        
        return CGRect(x: statusViewX,
                      y: statusViewY,
                      width: statusViewSize.width,
                      height: statusViewSize.height)
        
    }
    
    open var readLabelFrame: CGRect {
        
        var readLabelX: CGFloat = 0.0
        let readLabelY: CGFloat = bubbleFrame.maxY - readLabelSize.height
        
        if isOutGoingMessage {
            readLabelX = bubbleFrame.origin.x -
                readLabelSize.width
        } else {
            readLabelX = bubbleFrame.origin.x +
                bubbleFrame.size.width
        }
        
        return CGRect(x: readLabelX,
                      y: readLabelY,
                      width: readLabelSize.width,
                      height: readLabelSize.height)
        
    }
    
    open var bubbleContentView: IMUIMessageContentViewProtocol {
        return IMUIDefaultContentView()
    }
    
    open var bubbleContentType: MessgeType {
        return .defaulted
    }
    
}

class IMUIDefaultContentView: UIView, IMUIMessageContentViewProtocol{
    
    func layoutContentView(message: IMUIMessageModelProtocol) {
        
    }
    
    func Activity() {
        
    }
    
    func inActivity () {
        
    }
}
