//
//  ZBBCreditAuthPhotoItemView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit
import SKPhotoBrowser
import IQKeyboardManagerSwift

class ZBBCreditAuthPhotoItemView: UIView {
    
    ///是否必填
    var isRequried: Bool {
        set {
            requiredLabel.isHidden = !newValue
        }
        get {
            !requiredLabel.isHidden
        }
    }
    
    ///标题
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            titleLabel.text
        }
    }
    
    ///是否可编辑
    var isEditable: Bool = true
    
    var hideSeparatorLine: Bool {
        set {
            separatorLine.isHidden = newValue
        }
        get {
            separatorLine.isHidden
        }
    }
    
    ///
    var maxCount = 1 {
        didSet {
            if isEditable {
                if imageURLs.count > maxCount {
                    imageURLs = Array(imageURLs[0..<maxCount])
                }
                refreshViews()
            }
        }
    }
    
    var imageURLs = [String]() {
        didSet {
            refreshViews()
        }
    }

    private var requiredLabel: UILabel!
    private var titleLabel: UILabel!
    private var contentView: UIView!
    private var separatorLine: UIView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
        refreshViews()
    }
    
    private func createViews() {
        backgroundColor = .white
        
        requiredLabel = UILabel()
        requiredLabel.isHidden = true
        requiredLabel.text = "*"
        requiredLabel.font = .systemFont(ofSize: 14)
        requiredLabel.textColor = .hexColor("#FF3C2F")
        addSubview(requiredLabel)
        requiredLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(8)
            make.height.equalTo(20)
        }
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .hexColor("#131313")
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.greaterThanOrEqualTo(20)
        }
        
        contentView = UIView()
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(100)
            make.right.equalTo(-15)
            make.bottom.equalTo(-15)
        }
        
        separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
    
    private func refreshViews() {
        contentView.removeSubviews()
        
        var count = imageURLs.count
        if count < maxCount, isEditable {
            count += 1
        }

        let itemWidth = 60.0
        let maxWidth = SCREEN_WIDTH - 100 - 15
        var x = 0.0
        var y = 0.0
        
        for index in 0 ..< count {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapGestureAction(_:))))
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.top.equalTo(y)
                make.left.equalTo(x)
                make.width.height.equalTo(itemWidth)
                if index == count - 1 {
                    make.bottom.equalTo(0)
                }
            }
            
            if index >= imageURLs.count {
                imageView.image = UIImage(named: "zbbt_sczp")
            } else {
                var url = imageURLs[index]
                if !url.hasPrefix("http") {
                    url = APIURL.ossPicUrl + url
                }
                imageView.kf.setImage(with: URL(string: url), placeholder: UIImage(named: "loading"))
                if isEditable {
                    addDeleteBtn(for: imageView, index: index)
                }
            }
            
            let nextX = x + itemWidth + 10
            if nextX + itemWidth > maxWidth {
                //换行
                x = 0
                y = y + itemWidth + 10
            } else {
                //
                x = nextX
            }
         }
    }
    
    private func addDeleteBtn(for imageView: UIImageView, index: Int) {
        IQKeyboardManager.shared.resignFirstResponder()
        
        let delBtn = UIButton(type: .custom)
        delBtn.tag = 10000 + index
        delBtn.setImage(UIImage(named: "zbbt_photoDel"), for: .normal)
        delBtn.addTarget(self, action: #selector(delBtnAction(_:)), for: .touchUpInside)
        contentView.addSubview(delBtn)
        delBtn.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top).offset(-5)
            make.right.equalTo(imageView.snp.right).offset(5)
            make.width.height.equalTo(25)
        }
    }
    
    @objc private func imageViewTapGestureAction(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        IQKeyboardManager.shared.resignFirstResponder()
        
        let index = contentView.subviews.firstIndex(of: view) ?? 0
        if isEditable, index >= imageURLs.count {
            //上传图片
            let vc = TZImagePickerController(maxImagesCount: maxCount - imageURLs.count, delegate: self)!
            vc.allowTakePicture = true
            vc.allowTakeVideo = false
            vc.allowPickingVideo = false
            getCurrentVC().present(vc, animated: true)
        } else {
            //看大图
            var images = [SKPhoto]()
            for url in imageURLs {
                let photo = SKPhoto.photoWithImageURL(APIURL.ossPicUrl + url, holder: UIImage(named: ""))
                photo.shouldCachePhotoURLImage = true
                images.append(photo)
            }
            SKPhotoBrowserOptions.displayCloseButton = false
            SKPhotoBrowserOptions.displayAction = false
            SKPhotoBrowserOptions.displayBackAndForwardButton = false
            SKPhotoBrowserOptions.enableSingleTapDismiss = true
            SKPhotoBrowserOptions.disableVerticalSwipe = true
            let browser = SKPhotoBrowser(photos: images)
            browser.initializePageIndex(index)
            getCurrentVC().present(browser, animated: true)
        }
    }
    
    @objc private func delBtnAction(_ sender: UIButton) {
        IQKeyboardManager.shared.resignFirstResponder()
        let index = sender.tag - 10000
        imageURLs.remove(at: index)
    }
}

extension ZBBCreditAuthPhotoItemView: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        
        uploadImages(images: photos) {[weak self] url, isEnd in
            if let url = url {
                self?.imageURLs.append(url)
            }
        }
    }
    
    private func uploadImages(images: [UIImage], complete: ((_ url: String?, _ isEnd: Bool) -> Void)?) {
        let image = images.first
        let type = "zbb/auth"
        
        if let image = image {
            var nextImage = images
            nextImage.remove(at: 0)
            YZBSign.shared.upLoadImageRequest(oldUrl: nil, imageType: type, image: image) {[weak self] response in
                let url = response.replacingOccurrences(of: "\"", with: "")
                complete?(url, false)
                self?.uploadImages(images: nextImage, complete: complete)
            } failture: {[weak self] error in
                self?.uploadImages(images: nextImage, complete: complete)
            }
        } else {
            complete?(nil, true)
        }
      
                
    }
}
