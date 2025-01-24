//
//  InvitationCodeController.swift
//  YZB_Company
//
//  Created by 刘毅 on 2019/8/20.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit

class InvitationCodeController: BaseViewController {

    @IBOutlet weak var saveBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "我的邀请码"
        
        let backgroundImg = PublicColor.gradualColorImage
        let backgroundHImg = PublicColor.gradualHightColorImage
        
        saveBtn.setBackgroundImage(backgroundImg, for: .normal)
        saveBtn.setBackgroundImage(backgroundHImg, for: .highlighted)
        
    }

    @IBAction func saveAction(_ sender: Any) {
       let image = UIImage(named: "invitationCode")

        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
  
        
        if didFinishSavingWithError != nil {
           self.noticeOnlyText("保存失败")
            return
        }
        self.noticeOnlyText("保存成功")
    }
   
}
