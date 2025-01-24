//
//  ExportingView.swift
//  YZB_Company
//
//  Created by TanHao on 2017/9/15.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit

class ExportingView: UIView {
    
    var popupView: UIImageView!             //弹窗
    var progressLabel: UILabel!             //百分比
    
    var cancelBlock: (()->())?              //取消导出block
    
    var progress: Float = 0 {
        didSet {
            progressLabel.text = String.init(format: "%.1f%%", progress*100)
        }
    }
    
    deinit {
        AppLog(">>>>>>>>>>>> 导出弹窗释放 <<<<<<<<<<<<")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isHidden = true
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        
        let window = UIApplication.shared.keyWindow
        window?.addSubview(self)
        
        self.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //支付弹窗
        popupView = UIImageView()
        popupView.isUserInteractionEnabled = true
        popupView.image = UIImage.init(named: "export_back")
        self.addSubview(popupView)
        
        popupView.snp.makeConstraints { (make) in
            make.width.equalTo(280)
            make.height.equalTo(180)
            make.center.equalToSuperview()
        }
        
        //取消按钮
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.setImage(UIImage.init(named: "export_turnoff"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        popupView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(40)
        }
        
        //加载动画
        let exportLoading = UIImageView()
        exportLoading.image = UIImage.init(named: "export_activity")
        popupView.addSubview(exportLoading)
        
        exportLoading.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(45)
            make.width.height.equalTo(70)
        }
        
        //添加旋转动画
        let rotationAnimation = CABasicAnimation.init(keyPath: "transform.rotation.z")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = NSNumber.init(value: Double.pi*Double(2))
        rotationAnimation.duration = 2
        rotationAnimation.repeatCount = MAXFLOAT
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = CAMediaTimingFillMode.forwards
        exportLoading.layer.add(rotationAnimation, forKey: nil)
        
        //正在导出
        let loadingLable = UILabel()
        loadingLable.text = "正在导出"
        loadingLable.font = UIFont.systemFont(ofSize: 14)
        loadingLable.textColor = PublicColor.minorTextColor
        popupView.addSubview(loadingLable)
        
        loadingLable.snp.makeConstraints { (make) in
            make.top.equalTo(exportLoading.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        //导出进度
        progressLabel = UILabel()
        progressLabel.text = "0.00%"
        progressLabel.font = UIFont.systemFont(ofSize: 14)
        progressLabel.textColor = PublicColor.minorTextColor
        popupView.addSubview(progressLabel)
        
        progressLabel.snp.makeConstraints { (make) in
            make.center.equalTo(exportLoading)
        }
    }
    
    //MARK: - 按钮事件
    @objc func cancelAction() {
        AppLog("点击了取消")
        
        if let block = cancelBlock {
            block()
        }
        
        hiddenView()
    }
    
    //MARK: -
    func showView() {
        
        progressLabel.text = "0.00%"
        
        self.isHidden = false
        self.alpha = 0
        popupView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        
        UIView.animate(withDuration: 0.3) { 
            self.alpha = 1
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            
            self.popupView.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            
        }) { (isFinish) in
            
        }
    }
    
    func hiddenView() {
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { (isFinish) in
            self.removeFromSuperview()
        }
    }

}
