//
//  IMEmotionCell.swift
//  YZB_Company
//
//  Created by liuyi on 2019/1/8.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class IMEmotionCell: UICollectionViewCell {
    // MARK:- 定义属性
    var emotion: IMEmotion? {
        didSet {
            guard let emo = emotion else { return }
            if emo.isRemove {
                emotionImageView.image = UIImage(named: "DeleteEmoticonBtn")
            } else if emo.isEmpty {
                emotionImageView.image = UIImage()
            } else {
                guard let imgPath = emo.imgPath else {
                    return
                }
                emotionImageView.image = UIImage(contentsOfFile: imgPath)
            }
        }
    }
    
    // MARK:- 懒加载
    lazy var emotionImageView: UIImageView = {
        return UIImageView()
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.addSubview(emotionImageView)
        emotionImageView.snp.makeConstraints { (make) in
            make.center.equalTo(self.snp.center)
            make.width.height.equalTo(32)
        }
    }
}
