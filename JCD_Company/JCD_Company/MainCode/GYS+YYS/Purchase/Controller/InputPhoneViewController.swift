//
//  InputPhoneViewController.swift
//  YZB_Company
//
//  Created by Mac on 19.10.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import Alamofire

class InputPhoneViewController: UIViewController {

    
    @IBOutlet weak var displayPhone: UILabel!
    @IBOutlet weak var payButton: UIButton! {
        didSet {
            payButton.setBackgroundImage(PublicColor.gradualColorImage, for: .normal)
            payButton.setBackgroundImage(UIColor.gray.image(), for: .disabled)
            payButton.layer.cornerRadius = 6
            payButton.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var fetchBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    
    var blockff: ((String) -> Void)?
    var tel: String?
    var mobile: String?
    
    private var timer: Timer?
    private var count = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (UserData.shared.workerModel?.jobType == 999) {
            displayPhone?.text = UserData.shared.workerModel?.mobile ?? ""
        } else {
            displayPhone?.text = mobile
        }
        
        // Do any additional setup after loading the view.
    }
    @IBAction func fetch(_ sender: UIButton) {
        if timer == nil {
            fetchBtn.isEnabled = false
            fetchBtn.setTitle("获取验证码(\(count))", for: .normal)
            fetchCode()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCount), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateCount() {
        count -= 1
        fetchBtn.setTitle("获取验证码(\(count))", for: .normal)
        if count == 0 {
            count = 60
            fetchBtn.setTitle("获取验证码", for: .normal)
            fetchBtn.isEnabled = true
            timer?.invalidate()
            timer = nil
        }
    }
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchCode() {
        YZBSign.shared.request(APIURL.balancePayMsg, method: .get, parameters: Parameters(), success: { (response) in
            AppLog(response)
        }) { (err) in
            AppLog(err)
        }
    }
    
    @IBAction func pay(_ sender: Any) {
        blockff?(textField.text!)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textField(_ sender: UITextField) {
        
        if textField.text?.length ?? 0 >= 4 {
            payButton?.isEnabled = true
            if textField.text!.length >= 6 {
                textField.text = textField.text!.subString(to: 6)
            }
        }
        else {
            payButton?.isEnabled = false
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         
         UIView.animate(withDuration: 0.2) {
             self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
         }
     }

}
extension InputPhoneViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresnetTransitionUpAnimated(transitionType: 1)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresnetTransitionUpAnimated(transitionType: 2)
    }
}
