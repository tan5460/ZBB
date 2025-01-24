//
//  IMUIRecordVoiceHelper.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/11.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import AVFoundation

protocol IMUIVoiceHelperDelegate: NSObjectProtocol {
    func beyondLimit(_ time: TimeInterval)
    func getPeakPower(power: Float, countdown: Int)
}

typealias CompletionCallBack = () -> Void

class IMUIRecordVoiceHelper: NSObject {

    weak var delegate: IMUIVoiceHelperDelegate?
    
    var stopRecordCompletion: CompletionCallBack?
    var startRecordCompleted: CompletionCallBack?
    var cancelledDeleteCompletion: CompletionCallBack?
    
    
    var recorder: AVAudioRecorder?
    var recordPath: String?
    var recordDuration: String?
    var recordProgress: Float?
    var theTimer: Timer?
    var currentTimeInterval: TimeInterval?
    
    let maxRecordTime: TimeInterval = 60.0
    
    override init() {
        super.init()
    }
    
    deinit {
        stopRecord()
        recordPath = nil
    }
    
    @objc func updateMeters() {

        recorder?.updateMeters()
       
        if let currentTime = recorder?.currentTime {
            
            if let power = recorder?.peakPower(forChannel: 0) {
                AppLog(power)
                delegate?.getPeakPower(power: power, countdown: Int(currentTime))
            }
            
            if currentTime >= maxRecordTime {
                delegate?.beyondLimit(currentTime)
            }
        }
    }
    func getRecorderPath() -> String {
        var recorderPath:String? = nil
        let now:Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MMMM-dd"
        recorderPath = "\(NSHomeDirectory())/Documents/"
        
        dateFormatter.dateFormat = "yyyy-MM-dd-hh-mm-ss"
        recorderPath?.append("\(dateFormatter.string(from: now))-MySound.ilbc")
        return recorderPath!
    }
    
    func getVoiceDuration(_ recordPath:String) {
        do {
            let player:AVAudioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: recordPath))
            player.play()
            self.recordDuration = "\(player.duration)"
            player.stop()
        } catch let error as NSError {
            print("get AVAudioPlayer is fail \(error)")
        }
    }
    
    func resetTimer() {
        if theTimer == nil {
            return
        } else {
            theTimer!.invalidate()
            theTimer = nil
        }
    }
    
    func cancelRecording() {
        if recorder == nil {
            return
        }
        if recorder?.isRecording != false {
            recorder?.stop()
        }
        recorder = nil
    }
    
    func stopRecord() {
        cancelRecording()
        resetTimer()
    }
    
    func startRecordingWithPath(_ path:String, startRecordCompleted:@escaping CompletionCallBack) {
        print("Action - startRecordingWithPath:")
        self.startRecordCompleted = startRecordCompleted
        self.recordPath = path
        
        let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
        } catch let error as NSError {
            AppLog("could not set session category")
            AppLog(error.localizedDescription)
        }
        
        do {
            try audioSession.setActive(true)
        } catch let error as NSError {
            AppLog("could not set session active")
            AppLog(error.localizedDescription)
        }
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleIMA4 as UInt32),
            AVNumberOfChannelsKey: 1 as AnyObject,
            AVSampleRateKey : 16000.0 as AnyObject
        ]
        
        do {
            self.recorder = try AVAudioRecorder(url: URL(fileURLWithPath: self.recordPath!), settings: recordSettings)
            self.recorder!.delegate = self
            self.recorder!.isMeteringEnabled = true
            self.recorder!.prepareToRecord()
            self.recorder?.record(forDuration: 160.0)
        } catch let error as NSError {
            recorder = nil
            AppLog(error.localizedDescription)
        }
        
        if ((self.recorder?.record()) != false) {
            self.resetTimer()
            self.theTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateMeters), userInfo: nil, repeats: true)
        } else {
            AppLog("fail record")
        }
        
        if self.startRecordCompleted != nil {
            DispatchQueue.main.async(execute: self.startRecordCompleted!)
        }
    }
    
    func finishRecordingCompletion() {
        stopRecord()
        getVoiceDuration(recordPath!)
        
        if stopRecordCompletion != nil {
            DispatchQueue.main.async(execute: stopRecordCompletion!)
        }
    }
    
    func cancelledDeleteWithCompletion() {
        stopRecord()
        if recordPath != nil {
            let fileManager:FileManager = FileManager.default
            if fileManager.fileExists(atPath: recordPath!) == true {
                do {
                    try fileManager.removeItem(atPath: recordPath!)
                } catch let error as NSError {
                    AppLog("can no to remove the voice file \(error.localizedDescription)")
                }
            } else {
                if cancelledDeleteCompletion != nil {
                    DispatchQueue.main.async(execute: cancelledDeleteCompletion!)
                }
            }
            
        }
    }
   
}



extension IMUIRecordVoiceHelper : AVAudioRecorderDelegate {
    /* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
    }
    
    
    /* if an error occurs while encoding it will be reported to the delegate. */
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        
    }
    
}
