//
//  MemberViewController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/6/14.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Kingfisher
import PopupDialog


class MemberViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var rowsData: Array<IntegralMallModel> = []
    let identifier = "MemberCell"
    
    var titleLB: UILabel!                           //自定义标题
    var ruleBtn: UIButton!                          //积分规则
    var locatLabel: UILabel!                        //定位
    var headImageView: UIImageView!                 //头像
    var gradeLabel: UILabel!                        //会员等级
    var nameLabel: UILabel!                         //会员名
    var growthLabel: UILabel!                       //成长值
    var scoreLabel: UILabel!                        //会员积分
    var backBarView: UIView!                        //经验条背景
    var expBarView: UIView!                         //经验条
    var expBeginLabel: UILabel!                     //经验起点
    var expEndLabel: UILabel!                       //经验终点
    var gapLabel: UILabel!                          //距离下一级成长值
    var rankLabel: UILabel!                         //排名
    var disparityLabel: UILabel!                    //距离上一名的差距
    
    var userModel: WorkerModel? {
        
        didSet{
            
            locatLabel.text = "未知"
            headImageView.image = UIImage.init(named: "headerImage_man")
            gradeLabel.text = "普通会员"
            nameLabel.text = "姓名"
            growthLabel.text = "0点"
            expBeginLabel.text = "0"
            expEndLabel.text = "0"
            gapLabel.text = "还差0点升级为黄金会员"
            scoreLabel.text = "0"
            
            expBarView.snp.makeConstraints { (make) in
                make.left.centerY.height.equalTo(backBarView)
                make.width.equalTo(5)
            }
            
            //地址
            if let valueStr = userModel?.store?.city?.name {
                locatLabel.text = valueStr
            }
            
            //头像
            var headerImage = UIImage.init(named: "headerImage_man")
            
            if let valueType = userModel?.sex?.intValue {
                if valueType == 2 {
                    headerImage = UIImage.init(named: "headerImage_woman")
                }
            }
            
            headImageView.image = headerImage
            
            if let imagestr = userModel?.headUrl {
                
                if imagestr != "" {
                    
                    let imageUrl = URL(string: APIURL.ossPicUrl + imagestr)!
                    headImageView.kf.setImage(with: imageUrl, placeholder: headerImage)
                }
            }
            
            //姓名
            if let name = userModel?.realName {
                nameLabel.text = name
            }
            
            var growthValue: Int = 0
            var growthStartValue: Int = 0
            var growthEndValue: Int = 0
            
            //成长值
            if let valueStr = userModel?.growth?.intValue {
                growthValue = valueStr
                growthLabel.text = "\(valueStr)点"
                if valueStr == 0 {
                    rankLabel.text = "本市排名: 暂无排名"
                    disparityLabel.text = "(暂无排名)"
                }else {
                    getRankData()
                }
            }
            
            //分数
            if let valueStr = userModel?.integration?.intValue {
                scoreLabel.text = "\(valueStr)"
            }
            
            //开始分数
            if let valueStr = userModel?.yzbWorkerLv?.growthStart?.intValue {
                
                if valueStr > 0 {
                    let expBValue = valueStr/10000
                    expBeginLabel.text = "\(expBValue)w"
                }
                growthStartValue = valueStr
            }
            
            //结束分数
            if let valueStr = userModel?.yzbWorkerLv?.growthEnd?.intValue {
                let expEValue = valueStr/10000
                expEndLabel.text = "\(expEValue)w"
                growthEndValue = valueStr
            }
            
            //距离下一级差距
            if let valueStr = userModel?.yzbWorkerLv?.lv?.intValue {
                if valueStr >= 0 && valueStr < AppData.gradeNameList.count {
                    gradeLabel.text = AppData.gradeNameList[valueStr]+"会员"
                    
                    if valueStr == AppData.gradeNameList.count {
                        gapLabel.text = "当前已是最高等级会员"
                    }else {
                        gapLabel.text = "还差\(growthEndValue-growthValue+1)点升级为" + AppData.gradeNameList[valueStr+1]+"会员"
                    }
                }
            }
            
            //经验条
            if growthEndValue-growthStartValue == 0 {
                
                expBarView.snp.remakeConstraints { (make) in
                    make.left.centerY.height.equalTo(backBarView)
                    make.width.equalTo(5)
                }
                
            }else {
                
                //计算经验条比率
                let growRatio = CGFloat(growthValue-growthStartValue)/CGFloat(growthEndValue-growthStartValue)
                
                //经验条宽
                let growBackBarWidth = PublicSize.screenWidth-50-10-68-15-10
                var growBarWidth = growBackBarWidth*growRatio
                
                if growBarWidth < 5 {
                    growBarWidth = 5
                }
                
                expBarView.snp.remakeConstraints { (make) in
                    make.left.centerY.height.equalTo(backBarView)
                    make.width.equalTo(growBarWidth)
                }
            }
        }
    }
    
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>>>> 会员中心界面释放 <<<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareNavigationItem()
        prepareTableView()
        
        self.pleaseWait()
        getExchangeData()
        refreshUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true
        
        let barBackground = navigationController?.navigationBar.subviews.first
        barBackground?.alpha = 0
        
        self.statusStyle = .lightContent
        navigationController?.navigationBar.tintColor = .white
        titleLB.textColor = UIColor.white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let barBackground = navigationController?.navigationBar.subviews.first
        barBackground?.alpha = 1
        
        self.statusStyle = .default
        navigationController?.navigationBar.tintColor = UIColor.black
        titleLB.textColor = UIColor.black
        
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
    
    func prepareNavigationItem() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back_nav"), style: .plain, target: self, action: #selector(backAction))
        
        titleLB = UILabel()
        titleLB.textColor = UIColor.white
        titleLB.font = UIFont.systemFont(ofSize: 17)
        titleLB.text = "会员中心"
        navigationItem.titleView = titleLB
        titleLB.sizeToFit()
        
        // 积分规则
        ruleBtn = UIButton(type: .custom)
        ruleBtn.frame = CGRect.init(x: 0, y: 0, width: 60, height: 30)
        ruleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        ruleBtn.setTitle("积分规则", for: .normal)
        ruleBtn.setTitleColor(UIColor.colorFromRGB(rgbValue: 0xECA22D), for: .normal)
        ruleBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        ruleBtn.addTarget(self, action: #selector(ruleAction), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: ruleBtn)
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.clear
        tableView.rowHeight = 85
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.register(MemberCell.self, forCellReuseIdentifier: identifier)
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        if #available(iOS 11.0, *) {
            
            tableView.contentInsetAdjustmentBehavior = .never
        }else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        //头视图
        var headerHeight: CGFloat = 330*(IS_iPad ? PublicSize.PadRateHeight:PublicSize.RateHeight)
        
        if headerHeight<330 {
            headerHeight = 330
        }
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: headerHeight))
        headerView.backgroundColor = .white
        tableView.tableHeaderView = headerView
        
        //深色背景
        let darkBackView = UIView()
        darkBackView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x232323)
        headerView.addSubview(darkBackView)
        
        var darkHeight: CGFloat = 290*(IS_iPad ? PublicSize.PadRateHeight:PublicSize.RateHeight)
        
        if darkHeight<290 {
            darkHeight = 290
        }
        
        darkBackView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(darkHeight)
        }
        
        //会员背景
        let memberBackView = UIImageView()
        memberBackView.layer.cornerRadius = 10
        memberBackView.layer.masksToBounds = true
        memberBackView.image = UIImage.init(named: "vip_bg_img")
        darkBackView.addSubview(memberBackView)
        
        
        memberBackView.snp.makeConstraints { (make) in
            make.left.equalTo(25)
            make.right.equalTo(-25)
            make.height.equalTo(150)
            make.bottom.equalToSuperview().offset(-70)
        }
        
        //定位
        locatLabel = UILabel()
        locatLabel.text = "未知"
        locatLabel.textColor = .white
        locatLabel.font = UIFont.systemFont(ofSize: 12)
        memberBackView.addSubview(locatLabel)
        
        locatLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.right.equalTo(-10)
        }
        
        //定位图标
        let locatIcon = UIImageView()
        locatIcon.image = UIImage.init(named: "location_icon")
        locatIcon.contentMode = .scaleAspectFit
        memberBackView.addSubview(locatIcon)
        
        locatIcon.snp.makeConstraints { (make) in
            make.centerY.equalTo(locatLabel)
            make.right.equalTo(locatLabel.snp.left).offset(-2)
            make.width.height.equalTo(12)
        }
        
        //头像
        headImageView = UIImageView()
        headImageView.backgroundColor = .white
        headImageView.contentMode = .scaleAspectFill
        headImageView.image = UIImage.init(named: "headerImage_man")
        headImageView.layer.borderWidth = 2
        headImageView.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xF7C679).cgColor
        headImageView.layer.cornerRadius = 34
        headImageView.layer.masksToBounds = true
        memberBackView.addSubview(headImageView)
        
        headImageView.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.width.height.equalTo(68)
            make.top.equalTo(30)
        }
        
        //等级
        gradeLabel = UILabel()
        gradeLabel.text = "普通会员"
        gradeLabel.textAlignment = .center
        gradeLabel.backgroundColor = PublicColor.commonTextColor
        gradeLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xEDCA25)
        gradeLabel.font = UIFont.systemFont(ofSize: 10)
        gradeLabel.layer.cornerRadius = 8
        gradeLabel.layer.masksToBounds = true
        memberBackView.addSubview(gradeLabel)
        
        gradeLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(headImageView)
            make.top.equalTo(headImageView.snp.bottom).offset(5)
            make.height.equalTo(16)
            make.width.equalTo(60)
        }
        
        //用户名
        nameLabel = UILabel()
        nameLabel.text = "姓名"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.systemFont(ofSize: 13)
        memberBackView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(40)
            make.left.equalTo(headImageView.snp.right).offset(15)
        }
        
        //会员成长值
        growthLabel = UILabel()
        growthLabel.text = "0点"
        growthLabel.textColor = PublicColor.commonTextColor
        growthLabel.font = UIFont.systemFont(ofSize: 12)
        memberBackView.addSubview(growthLabel)
        
        growthLabel.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(nameLabel)
        }
        
        //经验条背景
        backBarView = UIView()
        backBarView.layer.cornerRadius = 2.5
        backBarView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xA37123)
        memberBackView.addSubview(backBarView)
        
        backBarView.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.right.equalTo(growthLabel)
            make.centerY.equalTo(headImageView)
            make.height.equalTo(5)
        }
        
        //经验条
        expBarView = UIView()
        expBarView.layer.cornerRadius = 2.5
        expBarView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0xFFF100)
        memberBackView.addSubview(expBarView)
        
        expBarView.snp.makeConstraints { (make) in
            make.left.centerY.height.equalTo(backBarView)
            make.width.equalTo(5)
        }
        
        //经验起点
        expBeginLabel = UILabel()
        expBeginLabel.text = "0"
        expBeginLabel.textColor = .white
        expBeginLabel.font = UIFont.systemFont(ofSize: 10)
        memberBackView.addSubview(expBeginLabel)
        
        expBeginLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(backBarView.snp.bottom).offset(5)
        }
        
        //经验终点
        expEndLabel = UILabel()
        expEndLabel.text = "0"
        expEndLabel.textColor = .white
        expEndLabel.font = UIFont.systemFont(ofSize: 10)
        memberBackView.addSubview(expEndLabel)
        
        expEndLabel.snp.makeConstraints { (make) in
            make.right.equalTo(backBarView)
            make.centerY.equalTo(expBeginLabel)
        }
        
        //距离下一级分数
        gapLabel = UILabel()
        gapLabel.text = "还差0点升级为黄金会员"
        gapLabel.textColor = UIColor.colorFromRGB(rgbValue: 0x594A25)
        gapLabel.font = UIFont.systemFont(ofSize: 10)
        memberBackView.addSubview(gapLabel)
        
        gapLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(backBarView)
            make.centerY.equalTo(expBeginLabel)
        }
        
        //会员积分
        scoreLabel = UILabel()
        scoreLabel.text = "0"
        scoreLabel.textColor = .white
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 16)
        memberBackView.addSubview(scoreLabel)
        
        scoreLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(gradeLabel)
            make.left.equalTo(nameLabel)
        }
        
        //积分单位
        let scoreUnitLabel = UILabel()
        scoreUnitLabel.text = "积分"
        scoreUnitLabel.textColor = .white
        scoreUnitLabel.font = UIFont.systemFont(ofSize: 10)
        memberBackView.addSubview(scoreUnitLabel)
        
        scoreUnitLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(scoreLabel)
            make.left.equalTo(scoreLabel.snp.right).offset(2)
        }
        
        //本市排名
        rankLabel = UILabel()
        rankLabel.text = "本市排名: NO.0"
        rankLabel.textColor = .white
        rankLabel.font = UIFont.systemFont(ofSize: 12)
        memberBackView.addSubview(rankLabel)
        
        rankLabel.snp.makeConstraints { (make) in
            make.right.equalTo(backBarView)
            make.centerY.equalTo(gradeLabel)
        }
        
        //距上一名差距
        disparityLabel = UILabel()
        disparityLabel.text = "(离上一名只差0点)"
        disparityLabel.textColor = UIColor.colorFromRGB(rgbValue: 0xE9D0AE)
        disparityLabel.font = UIFont.systemFont(ofSize: 10)
        memberBackView.addSubview(disparityLabel)
        
        disparityLabel.snp.makeConstraints { (make) in
            make.right.equalTo(rankLabel)
            make.top.equalTo(rankLabel.snp.bottom).offset(3)
        }
        
        //积分提现背景
        let bottomBackView = UIView()
        bottomBackView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x1A1A1A)
        darkBackView.addSubview(bottomBackView)
        
        bottomBackView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(47)
        }
        
        //积分提现
        let withdrawBtn = UIButton(type: .custom)
        withdrawBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        withdrawBtn.setTitle("积分提现", for: .normal)
        withdrawBtn.setTitleColor(.white, for: .normal)
        withdrawBtn.setTitleColor(UIColor.init(white: 1, alpha: 0.4), for: .highlighted)
        withdrawBtn.addTarget(self, action: #selector(withdrawAction), for: .touchUpInside)
        bottomBackView.addSubview(withdrawBtn)
        
        withdrawBtn.snp.makeConstraints { (make) in
            make.height.centerY.equalToSuperview()
            make.width.centerX.equalToSuperview().multipliedBy(0.5)
        }
        
        //积分明细
        let detailBtn = UIButton(type: .custom)
        detailBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        detailBtn.setTitle("积分明细", for: .normal)
        detailBtn.setTitleColor(.white, for: .normal)
        detailBtn.setTitleColor(UIColor.init(white: 1, alpha: 0.4), for: .highlighted)
        detailBtn.addTarget(self, action: #selector(detailAction), for: .touchUpInside)
        bottomBackView.addSubview(detailBtn)
        
        detailBtn.snp.makeConstraints { (make) in
            make.height.centerY.equalToSuperview()
            make.centerX.equalToSuperview().multipliedBy(1.5)
            make.width.equalToSuperview().multipliedBy(0.5)
        }
        
        //分割线
        let lineView = UIView()
        lineView.backgroundColor = UIColor.colorFromRGB(rgbValue: 0x0C0C0C)
        bottomBackView.addSubview(lineView)
        
        lineView.snp.makeConstraints { (make) in
            make.centerX.top.bottom.equalToSuperview()
            make.width.equalTo(1)
        }
        
        //积分商城
        let mallLabel = UILabel()
        mallLabel.text = "积分商城"
        mallLabel.textColor = .black
        mallLabel.font = UIFont.boldSystemFont(ofSize: 15)
        headerView.addSubview(mallLabel)
        
        mallLabel.snp.makeConstraints { (make) in
            make.left.equalTo(15)
            make.top.equalTo(darkBackView.snp.bottom).offset(12)
        }
        
        //分割线
        let mallLineView = UIView()
        mallLineView.backgroundColor = PublicColor.partingLineColor
        headerView.addSubview(mallLineView)
        
        mallLineView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    
    //MARK: - 网络请求
    
    //获取用户信息
    func refreshUserData() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        
        let parameters: Parameters = ["id": userId]
        let urlStr = APIURL.getUserInfo
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                //储存用户数据
                AppUtils.setUserData(response: response)
                self.userModel = UserData.shared.workerModel
            }
            
        }) { (error) in
            
        }
    }
    
    //获取积分排名
    func getRankData() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        var storeID = ""
        if let valueStr = UserData.shared.workerModel?.store?.id {
            storeID = valueStr
        }
        
        let parameters: Parameters = ["id": userId, "store.id": storeID]
        let urlStr = APIURL.getRank
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                let rankStr = Utils.getReadString(dir: dataDic, field: "rank")
                let integrationStr = Utils.getReadString(dir: dataDic, field: "integration")
                self.rankLabel.text = "本市排名: NO."+rankStr
                self.disparityLabel.text = "(离上一名只差\(integrationStr)点)"
            }
            
        }) { (error) in
            
        }
    }
    
    //获取积分商城
    func getExchangeData() {
        
        let parameters: Parameters = ["pageSize": "500"]
        let urlStr = APIURL.exchange
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            self.rowsData.removeAll()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let dataArray = Utils.getReqArr(data: response as AnyObject)
                let modelArray = Mapper<IntegralMallModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.rowsData = modelArray
            }
            self.tableView.reloadData()
            
        }) { (error) in
            
        }
    }
    
    //是否可提现
    func getWithdrawCount() {
        
        var userId = ""
        if let valueStr = UserData.shared.workerModel?.id {
            userId = valueStr
        }
        
        self.pleaseWait()
        
        let parameters: Parameters = ["workerId": userId]
        let urlStr = APIURL.withdrawCount
        
        YZBSign.shared.request(urlStr, method: .post, parameters: parameters, success: { (response) in
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "errorCode")
            if errorCode == "000" {
                
                let bodyDic = Utils.getReadDic(data: response as AnyObject, field: "body")
                let dataStr = Utils.getReadString(dir: bodyDic, field: "data")
                
                
                let vc = IntegralWithdrawController()
                vc.userModel = self.userModel
                
                if dataStr == "Y" {
                    vc.isCanWithdraw = true
                }
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }) { (error) in
            
        }
    }
    
    
    //MARK: - 触发事件
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func ruleAction() {
        
        let vc = IntegralRuleController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func withdrawAction() {
        
        if userModel == nil {
            self.noticeOnlyText("正在读取会员信息")
            return
        }
        
        getWithdrawCount()
    }
    
    @objc func detailAction() {
        
        let vc = IntegralDetailController()
        navigationController?.pushViewController(vc, animated: true)
    }

    
    //MARK: - tableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! MemberCell
        
        let mallModel = rowsData[indexPath.row]
        cell.mallModel = mallModel
        
        cell.exchangeBlock = { [weak self] in
            
            if let userLv = self?.userModel?.yzbWorkerLv?.lv?.intValue, let needLv = mallModel.needLv {
                
                if userLv < Int(needLv)! {
                    self?.noticeOnlyText("您的会员等级不够哦~")
                    return
                }
                if mallModel.goodsCount!.intValue <= 0 {
                    self?.noticeOnlyText("糟糕，库存不足了~~")
                    return
                }
                if (self?.userModel?.integration?.intValue)! < Int(mallModel.integration!)! {
                    self?.noticeOnlyText("您的积分不够~")
                    return
                }
                
                var integration: Int = 0
                
                if let valueStr = mallModel.integration {
                    integration = Int(valueStr)!
                }
                
                let popup = PopupDialog(title: "提示", message: "将消耗\(integration)积分兑换本商品，确认兑换吗?", buttonAlignment: .horizontal)
                let sureBtn = DestructiveButton(title: "确认兑换") {
                    
                    let vc = IntegralExchangeController()
                    vc.mallModel = mallModel
                    self?.navigationController?.pushViewController(vc, animated: true)
                    
                }
                let cancelBtn = CancelButton(title: "暂不兑换") {
                }
                popup.addButtons([cancelBtn,sureBtn])
                self?.present(popup, animated: true, completion: nil)
            }
            
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if navigationController?.navigationBar.shadowImage != nil {
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil
        }
        
        let maxAlphaOffset: CGFloat = 10
        let offset: CGFloat = scrollView.contentOffset.y
        let alpha: CGFloat = offset/maxAlphaOffset
        
        let barBackground = navigationController?.navigationBar.subviews.first
        barBackground?.alpha = alpha
        
        if alpha == 0 {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.05) {
                barBackground?.alpha = 0
            }
        }
        
        if offset >= maxAlphaOffset {
            
            if UIApplication.shared.statusBarStyle == .lightContent {
                self.statusStyle = .default
                navigationController?.navigationBar.tintColor = UIColor.black
                titleLB.textColor = UIColor.black
            }
        }
        else {
            
            if UIApplication.shared.statusBarStyle == .default {
                self.statusStyle = .lightContent
                navigationController?.navigationBar.tintColor = .white
                titleLB.textColor = UIColor.white
            }
        }
    }
}
