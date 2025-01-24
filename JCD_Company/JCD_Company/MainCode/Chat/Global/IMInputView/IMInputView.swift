//
//  IMInputView.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/7.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
protocol ChatBarViewDelegate: NSObjectProtocol {
    func chatBarShowTextKeyboard()
    func chatBarShowVoice()
    func chatBarVoiceLongTap(longTap:UILongPressGestureRecognizer)
    func chatBarShowEmotionKeyboard()
    func chatBarShowMoreKeyboard()
    func chatBarSendMessage()
    func chatBarUpdateHeight(height: CGFloat)
}

enum ChatKeyboardType: Int {
    case noting
    case voice
    case text
    case emotion
    case more
}

class IMInputView: UIView {
    // MARK:- 记录属性
    var keyboardType: ChatKeyboardType = .noting
    weak var delegate: ChatBarViewDelegate?
    
    let chatBarOriginHeight: CGFloat = 49.0
    let chatBarTextViewMaxHeight: CGFloat = 100
    let chatBarTextViewHeight: CGFloat = 49.0 - 14.0
    
    // MARK:- 懒加载
    lazy var voiceButton: UIButton = {
        let voiceBtn = UIButton(type: .custom)
        voiceBtn.addTarget(self, action: #selector(voiceBtnClick(_:)), for: .touchUpInside)
        return voiceBtn
    }()
    lazy var emotionButton: UIButton = {
        let emotionBtn = UIButton(type: .custom)
        emotionBtn.addTarget(self, action: #selector(emotionBtnClick(_:)), for: .touchUpInside)
        return emotionBtn
    }()
    lazy var moreButton: UIButton = {
        let moreBtn = UIButton(type: .custom)
        moreBtn.addTarget(self, action: #selector(moreBtnClick(_:)), for: .touchUpInside)
        return moreBtn
    }()
    
    lazy var recordButton: UIButton = {
        let recordBtn = UIButton(type: .custom)
        recordBtn.backgroundColor = UIColor.white
        recordBtn.setTitle("按住 说话", for: .normal)
        recordBtn.setBackgroundImage(PublicColor.buttonColorImage, for: .normal)
        recordBtn.setBackgroundImage(PublicColor.buttonHightColorImage, for: .highlighted)
        recordBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        recordBtn.setTitleColor(UIColor.black, for: .normal)
        recordBtn.setTitleColor(UIColor.black, for: .highlighted)
        recordBtn.layer.cornerRadius = 4.0
        recordBtn.layer.masksToBounds = true
        recordBtn.layer.borderColor = PublicColor.partingLineColor.cgColor
        recordBtn.layer.borderWidth = 0.5
        recordBtn.isHidden = true
        
        //长按事件
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(voiceBtnLongTap(_:)))
        longTap.minimumPressDuration = 0.15
        recordBtn.addGestureRecognizer(longTap)
        
        return recordBtn
    }()
    
    lazy var inputTextView: UITextView = { [unowned self] in
        let inputV = UITextView()
        inputV.font = UIFont.systemFont(ofSize: 15.0)
        inputV.textColor = UIColor.black
        inputV.returnKeyType = .send
        inputV.enablesReturnKeyAutomatically = true
        inputV.layer.cornerRadius = 4.0
        inputV.layer.masksToBounds = true
        inputV.layer.borderColor = PublicColor.partingLineColor.cgColor
        inputV.layer.borderWidth = 0.5
        inputV.delegate = self
        inputV.addObserver(self, forKeyPath: "attributedText", options: .new, context: nil)
        return inputV
        }()
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        // 设置按钮图片
        self.resetBtnsUI()
        // 初始化UI
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
// MARK:- 初始化UI
extension IMInputView {
    
    fileprivate func setupUI() {
        backgroundColor = .white
        self.layerShadow()
        
        addSubview(voiceButton)
        addSubview(emotionButton)
        addSubview(moreButton)
        addSubview(inputTextView)
        addSubview(recordButton)
        
        // 布局
        voiceButton.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.left).offset(5)
            make.width.height.equalTo(35)
            make.bottom.equalTo(self.snp.bottom).offset(-7)
        }
        moreButton.snp.makeConstraints { (make) in
            make.right.equalTo(self.snp.right).offset(-5)
            make.width.height.equalTo(35)
            make.bottom.equalTo(self.snp.bottom).offset(-7)
        }
        emotionButton.snp.makeConstraints { (make) in
            make.right.equalTo(moreButton.snp.left)
            make.width.height.equalTo(35)
            make.bottom.equalTo(self.snp.bottom).offset(-7)
        }
        inputTextView.snp.makeConstraints { (make) in
            make.left.equalTo(voiceButton.snp.right).offset(7)
            make.right.equalTo(emotionButton.snp.left).offset(-7)
            make.top.equalTo(self).offset(7)
            make.bottom.equalTo(self).offset(-7)
        }
        recordButton.snp.makeConstraints { (make) in
            make.left.equalTo(voiceButton.snp.right).offset(7)
            make.right.equalTo(emotionButton.snp.left).offset(-7)
            make.height.equalTo(35)
            make.centerY.equalTo(self.snp.centerY)
        }
       
    }
}

// MARK:- 初始化事件
extension IMInputView {
    
