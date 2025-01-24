//
//  CorrectHomeHeadView.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/18.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class CorrectHomeHeadView: UIView {

    var iconImage: UIImageView!
    var titleLabel: BSLabel!
    
    var titleStr: String = ""
    
    var downTimer: Timer?           //倒计时定时器
    var timerCount: Int = 0         //倒计时时间

    var isStart:Int = 1  {
        didSet {
            if timerCount > 0 {
                if isStart == 1 {
                    titleStr = "距开始 "
                    startDowntimeAction()
                }else if isStart == 2{
                    titleStr = "后结束"
                    startDowntimeAction()
                }else {
                    titleStr = ""
                    invalidateTimer()
                }
            } else {
                invalidateTimer()
            }
        }
    }
    
    deinit {
        invalidateTimer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
    
        titleLabel = BSLabel()
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
        }
        
//        iconImage = UIImageView()
//        iconImage.contentMode = .center
//        iconImage.image = UIImage.init(named: "CorrectingHome1")
//        addSubview(iconImage)
//
//        iconImage.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalTo(titleLabel.snp.left).offset(-7)
//            make.height.width.equalTo(22)
//        }
        
        
    }
    
    //开启倒计时
    func startDowntimeAction() {
        
        invalidateTimer()
        
        if timerCount > 0 {
            let str = getMMSSFromSecond(timerCount)
            
            let attr = fillItem(itemText: "限时秒杀  ", textColor:  PublicColor.commonTextColor)
            str.components(separatedBy: ":").forEach {
                attr.append(fillItem(itemText: $0, fillColor: UIColor.colorFromRGB(rgbValue: 0xF53F3F), font: UIFont.systemFont(ofSize: 12)))
                attr.append(fillItem(itemText: ":", textColor: UIColor.colorFromRGB(rgbValue: 0xF53F3F), font: UIFont.systemFont(ofSize: 12)))
            }
            attr.append(fillItem(itemText: " \(titleStr)", textColor: PublicColor.minorTextColor, font: UIFont.systemFont(ofSize: 10)))
        }
        
        self.downTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.downtimeWait), userInfo: nil, repeats: true)
        RunLoop.current.add(self.downTimer!, forMode: .common)
    }
    
    //结束
    func invalidateTimer() {
        if let timer = self.downTimer {
            if timer.isValid {
                timer.invalidate()
            }
        }
    }
    //倒计时
    @objc func downtimeWait() {
        var str: String = ""
        
        if timerCount <= 0 {
            str = "已结束"
            
            invalidateTimer()
        }else {
            
            timerCount = timerCount-1
            
            str = getMMSSFromSecond(timerCount)
        }
        
        let attr = fillItem(itemText: "限时秒杀  ", textColor:  PublicColor.commonTextColor)
        let arr = str.components(separatedBy: ":")
        arr.enumerated().forEach { (index, st) in
            attr.append(fillItem(itemText: st, fillColor: UIColor.colorFromRGB(rgbValue: 0xF53F3F), font: UIFont.systemFont(ofSize: 12)))
            if index < arr.count - 1  {
                attr.append(fillItem(itemText: ":", textColor: UIColor.colorFromRGB(rgbValue: 0xFF756D), font: UIFont.systemFont(ofSize: 12)))
            }
        }
        attr.append(fillItem(itemText: " \(titleStr)", textColor: PublicColor.minorTextColor, font: UIFont.systemFont(ofSize: 10)))
        
        titleLabel.attributedText = attr
        
    }
    
    //获取时分秒
    func getMMSSFromSecond(_ second: Int) -> String {
        
        var timeString: String = ""
        
        let day = second/(3600*24)
        let hour = day * 24 + (second%(3600*24))/3600
        var hourStr = "\(hour)"
        if hour < 10 {
            hourStr = "0\(hour)"
        }
        let minute = (second%3600)/60
        var minuteStr = "\(minute)"
        if minute < 10 {
            minuteStr = "0\(minute)"
        }
        let seconds = second%60
        var secondsStr = "\(seconds)"
        if seconds < 10 {
            secondsStr = "0\(seconds)"
        }
        if day > 0 {
            timeString = " \(hourStr) : \(minuteStr) : \(secondsStr) "
        }else if hour > 0 {
            timeString = " \(hourStr) : \(minuteStr) : \(secondsStr) "
        }else if minute > 0 {
            timeString = " \(minuteStr) : \(secondsStr) "
        }else {
            timeString = " \(secondsStr)秒 "
        }
        
        return timeString
    }
    
    func fillItem(
        itemText: String,
        textColor: UIColor? = UIColor.white,
        strokeColor: UIColor? = UIColor.white,
        fillColor: UIColor? = nil,
        font: UIFont = UIFont.boldSystemFont(ofSize: 18)
        ) -> NSMutableAttributedString {
        
        let tagStrokeColor: UIColor? = strokeColor
        let tagFillColor: UIColor? = fillColor
        let tagText = NSMutableAttributedString(string: itemText)
        tagText.bs_font = font
        tagText.bs_color = textColor
        tagText.bs_set(textBinding: TextBinding.binding(with: false), range: tagText.bs_rangeOfAll)
        
        let border = TextBorder()
        border.strokeWidth = 1
        border.strokeColor = tagStrokeColor
        border.fillColor = tagFillColor
        border.cornerRadius = 0 // a huge value
        border.lineJoin = CGLineJoin.bevel
        tagText.bs_set(textBackgroundBorder: border, range: (tagText.string as NSString).range(of: itemText))
        
        return tagText
    }
}
