//
//  MembershipListVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/24.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import CHIPageControl

class MembershipListVC: BaseViewController {
    var isFirstEnter = true
    var tableView = UITableView.init(frame: .zero, style: .grouped)
    var levelPathGroup = [String]()
    lazy var levelBannerView: ZKCycleScrollView = {
        let localBannerView = ZKCycleScrollView()
        localBannerView.delegate = self
        localBannerView.isAutoScroll = false
        localBannerView.dataSource = self
        localBannerView.backgroundColor = .white
        localBannerView.customPageControl = pageControl
        localBannerView.register(cellClass: LevelListCell.self)
        localBannerView.pageControlTransform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        return localBannerView
    }()
    
    lazy var pageControl: CHIPageControlJaloro = {
        let pageControl = CHIPageControlJaloro()
        pageControl.radius = 1.5
        pageControl.padding = 8.0
        pageControl.tintColor = UIColor(hexString: "#F6E5CA")!
        pageControl.currentPageTintColor = UIColor(hexString: "#E3BA88")!
        pageControl.numberOfPages = levelPathGroup.count
        pageControl.isHidden = true
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "会员等级"

        for index in 1...8 {
            levelPathGroup.append("\(index)")
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
        }
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        
        
    }
    
}

extension MembershipListVC: ZKCycleScrollViewDelegate {
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, didSelectItemAt indexPath: IndexPath) {
        print("点击了：\(indexPath.item)")
    }
    
    func cycleScrollViewDidScroll(_ cycleScrollView: ZKCycleScrollView) {
        
        guard cycleScrollView === levelBannerView else { return }
        
        let total = CGFloat(levelPathGroup.count) * cycleScrollView.bounds.width
        if isFirstEnter {
            isFirstEnter = false
            var currentType = UserData.shared.userInfoModel?.yzbVip?.vipType ?? 1
            if currentType == 999 {
                currentType = 0
            }
            cycleScrollView.contentOffset = CGPoint(x: view.width * CGFloat((currentType)), y: 0)
            
        }
        let offset = cycleScrollView.contentOffset.x.truncatingRemainder(dividingBy:(levelBannerView.bounds.width * CGFloat(levelPathGroup.count)))
        let percent = Double(offset / total)
        let progress = percent * Double(levelPathGroup.count)
        pageControl.progress = progress
        
    }
}

extension MembershipListVC: ZKCycleScrollViewDataSource {
    
    func numberOfItems(in cycleScrollView: ZKCycleScrollView) -> Int {
        return levelPathGroup.count
    }
    
    func cycleScrollView(_ cycleScrollView: ZKCycleScrollView, cellForItemAt indexPath: IndexPath) -> ZKCycleScrollViewCell {
        let cell = cycleScrollView.dequeueReusableCell(for: indexPath) as! LevelListCell
        
        cell.levelType = indexPath.row
        // cell.imageView.image = UIImage(named: levelPathGroup[indexPath.item])
        return cell
    }
}


