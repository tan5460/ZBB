//
//  IMUIImageBrowserCell.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/15.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Kingfisher

protocol IMUIImageBrowserCellDelegate: NSObjectProtocol {
    func singleTap()
    func longTap(tableviewCell cell: IMUIImageBrowserCell)
}

class IMUIImageBrowserCell: UICollectionViewCell, UIScrollViewDelegate {
    weak var delegate: IMUIImageBrowserCellDelegate?
    
    lazy var messageImageContent: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = UIScreen.main.bounds
        scrollView.delegate = self
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 1.0
        scrollView.contentSize = scrollView.frame.size
        return scrollView
    }()
    
    lazy var messageImage: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = UIColor.black
        imgView.frame = UIScreen.main.bounds
        imgView.isUserInteractionEnabled = true
        return imgView
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(messageImageContent)
        messageImageContent.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        messageImageContent.addSubview(messageImage)
        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(singleTapImage(_:)))
        singleTapGesture.numberOfTapsRequired = 1
        messageImage.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapImage(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        messageImage.addGestureRecognizer(doubleTapGesture)
        
        singleTapGesture.require(toFail: doubleTapGesture)
        
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTapImage(_:)))
        messageImage.addGestureRecognizer(longTapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    @objc func singleTapImage(_ gestureRecognizer: UITapGestureRecognizer)  {
        delegate?.singleTap()
    }
    
    @objc func doubleTapImage(_ gestureRecognizer: UITapGestureRecognizer) {
        adjustImageScale()
    }
    
    @objc func longTapImage(_ gestureRecognizer: UILongPressGestureRecognizer)  {
        if gestureRecognizer.state == .began {
            delegate?.longTap(tableviewCell: self)
        }
    }
    
    func adjustImageScale() {
        if messageImageContent.zoomScale > 1.5 {
            messageImageContent.setZoomScale(1.0, animated: true)
        } else {
            messageImageContent.setZoomScale(2.0, animated: true)
        }
    }
    
    func setImage(imageUrl: URL) {
        messageImage.kf.setImage(with: imageUrl, placeholder: UIImage.init(named: "loading"))
    }
    
    func setMessage(_ message: JMSGMessage) {
        guard let content = message.content as? JMSGImageContent else {
            return
        }
       
        content.thumbImageData { (data, msgId, error) in
            if msgId == message.msgId {
                if error == nil && data != nil {
                    self.messageImage.image = UIImage(data: data!)
                }
            }
            
            content.largeImageData(progress: nil, completionHandler: { (data, msgId, error) in
                if error == nil {
                    if msgId != message.msgId {
                        return
                    }
                    if data != nil {
                        self.messageImage.image = UIImage(data: data!)
                    }
                }
            })
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return messageImage
    }
}
