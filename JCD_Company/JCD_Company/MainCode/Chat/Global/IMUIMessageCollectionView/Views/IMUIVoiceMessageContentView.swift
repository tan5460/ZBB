//
//  IMUIVoiceMessageContentView.swift
//  sample
//
//  Created by oshumini on 2017/6/12.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import AVFoundation

public class IMUIVoiceMessageContentView: UIView, IMUIMessageContentViewProtocol {
    public static var outGoingVoiceDurationColor = UIColor.white
    public static var inComingVoiceDurationColor = PublicColor.commonTextColor
    
    var voiceImg = UIImageView()
    fileprivate var isMediaActivity = false
    var message: IMUIMessageModelProtocol?
    var voiceDuration = UILabel()
    fileprivate var voiceImageIndex = 0
    
    override init(frame: CGRect) {
        
        AppLog(">>>>>>>>>>>>>>>>>>>>>> 语音单元格被创建 <<<<<<<<<<<<<<<<<<<<<")
        
        super.init(frame: frame)
        self.addSubview(voiceImg)
        self.addSubview(voiceDuration)
        voiceDuration.textColor = UIColor.white
        voiceDuration.font = UIFont.systemFont(ofSize: 12.0)
        voiceDuration.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 40, height: 20))
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.onTapContentView))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(gesture)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>>>>> 语音单元格被释放 <<<<<<<<<<<<<<<<<<<<<")
        IMUIAudioPlayerHelper.sharedInstance.stopAudio()
    }
    
    
    public func layoutContentView(message: IMUIMessageModelProtocol) {
        
        self.message = message
        resetVoiceImage()
        
        let seconds = Int(message.duration)
        if seconds/3600 > 0 {
            voiceDuration.text = "\(seconds/3600):\(String(format: "%02d", (seconds/3600)%60)):\(seconds%60)"
        }else if (seconds-1)/60 > 0 {
            voiceDuration.text = "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
        }else {
            voiceDuration.text = "\(seconds)\""
        }
        
        self.layoutToVoice(isOutGoing: message.isOutGoing)
        
        IMUIAudioPlayerHelper.sharedInstance.renewProgressCallback(message.msgId) { (id, volume, currendTime, duration) in
            if self.message?.msgId == id {
                self.setImage(with: Int(currendTime*4)%3 + 1)
            }
            print("\(volume)")
        }
    }
    
    @objc func onTapContentView() {
        
        if self.isMediaActivity {
            self.resetVoiceImage()
            self.isMediaActivity = false
            IMUIAudioPlayerHelper.sharedInstance.stopAudio()
        } else {
            IMUIAudioPlayerHelper.sharedInstance.stopAudio()
            
            if let voiceData = (message?.mediaData?()) {
                IMUIAudioPlayerHelper
                    .sharedInstance
                    .playAudioWithData((self.message?.msgId)!, voiceData,
                                       {[weak self] (id, power, currendTime, duration) in
                                        if self?.message?.msgId == id {
                                            self?.setImage(with: Int(currendTime+0.2)%3 + 1)
                                        }
                    },
                                       {[weak self] id in
                                        if self?.message?.msgId == id {
                                            self?.isMediaActivity = false
                                            self?.resetVoiceImage()
                                        }
                    },
                                       {[weak self] id in
                                        if self?.message?.msgId == id {
                                            self?.isMediaActivity = false
                                            self?.resetVoiceImage()
                                        }
                    })
            }
            
            self.isMediaActivity = true
        }
    }
    
    func resetVoiceImage() {
        if (message?.isOutGoing)! {
            self.voiceImg.image = UIImage.imuiImage(with: "outgoing_voice_3")
        } else {
            self.voiceImg.image = UIImage.imuiImage(with: "incoming_voice_3")
        }
    }
    
    func setImage(with index:Int) {
        if (message?.isOutGoing)! {
            self.voiceImg.image = UIImage.imuiImage(with: "outgoing_voice_\(index)")
        } else {
            self.voiceImg.image = UIImage.imuiImage(with: "incoming_voice_\(index)")
        }
    }
    
    func layoutToVoice(isOutGoing: Bool) {
        if isOutGoing {
            self.voiceImg.image = UIImage.imuiImage(with: "outgoing_voice_3")
            self.voiceImg.frame = CGRect(x: 0, y: 0, width: 12, height: 16)
            self.voiceImg.center = CGPoint(x: frame.width - 20, y: frame.height/2)
            self.voiceDuration.center = CGPoint(x: 28, y: frame.height/2)
            voiceDuration.textAlignment = .center
            voiceDuration.textColor = IMUIVoiceMessageContentView.outGoingVoiceDurationColor
        } else {
            self.voiceImg.image = UIImage.imuiImage(with: "incoming_voice_3")
            self.voiceImg.frame = CGRect(x: 0, y: 0, width: 12, height: 16)
            self.voiceImg.center = CGPoint(x: 20, y: frame.height/2)
            self.voiceDuration.center = CGPoint(x: frame.width - 28, y: frame.height/2)
            voiceDuration.textAlignment = .center
            voiceDuration.textColor = IMUIVoiceMessageContentView.inComingVoiceDurationColor
        }
    }
}
