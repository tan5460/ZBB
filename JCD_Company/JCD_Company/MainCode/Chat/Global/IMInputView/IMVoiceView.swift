//
//  IMVoiceView.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/10.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class IMVoiceView: UIView {
    
    // MARK:- 懒加载
    lazy var centerView: UIView = {
        let centerV = UIView()
        centerV.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        return centerV
    }()
    lazy var noteLabel: UILabel = {
        let noteL = UILabel()
        noteL.text = "松开手指，取消发送"
        noteL.font = UIFont.systemFont(ofSize: 14.0)
        noteL.textColor = UIColor.white
        noteL.textAlignment = .center
        noteL.layer.cornerRadius = 2
        noteL.layer.masksToBounds = true
        return noteL
    }()
    lazy var cancelImgView: UIImageView = {
        let cancelImgV = UIImageView(image: #imageLiteral(resourceName: "RecordCancel"))
        return cancelImgV
    }()
    lazy var tooShortImgView: UIImageView = {
        let tooShortImgV = UIImageView(image: #imageLiteral(resourceName: "MessageTooShort"))
        return tooShortImgV
    }()
    lazy var recordingView: UIView = {
        let recordingV = UIView()
        return recordingV
    }()
    lazy var recordingBkg: UIImageView = {
        let recordingBkg = UIImageView(image: #imageLiteral(resourceName: "RecordingBkg"))
        recordingBkg.layer.cornerRadius = 5
        recordingBkg.layer.masksToBounds = true
        return recordingBkg
    }()
    lazy var countdownLabel: UILabel = {
        let countL = UILabel()
        countL.text = "10"
        countL.font = UIFont.systemFont(ofSize: 46.0)
        countL.textColor = UIColor.white
        countL.textAlignment = .center
        return countL
    }()
    
    var signalValueImgView: UIImageView = UIImageView(image: UIImage(named: "RecordingSignal001"))
    var isCountdown = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK:- 初始化
extension IMVoiceView {
    
    fileprivate func setup() {
        
        // 添加视图
        self.addSubview(centerView)
        centerView.addSubview(noteLabel)
        centerView.addSubview(cancelImgView)
        centerView.addSubview(tooShortImgView)
        centerView.addSubview(recordingView)
        recordingView.addSubview(recordingBkg)
        recordingView.addSubview(signalValueImgView)
        recordingView.addSubview(countdownLabel)
        
        // 布局
        centerView.snp.makeConstraints { (make) in
            make.width.height.equalTo(150)
            make.centerX.equalTo(self.snp.centerX)
            make.centerY.equalTo(self.snp.centerY).offset(-30)
        }
        noteLabel.snp.makeConstraints { (make) in
            make.left.equalTo(centerView.snp.left).offset(8)
            make.right.equalTo(centerView.snp.right).offset(-8)
            make.bottom.equalTo(centerView.snp.bottom).offset(-6)
            make.height.equalTo(20)
        }
        cancelImgView.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.centerX.equalTo(centerView.snp.centerX)
            make.top.equalTo(centerView.snp.top).offset(14)
        }
        tooShortImgView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(cancelImgView)
        }
        recordingView.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(cancelImgView)
        }
        recordingBkg.snp.makeConstraints { (make) in
            make.top.left.bottom.equalTo(recordingView)
            make.width.equalTo(62)
        }
        signalValueImgView.snp.makeConstraints { (make) in
            make.top.right.bottom.equalTo(recordingView)
            make.left.equalTo(recordingBkg.snp.right)
        }
        countdownLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

// MARK:- 对外提供的方法
extension IMVoiceView {
    
    // MARK: 正在录音
    func recording() {
        
        self.isHidden = false
        self.cancelImgView.isHidden = true
        self.tooShortImgView.isHidden = true
        self.recordingView.isHidden = false
        self.noteLabel.backgroundColor = UIColor.clear
        self.noteLabel.text = "手指上滑，取消发送"
        
        if isCountdown {
            recordingBkg.isHidden = true
            signalValueImgView.isHidden = true
            countdownLabel.isHidden = false
        }else {
            recordingBkg.isHidden = false
            signalValueImgView.isHidden = false
            countdownLabel.isHidden = true
        }
    }
    
    // MARK: 滑动取消
    func slideToCancelRecord() {
        
        self.isHidden = false
        self.cancelImgView.isHidden = false
        self.tooShortImgView.isHidden = true
        self.recordingView.isHidden = true
        self.noteLabel.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x9C3638)
        self.noteLabel.text = "松开手指，取消发送"
    }
    
    // MARK: 提示录音时间太短
    func messageTooShort() {
        
        self.isHidden = false
        self.cancelImgView.isHidden = true
        self.tooShortImgView.isHidden = false
        self.recordingView.isHidden = true
        self.noteLabel.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x9C3638)
        self.noteLabel.text = "说话时间太短"
        // 1秒后消失
        let time: TimeInterval = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time) {
            self.endRecord()
        }
    }
    
    // MARK: 录音结束
    func endRecord() {
        self.isHidden = true
        
        isCountdown = false
        recordingBkg.isHidden = false
        signalValueImgView.isHidden = false
        countdownLabel.isHidden = true
        countdownLabel.text = "10"
        updateMetersValue(0)
    }
    
    // MARK: 更新麦克风的音量大小
    func updateMetersValue(_ value: Float) {
        
        var index = Int(String(value).first?.description ?? "0") ?? 0
        
        index = index > 7 ? 7 : index
        index = index < 0 ? 0 : index
        
        let array: [UIImage] = [
            UIImage(named: "RecordingSignal001")!,
            UIImage(named: "RecordingSignal002")!,
            UIImage(named: "RecordingSignal003")!,
            UIImage(named: "RecordingSignal004")!,
            UIImage(named: "RecordingSignal005")!,
            UIImage(named: "RecordingSignal006")!,
            UIImage(named: "RecordingSignal007")!,
            UIImage(named: "RecordingSignal008")!
        ]
        self.signalValueImgView.image = array[index]
//        AppLog("更新音量 -- \(index)")
    }
    
    //MARK: 更新倒计时
    func updateCountdown(value: Int, maxValue: Int) {
        
        let countdown = maxValue - value
        if countdown <= 10 {
            isCountdown = true
        }else {
            isCountdown = false
        }
        
        if isCountdown {
            recordingBkg.isHidden = true
            signalValueImgView.isHidden = true
            countdownLabel.isHidden = false
            countdownLabel.text = "\(countdown)"
        }else {
            recordingBkg.isHidden = false
            signalValueImgView.isHidden = false
            countdownLabel.isHidden = true
            countdownLabel.text = "10"
        }
    }
}