    // 切换 录音按钮的UI
    func replaceRecordBtnUI(isRecording: Bool) {
        if isRecording {
            recordButton.setTitle("松开 结束", for: .normal)
            recordButton.setBackgroundImage(PublicColor.buttonHightColorImage, for: .normal)
        } else {
            recordButton.setTitle("按住 说话", for: .normal)
            recordButton.setBackgroundImage(PublicColor.buttonColorImage, for: .normal)
        }
    }
}

// MARK:- 事件处理
extension IMInputView {
    
    //刷新UI
    func resetBtnsUI()  {
        
        voiceButton.setImage(UIImage(named:"chat_voice"), for: .normal)
        
        emotionButton.setImage(UIImage(named:"chat_emoji"), for: .normal)
        
        moreButton.setImage(UIImage(named:"chat_more"), for: .normal)
        
        // 时刻修改barView的高度
        self.textViewDidChange(inputTextView)
    }
    
    //语音长按
    @objc func voiceBtnLongTap(_ longTap: UILongPressGestureRecognizer) {
        
        delegate?.chatBarVoiceLongTap(longTap: longTap)
        
        if longTap.state == .began {    // 长按开始
            
            self.replaceRecordBtnUI(isRecording: true)
            
        } else if longTap.state == .changed {   // 长按平移
           
            
        } else if longTap.state == .ended { // 长按结束
       
            self.replaceRecordBtnUI(isRecording: false)
        }
    }
    
    //语音点击
    @objc func voiceBtnClick(_ btn: UIButton) {
        AppLog("voiceBtnClick")
        resetBtnsUI()
        if keyboardType == .voice { // 正在显示语音
            keyboardType = .text
            
            inputTextView.isHidden = false
            recordButton.isHidden = true
            inputTextView.becomeFirstResponder()
            
        } else {
            keyboardType = .voice
            inputTextView.resignFirstResponder()
            inputTextView.isHidden = true
            recordButton.isHidden = false
            
            voiceButton.setImage(UIImage(named:"chat_keybar"), for: .normal)
            
            // 调用代理方法
            delegate?.chatBarShowVoice()
            // 改变键盘高度为正常
            delegate?.chatBarUpdateHeight(height: chatBarOriginHeight)
        }
    }
    
    //表情
    @objc func emotionBtnClick(_ btn: UIButton) {
        AppLog("emotionBtnClick")
        resetBtnsUI()
        if keyboardType == .emotion { // 正在显示表情键盘
            keyboardType = .text
            inputTextView.becomeFirstResponder()
        } else {
            
            if keyboardType == .voice {
                recordButton.isHidden = true
                inputTextView.isHidden = false
                // textViewDidChange
            } else if keyboardType == .text {
                inputTextView.resignFirstResponder()
            }
            
            keyboardType = .emotion
            inputTextView.resignFirstResponder()
            
            emotionButton.setImage(UIImage(named:"chat_keybar"), for: .normal)
            
            // 调用代理方法
            delegate?.chatBarShowEmotionKeyboard()
        }
        
    }
    
    //更多
    @objc func moreBtnClick(_ btn: UIButton) {
        AppLog("moreBtnClick")
        resetBtnsUI()
        if keyboardType == .more { // 正在显示更多键盘
            keyboardType = .text
            inputTextView.becomeFirstResponder()
            
        } else {
            if keyboardType == .voice {
                recordButton.isHidden = true
                inputTextView.isHidden = false
                // textViewDidChange
            } else if keyboardType == .text {
                inputTextView.resignFirstResponder()
            }
            
            keyboardType = .more
            // inputTextView.resignFirstResponder()
            
            moreButton.setImage(UIImage(named:"chat_keybar"), for: .normal)
            
            // 调用代理方法
            delegate?.chatBarShowMoreKeyboard()
        }
    }
}


extension IMInputView : UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        keyboardType = .text
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        resetBtnsUI()
        
        keyboardType = .text
        
        // 调用代理方法
        delegate?.chatBarShowTextKeyboard()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.width == 0 {return}
        let height = getTextViewHeight(textView,textView.width)
        if height != textView.height {
            UIView.animate(withDuration: 0.05, animations: {
                self.delegate?.chatBarUpdateHeight(height: height)

            })
        }
    }
    
    //获取textvView的高度
    func getTextViewHeight(_ textView: UITextView,_ textViewWidth:CGFloat) -> CGFloat {
        var h = textView.sizeThatFits(CGSize(width: textViewWidth, height: CGFloat(MAXFLOAT))).height
        h = h > chatBarTextViewHeight ? h : chatBarTextViewHeight
        h = h < chatBarTextViewMaxHeight ? h : textView.height
        let height = h + chatBarOriginHeight - chatBarTextViewHeight
        return height
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            AppLog("发送")
            delegate?.chatBarSendMessage()
            return false
        }
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        AppLog("文字改变")
        
        inputTextView.scrollRangeToVisible(NSMakeRange(inputTextView.text.count, 1))
        
        self.textViewDidChange(inputTextView)
    }
}

