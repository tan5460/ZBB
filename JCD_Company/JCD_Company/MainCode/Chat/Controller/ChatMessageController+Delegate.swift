//
//  ChatMessageController+Delegate.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/8.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import Foundation

//MARK: - JMSGMessage Delegate
extension ChatMessageController: JMessageDelegate {
    

    //接收消息(服务器端下发的)回调
    func onReceive(_ message: JMSGMessage!, error: Error!) {
        if error != nil {
            return
        }
      
        if (self.messageCollectionView.chatDataManager.allMessageDic[message.msgId] as? MyMessageModel) != nil{
            self.dealwithMessageModel(message, isUpdata: true)
        }else {
            self.dealwithMessageModel(message)
        }
        if let conver = conversation {
            
            conver.clearUnreadCount()
        }
    }
    
    //发送消息结果返回回调
    func onSendMessageResponse(_ message: JMSGMessage!, error: Error!) {
        
        if let error = error as NSError? {
            if error.code == 803009 {
                self.noticeOnlyText("发送失败，消息中包含敏感词")
            }
            else if error.code == 803005 {
                self.noticeOnlyText("您已不是群成员")
            }
            else {
                self.noticeOnlyText("发送失败")
            }
        }
        AppLog("发送消息回调")
        if let sendMsg = self.messageCollectionView.chatDataManager.allMessageDic[message.msgId] as? MyMessageModel{
            if error == nil {
                sendMsg.messageStatus = .success
            }else {
                sendMsg.messageStatus = .failed
            }
            self.messageCollectionView.updateMessage(with: sendMsg, isRefresh: true)
        }
    }
    
    //监听消息撤回事件
    func onReceive(_ retractEvent: JMSGMessageRetractEvent!) {
        
        if let message = retractEvent.retractMessage {
            if (self.messageCollectionView.chatDataManager.allMessageDic[message.msgId] as? MyMessageModel) != nil{
                self.messageCollectionView.removeMessage(with: message.msgId)
                self.jMessageCount -= 1
                
                self.dealwithMessageModel(message)
            }
        }
    }
    
    //同步离线消息、离线事件通知
    func onSyncOfflineMessageConversation(_ conversation: JMSGConversation!, offlineMessages: [JMSGMessage]!) {
        let msgs = offlineMessages.sorted(by: { (m1, m2) -> Bool in
            return m1.timestamp.intValue < m2.timestamp.intValue
        })
        for item in msgs {
            self.dealwithMessageModel(item)
        }
        if let conver = conversation {
            
            conver.clearUnreadCount()
        }
    }
    
