//
//  MemberViewController.swift
//  YZB_Company
//
//  Created by Mac on 16.10.2019.
//  Copyright © 2019 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire

class MemberCenterViewController: UIViewController {
    @IBOutlet weak var subZeroContains: NSLayoutConstraint!
    @IBOutlet weak var zeroContains: NSLayoutConstraint!
    
    @IBOutlet weak var lableWidth: NSLayoutConstraint!
    @IBOutlet weak var progressNumberView: UIView!
    @IBOutlet weak var bg: UIView!
    @IBOutlet weak var bgImageView: UIImageView!
    
    @IBOutlet weak var memberIcon: UIImageView!
    @IBOutlet weak var displayCompanyName: UILabel!
    
    @IBOutlet weak var displayMemberLevel: UILabel!
    
    @IBOutlet weak var displayNumber: HProgressView! {
        didSet { displayNumber.delegate = self }
    }
    
    @IBOutlet weak var displayStart: UILabel!
    @IBOutlet weak var displayEnd: UILabel!
    @IBOutlet weak var displayStartNumber: UILabel!
    
    @IBOutlet weak var displayAllCostNumber: UILabel!
    @IBOutlet weak var displayEndNumber: UILabel!
    private var popver: UIPopoverPresentationController!
    
    private var modelArray: [MemberCenterModel] = []
    private var curModel: MemberCenterModel!
    
    private struct Identifier {
        static let number = "number"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI(false)
        loadData()
    }
    
