//
//  RemarksViewController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/21.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import PopupDialog

enum RemarksType {
    case remarks
    case service
    case tel
}

class RemarksViewController: BaseViewController,UITextViewDelegate,UIViewControllerTransitioningDelegate, UITextFieldDelegate {
    
    var popupView: UIView!                  //弹窗
    var telField: UITextField!              //电话输入框
    var remarkField: UITextView!            //备注输入框
    var placeholderLabel: UILabel!          //文本提示语
    var remarkStr: String?                  //备注
    var titleStr = ""
    var titleLabel: UILabel!
    var doneBtn: UIButton!
    var money: String!
    var displayChangedNumber: UILabel!         //千分位显示
    
    var remarksType: RemarksType! {
        
        didSet {
            updateUI()
        }
    }
    
    var doneBlock: ((_ remarks: String?, _ re2: String?)->())?                //完成
    
    
    private func updateUI() {
       
        telField.text = remarkStr
        placeholderLabel.isHidden = true
        
        if remarksType == .remarks {
            telField.isHidden = true
            remarkField.isHidden = false
            placeholderLabel.isHidden = false
            
            popupView.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(300)
                make.height.equalTo(236)
            }
        }
        else if remarksType == .service {
            
            telField.keyboardType = .numberPad
            telField.isHidden = false
            remarkField.isHidden = false
            placeholderLabel.isHidden = remarkStr?.length == 0
            displayChangedNumber.isHidden = false
            telField.textColor = telField.backgroundColor
            
            remarkField.text = remarkStr
            telField.text = money
            displayChangedNumber.text = money.addMicrometerLevel()
            
            popupView.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(300)
                make.height.equalTo(336)
            }
            
