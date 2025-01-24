//
//  IMUIVideoMessageContentView.swift
//  sample
//
//  Created by oshumini on 2017/6/12.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import AVFoundation

public class IMUIVideoMessageContentView: UIView, IMUIMessageContentViewProtocol {

    lazy var videoView = UIImageView()
    lazy var playBtn = UIButton()
    lazy var videoDuration = UILabel()
    
    lazy var downloadView:DownloadingView = {
        let downView = DownloadingView.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        downView.layer.cornerRadius = downView.width/2
        downView.isHidden = true
        return downView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.videoView)
        
        videoView.addSubview(playBtn)
        videoView.addSubview(videoDuration)
        videoView.addSubview(downloadView)
        
        playBtn.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50))
        playBtn.setImage(UIImage.imuiImage(with: "video_play_btn"), for: .normal)
        videoDuration.textColor = UIColor.white
        videoDuration.font = UIFont.systemFont(ofSize: 10.0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func layoutContentView(message: IMUIMessageModelProtocol) {
        let layout = message.layout
        
        videoView.frame = CGRect(origin: CGPoint.zero, size: layout.bubbleContentSize)
        playBtn.center = CGPoint(x: videoView.imui_width/2, y: videoView.imui_height/2)
        
        downloadView.center = playBtn.center
 
        let durationX = videoView.imui_width - 30
        let durationY = videoView.imui_height - 26
        videoDuration.frame = CGRect(x: durationX,
                                     y: durationY,
                                     width: 30,
                                     height: 24)
        if let imageData = message.mediaData?() {
            let image = UIImage(data: imageData)
            self.videoView.image = image
        }else {
            self.videoView.image = UIImage.imuiImage(with: "image-broken")
            self.layoutVideo(with: message.mediaFilePath())
        }
        
        let seconds = Int(message.duration)
        if seconds/3600 > 0 {
            videoDuration.text = "\(seconds/3600):\(String(format: "%02d", (seconds/3600)%60)):\(seconds%60)"
        } else {
            videoDuration.text = "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
        }
        
        if message.messageStatus == .sending {
            
            if let msg = message as? MyMessageModel {
                if let content = msg.jmModel?.content as? JMSGVideoContent {
                    
                    content.uploadHandler = {(percent,msgId) in
                        
                        self.downloadingProgress(CGFloat(percent))
                    }
                }
            }
        }
    }
    
    
    func layoutVideo(with videoPath: String) {
        let asset = AVURLAsset(url: URL(fileURLWithPath: videoPath), options: nil)
        //    let seconds = Int (CMTimeGetSeconds(asset.duration))
        //
        //    if seconds/3600 > 0 {
        //      videoDuration.text = "\(seconds/3600):\(String(format: "%02d", (seconds/3600)%60)):\(seconds%60)"
        //    } else {
        //      videoDuration.text = "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
        //    }
        
        let serialQueue = DispatchQueue(label: "videoLoad")
        serialQueue.async {
            do {
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                DispatchQueue.main.async {
                    self.videoView.image = UIImage(cgImage: cgImage)
                }
            } catch {
                DispatchQueue.main.async {
                    self.videoView.image = nil
                }
            }
        }
    }
    
    func downloadingProgress(_ progress:CGFloat){
        DispatchQueue.main.async {
            if progress >= 1 ||  progress <= 0 {
                self.downloadView.reveal()
                self.downloadView.isHidden = true
                self.playBtn.isHidden = false
            }else if progress > 0.0 {
                
                self.playBtn.isHidden = true
                self.downloadView.isHidden = false
                self.downloadView.progress = CGFloat(progress)
            }
        }
    }
}
