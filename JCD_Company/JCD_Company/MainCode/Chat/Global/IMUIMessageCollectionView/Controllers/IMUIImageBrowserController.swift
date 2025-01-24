//
//  IMUIImageBrowserController.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/15.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class IMUIImageBrowserController: BaseViewController {
   
    var imageMessages: [JMSGMessage] = []
    
    var currentMessage: JMSGMessage!
    var imageArr: [URL] = []
    var imgCurrentIndex:Int = 0
    
    var isFirst = true
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        flowLayout.minimumLineSpacing = 0
        let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        colView.backgroundColor = UIColor.clear
        colView.delegate = self
        colView.dataSource = self
        colView.minimumZoomScale = 1
        colView.maximumZoomScale = 3
        colView.isPagingEnabled = true
        colView.register(IMUIImageBrowserCell.self, forCellWithReuseIdentifier: IMUIImageBrowserCell.self.description())
        return colView
    }()
    fileprivate var isMessageType = false
    
    fileprivate var selectImage: UIImage?
    
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isStatusHidden = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isStatusHidden = true
        if imageMessages.count > 0 {
            if let index = imageMessages.firstIndex(where: { (m) -> Bool in
                m.msgId == currentMessage.msgId
            }) {
                imgCurrentIndex = index
            } else {
                imgCurrentIndex = 0
            }
            isMessageType = true
        }
        
        setupImageBrowser()
    
    }
    let countLabel = UILabel().text("1/3").textColor(.white).font(14)
    
    func setupImageBrowser() {
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
//        ZcollectionView.sv(countLabel)
//        collectionView.layout(
//            >=0,
//            countLabel.height(15)-14-|,
//            20+PublicSize.kBottomOffset
//        )
//        countLabel.text("\(imgCurrentIndex+1)/\(imageArr.count)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirst {
            isFirst = false
            collectionView.scrollToItem(at: IndexPath.init(item: imgCurrentIndex, section: 0), at: .left, animated: false)
        }
    }
}

extension IMUIImageBrowserController:UICollectionViewDelegate, UICollectionViewDataSource,IMUIImageBrowserCellDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isMessageType {
            return imageMessages.count
        }
        return imageArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IMUIImageBrowserCell.self.description(), for: indexPath) as! IMUIImageBrowserCell
        if isMessageType {
            cell.setMessage(imageMessages[indexPath.row])
        }else {
            cell.setImage(imageUrl: imageArr[indexPath.row])
        }
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
    }
    
    func singleTap() {
        dismiss(animated: true, completion: nil)
    }
    
    func longTap(tableviewCell cell: IMUIImageBrowserCell) {
        selectImage = cell.messageImage.image
        let actionVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sure = UIAlertAction.init(title: "保存到手机", style: .default, handler: { (sureAction) in
            
            if let image = self.selectImage {
                
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(image:didFinishSavingWithError:contextInfo:)), nil)
            }
            
        })
        
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: { (sureAction) in
            
        })
        
        actionVC.addAction(sure)
        actionVC.addAction(cancel)
        self.present(actionVC, animated: true, completion: nil)
        
    }
    @objc func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafeRawPointer){
        if error == nil {
            self.noticeOnlyText("保存成功")
        } else {
            self.noticeOnlyText("保存失败，请重试")
        }
    }
}