            telField.snp.remakeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(11)
                make.left.equalTo(15)
                make.right.equalTo(-15)
                make.height.equalTo(44)
            }
            
            displayChangedNumber.snp.remakeConstraints { (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(11)
                make.left.equalTo(22)
                make.right.equalTo(-15)
                make.height.equalTo(44)
            }
            
            remarkField.snp.remakeConstraints { (make) in
                make.left.equalTo(telField.snp.left)
                make.right.equalTo(telField.snp.right)
                make.top.equalTo(telField.snp.bottom).offset(11)
                make.bottom.equalTo(doneBtn.snp.top).offset(-11)
            }
            
            placeholderLabel.snp.remakeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalToSuperview()
            }
        }
        else {
            telField.isHidden = false
            remarkField.isHidden = true
            placeholderLabel.isHidden = true
            if remarksType == .tel {
                telField.keyboardType = .phonePad
            }
            else {
                telField.keyboardType = .default
            }
            popupView.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(300)
                make.height.equalTo(175)
            }
        }
    }
    
    init(title: String, remark:String){
        super.init(nibName: nil, bundle: nil)
        remarkStr = remark
        titleStr = title
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        self.view.backgroundColor = UIColor.clear
        updateUI()
    }
    
    /// 服务
    init(title: String, money: String, remark: String){
        super.init(nibName: nil, bundle: nil)
        
        self.money = money
        remarkStr = remark
        titleStr = title
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
        self.view.backgroundColor = UIColor.clear
        updateUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSubView()
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.2) {
            self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        }
    }
    
    func createSubView() {

        //内容弹窗
        popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 5
        self.view.addSubview(popupView)
        
        popupView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(236)
        }
        
        //标题
        titleLabel = UILabel()
        titleLabel.text = titleStr
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = PublicColor.commonTextColor
        popupView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(15)
        }
        
        //输入框
        remarkField = UITextView()
        remarkField.delegate = self
        remarkField.backgroundColor = PublicColor.backgroundViewColor
        remarkField.layer.cornerRadius = 2
        remarkField.font = UIFont.systemFont(ofSize: 14)
        popupView.addSubview(remarkField)
        
        remarkField.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(-76)
        }
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "请输入备注"
        placeholderLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x808080)
        placeholderLabel.font = remarkField.font
        remarkField.addSubview(placeholderLabel)
        remarkField.setValue(placeholderLabel, forKey: "_placeholderLabel")
      
        
        //电话输入框
        telField = UITextField()
        telField.delegate = self
        telField.isHidden = true
        telField.backgroundColor = PublicColor.backgroundViewColor
        telField.returnKeyType = .done
        telField.keyboardType = .decimalPad
        telField.layer.cornerRadius = 2
        telField.textColor = PublicColor.commonTextColor
        telField.leftView = UIView(frame: CGRect.init(x: 0, y: 0, width: 10, height: 10))
        telField.leftViewMode = .always
        telField.font = remarkField.font
        telField.addTarget(self, action: #selector(textFieldEditChanged(_:)), for: .editingChanged)
        popupView.addSubview(telField)
        
        telField.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(remarkField)
            make.height.equalTo(46)
        }
        
        //千分位显示
        displayChangedNumber = UILabel()
        displayChangedNumber.textColor = PublicColor.commonTextColor
        displayChangedNumber.font = remarkField.font
        popupView.addSubview(displayChangedNumber)
        displayChangedNumber.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(remarkField)
            make.height.equalTo(46)
        }
        displayChangedNumber.isHidden = true
        
        //返回
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        doneBtn = UIButton.init(type: .custom)
        doneBtn.layer.cornerRadius = 2
        doneBtn.layer.masksToBounds = true
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        doneBtn.setTitle("修改", for: .normal)
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.setBackgroundImage(backgroundImg, for: .normal)
        doneBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        doneBtn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        popupView.addSubview(doneBtn)
        
        doneBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-40)
            make.bottom.equalTo(-25)
            make.width.equalTo(90)
            make.height.equalTo(34)
        }
        
        //返回
        let btnNormalImg = PublicColor.buttonColorImage
        let btnHighLightedImg = PublicColor.buttonHightColorImage
        let cancelBtn = UIButton.init(type: .custom)
        cancelBtn.layer.cornerRadius = doneBtn.layer.cornerRadius
        cancelBtn.layer.masksToBounds = true
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = PublicColor.partingLineColor.cgColor
        cancelBtn.titleLabel?.font = doneBtn.titleLabel?.font
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        cancelBtn.setBackgroundImage(btnNormalImg, for: .normal)
        cancelBtn.setBackgroundImage(btnHighLightedImg, for: .highlighted)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        popupView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(40)
            make.centerY.width.height.equalTo(doneBtn)
        }
    }
   
    @objc func doneAction() {
        
        var remarkStr = ""
        var remarkStr2 = ""

        if remarksType == .remarks {
            if let valueStr = remarkField.text {
                remarkStr = valueStr
            }
        }
        else if remarksType == .service {
            if let valueStr = remarkField.text {
                remarkStr2 = valueStr
            }
            if let valueStr = telField.text {
                remarkStr = valueStr
            }
        }
        else {
            if let valueStr = telField.text {
                remarkStr = valueStr
            }
        }
        
        guard let block = doneBlock else {
            return
        }
        
        self.dismiss(animated: true) {
            
            if remarkStr.count <= 0 {
                block(nil, nil)
            }else {
                block(remarkStr, remarkStr2)
            }
        }
    }
    
    @objc func cancelAction() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UITextViewDelegate
    @objc func textFieldEditChanged(_ textField: UITextField) {
        if remarksType == .service {
            
            // 最大金额不过10万.99
            if (textField.text! as NSString).doubleValue >= 100000 || textField.text!.length >= 8 {
                textField.text = "99999.99"
            }
            
            displayChangedNumber.text = textField.text!.addMicrometerLevel()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.keyboardType == .decimalPad || textField.keyboardType == .phonePad {
            //只允许输入数字
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            if newString == "" {
                return true
            }
            
//            let expression = "^[0-9]-*$"
//            
//            let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
//            let numberOfMatches = regex.numberOfMatches(in: newString, options:NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
//            
//            if numberOfMatches == 0 {
//                return false
//            }
        }
        
       
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        //收起键盘
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.text = "0"
        }
    }

    //MARK: - UIViewControllerTransitioningDelegate
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresnetTransitionUpAnimated(transitionType: 1)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresnetTransitionUpAnimated(transitionType: 2)
    }

}
class PresnetTransitionUpAnimated: NSObject,UIViewControllerAnimatedTransitioning {
    var typeT : Int!
    init(transitionType:Int) {
        super.init()
        typeT = transitionType
    }
    // 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    // 做动画需要的前后两个视图
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        let contentView = transitionContext.containerView

        switch typeT {
        case 1:
            contentView.addSubview(toVC!.view)
            toVC!.view.bounds.origin = CGPoint(x: 0, y: -fromVC!.view.bounds.size.height)
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.curveEaseOut], animations: {
                toVC!.view.bounds = fromVC!.view.bounds
            }, completion: { completed in
                transitionContext.completeTransition(true)
            })
        case 2:
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: {
                fromVC!.view.bounds.origin = CGPoint(x: 0, y: -fromVC!.view.bounds.size.height)
                fromVC!.view.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        default:
            break
        }
    }
    
    
}

