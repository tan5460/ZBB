//
//  IMEmotionHelper.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/9.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class IMEmotionHelper: NSObject {

    // MARK:- 获取表情模型数组
    class func getAllEmotions() -> [IMEmotion] {
        
        var emotions: [IMEmotion] = [IMEmotion]()
        let plistPath = Bundle.main.path(forResource: "Expression", ofType: "plist")
        let array = NSArray(contentsOfFile: plistPath!) as! [[String : String]]
        
        var index = 0
        for dict in array {
            emotions.append(IMEmotion(dict: dict))
            index += 1
            if index == 23 {
                // 添加删除表情
                emotions.append(IMEmotion(isRemove: true))
                index = 0
            }
        }
        
        // 添加空白表情
        emotions = self.addEmptyEmotion(emotiions: emotions)
        
        return emotions
    }
    // 添加空白表情
    fileprivate class func addEmptyEmotion(emotiions: [IMEmotion]) -> [IMEmotion] {
        var emos = emotiions
        let count = emos.count % 24
        if count == 0 {
            return emos
        }
        for _ in count..<23 {
            emos.append(IMEmotion(isEmpty: true))
        }
        emos.append(IMEmotion(isRemove: true))
        return emos
    }
    
    class func getImagePath(emotionName: String?) -> String? {
        if emotionName == nil {
            return nil
        }
        return Bundle.main.bundlePath + "/Expression.bundle/" + emotionName! + ".png"
    }
    
   
}
class IMFindEmotion: NSObject {
    // MARK:- 单例
//    static let shared: IMFindEmotion = IMFindEmotion()
    
    // MARK:- 查找属性字符串的方法
    class func findAttrStr(text: String?, font: UIFont) -> NSMutableAttributedString? {
        guard let text = text else {
            return nil
        }
        
        let pattern = "\\[.*?\\]" // 匹配表情
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let resutlts = regex.matches(in: text, options: [], range: NSMakeRange(0, text.count))
        
        let attrMStr = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font : font])
        
        
        for (_, result) in resutlts.enumerated().reversed() {
            let emoStr = (text as NSString).substring(with: result.range)
            if let imgPath = self.findImgPath(emoStr: emoStr) {
                let attachment = IMEmotionAttachment()
                attachment.text = emoStr
                attachment.image = UIImage(contentsOfFile: imgPath)
                attachment.bounds = CGRect(x: 0, y: -5.5, width: font.lineHeight+3, height: font.lineHeight+3)
                let attrImageStr = NSAttributedString(attachment: attachment)
                attrMStr.replaceCharacters(in: result.range, with: attrImageStr)
            }
        }
        
        return attrMStr
    }
    
    class func findImgPath(emoStr: String) -> String? {
        for emotion in IMEmotionHelper.getAllEmotions() {
            if let text = emotion.text {
                
                if text == emoStr {
                    return emotion.imgPath
                }
            }
        }
        return nil
    }
}

class IMEmotion: NSObject {
    
    // MARK:- 定义属性
    var image: String?    // 表情对应的图片名称
    
    var text: String?     // 表情对应的文字
    
    // MARK:- 数据处理
    var imgPath: String?
    var isRemove: Bool = false
    var isEmpty: Bool = false
    
    override init() {
        super.init()
    }
    
    convenience init(dict: [String : String]) {
        self.init()
        self.image = dict["image"]
        if self.image != nil {
            self.imgPath = Bundle.main.bundlePath + "/Expression.bundle/" + image! + ".png"
        }
        self.text = dict["text"]
    }
    
    init(isRemove: Bool) {
        self.isRemove = (isRemove)
    }
    init(isEmpty: Bool) {
        self.isEmpty = (isEmpty)
    }
    
}


extension UITextView {
    // MARK:- 获取textView属性字符串,换成对应的表情字符串
    func getEmotionString() -> String {
        let attrMStr = NSMutableAttributedString(attributedString: attributedText)
        
        let range = NSRange(location: 0, length: attrMStr.length)
        
        attrMStr.enumerateAttributes(in: range, options: []) { (dict, range, _) in
            if let attachment = dict[NSAttributedString.Key.attachment] as? IMEmotionAttachment {
                attrMStr.replaceCharacters(in: range, with: attachment.text!)
            }
        }
        
        return attrMStr.string
    }
    
    func insertEmotion(emotion: IMEmotion) {
        // 空白
        if emotion.isEmpty {
            return
        }
        
        // 删除
        if emotion.isRemove {
            deleteBackward()
            return
        }
        
        // 表情
        let attachment = IMEmotionAttachment()
        attachment.text = emotion.text
        attachment.image = UIImage(contentsOfFile: emotion.imgPath!)
        let font = self.font!
        attachment.bounds = CGRect(x: 0, y: -5.5, width: font.lineHeight+3, height: font.lineHeight+3)
        let attrImageStr = NSAttributedString(attachment: attachment)
        
        let attrMStr = NSMutableAttributedString(attributedString: attributedText)
        let range = selectedRange
        attrMStr.replaceCharacters(in: range, with: attrImageStr)
        attributedText = attrMStr
        self.font = font
        selectedRange = NSRange(location: range.location + 1, length: 0)
    }
}

class IMEmotionAttachment: NSTextAttachment {
    var text: String?
}
