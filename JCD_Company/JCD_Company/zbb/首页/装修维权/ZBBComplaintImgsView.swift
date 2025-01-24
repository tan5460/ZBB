//
//  ZBBComplaintImgsView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/4.
//

import UIKit
import SKPhotoBrowser

class ZBBComplaintImgsView: UIView {
    
    private var urls = [String]()

    func refreshViews(urls: [String], totalWidth: CGFloat) {
        self.urls = urls
        
        removeSubviews()
    
        for (index, url) in urls.enumerated() {
            //
            let row = index/4
            let column = index%4
            let itemWidth = (totalWidth - 30)/4
            //
            let imageView = UIImageView()
            imageView.backgroundColor = .hexColor("#F0F0F0")
            imageView.layer.cornerRadius = 4
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.kf.setImage(with: URL(string: APIURL.ossPicUrl + url), placeholder: UIImage(named: "loading"))
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageViewTapGesture(_:))))
            addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.top.equalTo(CGFloat(row)*(itemWidth + 10))
                make.left.equalTo((CGFloat(column)*(itemWidth + 10)))
                make.width.height.equalTo(itemWidth)
                if index == urls.count - 1 {
                    make.bottom.equalTo(0)
                }
            }
        }
    }
    
    @objc private func imageViewTapGesture(_ sender: UITapGestureRecognizer) {
        var images = [SKPhoto]()
        for url in urls {
            let photo = SKPhoto.photoWithImageURL(APIURL.ossPicUrl + url)
            photo.shouldCachePhotoURLImage = true
            images.append(photo)
        }
        let index = subviews.firstIndex(where: {$0 == sender.view}) ?? 0
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
