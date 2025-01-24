//
//  MyDataCenterDetailVC.swift
//  YZB_Company
//
//  Created by Cloud on 2020/3/10.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Then
import Alamofire
import ObjectMapper

class MyDataCenterDetailVC: BaseViewController {
    var dataSource = [DataCenterDetailModel]()
    var fileUrls: String? = nil
    var dateStr: String? = nil
    private var downloadProgress: UIProgressView? = nil

    private let tableView = UITableView.init(frame: .zero, style: .grouped)
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "资料中心"
            let jsonData:Data? = fileUrls?.data(using: .utf8)
            let arr = try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)
            dataSource = Mapper<DataCenterDetailModel>().mapArray(JSONArray: arr as! [[String : Any]])

            tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height-PublicSize.kNavBarHeight)
//            if #available(iOS 11.0, *) {
//                tableView.contentInsetAdjustmentBehavior = .never
//            } else {
//                automaticallyAdjustsScrollViewInsets = false
//            }
            tableView.delegate = self
            tableView.dataSource = self
            
            view.addSubview(tableView)
            
            
            downloadProgress = UIProgressView.init(frame: CGRect.init(x: view.frame.width * 0.1, y: 200, width: view.frame.width * 0.8, height: 20))
            //view.addSubview(downloadProgress!)
        }
}

extension MyDataCenterDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = model.fileName
        if let size = model.size {
            let sizeInt = Int(size)
            let sizeStr = String(format: "%.2f", bytes2mb(bytes: sizeInt ?? 0))
            cell.detailTextLabel?.text = "\(sizeStr)MB"
        } else {
            cell.detailTextLabel?.text = "未知"
        }
        
        cell.imageView?.image = #imageLiteral(resourceName: "file_icon")
        _ = cell.textLabel?.textColor(PublicColor.c333).font(12)
        _ = cell.detailTextLabel?.textColor(PublicColor.c999).font(10)
        let downloadBtn = UIButton().image(#imageLiteral(resourceName: "share_nav"))
        downloadBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        downloadBtn.tag = indexPath.row
        downloadBtn.addTarget(self, action: #selector(downloadBtnClick(btn:)))
        cell.accessoryView = downloadBtn
        return cell
    }
    
    @objc func downloadBtnClick(btn: UIButton) {
        let model = dataSource[btn.tag]
        let textToShare = model.fileName
         let imageToShare = #imageLiteral(resourceName: "yzb_logo")
         let urlToShare = NSURL.init(string: APIURL.ossPicUrl + (model.url ?? ""))
        let items = [textToShare ?? "", imageToShare, urlToShare as Any] as [Any]
         let activityVC = UIActivityViewController(
             activityItems: items,
             applicationActivities: nil)
        activityVC.completionWithItemsHandler =  { activity, success, items, error in
//             print(activity)
//             print(success)
//             print(items)
//             print(error)
         }
         self.present(activityVC, animated: true, completion: { () -> Void in
             
         })
//        let mURLSession = URLSession.init(configuration: .default, delegate: self, delegateQueue: nil)
//        mURLSession.downloadTask(with: URL.init(string: APIURL.ossPicUrl + (model.url ?? ""))!).resume()
    }
       
    
    func bytes2mb(bytes: Int) -> Float {
        let fileSize = Decimal(integerLiteral: bytes)
        let keioByte = Decimal(integerLiteral: 1024*1024)
        let returnValue = fileSize / keioByte
        return Float.init(string: "\(returnValue)") ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 91
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView().backgroundColor(PublicColor.backgroundViewColor)
        let timeView = UIView().backgroundColor(.white)
        timeView.frame = CGRect(x: 0, y: 4.5, width: view.width, height: 35)
        let timeLab = UILabel().text(dateStr ?? "").textColor(PublicColor.c666).font(12)
        timeView.sv(timeLab)
        |-10-timeLab.centerVertically()
        v.addSubview(timeView)
        
        let titleView = UIView().backgroundColor(.white)
        titleView.frame = CGRect(x: 0, y: 44.5, width: view.width, height: 46.5)
        let titleLab = UILabel().text("附件：").textColor(PublicColor.c666).font(12, weight: .bold)
        titleView.sv(titleLab)
        |-10-titleLab.centerVertically()
        v.addSubview(titleView)
        
        return v
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = dataSource[indexPath.row]
        let vc = MyDataCenterDetailWebVC()
        vc.title = model.fileName
        vc.urlStr = APIURL.ossPicUrl + (model.url ?? "")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

//extension MyDataCenterDetailVC: URLSessionDownloadDelegate {
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//
//    }
//
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        if let downloadProgress = self.downloadProgress {
//            if Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) == 1 {
//                DispatchQueue.main.async {
//                    self.noticeOnlyText("下载完成")
//                }
//            }
//
//        }
//    }
//
//}


class DataCenterDetailModel: NSObject, Mappable {
    var url: String?
    var fileName: String?          //资料下载列表
    var size: String?  // 文本

    required init?(map: Map) {
        
    }

    func mapping(map: Map) {
        url <- map["url"]
        fileName <- map["fileName"]
        size <- map["size"]
    }
}

