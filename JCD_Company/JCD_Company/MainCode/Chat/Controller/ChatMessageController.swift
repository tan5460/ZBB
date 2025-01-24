//
//  ChatMessageController.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/5.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Photos
import IQKeyboardManagerSwift
import ObjectMapper
import MobileCoreServices
import AVFoundation
import MJRefresh
import Kingfisher

class ChatMessageController: BaseViewController {

    open var conversation: JMSGConversation?
    var materialModel: MaterialsModel?
    var caseModel: HouseCaseModel?
        
    fileprivate var isGroup = false
    
    var userName:String = ""
    
    var sendImageMessages:[JMSGMessage] = []
    
    var imageMessages:[JMSGMessage] = []
    
    var longTapMsg:MyMessageModel?
    
    fileprivate var maxTime = 0
    fileprivate var minTime = 0
    
    var jMessageCount = 0
    
    fileprivate var messagePage = 0
    
    let currentUser = JMSGUser.myInfo()
    
    var convenUser: JMSGUser?
    
    var finishRecordingVoice: Bool = true   // 决定是否停止录音还是取消录音
    
    var isRecordOutTime = false             //录音超时
    
    // MARK: 消息列表
    lazy var messageCollectionView: IMUIMessageCollectionView = {
        let messageView:IMUIMessageCollectionView = IMUIMessageCollectionView()
        messageView.backgroundColor = PublicColor.backgroundViewColor
        messageView.delegate = self
        messageView.messageCollectionView.register(MessageEventCollectionViewCell.self, forCellWithReuseIdentifier: MessageEventCollectionViewCell.self.description())
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(onPullToFresh))
        header.stateLabel?.isHidden = true
        messageView.messageCollectionView.mj_header = header
 
        messageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction)))
        return messageView
    }()
    
    // MARK: 输入栏
    lazy var myInputView: IMInputView = {
        let inputView: IMInputView = IMInputView()
        inputView.delegate = self
        return inputView
    }()

    // MARK: 表情面板
    lazy var emotionView: IMEmotionView = {
        let emotionV = IMEmotionView()
        emotionV.isHidden = true
        emotionV.delegate = self
        return emotionV
        }()
    // MARK: 更多面板
    lazy var moreView: IMMoreView = {
        let moreV: IMMoreView = IMMoreView()
        moreV.isHidden = true
        moreV.delegate = self
        return moreV
    }()
    
    // MARK: 录音视图
    lazy var recordVoiceView: IMVoiceView = {
        let recordVoiceV = IMVoiceView()
        recordVoiceV.isHidden = true
        return recordVoiceV
    }()
    
    //录音
    lazy var recordHelper: IMUIRecordVoiceHelper = {
        let recordHelper = IMUIRecordVoiceHelper()
        recordHelper.delegate = self
        return recordHelper
    }()
    
    //图片选择
