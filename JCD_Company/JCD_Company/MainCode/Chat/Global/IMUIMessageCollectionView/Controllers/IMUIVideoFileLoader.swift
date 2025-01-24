//
//  IMUIVideoFileLoader.swift
//  IMUIChat
//
//  Created by oshumini on 2017/3/24.
//  Copyright © 2017年 HXHG. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

typealias ReadFrameCallBack = (CGImage) -> ()

class IMUIVideoFileLoader: NSObject {
 
  
    var readFrameCallback: ReadFrameCallBack?
    
    static let queue = OperationQueue()
    var videoReadOperation: IMUIVideFileLoaderOperation?
    
    var isNeedToStopVideo: Bool {
        set {
            self.videoReadOperation?.isNeedToStop = newValue
        }
        
        get {
            return true
        }
    }
    
    func loadVideoFile(with url: URL, callback: @escaping ReadFrameCallBack) {
        self.readFrameCallback = callback
        videoReadOperation?.isNeedToStop = true
        videoReadOperation = IMUIVideFileLoaderOperation(url: url, callback: callback)
        IMUIVideoFileLoader.queue.addOperation(videoReadOperation!)
        return
    }
    
    static func playVideo(data: Data, _ fileType: String = "MOV", currentViewController: UIViewController) {
        let  playVC = AVPlayerViewController()
        
        let filePath = "\(NSHomeDirectory())/Documents/abcd." + fileType
        
        if self.saveFileToLocal(data: data, savaPath: filePath) {
            let url = URL(fileURLWithPath: filePath)
            let player = AVPlayer(url: url)
            player.play()
            playVC.player = player
            currentViewController.present(playVC, animated: true, completion: nil)
        }
    }
    
    static func fileExists(atPath: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: atPath)
    }
    
    static func saveFileToLocal(data: Data, savaPath: String) -> Bool {
        let fileManager = FileManager.default
        let exist = fileManager.fileExists(atPath: savaPath)
        if exist {
            try! fileManager.removeItem(atPath: savaPath)
        }
        if !fileManager.createFile(atPath: savaPath, contents: data, attributes: nil) {
            return false
        }
        return true
    }
    
    //视频转换格式.mov 转成 .mp4
    //方法中sourceUrl参数为.mov的URL数据
    static func movFileTransformToMp4WithSourceUrl(sourceUrl: URL,completionHandler:@escaping (URL?,String?) -> ()) {
        //以当前时间来为文件命名
        let date = Date()
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = formatter.string(from: date) + ".mp4"
        
        //保存址沙盒路径
        let docPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
        let videoSandBoxPath = (docPath as String) + "/ablumVideo" + fileName
        
        AppLog(videoSandBoxPath)
        
        //转码配置
        let avAsset = AVURLAsset.init(url: sourceUrl, options: nil)
        
        //取视频的时间并处理，用于上传
        let time = avAsset.duration
        let number = Float(CMTimeGetSeconds(time)) - Float(Int(CMTimeGetSeconds(time)))
        let totalSecond = number > 0.5 ? Int(CMTimeGetSeconds(time)) + 1 : Int(CMTimeGetSeconds(time))
        _ = String(totalSecond)
        
        
        let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPresetMediumQuality)
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.outputURL = URL.init(fileURLWithPath: videoSandBoxPath)
        exportSession?.outputFileType = AVFileType.mp4 //控制转码的格式
        exportSession?.shouldOptimizeForNetworkUse = true
        
        exportSession?.exportAsynchronously(completionHandler: {
            if exportSession?.status == AVAssetExportSession.Status.failed {
                print("转码失败")
                completionHandler(nil,"转码失败")
            }
            if exportSession?.status == AVAssetExportSession.Status.completed {
                print("转码成功")
                //转码成功后就可以通过dataurl获取视频的Data用于上传了
                let dataurl = URL.init(fileURLWithPath: videoSandBoxPath)
                
                completionHandler(dataurl,nil)
            }
        })
    }
    
    ///获取video的第一张图片
    static func getVideoCropPicture(videoUrl: URL, completionHandler:@escaping (UIImage?,Double) -> ()) {
        
        let opts = [AVURLAssetPreferPreciseDurationAndTimingKey : NSNumber(value: false)]
        let urlAsset = AVURLAsset(url: videoUrl, options: opts)
        
        let time = urlAsset.duration
        let number = Float(CMTimeGetSeconds(time)) - Float(Int(CMTimeGetSeconds(time)))
        let totalSecond = number > 0.5 ? Int(CMTimeGetSeconds(time)) + 1 : Int(CMTimeGetSeconds(time))
        
        let generator = AVAssetImageGenerator(asset: urlAsset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 120, height: 160)
        var _: Error? = nil
        let img = try? generator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        if img == nil {
           completionHandler(nil,Double(totalSecond))
        }else {
            completionHandler(UIImage(cgImage: img!), Double(totalSecond))
        }
    }
}

class IMUIVideFileLoaderOperation: Operation {
  
  var isNeedToStop = false

  var previousFrameTime: CMTime?
  
  var url: URL
  var readFrameCallback: ReadFrameCallBack
  
  init(url: URL, callback: @escaping ReadFrameCallBack) {
    self.url = url
    self.readFrameCallback = callback
    super.init()
  }
  
  override func main() {
    self.isNeedToStop = false
    do {
      while !self.isNeedToStop {
        let videoAsset = AVAsset(url: url)
        let reader = try AVAssetReader(asset: videoAsset)
        let videoTracks = videoAsset.tracks(withMediaType: AVMediaType.video)
        let videoTrack = videoTracks[0]
        
        let options = [String(kCVPixelBufferPixelFormatTypeKey): kCVPixelFormatType_32BGRA]
        let videoReaderOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: options)
        reader.add(videoReaderOutput)
        reader.startReading()
        
        while reader.status == .reading && videoTrack.nominalFrameRate > 0 {
          let videoBuffer = videoReaderOutput.copyNextSampleBuffer()
          
          if videoBuffer == nil {
            if reader.status != .cancelled {
              reader.cancelReading()
            }
            break
          }
          
          let image = self.imageFromSampleBuffer(sampleBuffer: videoBuffer!)
          
          if self.isNeedToStop != true {
            self.readFrameCallback(image)
          } else {
            break
          }

          usleep(41666)

          if reader.status == .completed {
            reader.cancelReading()
          }
        }

      }
    } catch {
      print("can not load video file")
      return
    }
  }
  
  fileprivate func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage {
    let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
    CVPixelBufferLockBaseAddress(imageBuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
    let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer!)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer!)
    let width = CVPixelBufferGetWidth(imageBuffer!)
    let height = CVPixelBufferGetHeight(imageBuffer!)
    
    // Create a device-dependent RGB color space
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
    let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    
    let quartzImage = context!.makeImage();
    CVPixelBufferUnlockBaseAddress(imageBuffer!,CVPixelBufferLockFlags(rawValue: 0));
    
    return quartzImage!
  }
  
  fileprivate func ciImageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CIImage {
    return CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(sampleBuffer)!)
    
  }
  
}