    private func loadData() {
        
        let mapper: Parameters = ["storeId": UserData.shared.workerModel?.store?.id ?? ""]
        YZBSign.shared.request(APIURL.memberLevel, method: .post, parameters: mapper, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                self.modelArray = Mapper<MemberCenterModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.fetchSelfData()
            }
            
        }) { (er) in
            AppLog(er)
        }
    }
    
    private func fetchSelfData() {
        
        YZBSign.shared.request(APIURL.memberInfo, method: .post, parameters: ["storeId": UserData.shared.workerModel?.store?.id ?? "b92565f0cb204551a40e806a3f540e3"], success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                let dataArray = Utils.getReqDir(data: response as AnyObject)
                self.curModel = Mapper<MemberCenterModel>().map(JSON: dataArray as! [String : Any])
                self.updateUI()
            }
            else if errorCode == "008" {
                self.updateUI(true)
            }
            
            
        }) { (er) in
            AppLog(er)
        }
    }
    
    private func setupUI() {
        
        self.title = "会员等级"
        bg.layer.cornerRadius = 8
        bg.layer.masksToBounds = true
        displayAllCostNumber.layer.cornerRadius = 2
        displayAllCostNumber.layer.masksToBounds = true
        
        let rightBtn = UIButton(type: .custom)
        rightBtn.setTitle("等级说明", for: .normal)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightBtn.setTitleColor(.white, for: .normal )
        rightBtn.addTarget(self, action: #selector(level), for: .touchUpInside)
        let rightBarItem = UIBarButtonItem(customView: rightBtn)
        navigationItem.rightBarButtonItems = [rightBarItem]
    }
    
    private func updateUI(_ isZero: Bool = false) {
      
        displayCompanyName?.text = UserData.shared.workerModel?.store?.name
        
        if isZero {
            // 无记录
            self.displayNumber?.progress = 0
            self.displayAllCostNumber?.text = "暂无消费"
            displayMemberLevel?.text = "普通会员"
            memberIcon?.image = UIImage(named: displayMemberLevel?.text ?? "普通会员")
            lableWidth.constant = 60
            
            if modelArray.count > 1 {
                displayStart?.text = modelArray[0].name
                displayStartNumber?.text = "\(Double((modelArray[0].minInterval) / 10000))W"
                
                displayEnd?.text = modelArray[1].name
                displayEndNumber?.text = "\(Double((modelArray[1].minInterval) / 10000))W"
            }
        }
        
        else if let curModel = self.curModel {
            self.displayNumber?.progress = Float(Float(curModel.totalPurchasesMoney.intValue - curModel.minInterval) / Float(curModel.maxInterval-curModel.minInterval))
            let ljMoney = curModel.totalPurchasesMoney.doubleValue
            self.displayAllCostNumber?.text = "累积消费:"+ljMoney.notRoundingString(afterPoint: 2)+"元"
            displayMemberLevel?.text = curModel.rateName
            memberIcon?.image = UIImage(named: curModel.rateName ?? "普通会员")
            lableWidth.constant = 120

            if modelArray.count > 1 {
                displayStart?.text = curModel.rateName
                displayStartNumber?.text = "\((Double(curModel.minInterval) / 10000))W"
                
                displayEnd?.text = curModel.nextRateName
                displayEndNumber?.text = "\((Double(curModel.maxInterval) / 10000))W"
            }
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.statusStyle = .lightContent
        
        self.navigationController?.navigationBar.barTintColor = bg.superview?.backgroundColor
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //导航栏字体
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.white]
        
        var shadowHeaght: CGFloat = 1
        let screenScale = UIScreen.main.scale
        
        if screenScale == 2 {
            shadowHeaght = shadowHeaght/2
        }else if screenScale == 3 {
            shadowHeaght = shadowHeaght/3
        }
        
        //设置导航栏分割线
        let shadImage = bg.superview?.backgroundColor?.image(size: CGSize(width: PublicSize.screenWidth, height: shadowHeaght))
        navigationController?.navigationBar.shadowImage = shadImage
        bgImageView.image = PublicColor.gradualColorImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.statusStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.black
        
        //导航栏背景颜色
        navigationController?.navigationBar.barTintColor = .white
        
        //导航栏半透明
        navigationController?.navigationBar.isTranslucent = false
        
        //导航栏字体
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black]
        
        var shadowHeaght: CGFloat = 1
        let screenScale = UIScreen.main.scale
        
        if screenScale == 2 {
            shadowHeaght = shadowHeaght/2
        }else if screenScale == 3 {
            shadowHeaght = shadowHeaght/3
        }
        
        //设置导航栏分割线
        let shadImage = PublicColor.navigationLineColor.image(size: CGSize(width: PublicSize.screenWidth, height: shadowHeaght))
        navigationController?.navigationBar.shadowImage = shadImage
    }
    
    var statusStyle : UIStatusBarStyle = .default {
        didSet{
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    //修改状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return self.statusStyle
        }
    }
    
    @objc private func level() {
        let vc = AgreementViewController()
        vc.type = .level
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func ff(_ sender: UISlider) {
        
        displayNumber.progress = sender.value
        displayNumber.setNeedsLayout()
    }
    
    private func updateProgress() {
        displayNumber.progress = 0.5
    }
    
    private var pwidth: CGFloat = 300
}
// MARK: - HProgressViewDeleagate
extension MemberCenterViewController: HProgressViewDeleagate {
    
    
    func layoutChanged(_ width: CGFloat) {
        updateDisplayLabel(width)
    }
    
    func updateDisplayLabel(_ fWidth: CGFloat) {
        let zero = fWidth / 2
        
        // 默认是 0.5
        
        let maxWidth = fWidth - ( lableWidth.constant / 2) - zero
        let minWidth = (lableWidth.constant / 2) - zero
        
        let max: Float = Float(maxWidth + zero) / Float(fWidth)
        let min: Float = Float(lableWidth.constant / 2) / Float(fWidth)
        
        if displayNumber.progress > min && displayNumber.progress < max {
            
            zeroContains.constant = CGFloat(displayNumber.progress - 0.5) * fWidth
            subZeroContains.constant = 0
        }
        else if displayNumber.progress <= min {

            let minValue = minWidth - 8
            zeroContains.constant = minValue
            let subWidth = lableWidth.constant / 2 - 8
            let x = subWidth / CGFloat(min)
            subZeroContains.constant = CGFloat(displayNumber.progress) * x - subWidth
        }
        else {
            let maxValue = maxWidth + 8
            zeroContains.constant = maxValue
            let subWidth = lableWidth.constant / 2 - 8
            let x = subWidth / CGFloat(1-max)
            subZeroContains.constant = CGFloat(displayNumber.progress-max) * x
        }
        
    }
}