    //已读
    func onReceive(_ receiptEvent: JMSGMessageReceiptStatusChangeEvent!) {
        for message in receiptEvent.messages! {
            if (self.messageCollectionView.chatDataManager.allMessageDic[message.msgId] as? MyMessageModel) != nil{
                
//                self.dealwithMessageModel(message, .success, isUpdata: true)
                
                if let oldMessage = messageCollectionView.chatDataManager.allMessageDic[message.msgId] as? MyMessageModel {
                    oldMessage.isRead = true
                    
                    if let index =  messageCollectionView.chatDataManager.allMsgidArr.firstIndex(of: message.msgId) {
                        let indexPath = IndexPath(item: index, section: 0)
                        messageCollectionView.messageCollectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }
}



// MARK: - inputView的代理
extension ChatMessageController: ChatBarViewDelegate, IMMoreViewDelegate, IMEmotionViewDelegate, IMUIVoiceHelperDelegate {
    
    
    //输入框向下的约束
    func updateInputViewBottomOf(_ h:CGFloat) {
        self.messageCollectionView.scrollToBottom(with: true)
        myInputView.snp.updateConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide).offset(h)
            } else {
                make.bottom.equalToSuperview().offset(h)
            }
        }
    }
    
    //ChatBarViewDelegate
    func chatBarShowTextKeyboard() {
        UIMenuController.shared.menuItems = []
        self.moreView.isHidden = true
        self.emotionView.isHidden = true
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func chatBarShowVoice() {
        self.moreView.isHidden = true
        self.emotionView.isHidden = true
        updateInputViewBottomOf(0)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    //语音按钮状态
    func chatBarVoiceLongTap(longTap: UILongPressGestureRecognizer) {
      
        if longTap.state == .began {    // 长按开始
            
            if !isRecordOutTime {
                
                finishRecordingVoice = true
                recordVoiceView.recording()
                // 开始录音
                recordHelper.startRecordingWithPath(recordHelper.getRecorderPath()) {
                    
                }
            }
        } else if longTap.state == .changed {   // 长按平移
            
            if !isRecordOutTime {
                
                let point = longTap.location(in: self.recordVoiceView)
                if recordVoiceView.point(inside: point, with: nil) {
                    recordVoiceView.slideToCancelRecord()
                    finishRecordingVoice = false
                } else {
                    recordVoiceView.recording()
                    finishRecordingVoice = true
                }
            }
            
        } else if longTap.state == .ended { // 长按结束
            
            if !isRecordOutTime {
                
                if finishRecordingVoice {
                    // 停止录音
                    recordHelper.finishRecordingCompletion()
                    
                    if (recordHelper.recordDuration! as NSString).floatValue < 1  {
                        self.noticeOnlyText("说话时间太短")
                    }else {
                        let data = try! Data(contentsOf: URL(fileURLWithPath: recordHelper.recordPath!))
                        send(voiceData: data, duration: Double(recordHelper.recordDuration!)!)
                    }
                } else {
                    // 取消录音
                    recordHelper.stopRecord()
                }
                recordVoiceView.endRecord()
            }else {
                isRecordOutTime = false
            }
        }
    }
    
    //IMUIVoiceHelperDelegate
    //超过录音最大时间的回调
    func beyondLimit(_ time: TimeInterval) {
        
        isRecordOutTime = true
        recordVoiceView.endRecord()
        recordHelper.finishRecordingCompletion()
        let data = try! Data(contentsOf: URL(fileURLWithPath: recordHelper.recordPath!))
        send(voiceData: data, duration: Double(recordHelper.recordDuration!)!)
        myInputView.replaceRecordBtnUI(isRecording: false)
    }
    
    //录音分贝大小 -40 ～ 0
    func getPeakPower(power: Float, countdown: Int) {
        
        //音量大小
        var p = -power
        p = p > 30 ? 30 : p
        p = p <= 0 ? 0 : p
        p = (30 - p)/30 * 7
        
        recordVoiceView.updateMetersValue(p)
        
        //倒计时
        recordVoiceView.updateCountdown(value: countdown, maxValue: Int(recordHelper.maxRecordTime))
    }
    
    //IMMoreViewDelegate
    func chatBarShowEmotionKeyboard() {
       
        self.moreView.isHidden = true
        self.emotionView.isHidden = false
        updateInputViewBottomOf(-216)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func chatBarShowMoreKeyboard() {
        
        self.moreView.isHidden = false
        self.emotionView.isHidden = true
        updateInputViewBottomOf(-90)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func chatBarSendMessage() {
        let msg = myInputView.inputTextView.getEmotionString()
        AppLog(msg)
        
        if msg != "" {
            myInputView.inputTextView.text = ""
            send(forText: msg)
        }
    }
    
    func chatBarUpdateHeight(height: CGFloat) {
        myInputView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
    }
    
    //IMMoreViewDelegate
    func moreView(moreView: IMMoreView, didSeletedType type: IMMoreType){
        
        switch type {
            
        case .order:
            let vc = PurchaseViewController()
            vc.isSecondSearch = true
            vc.isSendOrder = true
            vc.isChatIn = true
            if let userId = convenUser?.extras?["userId"] as? String {
                if let storeType = convenUser?.extras?["storeType"] as? String {
                    vc.storeId = userId
                    //1:会员；2：品牌商；3：合伙人
                    vc.remoteType = LoginType.init(rawValue: storeType.toInt ?? 1)
                }
            }
                
            vc.sendOrderBlock = {[weak self] (model) in
                self?.send(orderModel:model)
            }
            navigationController?.pushViewController(vc, animated: true)
            
        case .camera:
            let videoRecord = IMUIVideoRecordController()
            videoRecord.endRecordVideoURL = {[weak self] (url) in
                IMUIVideoFileLoader.getVideoCropPicture(videoUrl: url) { (image, duration) in
                    if image != nil {
                        
                        self?.send(videoURL: url , thumbImage: image!, duration: duration)
                    }
                }
            }
            videoRecord.endRecordImage = {[weak self] (image) in
                self?.send(forImage: image)
            }
            present(videoRecord, animated: true, completion: nil)
          
        case .pic:
            let imgPicker = TZImagePickerController(maxImagesCount: 9, columnNumber: 4, delegate: self)
            imgPicker?.allowPickingVideo = false
            
            self.present(imgPicker!, animated: true, completion: nil)
            
        case .location:
            let vc = SelectMapPlaceController()
 
            vc.onDismissback = {[weak self] (plot) in
                
                //获取城市
                var getAreaName = ""
                var getCityName = ""
                var getDistrictName = ""
                //省
                if let areaName = plot?.prov?.name {
                    getAreaName = areaName
                }
                
                //市
                if let cityName = plot?.city?.name {
                    getCityName = cityName
                }
                //区
                if let districtName = plot?.dist?.name {
                    getDistrictName = districtName
                }
                
                var address = getAreaName + getCityName + getDistrictName
                
                if let adr = plot?.address {
                    address = address + adr
                }
                var lon:NSNumber = 0
                if let lonStr = plot?.lon {
                    lon = NSNumber(value: Double(string: lonStr) ?? 0)
                }
                
                var lat:NSNumber = 0
                if let latStr = plot?.lat {
                    lat = NSNumber(value: Double(string: latStr) ?? 0)
                }
                self?.send(address: address, lon: lon, lat: lat)
               
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //IMEmotionViewDelegate
    func emotionView(emotionView: IMEmotionView, didSelectedEmotion emotion: IMEmotion) {

        // 插入表情
        myInputView.inputTextView.insertEmotion(emotion: emotion)
    }
    
    func emotionViewSend(emotionView: IMEmotionView) {
        let msg = myInputView.inputTextView.getEmotionString()
        AppLog(msg)
        
        if msg != "" {
            myInputView.inputTextView.text = ""
            send(forText: msg)
        }
    }
    
}

// MARK:- TZImagePickerControllerDelegate 图片选择器代理
extension ChatMessageController: TZImagePickerControllerDelegate {
    
    //选择图片
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool, infos: [[AnyHashable : Any]]!) {
        
        self.sendImageMessages.removeAll()
        for photo in photos {
            send(forImage: photo)
        }
        
    }
    
    //选择视频
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        
//        TZImageManager.default()?.getVideoOutputPath(with: asset, success: { (outputPath) in
//            if outputPath != nil && outputPath != "" {
//                AppLog(outputPath)
//                let videoUrl = URL(fileURLWithPath: outputPath!)
//                self.send(videoURL: videoUrl, thumbImage: coverImage, duration: asset.duration)
//
//            }
//        }, failure: { (errorMessage, error) in
//            AppLog(errorMessage)
//        })
     
    }
   
}

// MARK: - IMUIMessageMessageCollectionViewDelegate
extension ChatMessageController: IMUIMessageMessageCollectionViewDelegate {
    
    // 自定义试图
    func messageCollectionView(messageCollectionView: UICollectionView, forItemAt: IndexPath, messageModel: IMUIMessageProtocol) -> UICollectionViewCell? {
        if messageModel is MessageEventModel {
            let cellIdentify = MessageEventCollectionViewCell.self.description()
            let cell = messageCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentify, for: forItemAt) as! MessageEventCollectionViewCell
            let message = messageModel as! MessageEventModel
            cell.presentCell(eventText: message.eventText)
            return cell
        } else {
            return nil
        }
        
    }
    
    func messageCollectionView(messageCollectionView: UICollectionView, heightForItemAtIndexPath forItemAt: IndexPath, messageModel: IMUIMessageProtocol) -> NSNumber? {
        if messageModel is MessageEventModel {
            return 40.0
        } else {
            return nil
        }
    }
    
    //点击内容
    func messageCollectionView(didTapMessageBubbleInCell: UICollectionViewCell, model: IMUIMessageProtocol) {
        
        if let md = model as? MyMessageModel {
            if md.jmModel?.contentType == .video {
                let cell = didTapMessageBubbleInCell as! IMUIBaseMessageCell
                if let videoView = cell.bubbleContentView as? IMUIVideoMessageContentView {
                    
                    if let content = md.jmModel?.content as? JMSGVideoContent {
                        content.videoData(progress: { (progress, str) in
                            AppLog("\(progress)")
                            videoView.downloadingProgress(CGFloat(progress))
                            
                        }) { (data, id, error) in
                            if error == nil && data != nil {
                                videoView.downloadingProgress(1)
                                
                                var videoFormat = "MOV"
                                if let valueStr = content.format {
                                    videoFormat = valueStr
                                }
                                IMUIVideoFileLoader.playVideo(data: data!, videoFormat, currentViewController: self)
                            }else {
                                AppLog(error)
                            }
                        }
                    }
                }
                
            }else if md.jmModel?.contentType == .image {
                
                if md.type == .material {
                    
                    if let ex = md.jmModel?.content?.extras {
                        
                        let nameStr = (ex["materialName"] as? String) ?? ""
                        let urlStr = (ex["materialUrl"] as? String) ?? ""
                        let imgStr = (ex["materialImageUrl"] as? String) ?? ""
                        let idStr = (ex["materialsId"] as? String) ?? ""
                        let speStr = (ex["materialSpe"] as? String) ?? ""
                        if speStr.contains("风格") {
                            let tempCaseModel = HouseCaseModel()
                            tempCaseModel.id = idStr
                            tempCaseModel.url = urlStr
                            tempCaseModel.mainImgUrl = imgStr
                            tempCaseModel.caseRemarks = nameStr
                            let vc = WholeHouseDetailController()
                            vc.detailUrl = urlStr
                            vc.caseModel = tempCaseModel
                            navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let material = MaterialsModel()
                            material.name = nameStr
                            material.url = urlStr
                            material.imageUrl = imgStr
                            material.id = idStr
                            let rootVC = MaterialsDetailVC()
                            rootVC.isDismiss = true
                            rootVC.materialsModel = material
                            let vc = BaseNavigationController.init(rootViewController: rootVC)
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        }
                        
                        
                    }else {
                        self.noticeOnlyText("产品信息异常~")
                    }
                    
                }else {
                    let browserImageVC = IMUIImageBrowserController()
                    browserImageVC.imageMessages = imageMessages
                    browserImageVC.currentMessage = md.jmModel
                    browserImageVC.modalPresentationStyle = .overFullScreen
                    present(browserImageVC, animated: true, completion: nil)
                }
                
            }else if md.jmModel?.contentType == .location {
                if let content = md.jmModel?.content as? JMSGLocationContent {
                    
                    let vc = SelectMapPlaceController()
                    vc.isLookMap = true
                    let plot = PlotModel()
                    plot.lon = "\(content.longitude)"
                    plot.lat = "\(content.latitude)"
                    vc.selectPlaceModel = plot
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }else if md.jmModel?.contentType == .text {
                if let content = md.jmModel?.content as? JMSGTextContent {
                   
                    guard let orderId = content.extras?["orderId"] as? String else {
                        return
                    }
                    let vc = PurchaseDetailController()
                    
                    vc.orderId = orderId
                   
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    //长按内容
    func messageCollectionView(beganLongTapMessageBubbleInCell: UICollectionViewCell, model: IMUIMessageProtocol) {
        
        if myInputView.inputTextView.isFirstResponder {
            myInputView.inputTextView.resignFirstResponder()
            return
        }
        
        if let cell = beganLongTapMessageBubbleInCell as? IMUIBaseMessageCell {
            if let md = model as? MyMessageModel {
                longTapMsg = md
                
                cell.becomeFirstResponder()
                let popMenu = UIMenuController.shared
                
                let deleteItem = UIMenuItem.init(title: "删除", action: #selector(deleteAction))

                var items = [deleteItem]
                if md.jmModel?.contentType == .text {
                    let copyItem = UIMenuItem.init(title: "复制", action: #selector(copyAction))
                    items.append(copyItem)
                }
                if md.isOutGoing {
                    let revocationItem = UIMenuItem.init(title: "撤回", action: #selector(revocationAction))
                    items.append(revocationItem)
                }
                
                popMenu.menuItems = items
                popMenu.arrowDirection = .down
                popMenu.setTargetRect(cell.bubbleView.frame, in: cell.contentView)
                popMenu.setMenuVisible(true, animated: true)
            }
        }
    }
    
    //撤回
    @objc func revocationAction() {
        
        if let msg = longTapMsg?.jmModel {
            
            JMSGMessage.retractMessage(msg, completionHandler: { (result, error) in
                DispatchQueue.main.async {
            
                    if error == nil {
                        if (self.messageCollectionView.chatDataManager.allMessageDic[msg.msgId] as? MyMessageModel) != nil {
                            self.messageCollectionView.removeMessage(with: msg.msgId)
                            self.jMessageCount -= 1
                            
                            if let model = result as? JMSGMessage {
                                self.dealwithMessageModel(model)
                            }
                        }
                    } else {
                        self.noticeOnlyText("发送时间超过3分钟，不能撤回")
                    }
                }
            })
        }
        longTapMsg = nil
    }
    
    /// 删除
    @objc func deleteAction() {
        if let msg = longTapMsg?.jmModel {
            if let conver = conversation {
                let delete = conver.deleteMessage(withMessageId: msg.msgId)
                DispatchQueue.main.async {
                    
                    if delete {
                        if (self.messageCollectionView.chatDataManager.allMessageDic[msg.msgId] as? MyMessageModel) != nil {
                            self.messageCollectionView.removeMessage(with: msg.msgId)
                            self.jMessageCount -= 1
                        }
                    }else {
                        self.noticeOnlyText("删除失败")
                    }
                }
            }
        }
        longTapMsg = nil
    }
    
    @objc func copyAction() {
        if let msg = longTapMsg?.jmModel {
            if let content = msg.content as? JMSGTextContent {
                let pas = UIPasteboard.general
                pas.string = content.text
            }
        }
        longTapMsg = nil
    }
    
    //点击头像
    func messageCollectionView(didTapHeaderImageInCell: UICollectionViewCell, model: IMUIMessageProtocol) {
        
        if let md = model as? MyMessageModel {
            
            if let jmd = md.jmModel {
                
                let vc = ChatUserInfoController()
                
                if jmd.isReceived {
                    vc.userInfo = convenUser
                }else {
                    vc.userInfo = JMSGUser.myInfo()
                }
                
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //点击失败状态试图
    func messageCollectionView(didTapStatusViewInCell: UICollectionViewCell, model: IMUIMessageProtocol) {
        
        if let md = model as? MyMessageModel {
            if md.messageStatus == .failed {
                if let content = md.jmModel?.content {
                    
                     if let conver = conversation {
                        
                        let delete = conver.deleteMessage(withMessageId: md.jmModel!.msgId)
                        DispatchQueue.main.async {
                            
                            if delete {
                                
                                self.messageCollectionView.removeMessage(with: md.msgId)
                                self.jMessageCount -= 1
                                let massage = JMSGMessage.createSingleMessage(with: content, username: self.currentUser.username)
                                md.msgId = massage.msgId
                                md.jmModel = massage
                                md.messageStatus = .sending
                                self.send(massage, md)
                            }
                        }
                    }
                    
                }
            }
        }
        
    }
    
    //单元格将要显示
    func messageCollectionView(_: UICollectionView, willDisplayMessageCell: UICollectionViewCell, forItemAt: IndexPath, model: IMUIMessageProtocol) {
        
    }
    
    //单元格结束显示
    func messageCollectionView(_: UICollectionView, didEndDisplaying: UICollectionViewCell, forItemAt: IndexPath, model: IMUIMessageProtocol) {
        
    }
    
    //试图开始拖拽
    func messageCollectionView(_ willBeginDragging: UICollectionView) {

    }
 
    //单击事件
    @objc func tapAction() {
        
        myInputView.resetBtnsUI()
        if myInputView.inputTextView.isFirstResponder {
            myInputView.inputTextView.resignFirstResponder()
        }
        
        self.moreView.isHidden = true
        self.emotionView.isHidden = true
        updateInputViewBottomOf(0)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
