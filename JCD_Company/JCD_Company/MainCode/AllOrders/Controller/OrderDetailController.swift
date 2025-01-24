//
//  OrderDetailController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/2/5.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import PopupDialog
import ObjectMapper


class OrderDetailController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var topView: OrderTopDetailView!            //顶部栏
    
    var bottomView: UIView!                     //底部栏
    var iconImage: UIImageView!                 //状态图标
    var orderStateLabel: UILabel!               //订单状态
    var changeStateBtn: UIButton!               //更改状态
    var modifyBtn: UIButton!                    //修改
    var deleteBtn: UIButton!                    //删除
    var exportBtn: UIButton!                    //导出
    var oneKeyBtn: UIButton!                    //一键采购
    
    var tableView: UITableView!
    let identifier = "orderDetailCell"
    let sectionHeaderId = "orderDetailHeaderView"
    var rowsData: Array<MaterialsModel> = []
    var orderModel: OrderModel? {
        
        didSet {
            updateUI()
        }
    }
    var excelPath = ""
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>> 订单详情页面释放了 <<<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "订单详情"
        
        prepareBottomView()
        prepareHeaderView()
        prepareTableView()
        
        updateUI()
        
        self.pleaseWait()
        self.loadData()
    }
    
    private func updateUI() {
        topView?.orderModel = orderModel
        
        deleteBtn?.isHidden = true
        modifyBtn?.isHidden = true
        oneKeyBtn?.isHidden = true
        
        if let valueStr = orderModel?.orderStatus?.intValue {
            let status = Utils.getFieldValInDirArr(arr: AppData.plusOrderStatusTypeList, fieldA: "value", valA: "\(valueStr)", fieldB: "label")
            if status.count > 0 {
                orderStateLabel?.text = status
            }
        }
        
        if orderModel?.orderStatus == 3 {
            changeStateBtn.isHidden = true
        }
        else if orderModel?.orderStatus == 2 {
            
            changeStateBtn?.snp.remakeConstraints { (make) in
                make.width.equalTo(76)
                make.centerY.height.equalTo(exportBtn)
                make.right.equalTo(exportBtn.snp.left).offset(-8)
            }
        }
        else {
            deleteBtn?.isHidden = false
            modifyBtn?.isHidden = false
            oneKeyBtn?.isHidden = true
            
            changeStateBtn?.snp.remakeConstraints { (make) in
                make.width.equalTo(76)
                make.centerY.height.equalTo(exportBtn)
                make.right.equalTo(deleteBtn.snp.left).offset(-8)
            }
        }
        
        if UserData.shared.workerModel?.jobType == 999 || UserData.shared.workerModel?.jobType == 4 {
            
            if orderModel?.orderStatus == 2 && UserData.shared.userType == .cgy {
                oneKeyBtn?.isHidden = false
                oneKeyBtn?.snp.remakeConstraints { (make) in
                    make.width.equalTo(76)
                    make.centerY.height.equalTo(exportBtn)
                    make.right.equalTo(changeStateBtn.snp.left).offset(-8)
                }
            }
        }
        
        if orderModel?.orderStatus == 1 {
            deleteBtn?.isHidden = false
            modifyBtn?.isHidden = false
            iconImage?.image = UIImage.init(named: "orderState_wait")
        }else if orderModel?.orderStatus == 2 {
            iconImage?.image = UIImage.init(named: "orderState_sure")
        }else if orderModel?.orderStatus == 3 {
            iconImage?.image = UIImage.init(named: "orderState_done")
        }
    }
    
    //MARK: - 触发事件
    
    /// 拨打电话
    @objc func telAction(){
        
        var name = "姓名未填"
        if let valueStr = orderModel?.house?.custom?.realName {
            name = valueStr
        }
        
        var phone = ""
        if let valueStr = orderModel?.house?.custom?.tel {
            phone = valueStr
        }
        houseListCallTel(name: name, phone: phone)
    }
    
    //复制订单号
    @objc func copyAction() {
        
        if let valueStr = orderModel?.orderNo {
            let paste = UIPasteboard.general
            paste.string = valueStr
            self.noticeSuccess("已复制到剪切板")
        }else {
            self.noticeOnlyText("订单编号为空")
        }
    }
    
    //修改状态
    @objc func changeStateAction() {
        
        let changeStateBlock: ((_ statusValue: NSNumber)->()) = { [weak self] statusValue in
            
            let parameters: Parameters = ["id": (self?.orderModel?.id)!, "orderStatus": "\(statusValue)"]
            AppLog("订单id: \(parameters)")
            
            self?.pleaseWait()
            let urlStr = APIURL.updateOrderStatus
            
            YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
                
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
                if errorCode == "000" {
                    
                    let model = self?.orderModel
                    model?.orderStatus = statusValue
                    self?.orderModel = model
                    GlobalNotificationer.post(notification: .order, object: nil, userInfo: nil)
                    GlobalNotificationer.post(notification: .record, object: nil, userInfo: nil)
                }
                
            }) { (error) in
                
            }
        }
        
        let popup = PopupDialog(title: "修改订单状态", message: nil)
        
        let btn1 = AlertButton(title: "待确认") {
            changeStateBlock(1)
        }
        let btn2 = AlertButton(title: "已确认") {
            changeStateBlock(2)
        }
        let btn3 = AlertButton(title: "已完成") {
            changeStateBlock(3)
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        
        if orderModel?.orderStatus == 1 {
            popup.addButtons([btn2, btn3, cancelBtn])
        }else if orderModel?.orderStatus == 2 {
            popup.addButtons([btn1, btn3, cancelBtn])
        }else if orderModel?.orderStatus == 3 {
            popup.addButtons([btn1, btn2, cancelBtn])
        }else {
            popup.addButtons([cancelBtn])
        }
        
        self.present(popup, animated: true, completion: nil)
    }
    
    //删除订单
    @objc func deleteAction() {
        
        if orderModel?.orderStatus == 1 {
            
            let popup = PopupDialog(title: "警告", message: "订单删除后不可恢复，是否继续？",buttonAlignment: .horizontal)
            let sureBtn = DestructiveButton(title: "是") {
                
                self.pleaseWait()
                let orderId = self.orderModel?.id
                
                let parameters: Parameters = ["id": orderId!]
                let urlStr = APIURL.delCompanyOrder
                
                YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
                    
                    let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
                    if errorCode == "000" {
                        
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                }) { (error) in
                    
                }
            }
            let cancelBtn = CancelButton(title: "否") {
            }
            popup.addButtons([cancelBtn,sureBtn])
            self.present(popup, animated: true, completion: nil)
        }
    }
    
    //导出订单
    @objc func exportAction() {
        
        guard let orderNo = orderModel?.orderNo else {
            self.noticeOnlyText("订单编号异常")
            return
        }
        
        let popup = PopupDialog(title: "导出订单", message: "将从服务器获取最新的订单文件,该过程需要一点时间，是否继续导出？",buttonAlignment: .horizontal)
        
        let sureBtn = AlertButton(title: "继续") { [weak self] in
            
            let fileManager = FileManager.default
            
            let cachePath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as NSString
            let orderPath = cachePath.appendingPathComponent("order")
            AppLog("缓存目录: \(orderPath)")
            
            //判断路径是否存在
            if !fileManager.fileExists(atPath: orderPath) {
                AppLog("创建目录")
                try? fileManager.createDirectory(atPath: orderPath, withIntermediateDirectories: true, attributes: nil)
            }
            else {
                AppLog("目录已存在")
            }
            
            var fileName = orderNo
            
            if let valueStr = self?.orderModel?.house?.custom?.realName {
                fileName = "\(valueStr)"
                
                if let plotName = self?.orderModel?.house?.plot?.name {
                    fileName += "-\(plotName)"
                }
            }
            
            self?.excelPath = cachePath.appendingPathComponent("order/\(fileName).xls")
            AppLog("表格路径: \(self!.excelPath)")
            
            self?.downloadExcelData()
        }
        let cancelBtn = CancelButton(title: "取消") {
            
        }
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    //一键采购
    @objc func oneKeyAction() {
        
        let vc = WantPurchaseController()
        vc.isOneKeyBuy = true
        vc.houseModel = self.orderModel?.house
        vc.cusOrderId = self.orderModel?.id ?? ""
        vc.dealWithData(data: rowsData,isSelect: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //分享
    func shareAction() {
        
        if excelPath == "" {
            self.noticeOnlyText("文件路径无效")
            return
        }
        
        //准备分享内容
        let items:[Any] = [URL.init(fileURLWithPath: excelPath)]
        
        let activity = UIActivityViewController.init(activityItems: items, applicationActivities: nil)
        activity.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            
            if completed {
                AppLog("分享成功")
            }else{
                AppLog("分享失败")
            }
        }
        
        //98
        
        if IS_iPad {
            
            let popPresenter = activity.popoverPresentationController
            popPresenter?.sourceView = exportBtn
            popPresenter?.sourceRect = exportBtn.bounds
        }
        
        self.present(activity, animated: true, completion: nil)
    }
    
    //MARK: - 网络请求
    
    @objc func loadData() {
        
        guard let orderId = orderModel?.id else {
            self.clearAllNotice()
            self.noticeOnlyText("订单读取异常")
            return
        }
        
        let parameters: Parameters = ["orderId": orderId]
        AppLog("订单id: \(parameters)")
        
        let urlStr = APIURL.getComOrderData + orderId
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                
                //主材包归档
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let orderModel =  Mapper<OrderModel>().map(JSON: dataDic as! [String : Any])
                self.orderModel = orderModel
                
                let listArray =  Utils.getReadArrDic(data: dataDic, field: "orderDataDTOList")
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: listArray as! [[String : Any]])
                
                self.tableView.reloadData()
                
                var materialPrice: Double = 0
                var materialCount = 0
                
                for model1 in modelArray {
                    materialCount += 1
                    let tmpCount: Double = Double(model1.materialsCount ?? 0)
                    let tmpPrice: Double = Double.init(string: model1.materialsPriceCustom ?? "0") ?? 0
                    let tmpAllPrice = tmpCount * tmpPrice
                    materialPrice += tmpAllPrice
                }
                //赋值
                let materialPriceStr = materialPrice.notRoundingString(afterPoint: 2)
                self.topView.materialPriceLabel.text = String.init(format: "产品总价: ￥%@", materialPriceStr)
                self.topView.materialCountLabel.text = "产品项数: \(materialCount)"
            }
            
        }) { (error) in
            
            // 结束刷新
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    func downloadExcelData() {
        
        guard let orderId = orderModel?.id else {
            self.noticeOnlyText("订单读取异常")
            return
        }
        
        //获取文件路径
        let parameters: Parameters = ["id": orderId]
        AppLog("订单id: \(parameters)")
        
        self.pleaseWait()
        let urlStr = APIURL.exportOrder
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { [weak self] response in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                if let excelPath = self?.excelPath {
                    
                    //下载
                    let bodyDic = Utils.getReadDic(data: response as AnyObject, field: "body")
                    let dowloadStr = Utils.getReadString(dir: bodyDic, field: "data")
                    
                    var downloadUrl = APIURL.serverUrl + APIURL.serverPath + dowloadStr
                    downloadUrl = downloadUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    
                    let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                        var fileURL: URL!
                        
                        fileURL = URL.init(fileURLWithPath: excelPath)
                        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                    }
                    
                    var isCancel = false
                    var request: DownloadRequest
                    //进度弹窗
                    let loadingView = ExportingView()
                    loadingView.showView()
                    
                    request = Alamofire.download(downloadUrl, to: destination).downloadProgress(closure: { (progress) in
                        
                        loadingView.progress = Float(progress.fractionCompleted)
                        
                    }).response(completionHandler: { (response) in
                        
                        if !isCancel {
                            loadingView.hiddenView()
                        }
                        
                        AppLog(response)
                        if response.error == nil, let filePath = response.destinationURL?.path {
                            AppLog(">>>>>>>>>>> 下载文件路径: \(filePath)")
                            self?.shareAction()
                        }
                        else {
                            if !isCancel {
                                self?.noticeError("下载失败")
                            }else {
                                AppLog("取消下载")
                            }
                        }
                    })
                    
                    //设置取消block
                    loadingView.cancelBlock = {
                        isCancel = true
                        request.cancel()
                    }
                }
            }
            
        }) { (error) in
            
        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = rowsData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! OrderDetailCell
        cell.materialModel = model
        
        cell.detailBlock = { [weak self] in
            let rootVC = MaterialsDetailVC()
            rootVC.isDismiss = true
            rootVC.materialsModel = model
            let vc = BaseNavigationController.init(rootViewController: rootVC)
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true, completion: nil)
        }
        
        cell.openBlock = {
            
            tableView.reloadData()
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 10
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
    
    
}
