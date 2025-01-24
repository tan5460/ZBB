//
//  BaseFormController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/1/22.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

class BaseFormController: FormViewController {

    var isChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let item = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = item
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        
        ImageRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            cell.accessoryView?.contentMode = .scaleAspectFit
            cell.accessoryView?.layer.cornerRadius = 0
            cell.height = {60}
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        AppLog(">>>>>>>>>>>>>>>>>>>>>>>> 内存溢出 <<<<<<<<<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isTranslucent = false
        
        if !AppData.isBaseDataLoaded {
            //获取基础数据
            YZBSign.shared.getBaseInfo()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.keyWindow?.endEditing(true)
        self.clearAllNotice()
    }
    
    @objc func backAction() { 
        
        if isChange {
            
            let popup = PopupDialog(title: "提示", message: "当前信息未保存，是否返回上一页？",buttonAlignment: .horizontal)
            
            let sureBtn = DestructiveButton(title: "返回") {
                
                self.navigationController?.popViewController(animated: true)
            }
            let cancelBtn = CancelButton(title: "取消") {
            }
            popup.addButtons([cancelBtn,sureBtn])
            self.present(popup, animated: true, completion: nil)
        }else {
            self.navigationController?.popViewController(animated: true)
        }
    }

}
