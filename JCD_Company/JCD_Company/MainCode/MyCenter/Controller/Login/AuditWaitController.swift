//
//  WaitAuditController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/3/15.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit

class AuditWaitController: BaseViewController {
    
    var workerModel: WorkerModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //图标
        let waitImageView = UIImageView()
        waitImageView.image = UIImage.init(named: "complete_wait")
        view.addSubview(waitImageView)
        
        waitImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(80)
            make.width.height.equalTo(100)
        }
        
        //提示语
        let waitTitleLabel = UILabel()
        waitTitleLabel.numberOfLines = 0
        waitTitleLabel.font = UIFont.systemFont(ofSize: 16)
        waitTitleLabel.textColor = PublicColor.placeholderTextColor
        view.addSubview(waitTitleLabel)
        
        waitTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(waitImageView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
        }
        
        var cityMobile = ""
        if let valueStr = workerModel?.cityMobile {
            cityMobile = valueStr
        }
        
        let titleStr = "您的身份正在审核中，请耐心等待！如有疑问请拨打: \(cityMobile)"
        let attributedString = NSMutableAttributedString.init(string: titleStr)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 8
        attributedString.addAttributes([NSAttributedString.Key.paragraphStyle : paragraphStyle], range: NSMakeRange(0, titleStr.count))
        waitTitleLabel.attributedText = attributedString
        
    }

}