extension MembershipListVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        let sjBtn = UIButton().text("立即升级，获取更多特权").textColor(.kColor33).font(14, weight: .bold).cornerRadius(20).masksToBounds()
        let gzView = UIView().cornerRadius(10).borderColor(UIColor.hexColor("#F6E5CA")).borderWidth(0.5)
        
        cell.sv(levelBannerView, sjBtn, gzView)
        cell.layout(
            0,
            |levelBannerView.height(405)|,
            13,
            sjBtn.height(40).centerHorizontally(),
            35,
            |-20-gzView.height(130)-20-|,
            >=100
        )
        sjBtn.width(PublicSize.kScreenWidth-40).height(40)
        sjBtn.backgroundColor(.red)
        sjBtn.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.96, green: 0.85, blue: 0.67, alpha: 1).cgColor, UIColor(red: 0.86, green: 0.62, blue: 0.33, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = sjBtn.bounds
        bgGradient.startPoint = CGPoint(x: 1, y: 0.5)
        bgGradient.endPoint = CGPoint(x: 0, y: 0.5)
        sjBtn.layer.insertSublayer(bgGradient, at: 0)
        
        let lab1 = UILabel().text("会员升级规则").textColor(.kColor33).fontBold(12)
        let lab2 = UILabel().text("1.会员一年内可以升级一次；\n2.支付对应等级的年费，升级成为对应会员；\n3.会员升级后有效期为1年；").textColor(.kColor66).font(12)
        gzView.sv(lab1, lab2)
        gzView.layout(
            25,
            |-15-lab1.height(16.5),
            15,
            |-15-lab2-15-|,
            >=10
        )
        lab2.numberOfLines(0).lineSpace(2)
        sjBtn.addTarget(self, action: #selector(sjBtnClick(btn:)))
        
        levelBannerView.layoutIfNeeded()
        
        return cell
    }
    
    @objc private func sjBtnClick(btn: UIButton) {
        let vc = MembershipLevelsVC()
        navigationController?.pushViewController(vc)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


class LevelListCell: ZKCycleScrollViewCell {
    var levelType: Int? {
        didSet {
            configCell()
        }
    }
    let v = UIView().cornerRadius(10).masksToBounds().backgroundColor(.white)
    let topView = UIView()
    let bottomView = UIView()
    let icon = UIImageView().image(#imageLiteral(resourceName: "level_zzhy"))
    let levelName = UILabel().text("至尊会员").textColor(.white).fontBold(18)
    let invalidTime = UILabel().text("有效期至：2020-10-10").textColor(.white).font(12)
    let bottomIcon = UIImageView().image(#imageLiteral(resourceName: "level_zzhy_2"))
    let currentLevel = UILabel().text("当前等级").textColor(.kColor33).fontBold(12)
    var topViewBgGradient = CAGradientLayer()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        sv(v)
        layout(
            15,
            |-20-v.height(370)-20-|,
            >=0
        )
        v.sv(topView, bottomIcon, bottomView)
        v.layout(
            0,
            |-0-topView.height(100)-0-|,
            0,
            |-0-bottomView.height(270)-0-|,
            0
        )
        v.layout(
            >=0,
            bottomIcon.width(100).height(160)-0-|,
            0
        )
        topView.sv(icon, levelName, invalidTime, currentLevel)
        topView.layout(
            0,
            currentLevel.width(70).height(24)-0-|,
            >=0
        )
        topView.layout(
            25,
            |-15-icon.width(43).height(52),
            >=0
        )
        topView.layout(
            25,
            |-68-levelName.height(25),
            10,
            |-68-invalidTime.height(16.5),
            >=0
        )
        currentLevel.width(70).height(24)
        currentLevel.textAligment(.center)
        currentLevel.corner(byRoundingCorners: [.topRight, .bottomLeft], radii: 10)
       // currentLevel.layoutIfNeeded()
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.96, green: 0.85, blue: 0.67, alpha: 1).cgColor, UIColor(red: 0.86, green: 0.62, blue: 0.33, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = currentLevel.bounds
        bgGradient.startPoint = CGPoint(x: 1, y: 0.18)
        bgGradient.endPoint = CGPoint(x: 0, y: 0.18)
        currentLevel.layer.insertSublayer(bgGradient, at: 0)
        
        let currentLevel1 = UILabel().text("当前等级").textColor(.kColor33).fontBold(12)
        currentLevel.sv(currentLevel1)
        currentLevel1.centerInContainer()
        
       // currentLevel
        
        topView.layoutIfNeeded()
        topViewBgGradient.locations = [0, 1]
        topViewBgGradient.frame = topView.bounds
        topViewBgGradient.startPoint = CGPoint(x: 1, y: 0.18)
        topViewBgGradient.endPoint = CGPoint(x: 0, y: 0.18)
        topView.layer.insertSublayer(topViewBgGradient, at: 0)
        
        configCell()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell() {
        
        var currentType = UserData.shared.userInfoModel?.yzbVip?.vipType ?? 1
        if currentType == 999 {
            currentType = 0
        }
        let type = levelType
        if currentType == type {
            currentLevel.isHidden = false
            let validEndDate = UserData.shared.userInfoModel?.yzbVip?.validEndDate ?? ""
            let validEndDate1 = validEndDate.components(separatedBy: " ").first
            invalidTime.text("有效期至：\(validEndDate1 ?? "")")
            invalidTime.isHidden = false
            
        } else {
            currentLevel.isHidden = true
            invalidTime.isHidden = true
        }
        v.borderColor(UIColor.hexColor("#4D4D4D")).borderWidth(0.5)
        
        var levelTitles = ["代金券", "VR特权", "参与活动", "官网宣传", "媒体推广", "颁发牌匾", "年费特免", "闭门会议", "国际会议", "工作会议", "人脉资源圈", "项目推荐"]
        var levelIcons = [#imageLiteral(resourceName: "level_djq"), #imageLiteral(resourceName: "level_vr"), #imageLiteral(resourceName: "level_hd"), #imageLiteral(resourceName: "level_xc"), #imageLiteral(resourceName: "level_mttg"), #imageLiteral(resourceName: "level_pb"), #imageLiteral(resourceName: "level_tm"), #imageLiteral(resourceName: "level_bmhy"), #imageLiteral(resourceName: "level_gjhy"), #imageLiteral(resourceName: "level_gzhy"), #imageLiteral(resourceName: "level_rmzy"), #imageLiteral(resourceName: "level_xmtj")]
        var levelColor = UIColor.hexColor("#121212")
        let btnH: CGFloat = 66.5
        let btnW: CGFloat = (PublicSize.kScreenWidth-40)/4
        
        switch type {
        case 0, 999:
            _ = levelName.text("体验会员")
            _ = v.borderColor(UIColor.hexColor("#F9D773"))
            icon.image(#imageLiteral(resourceName: "level_tyhy_0"))
            bottomIcon.image(#imageLiteral(resourceName: "level_tyhy_1"))
            levelTitles = ["系统使用", "账号特权", "优惠券", "会员价", "专区权益"]
            levelIcons = [#imageLiteral(resourceName: "level_tyhy_2"), #imageLiteral(resourceName: "level_tyhy_3"), #imageLiteral(resourceName: "level_tyhy_4"), #imageLiteral(resourceName: "level_tyhy_5"), #imageLiteral(resourceName: "level_tyhy_6")]
            levelColor = UIColor.hexColor("#3B300F")
            topViewBgGradient.colors = [UIColor(red: 0.98, green: 0.84, blue: 0.45, alpha: 1).cgColor, UIColor(red: 0.57, green: 0.46, blue: 0.15, alpha: 1).cgColor]
        case 1:
            _ = levelName.text("普通会员")
            _ = v.borderColor(UIColor.hexColor("#B2EEDD"))
            icon.image(#imageLiteral(resourceName: "level_pthy"))
            bottomIcon.image(#imageLiteral(resourceName: "level_pthy_2"))
            levelTitles = []
            topViewBgGradient.colors = [UIColor(red: 0.69, green: 0.93, blue: 0.86, alpha: 1).cgColor, UIColor(red: 0.15, green: 0.67, blue: 0.52, alpha: 1).cgColor]
        case 2:
            _ = levelName.text("中级会员")
            _ = v.borderColor(UIColor.hexColor("#72CBB0"))
            icon.image(#imageLiteral(resourceName: "level_zjhy"))
            bottomIcon.image(#imageLiteral(resourceName: "level_zjhy_2"))
            levelTitles = ["代金券", "VR特权", "参与活动"]
            levelIcons = [#imageLiteral(resourceName: "level_djq"), #imageLiteral(resourceName: "level_vr"), #imageLiteral(resourceName: "level_hd")]
            levelColor = UIColor.hexColor("#105742")
            topViewBgGradient.colors = [UIColor(red: 0.69, green: 0.93, blue: 0.86, alpha: 1).cgColor, UIColor(red: 0.15, green: 0.67, blue: 0.52, alpha: 1).cgColor]
        case 3:
            _ = levelName.text("VIP会员")
            _ = v.borderColor(UIColor.hexColor("#E3AF89"))
            icon.image(#imageLiteral(resourceName: "level_viphy"))
            bottomIcon.image(#imageLiteral(resourceName: "level_viphy_2"))
            levelTitles = ["代金券", "VR特权", "参与活动", "颁发牌匾", "闭门会议"]
            levelIcons = [#imageLiteral(resourceName: "level_djq"), #imageLiteral(resourceName: "level_vr"), #imageLiteral(resourceName: "level_hd"), #imageLiteral(resourceName: "level_pb"), #imageLiteral(resourceName: "level_bmhy")]
            levelColor = UIColor.hexColor("#6B4930")
            topViewBgGradient.colors = [UIColor(red: 0.89, green: 0.68, blue: 0.53, alpha: 1).cgColor, UIColor(red: 0.66, green: 0.44, blue: 0.27, alpha: 1).cgColor]
        case 4:
            _ = levelName.text("白金会员")
            _ = v.borderColor(UIColor.hexColor("#C8C3DC"))
            icon.image(#imageLiteral(resourceName: "level_bjhy"))
            bottomIcon.image(#imageLiteral(resourceName: "level_bjhy_2"))
            levelTitles = ["代金券", "VR特权", "参与活动", "官网宣传", "颁发牌匾", "闭门会议", "国际会议", "工作会议", "项目推荐"]
            levelIcons = [#imageLiteral(resourceName: "level_djq"), #imageLiteral(resourceName: "level_vr"), #imageLiteral(resourceName: "level_hd"), #imageLiteral(resourceName: "level_xc"), #imageLiteral(resourceName: "level_pb"), #imageLiteral(resourceName: "level_bmhy"), #imageLiteral(resourceName: "level_gjhy"), #imageLiteral(resourceName: "level_gzhy"), #imageLiteral(resourceName: "level_xmtj")]
            levelColor = UIColor.hexColor("#615A78")
            topViewBgGradient.colors = [UIColor(red: 0.78, green: 0.76, blue: 0.86, alpha: 1).cgColor, UIColor(red: 0.53, green: 0.51, blue: 0.59, alpha: 1).cgColor]
        case 5:
            _ = levelName.text("钻石会员")
            _ = v.borderColor(UIColor.hexColor("#C6A37A"))
            icon.image(#imageLiteral(resourceName: "level_zshy"))
            bottomIcon.image(#imageLiteral(resourceName: "level_zshy_2"))
            levelTitles = ["代金券", "VR特权", "参与活动", "官网宣传", "颁发牌匾", "闭门会议", "国际会议", "工作会议", "项目推荐"]
            levelIcons = [#imageLiteral(resourceName: "level_djq"), #imageLiteral(resourceName: "level_vr"), #imageLiteral(resourceName: "level_hd"), #imageLiteral(resourceName: "level_xc"), #imageLiteral(resourceName: "level_pb"), #imageLiteral(resourceName: "level_bmhy"), #imageLiteral(resourceName: "level_gjhy"), #imageLiteral(resourceName: "level_gzhy"), #imageLiteral(resourceName: "level_xmtj")]
            levelColor = UIColor.hexColor("#3A342E")
            topViewBgGradient.colors = [UIColor(red: 0.77, green: 0.63, blue: 0.47, alpha: 1).cgColor, UIColor(red: 0.49, green: 0.43, blue: 0.39, alpha: 1).cgColor]
        case 6:
            _ = levelName.text("金钻会员")
            _ = v.borderColor(UIColor.hexColor("#E9B56B"))
            icon.image(#imageLiteral(resourceName: "level_jzhy"))
            bottomIcon.image(#imageLiteral(resourceName: "level_jzhy_2"))
            levelColor = UIColor.hexColor("#2A130A")
            topViewBgGradient.colors = [UIColor(red: 0.91, green: 0.7, blue: 0.41, alpha: 1).cgColor, UIColor(red: 0.5, green: 0.27, blue: 0.1, alpha: 1).cgColor]
        case 7:
            _ = levelName.text("至尊会员")
            _ = v.borderColor(UIColor.hexColor("#4D4D4D"))
            icon.image(#imageLiteral(resourceName: "level_zzhy"))
            bottomIcon.image(#imageLiteral(resourceName: "level_zzhy_2"))
            levelColor = UIColor.hexColor("#121212")
            topViewBgGradient.colors = [UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1).cgColor, UIColor(red: 0.17, green: 0.17, blue: 0.17, alpha: 1).cgColor]
        default:
            break
        }
        bottomView.removeSubviews()
        if levelTitles.count > 0 {
            levelTitles.enumerated().forEach { (item) in
                let index = item.offset
                let title = item.element
                let offsetY: CGFloat = 20 + CGFloat(btnH + 15) * CGFloat(index / 4)
                let offsetX: CGFloat = btnW * CGFloat(index % 4)
                let btn = UIButton()
                bottomView.sv(btn)
                bottomView.layout(
                    offsetY,
                    |-offsetX-btn.width(btnW).height(btnH),
                    >=0
                )
                let btn1 = UIButton().image(levelIcons[index]).cornerRadius(20).masksToBounds().backgroundColor(levelColor)
                let titleLab = UILabel().text(title).textColor(.kColor33).fontBold(12)
                btn.sv(btn1, titleLab)
                btn.layout(
                    0,
                    btn1.size(40).centerHorizontally(),
                    >=0,
                    titleLab.height(16.5).centerHorizontally(),
                    0
                )
            }
        } else {
            let noDataLab = UILabel().text("暂无更多特权").textColor(.kColor33).fontBold(12)
            bottomView.sv(noDataLab)
            bottomView.layout(
                20,
                |-15-noDataLab.height(16.5),
                >=0
            )
            
        }
        
        
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