//    lazy var imgPickerVC: TZImagePickerController = {
//        let imgPicker = TZImagePickerController(maxImagesCount: 9, columnNumber: 4, delegate: self)
//        imgPicker?.allowPickingVideo = false
//        return imgPicker!
//    }()
    
    //MARK - life cycle
    public required init(conversation: JMSGConversation) {
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
        automaticallyAdjustsScrollViewInsets = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // 监听键盘
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendingMaterialAction), name: Notification.Name.init("SendingMaterial"), object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //键盘
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 7 // 输入框距离键盘的距离
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        if UIMenuController.shared.isMenuVisible {
            
            UIMenuController.shared.setMenuVisible(false, animated: true)
        }
        navigationController?.navigationBar.isTranslucent = true
    }
  
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //键盘
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 50 // 输入框距离键盘的距离
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>> 聊天界面释放 <<<<<<<<<<<<<<")
        NotificationCenter.default.removeObserver(self)
        JMessage.remove(self, with: conversation)
    }
    
    //MARK: 视图创建
    private func setupNavigationItem() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Chat_userInfo"), style: .plain, target: self, action: #selector(userInfoAction))
        
        let titleView = UIView.init(frame: CGRect(x: 0, y: 0, width: PublicSize.screenWidth*2/3, height: 44))
        navigationItem.titleView = titleView
        
        let plusNameLabel = UILabel()
        plusNameLabel.textColor = PublicColor.commonTextColor
        plusNameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        plusNameLabel.textAlignment = .center
        plusNameLabel.text = " "
        titleView.addSubview(plusNameLabel)
        
        plusNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.centerX.width.equalToSuperview()
        }
        
        let customNameLabel = UILabel()
        customNameLabel.textColor = PublicColor.minorTextColor
        customNameLabel.font = UIFont.systemFont(ofSize: 12)
        customNameLabel.textAlignment = .center
        customNameLabel.text = " "
        titleView.addSubview(customNameLabel)
        
        customNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(plusNameLabel.snp.bottom).offset(3)
            make.centerX.width.equalToSuperview()
            make.bottom.equalTo(-5)
        }
        
        if let user = convenUser {
            
            plusNameLabel.text = user.displayName()
            if let detailTitle = user.extras?["detailTitle"] as? String {
                customNameLabel.text = detailTitle
            }
        }
        
    }
    
    private func setupUI() {
        
        setupNavigationItem()
        
        if let conver = conversation {
            if let draftStr = JCDraft.getDraft(conver) {
                if draftStr != "" {
                   
                   myInputView.inputTextView.attributedText = IMFindEmotion.findAttrStr(text: draftStr, font: UIFont.systemFont(ofSize: 15))
                }
            }
            if let user = conver.target as? JMSGUser {
                userName = user.username
            }
            isGroup = conver.ex.isGroup
            loadAllMessage()
        }

        view.backgroundColor = .white
        JMessage.add(self, with: conversation)
        
        self.automaticallyAdjustsScrollViewInsets = false
        view.addSubview(messageCollectionView)
        messageCollectionView.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
        }
        
        view.addSubview(myInputView)
        
        let height = myInputView.getTextViewHeight(myInputView.inputTextView,PublicSize.screenWidth - 129)
        myInputView.snp.makeConstraints { (make) in
            make.top.equalTo(messageCollectionView.snp.bottom)
            make.height.equalTo(height)
            make.right.left.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        view.addSubview(moreView)
        moreView.snp.makeConstraints { (make) in
            make.top.equalTo(myInputView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(90)
        }

        view.addSubview(emotionView)
        emotionView.snp.makeConstraints { (make) in
            make.top.equalTo(myInputView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(216)
        }
        
        view.addSubview(recordVoiceView)
        recordVoiceView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.bottom.equalToSuperview().offset(-100)
            make.left.right.equalToSuperview()
        }
        
        if let storeType = convenUser?.extras?["storeType"] as? String {
            
            if storeType == "4" || UserData.shared.userType == .jzgs {
                moreView.isNoOrder = true
            }
        }
    }
  
    @objc func backAction() {
        
        if let conver = conversation {
            conver.clearUnreadCount()
            JCDraft.update(text: myInputView.inputTextView.getEmotionString(), conversation: conver)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func userInfoAction() {
        
        let vc = ChatUserInfoController()
        vc.userInfo = convenUser
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK:请求当前所有消息
    
    @objc func onPullToFresh() {
        messagePage += 1
        loadAllMessage()
    }
    
    func loadAllMessage() {
        if conversation == nil {return}
//        YZBChatRequest.shared.getAllMessage(conversation: conversation!) { (massages, error) in
//            if error == nil {
//
//                for model in massages.reversed() {
//                   self.dealwithMessageModel(model,.success)
//                }
//            }
//        }
        let msgs = conversation?.messageArrayFromNewest(withOffset: NSNumber(value: jMessageCount), limit: NSNumber(value: 20))
        messageCollectionView.messageCollectionView.mj_header?.endRefreshing()
        
        if msgs?.count == 0 {
            messagePage -= 1
            if materialModel != nil {
                createMaterialMsg()
            } else if caseModel != nil {
                createCaseMsg()
            }
            
            return
        }
        
        if messagePage == 0 {
            
            for model in msgs!.reversed() {
                self.dealwithMessageModel(model)
            }
            if materialModel != nil {
                createMaterialMsg()
            } else if caseModel != nil {
                createCaseMsg()
            }
        }else {
            for model in msgs! {
                self.dealwithMessageModel(model, isInsert:true)
            }
        }
    }
    
    //处理消息model
    func dealwithMessageModel(_ model: JMSGMessage, isUpdata: Bool = false, isInsert: Bool = false) {
        
        let isShowTime = isNeedInsertTimeLine(model.timestamp.intValue)
        
        if !isUpdata {
            jMessageCount += 1
        }
        
        var status: IMUIMessageStatus = .success
        if model.status == .sendFailed || model.status == .sendUploadFailed {
            status = .failed
        }else if model.status == .sending {
            status = .sending
        }
        
        //不管什么类型的消息，先创建占位单元格，防止乱序
        if !isUpdata {
            let message = MyMessageModel(msgModel: model, text: " ", isOutGoing: !model.isReceived, isNeedShowTime: isShowTime)
            message.messageStatus = status
            if isInsert {
                messageCollectionView.insertMessage(with: message)
            }else {
                messageCollectionView.appendMessage(with: message)
            }
        }
        
        switch model.contentType {
        case .text:
            
            if let content = model.content as? JMSGTextContent {
                
                var message = MyMessageModel(msgModel:model, text: content.text, isOutGoing: !model.isReceived, isNeedShowTime:isShowTime)
                if (content.extras?["orderId"] as? String) != nil  {
                    var state = ""
                    if let value = content.extras?["orderStatus"] as? String {
                        state = value
                    }
                    message = MyMessageModel(msgModel:model, orderText: content.text, state:state,isOutGoing: !model.isReceived,isNeedShowTime:isShowTime)
                }
                message.messageStatus = status
                
                if isInsert {
                    self.messageCollectionView.updateInsertMessage(with: message)
                }else {
                    self.messageCollectionView.updateMessage(with: message)
                }
                
//                if isUpdata {
//                    self.messageCollectionView.updateMessage(with: message)
//                }else {
//                    if isInsert {
//                         self.messageCollectionView.insertMessage(with: message)
//                    }else {
//                        self.messageCollectionView.appendMessage(with: message)
//                    }
//                }
            }
            
        case .voice:
            
            if let content = model.content as? JMSGVoiceContent {
                content.voiceData { (data, objectId, error) in
                
                    if error == nil && data != nil {
                       
                        let message = MyMessageModel(msgModel:model, voicePath: "",voiceData:data!, duration: CGFloat(truncating: content.duration), isOutGoing: !model.isReceived,isNeedShowTime:isShowTime)
                       
                        message.messageStatus = status
                        
                        if isInsert {
                            self.messageCollectionView.updateInsertMessage(with: message)
                        }else {
                            self.messageCollectionView.updateMessage(with: message)
                        }
                    }
                }
            }
            
        case .image:
            imageMessages.append(model)
            if let content = model.content as? JMSGImageContent {
                if let image = content.thumbImageLocalPath {
                    
                    let message = MyMessageModel(msgModel:model, imagePath: image,imageData:nil, isOutGoing: !model.isReceived,isNeedShowTime:isShowTime)
                    message.messageStatus = status
                    
                    if isInsert {
                        self.messageCollectionView.updateInsertMessage(with: message)
                    }else {
                        self.messageCollectionView.updateMessage(with: message)
                    }
            
                }else {
                    content.thumbImageData { (data, objectId, error) in
                        if error == nil && data != nil {
                            
                            let message = MyMessageModel(msgModel:model, imagePath: "",imageData:data, isOutGoing: !model.isReceived,isNeedShowTime:isShowTime)
                            message.messageStatus = status
                            
                            if isInsert {
                                self.messageCollectionView.updateInsertMessage(with: message)
                            }else {
                                self.messageCollectionView.updateMessage(with: message)
                            }
                        }
                    }
                }

            }

        case .location:
            if let content = model.content as? JMSGLocationContent {
                
                let message = MyMessageModel(msgModel: model, addrsess: content.address, addressImagePath: "", addressImageData: nil, isOutGoing: !model.isReceived,isNeedShowTime:isShowTime)
                
                message.messageStatus = status
                
                if isInsert {
                    self.messageCollectionView.updateInsertMessage(with: message)
                }else {
                    self.messageCollectionView.updateMessage(with: message)
                }
            }
            
        case .video:
            if let content = model.content as? JMSGVideoContent {
                if let videoThumbImage = content.videoThumbImageLocalPath {
                    
                    let image = UIImage(contentsOfFile: videoThumbImage)
                    
                    let message = MyMessageModel(msgModel: model, videoPath: "", imageData: image?.jpegRepresentationData, duration:CGFloat(truncating: content.duration), isOutGoing: !model.isReceived, isNeedShowTime: isShowTime)
                    message.messageStatus = status
                    
                    if isInsert {
                        self.messageCollectionView.updateInsertMessage(with: message)
                    }else {
                        self.messageCollectionView.updateMessage(with: message)
                    }
                }else {
                    content.videoThumbImageData { (data, objectId, error) in
                        
                        if error == nil && data != nil {
                            
                            let message = MyMessageModel(msgModel:model, videoPath: "", imageData: data,duration:CGFloat(truncating: content.duration), isOutGoing: !model.isReceived,isNeedShowTime:isShowTime)
                            message.messageStatus = status
                            
                            if isInsert {
                                self.messageCollectionView.updateInsertMessage(with: message)
                            }else {
                                self.messageCollectionView.updateMessage(with: message)
                            }
                        }
                    }
                }
              
            }
        case .prompt:
            
            if let content = model.content as? JMSGPromptContent {
                if content.promptType == .retractMessage {
                    let message = MessageEventModel(msgId: model.msgId, eventText: content.promptText)
                    
                    if isInsert {
                        self.messageCollectionView.updateInsertMessage(with: message)
                    }else {
                        self.messageCollectionView.updateMessage(with: message)
                    }
                }
            }
            
        default: break
        }
 
        if model.isReceived && !model.isHaveRead{
            
            model.setMessageHaveRead { (resultObject, error) in
                AppLog("发送已读回执" + ((error != nil) ? "失败" : "成功") )
            }
            
        }
    }
    
    func createMaterialMsg(isSendMsg: Bool = false) {
        
        if let material = materialModel {
            
            guard let imgStr = material.imageUrl else {
                return
            }
            guard let nameStr = material.name else {
                return
            }
            guard let urlStr = material.url else {
                return
            }
            guard let materialId = material.id else {
                return
            }
            
            let speStr = "规格: \(material.yzbSpecification?.name ?? "无")"
            let imageUrl = URL(string: APIURL.ossPicUrl + imgStr)!
            
            KingfisherManager.shared.retrieveImage(with: imageUrl, options: nil, progressBlock: nil) { image, error, cacheType, imageURL in
                if error == nil && image != nil {
                    
                    if let data = image?.jpegRepresentationData {
                        
                        let imageContent = JMSGImageContent.init(imageData: data)
                        
                        let msg = JMSGMessage.createSingleMessage(with: imageContent!, username: self.currentUser.username)
                        
                        msg.content?.addStringExtra(nameStr, forKey: "materialName")
                        msg.content?.addStringExtra(speStr, forKey: "materialSpe")
                        msg.content?.addStringExtra(urlStr, forKey: "materialUrl")
                        msg.content?.addStringExtra(imgStr, forKey: "materialImageUrl")
                        msg.content?.addStringExtra(materialId, forKey: "materialsId")
                        
                        if isSendMsg {
                            msg.content?.addNumberExtra(0, forKey: "isLocalImg")
                        }else {
                            msg.content?.addNumberExtra(1, forKey: "isLocalImg")
                        }
                        
                        let isShowTime = self.isNeedInsertTimeLine(msg.timestamp.intValue)
                        self.sendImageMessages.append(msg)
                        self.imageMessages.append(msg)
                        
                        let sendMessage = MyMessageModel(msgModel:msg, imagePath: "", imageData: data, isOutGoing: true, isNeedShowTime: isShowTime, isNewMsg: false)
                        sendMessage.messageStatus = .success
                        
                        if isSendMsg {
                            self.send(msg, sendMessage)
                        }else {
                            self.messageCollectionView.appendMessage(with: sendMessage)
                        }
                    }
                } else {
                    AppLog(error)
                }
            }
            
//            KingfisherManager.shared.retrieveImage(with: ImageResource.init(downloadURL: imageUrl ?? URL.init(string: "https://baidu.com/")!), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
//                
//                if error == nil && image != nil {
//                    
//                    if let data = image?.jpegRepresentationData {
//                        
//                        let imageContent = JMSGImageContent.init(imageData: data)
//                        
//                        let msg = JMSGMessage.createSingleMessage(with: imageContent!, username: self.currentUser.username)
//                        
//                        msg.content?.addStringExtra(nameStr, forKey: "materialName")
//                        msg.content?.addStringExtra(speStr, forKey: "materialSpe")
//                        msg.content?.addStringExtra(urlStr, forKey: "materialUrl")
//                        msg.content?.addStringExtra(imgStr, forKey: "materialImageUrl")
//                        msg.content?.addStringExtra(materialId, forKey: "materialsId")
//                        
//                        if isSendMsg {
//                            msg.content?.addNumberExtra(0, forKey: "isLocalImg")
//                        }else {
//                            msg.content?.addNumberExtra(1, forKey: "isLocalImg")
//                        }
//                        
//                        let isShowTime = self.isNeedInsertTimeLine(msg.timestamp.intValue)
//                        self.sendImageMessages.append(msg)
//                        self.imageMessages.append(msg)
//                        
//                        let sendMessage = MyMessageModel(msgModel:msg, imagePath: "", imageData: data, isOutGoing: true, isNeedShowTime: isShowTime, isNewMsg: false)
//                        sendMessage.messageStatus = .success
//                        
//                        if isSendMsg {
//                            self.send(msg, sendMessage)
//                        }else {
//                            self.messageCollectionView.appendMessage(with: sendMessage)
//                        }
//                    }
//                } else {
//                    AppLog(error)
//                }
//            }
        }
    }
    
    func createCaseMsg(isSendMsg: Bool = false) {
        
        if let model = caseModel {
            
            guard let imgStr = model.mainImgUrl1 else {
                return
            }
            guard let nameStr = model.caseRemarks else {
                return
            }
            guard let urlStr = model.url else {
                return
            }
            guard let materialId = model.id else {
                return
            }
            
            let speStr = "风格: \(model.caseStyleName ?? "无")"
            let imageUrl = URL(string: APIURL.ossPicUrl + imgStr)!
            
            KingfisherManager.shared.retrieveImage(with: imageUrl, options: nil, progressBlock: nil) { image, error, cacheType, imageURL in
                if error == nil && image != nil {
                    
                    if let data = image?.jpegRepresentationData {
                        
                        let imageContent = JMSGImageContent.init(imageData: data)
                        
                        let msg = JMSGMessage.createSingleMessage(with: imageContent!, username: self.currentUser.username)
                        
                        msg.content?.addStringExtra(nameStr, forKey: "materialName")
                        msg.content?.addStringExtra(speStr, forKey: "materialSpe")
                        msg.content?.addStringExtra(urlStr, forKey: "materialUrl")
                        msg.content?.addStringExtra(imgStr, forKey: "materialImageUrl")
                        msg.content?.addStringExtra(materialId, forKey: "materialsId")
                        
                        if isSendMsg {
                            msg.content?.addNumberExtra(0, forKey: "isLocalImg")
                        }else {
                            msg.content?.addNumberExtra(1, forKey: "isLocalImg")
                        }
                        
                        let isShowTime = self.isNeedInsertTimeLine(msg.timestamp.intValue)
                        self.sendImageMessages.append(msg)
                        self.imageMessages.append(msg)
                        
                        let sendMessage = MyMessageModel(msgModel:msg, imagePath: "", imageData: data, isOutGoing: true, isNeedShowTime: isShowTime, isNewMsg: false)
                        sendMessage.messageStatus = .success
                        
                        if isSendMsg {
                            self.send(msg, sendMessage)
                        }else {
                            self.messageCollectionView.appendMessage(with: sendMessage)
                        }
                    }
                } else {
                    AppLog(error)
                }
            }
            
//            KingfisherManager.shared.retrieveImage(with: ImageResource.init(downloadURL: imageUrl), options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
//                
//                if error == nil && image != nil {
//                    
//                    if let data = image?.jpegRepresentationData {
//                        
//                        let imageContent = JMSGImageContent.init(imageData: data)
//                        
//                        let msg = JMSGMessage.createSingleMessage(with: imageContent!, username: self.currentUser.username)
//                        
//                        msg.content?.addStringExtra(nameStr, forKey: "materialName")
//                        msg.content?.addStringExtra(speStr, forKey: "materialSpe")
//                        msg.content?.addStringExtra(urlStr, forKey: "materialUrl")
//                        msg.content?.addStringExtra(imgStr, forKey: "materialImageUrl")
//                        msg.content?.addStringExtra(materialId, forKey: "materialsId")
//                        
//                        if isSendMsg {
//                            msg.content?.addNumberExtra(0, forKey: "isLocalImg")
//                        }else {
//                            msg.content?.addNumberExtra(1, forKey: "isLocalImg")
//                        }
//                        
//                        let isShowTime = self.isNeedInsertTimeLine(msg.timestamp.intValue)
//                        self.sendImageMessages.append(msg)
//                        self.imageMessages.append(msg)
//                        
//                        let sendMessage = MyMessageModel(msgModel:msg, imagePath: "", imageData: data, isOutGoing: true, isNeedShowTime: isShowTime, isNewMsg: false)
//                        sendMessage.messageStatus = .success
//                        
//                        if isSendMsg {
//                            self.send(msg, sendMessage)
//                        }else {
//                            self.messageCollectionView.appendMessage(with: sendMessage)
//                        }
//                    }
//                } else {
//                    AppLog(error)
//                }
//            }
        }
    }
 
    private func isNeedInsertTimeLine(_ time: Int) -> Bool {
        if maxTime == 0 || minTime == 0 {
            maxTime = time
            minTime = time
            return true
        }
        if (time - maxTime) >= 5 * 60000 {
            maxTime = time
            return true
        }
        if (minTime - time) >= 5 * 60000 {
            minTime = time
            return true
        }
        return false
    }
  
    // MARK: - send message
    func send(_ jMessage:JMSGMessage,_ mMessage:MyMessageModel) {
       
        jMessageCount += 1
        
        let optionalContent = JMSGOptionalContent()
        
        optionalContent.needReadReceipt = true
        
//        jMessage.getUnreadCount()
        
        conversation?.send(jMessage, optionalContent: optionalContent)
        
        self.messageCollectionView.appendMessage(with: mMessage)
    }
    
    //发送文字
    func send(forText text: String) {
   
        let textContent = JMSGTextContent.init(text: text)
        
        let msg = JMSGMessage.createSingleMessage(with: textContent, username: currentUser.username)

        let isShowTime = isNeedInsertTimeLine(msg.timestamp.intValue)
        
        let sendMessage = MyMessageModel(msgModel:msg, text:text, isOutGoing: true,isNeedShowTime:isShowTime,isNewMsg:true)
        sendMessage.messageStatus = .sending
       
        send(msg, sendMessage)
    }
    
    //发送订单
    func send(orderModel: PurchaseOrderModel) {
        
        var text = "订单号: "
        if let valueStr = orderModel.orderNo {
            text += valueStr
        }
        
        text += "\n" + "时间: "
        text += orderModel.orderTime ?? ""
        
        text += "\n" + "收货人: "
        if let valueStr = orderModel.contact {
            text += valueStr
        }
        
        text += "\n" + "电话: "
        if let valueStr = orderModel.tel {
            text += valueStr
        }
        text += "\n" + "地址: "
        if let valueStr = orderModel.address {
            text += valueStr
        }
        
        let textContent = JMSGTextContent.init(text: text)
        var orderId = ""
        if let valueStr = orderModel.id {
            orderId = valueStr
        }
        textContent.addStringExtra(orderId, forKey: "orderId")
        
        var orderStatus = ""
        if let valueStr = orderModel.orderStatus?.stringValue {
            orderStatus = valueStr
        }
//        textContent.addStringExtra(orderStatus, forKey: "orderStatus")
        
        let msg = JMSGMessage.createSingleMessage(with: textContent, username: currentUser.username)
        
        let isShowTime = isNeedInsertTimeLine(msg.timestamp.intValue)
        
        let sendMessage = MyMessageModel(msgModel: msg, orderText: text,state: orderStatus, isOutGoing: true,isNeedShowTime:isShowTime,isNewMsg:true)
        sendMessage.messageStatus = .sending

        send(msg, sendMessage)
    }
    
    //发送图片
    func send(forImage image: UIImage) {
        
        if let data = image.jpegRepresentationData {
            
            let imageContent = JMSGImageContent.init(imageData: data)
            
            let msg = JMSGMessage.createSingleMessage(with: imageContent!, username: currentUser.username)
            
            let isShowTime = isNeedInsertTimeLine(msg.timestamp.intValue)
            
            sendImageMessages.append(msg)
            
            imageMessages.append(msg)
            
            let sendMessage = MyMessageModel(msgModel: msg, imagePath: "", imageData: data, isOutGoing: true, isNeedShowTime: isShowTime, isNewMsg: true)
            sendMessage.messageStatus = .sending

            send(msg, sendMessage)
        }
    }
    
    /// 发送主材
    @objc func sendingMaterialAction(noti : Notification) {
        if materialModel != nil {
            createMaterialMsg(isSendMsg: true)
        } else if caseModel != nil {
            createCaseMsg(isSendMsg: true)
        }
        
    }
    
    //发送语音
    func send(voiceData: Data, duration: Double) {

        let voiceContent = JMSGVoiceContent.init(voiceData: voiceData, voiceDuration: NSNumber(value: duration))
        
        let msg = JMSGMessage.createSingleMessage(with: voiceContent, username: currentUser.username)
      
        let isShowTime = isNeedInsertTimeLine(msg.timestamp.intValue)
        
        let sendMessage = MyMessageModel(msgModel:msg, voicePath: "",voiceData:voiceData, duration: CGFloat(duration), isOutGoing: true,isNeedShowTime:isShowTime,isNewMsg:true)
        sendMessage.messageStatus = .sending
        
        send(msg, sendMessage)
    }
    
    //发送视频
    func send(videoURL: URL,thumbImage:UIImage ,duration: Double) {
        
        let data = try! Data(contentsOf: videoURL)
 
        let imgData = thumbImage.jpegRepresentationData
        
        let videoContent = JMSGVideoContent.init(videoData: data, thumbData: imgData, duration: NSNumber(value: duration))
        videoContent.format = "MOV"
       
        let date = Date()
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = formatter.string(from: date)
        videoContent.fileName = fileName
        
        let msg = JMSGMessage.createSingleMessage(with: videoContent, username: currentUser.username)
        
        let isShowTime = isNeedInsertTimeLine(msg.timestamp.intValue)
        
        let sendMessage = MyMessageModel(msgModel:msg, videoPath: videoURL.absoluteString, imageData: imgData, duration:CGFloat(duration),isOutGoing: true,isNeedShowTime:isShowTime,isNewMsg:true)
        sendMessage.messageStatus = .sending

        send(msg, sendMessage)
    }
   
    func send(address: String, lon: NSNumber, lat: NSNumber) {
        
        let locationContent = JMSGLocationContent.init(latitude: lat, longitude: lon, scale: 1, address: address)
        
        let msg = JMSGMessage.createSingleMessage(with: locationContent, username: currentUser.username)
        
        let isShowTime = isNeedInsertTimeLine(msg.timestamp.intValue)
        
        let sendMessage = MyMessageModel(msgModel: msg, addrsess: address, addressImagePath: "", addressImageData: nil, isOutGoing: true,isNeedShowTime:isShowTime,isNewMsg:true)
        sendMessage.messageStatus = .sending
        
        send(msg, sendMessage)
    }
    
    //该方法表示屏幕边缘的手势动作（Screen Edge Gesture），一般来说都是由系统管理的，在控制器下重写这个方法，可以让自己的手势优先被调用。
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return UIRectEdge.bottom
    }
    
}

// MARK:- 键盘监听事件
extension ChatMessageController {
    @objc fileprivate func keyboardWillHide(_ note: NSNotification) {
        if myInputView.keyboardType == .emotion || myInputView.keyboardType == .more {
            return
        }
        updateInputViewBottomOf(0)
    }
    
    @objc fileprivate func keyboardFrameWillChange(_ note: NSNotification) {
        if myInputView.keyboardType == .emotion || myInputView.keyboardType == .more {
            return
        }
        let keyboardFrame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect?
        let h = keyboardFrame?.size.height ?? 0.0
        updateInputViewBottomOf(-h)
    }
}
