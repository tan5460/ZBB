//
//  GXGLVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/7/20.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import ObjectMapper
import TLTransitions

class GXGLVC: BaseViewController {
    private var navView = UIView().backgroundColor(.clear)
    private var arrowBtn = UIButton().image(#imageLiteral(resourceName: "back_white"))
    private var titleLab = UILabel().text("供需市场").textColor(.white).fontBold(15)
    private var releaseBtn = UIButton().text("发布").textColor(.white).font(15)
    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.white)
    private var homeModel: GXHomeModel?
    private var pop: TLTransition?
    private var timeTipLabel = UILabel()
    private var timer: Timer?
    
    private var distanceEnds: Int?
    private func starTimerCount() {
        timer?.invalidate()
        timer = nil 
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (seconds) in
            self.distanceEnds = (self.distanceEnds ?? 0) - 1000
            
            self.timeTipLabel.text("疯抢仅剩： \(String.secondsToTimeString(seconds: self.distanceEnds ?? 0))")
            if self.distanceEnds == 0 {
                self.loadData()
                return
            }
        })
        if let timer1 = timer {
            RunLoop.current.add(timer1, forMode: .common)
        }
        
    }
    
    deinit {
        GlobalNotificationer.remove(observer: self, notification: .purchaseRefresh)
        timer?.invalidate()
        timer = nil
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor(.white)
        statusStyle = .lightContent
        GlobalNotificationer.add(observer: self, selector: #selector(refresh), notification: .purchaseRefresh)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.sv(tableView)
        view.layout(
            0,
            |tableView|,
            0
        )
        
        view.sv(navView)
        view.layout(
            0,
            |navView| ~ PublicSize.kNavBarHeight,
            >=0
        )
        navView.sv(arrowBtn, titleLab, releaseBtn)
        navView.layout(
            PublicSize.kStatusBarHeight,
            |-0-arrowBtn.size(44)-(>=0)-titleLab.centerHorizontally()-(>=0)-releaseBtn.size(44)-0-|,
            0
        )
        arrowBtn.addTarget(self, action: #selector(arrowBtnClick(btn:)))
        tableView.refreshHeader { [weak self] in
            self?.loadData()
            self?.tableView.endHeaderRefresh()
        }
        releaseBtn.tapped { [weak self] (btn) in
            self?.releasePopView()
        }
        if !(UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy) {
            releaseBtn.isHidden = true
        } else {
            releaseBtn.isHidden = false
        }
        
        loadData()
    }
    //MARK: - 快捷发布弹出视图
    func releasePopView() {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 221)).backgroundColor(.white)
        let titleLabel = UILabel().text("快捷发布").textColor(.kColor33).fontBold(16)
        let tgBtn = UIButton().text("团购邀请").textColor(UIColor.hexColor("#2D2D2D")).font(12).image(#imageLiteral(resourceName: "gx_tgyq_btn"))
        let closeBtn = UIButton().image(#imageLiteral(resourceName: "gx_close_btn"))
        v.sv(titleLabel, tgBtn, closeBtn)
        v.layout(
            15,
            titleLabel.centerHorizontally(),
            19.5,
            |-27-tgBtn.width(50).height(80),
            >=0,
            closeBtn.size(40).centerHorizontally(),
            6
        )
        tgBtn.layoutButton(imageTitleSpace: 10)
        pop = TLTransition.show(v, popType: TLPopTypeActionSheet)
        pop?.cornerRadius = 10
        
        closeBtn.tapped { [weak self] (btn) in
            self?.pop?.dismiss()
        }
        
        tgBtn.tapped {  [weak self] (btn) in
            self?.pop?.dismiss(completion: {
                let vc = GXTGYQVC()
                self?.navigationController?.pushViewController(vc)
            })
        }
    }
     
   @objc func refresh() {
        loadData()
    }
    
    
    func loadData() {
        YZBSign.shared.request(APIURL.getGXHomeData, method: .get, parameters: Parameters(), success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.homeModel = Mapper<GXHomeModel>().map(JSON: dataDic as! [String : Any])
                let nowSeconds = Int(Date().milliStamp) ?? 0
                let endSeconds = self.homeModel?.promotion?.promotionTime ?? 0
                if endSeconds != 0 {
                    self.timeTipLabel.isHidden = false
                    self.distanceEnds = endSeconds - nowSeconds
                    self.starTimerCount()
                } else {
                    self.timeTipLabel.isHidden = true
                }
                
                self.tableView.reloadData()
            }
        }) { (error) in
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > PublicSize.kNavBarHeight {
            navView.backgroundColor(.white)
            arrowBtn.image(#imageLiteral(resourceName: "detail_back"))
            titleLab.textColor(.kColor33)
            statusStyle = .default
        } else {
            navView.backgroundColor(.clear)
            arrowBtn.image(#imageLiteral(resourceName: "icon_return"))
            titleLab.textColor(.white)
            statusStyle = .lightContent
        }
    }
}

extension GXGLVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.white)
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            let sv = UIScrollView()
            sv.showsHorizontalScrollIndicator = false
            cell.sv(sv)
            cell.layout(
                0,
                |sv.height(75.5)|,
                0
            )
            let titles = ["团购邀请", "工程项目", "招投标信息", "供需信息", "新技术发布", "活动组织"]
            let images = [#imageLiteral(resourceName: "gx_icon_tgyq"), #imageLiteral(resourceName: "gx_icon_gcxm"), #imageLiteral(resourceName: "gx_icon_ztbxx"), #imageLiteral(resourceName: "gx_icon_gxxx"), #imageLiteral(resourceName: "gx_icon_xjsfb"), #imageLiteral(resourceName: "gx_icon_hdzz")]
            let btnW: CGFloat = (view.width-20)/6
            titles.enumerated().forEach { (item) in
                let title = item.element
                let index = item.offset
                let offsetX: CGFloat = 10 + btnW * CGFloat(index)
                let btn = UIButton().image(images[index]).text(title).textColor(.kColor33).font(10)
                sv.sv(btn)
                sv.layout(
                    0,
                    |-offsetX-btn.width(60).height(75.5)-(>=10)-|,
                    0
                )
                btn.layoutButton(imageTitleSpace: 8)
                btn.tag = index
                btn.addTarget(self, action: #selector(btnsClick(btn:)))
            }
        case 1:
            let iv = UIButton().image(#imageLiteral(resourceName: "gx_banner"))
            cell.sv(iv)
            cell.layout(
                0,
                |-21.5-iv.height(82)-21.5-|,
                0
            )
            iv.addTarget(self, action: #selector(ivBtnClick(btn:)))
        case 2:
            let sv = UIScrollView()
            sv.showsHorizontalScrollIndicator = false
            cell.sv(sv)
            cell.layout(
                15,
                |sv.height(164.5)|,
                15
            )
            sv.width(view.width)
            let qcclBtn = UIButton().image(#imageLiteral(resourceName: "gx_img_background_qccl"))
            let xpssBtn = UIButton().image(#imageLiteral(resourceName: "gx_img_background_xpss"))
            sv.sv(qcclBtn, xpssBtn)
            let spaceW = view.width/2 - 180
            sv.layout(
                0,
                |-spaceW-qcclBtn.width(170).height(164.5)-9-xpssBtn.width(181).height(164.5)-spaceW-|,
                0
            )
            sv.layout(
                0,
                
                0
            )
            qcclBtn.width(170)
            xpssBtn.width(181)
            qcclBtn.addTarget(self, action: #selector(qcclBtnClick(btn:)))
            xpssBtn.addTarget(self, action: #selector(xpssBtnClick(btn:)))
            
            
//            let iv1 = UIImageView().image(#imageLiteral(resourceName: "gx_img_t1"))
//            let iv2 = UIImageView().image(#imageLiteral(resourceName: "gx_img_t2"))
//
//            if homeModel?.clearanceActivities?.count == 0 {
//                let noDataBtn = UIButton()
//                noDataBtn.image(#imageLiteral(resourceName: "gx_qc_nodata")).text("活动准备中...").textColor(#colorLiteral(red: 0.7921568627, green: 0.7921568627, blue: 0.7921568627, alpha: 1)).font(12)
//                qcclBtn.sv(noDataBtn)
//                noDataBtn.width(100).height(100)
//                noDataBtn.centerInContainer()
//                noDataBtn.layoutButton(imageTitleSpace: 10)
//            } else {
//                qcclBtn.sv(iv1, iv2)
//                qcclBtn.layout(
//                    37,
//                    |-4-iv1.width(82.5).height(121.5)-1.5-iv2.width(77.5).height(121.5)-4-|,
//                    6
//                )
//            }
//
//            let xpBg = UIImageView().image(#imageLiteral(resourceName: "gx_home_xp_0"))
//            xpssBtn.sv(xpBg)
//            xpssBtn.layout(
//                37,
//                |-6-xpBg-7-|,
//                5.5
//            )
//
//            let iv3 = UIImageView().image(#imageLiteral(resourceName: "gx_home_xp_1"))
//            let iv4 = UIImageView().image(#imageLiteral(resourceName: "gx_home_xp_2"))
//            xpssBtn.sv(iv3, iv4)
//            xpssBtn.layout(
//                37,
//                |-74-iv3.width(32.5).height(11),
//                1,
//                iv4.width(19.5).height(19)-16-|,
//                >=0
//            )
//            let iv3Label = UILabel().text("爆款新品").textColor(.white).font(6.15)
//            iv3.sv(iv3Label)
//            iv3Label.centerInContainer()
//            if homeModel?.clearanceActivities?.count ?? 0 > 0 {
//                let top1Model = homeModel?.clearanceActivities?[0]
//                let ivTop1 = UIImageView().image(#imageLiteral(resourceName: "gx_top1"))
//                let top1Icon = UIImageView().image(#imageLiteral(resourceName: "loading")).cornerRadius(2).masksToBounds()
//                if !top1Icon.addImage(top1Model?.materials?.imageUrl) {
//                    top1Icon.image(#imageLiteral(resourceName: "loading"))
//                }
//                let top1Title = UILabel().text("\(top1Model?.materials?.name ?? "")").textColor(.black).font(6)
//                top1Title.numberOfLines(2).lineSpace(1)
//                top1Title.textAligment(.center)
//                let top1Num = UILabel().text("共\(top1Model?.materialsCount ?? 0)件").textColor(.kColor66).font(4.5)
//                let ivTopLab1 = UILabel().text("TOP1").textColor(.white).fontBold(6)
//                iv1.sv(ivTop1, top1Icon, top1Title, top1Num)
//                iv1.layout(
//                    0,
//                    ivTop1.width(32.5).height(10.5).centerHorizontally(),
//                    18.5,
//                    top1Icon.size(53.5).centerHorizontally(),
//                    12,
//                    |-8.5-top1Title.centerHorizontally()-7.5-|,
//                    >=0,
//                    top1Num.height(5).centerHorizontally(),
//                    4
//                )
//                ivTop1.sv(ivTopLab1)
//                ivTopLab1.centerInContainer()
//            }
//
//            if homeModel?.clearanceActivities?.count ?? 0 > 1 {
//                let top2Model = homeModel?.clearanceActivities?[1]
//                let ivTop2 = UIImageView().image(#imageLiteral(resourceName: "gx_top2"))
//                let top2Icon = UIImageView().image(#imageLiteral(resourceName: "loading")).cornerRadius(2).masksToBounds()
//                if !top2Icon.addImage(top2Model?.materials?.imageUrl) {
//                    top2Icon.image(#imageLiteral(resourceName: "loading"))
//                }
//                let ivTopLab2 = UILabel().text("TOP2").textColor(.white).fontBold(6)
//                let top2Title = UILabel().text("\(top2Model?.materials?.name ?? "")").textColor(.black).font(6)
//                top2Title.numberOfLines(2).lineSpace(1)
//                top2Title.textAligment(.center)
//                let top2Num = UILabel().text("共\(top2Model?.materialsCount ?? 0)件").textColor(.kColor66).font(4.5)
//                iv2.sv(ivTop2, top2Icon, top2Title, top2Num)
//                iv2.layout(
//                    0,
//                    ivTop2.width(32.5).height(10.5).centerHorizontally(),
//                    18.5,
//                    top2Icon.size(53.5).centerHorizontally(),
//                    12,
//                    |-8.5-top2Title.centerHorizontally()-7.5-|,
//                    >=0,
//                    top2Num.height(5).centerHorizontally(),
//                    4
//                )
//                ivTop2.sv(ivTopLab2)
//                ivTopLab2.centerInContainer()
//            }
//
//            if homeModel?.newProductsMaterials?.count ?? 0 > 0 {
//                let xpModel = homeModel?.newProductsMaterials?.first
//                let xpIcon = UIImageView().backgroundColor(.kBackgroundColor)
//                let xpTitle = UILabel().text(xpModel?.materialsName ?? "").textColor(.kColor33).font(7)
//                xpIcon.addImage(xpModel?.materials?.imageUrl)
//                xpssBtn.sv(xpIcon, xpTitle)
//                xpssBtn.layout(
//                    49.5,
//                    |-43.5-xpIcon.height(81)-45.5-|,
//                    1,
//                    |-15-xpTitle-15-|,
//                    >=0
//                )
//                xpTitle.numberOfLines(0).lineSpace(2)
//                xpTitle.textAligment(.center)
//                xpIcon.contentMode = .scaleAspectFit
//
//            } else {
//                iv3.isHidden = true
//                iv4.isHidden = true
//                let noDataBtn = UIButton()
//                noDataBtn.image(#imageLiteral(resourceName: "gx_qc_nodata")).text("暂无新品...").textColor(#colorLiteral(red: 0.7921568627, green: 0.7921568627, blue: 0.7921568627, alpha: 1)).font(12)
//                xpssBtn.sv(noDataBtn)
//                noDataBtn.width(100).height(100)
//                noDataBtn.centerInContainer()
//                noDataBtn.isUserInteractionEnabled = false
//                noDataBtn.layoutButton(imageTitleSpace: 10)
//            }
        case 3:
            let iv = UIImageView().image(#imageLiteral(resourceName: "gx_img_pghd"))
            cell.sv(iv)
            cell.layout(
                0,
                |-9-iv.height(27)-8.5-|,
                0
            )
        case 4:
            let sv = UIScrollView().backgroundColor(.white)
            sv.showsHorizontalScrollIndicator = false
            cell.sv(sv)
            cell.layout(
                7,
                |-8.5-sv.height(119)-8.5-|,
                0
            )
            sv.cornerRadius(5)
            sv.addShadowColor()
            
            let iv = UIImageView().image(#imageLiteral(resourceName: "gx_img_bk_pg"))
            sv.sv(iv)
            sv.layout(
                0,
                iv.width(356).height(119).centerHorizontally(),
                0
            )
            iv.isUserInteractionEnabled = true
            let pgBtn1 = UIButton().image(#imageLiteral(resourceName: "gx_goods1"))
            let pgBtn2 = UIButton().image(#imageLiteral(resourceName: "gx_goods2"))
            let pgBtn3 = UIButton().image(#imageLiteral(resourceName: "gx_goods3"))
            let pgBtn4 = UIButton().image(#imageLiteral(resourceName: "gx_goods4"))
            iv.sv(pgBtn1, pgBtn2, pgBtn3, pgBtn4)
            iv.layout(
                31,
                |-8.5-pgBtn1.size(81)-5-pgBtn2.size(81)-5-pgBtn3.size(81)-5-pgBtn4.size(81)-8.5-|,
                7
            )
            pgBtn1.addTarget(self, action: #selector(pgBtn1Click(btn:)))
            pgBtn2.addTarget(self, action: #selector(pgBtn2Click(btn:)))
            pgBtn3.addTarget(self, action: #selector(pgBtn3Click(btn:)))
            pgBtn4.addTarget(self, action: #selector(pgBtn4Click(btn:)))
        case 5:
            let iv = UIImageView().image(#imageLiteral(resourceName: "gx_img_biaoti"))
            let moreBtn = UIButton()
            timeTipLabel = UILabel().text("疯抢仅剩：").textColor(#colorLiteral(red: 0.3019607843, green: 0.3019607843, blue: 0.3019607843, alpha: 1)).font(10.42)
            if self.distanceEnds == nil || homeModel?.promotion?.promotionMaterials?.count == 0 {
                timeTipLabel.isHidden = true
            }
            cell.sv(iv, moreBtn, timeTipLabel)
            cell.layout(
                15,
                |-(>=0)-iv.width(180.5).height(23.5).centerHorizontally()-(>=0)-moreBtn.width(70).height(30)|,
                20.5
            )
            let moreBtnTitle = UILabel().text("更多").textColor(.black).font(10)
            let moreBtnIV = UIImageView().image(#imageLiteral(resourceName: "gx_icon_arrow"))
            moreBtn.sv(moreBtnTitle, moreBtnIV)
            moreBtnTitle.centerVertically()-5-moreBtnIV.width(13).height(4).centerVertically()-10-|
            moreBtn.addTarget(self, action: #selector(moreBtnClick(btn:)))
            moreBtn.isHidden = true
        case 6:
            
            let thBtn = UIButton().backgroundImage(#imageLiteral(resourceName: "gx_th_bg_image"))
            cell.sv(thBtn)
            cell.layout(
                0,
                |-8.5-thBtn.height(81.5)-8.5-|,
                50
            )
            thBtn.contentMode = .scaleAspectFill
            thBtn.cornerRadius(0).masksToBounds()
            thBtn.tapped { [weak self] (btn) in
                self?.moreBtnClick(btn: btn)
            }
            
//            if homeModel?.promotion?.promotionMaterials?.count ?? 0 > 0 {
//                homeModel?.promotion?.promotionMaterials?.enumerated().forEach { (item) in
//                    let index = item.offset
//                    let materials = item.element
//                    let offsetY: CGFloat = CGFloat( 88 * index )
//                    let btn = UIButton().backgroundColor(.white).cornerRadius(14).masksToBounds()
//                    cell.sv(btn)
//                    cell.layout(
//                        offsetY,
//                        |-8.5-btn.height(81.5)-8.5-|,
//                        >=6.5
//                    )
//                    let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
//                    if !icon.addImage(materials.materials?.imageUrl) {
//                        icon.image(#imageLiteral(resourceName: "loading"))
//                    }
//                    let title = UILabel().text("\(materials.materialsName ?? "")").textColor(.kColor33).font(9.5)
//                    let price1 = UILabel().text("¥\(materials.promotionPrice?.doubleValue ?? 0)").textColor(#colorLiteral(red: 1, green: 0.3137254902, blue: 0.2, alpha: 1)).font(10)
//                    let price2 = UILabel().text("¥\(materials.priceSupply?.doubleValue ?? 0)").textColor(.kColor99).font(8)
//                    let numLabel = UILabel().text("已售\(materials.sellNum ?? 0)件").textColor(.kColor99).font(6)
//                    btn.sv(icon, title, price1, price2, numLabel)
//                    btn.layout(
//                        0,
//                        |icon.size(81.5),
//                        0
//                    )
//                    btn.layout(
//                        12,
//                        |-104-title-9.5-|,
//                        >=0,
//                        |-104-price1.height(10)-7-price2.height(10),
//                        7,
//                        |-104-numLabel.height(6.5),
//                        7.5
//                    )
//                    icon.backgroundColor(.kBackgroundColor)
//                    icon.contentMode = .scaleAspectFit
//                    icon.masksToBounds()
//                    price2.setLabelUnderline()
//                    btn.tag = index
//                    btn.addTarget(self, action: #selector(thBtnsClick(btn:)))
//                }
//            } else {
//                let v = UIView()
//                cell.sv(v)
//                cell.layout(
//                    0,
//                    |v.height(200)|,
//                    0
//                )
//                let noDataBtn = UIButton()
//                noDataBtn.image(#imageLiteral(resourceName: "gx_th_nodata")).text("活动准备中...").textColor(#colorLiteral(red: 0.7921568627, green: 0.7921568627, blue: 0.7921568627, alpha: 1)).font(12)
//                v.sv(noDataBtn)
//                noDataBtn.width(200).height(200)
//                noDataBtn.centerInContainer()
//                noDataBtn.layoutButton(imageTitleSpace: 2)
//            }
            
        default:
            break
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 258
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 258))
        let topV = UIImageView().image(#imageLiteral(resourceName: "gx_img_background_top"))
        v.sv(topV)
        v.layout(
            0,
            |topV.height(200)|,
            >=0
        )
        let releaseBtn = UIButton().image(#imageLiteral(resourceName: "gx_icon_fb")).text("  我的发布：\(homeModel?.publishCount ?? 0)").textColor(.white).font(9)
        let orderBtn = UIButton().image(#imageLiteral(resourceName: "gx_icon_wddd")).text("  我的订单：\(homeModel?.orderCount ?? 0)").textColor(.white).font(9)
        v.sv(releaseBtn, orderBtn)
        v.layout(
            98,
            |releaseBtn.height(30)-0-orderBtn|,
            >=0
        )
        equal(widths: releaseBtn, orderBtn)
        releaseBtn.addTarget(self, action: #selector(releaseBtnClick(btn:)))
        orderBtn.addTarget(self, action: #selector(orderBtnClick(btn:)))
        
        let bottomBtn = UIButton().image(#imageLiteral(resourceName: "gx_img_banner"))
        v.sv(bottomBtn)
        v.layout(
            133,
            |-8.5-bottomBtn.height(124.5)-8.5-|,
            >=0
        )
        bottomBtn.addTarget(self, action: #selector(bottomBtnClick(btn:)))
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - 按钮点击方法
extension GXGLVC {
    @objc private func releaseBtnClick(btn: UIButton) {
        let vc = GXReleaseVC()
        navigationController?.pushViewController(vc)
    }
    
    @objc private func orderBtnClick(btn: UIButton) {
        let vc = GXOrdersVC()
        navigationController?.pushViewController(vc)
    }
    
    @objc private func bottomBtnClick(btn: UIButton) {
        noticeOnlyText("开发中，敬请期待～")
    }
    
    @objc private func btnsClick(btn: UIButton) {
        if btn.tag == 0 {
            let vc = GXGroupInviteVC()
            navigationController?.pushViewController(vc)
        } else {
            noticeOnlyText("开发中，敬请期待～")
        }
        
    }
    
    @objc private func thBtnsClick(btn: UIButton) {
        let vc = MaterialsDetailVC()
        vc.detailType = .th
        let material = MaterialsModel()
        material.id = homeModel?.promotion?.promotionMaterials?[btn.tag].materialsId
        vc.activityId = homeModel?.promotion?.promotionMaterials?[btn.tag].activityId
        vc.materialsModel = material
        navigationController?.pushViewController(vc)
    }
    
    @objc private func ivBtnClick(btn: UIButton) {
        let vc = GXMZTHVC()
        navigationController?.pushViewController(vc)
    }
    
    @objc private func qcclBtnClick(btn: UIButton) {
        let vc = GXQCCLVC()
        navigationController?.pushViewController(vc)
    }
    /// 新品上市
    @objc private func xpssBtnClick(btn: UIButton) {
        let vc = GXNewVC()
        vc.title = "新品上市"
        navigationController?.pushViewController(vc)
    }
    @objc private func pgBtn1Click(btn: UIButton) {
        noticeOnlyText("开发中，敬请期待～")
    }
    @objc private func pgBtn2Click(btn: UIButton) {
        noticeOnlyText("开发中，敬请期待～")
    }
    @objc private func pgBtn3Click(btn: UIButton) {
        noticeOnlyText("开发中，敬请期待～")
    }
    @objc private func pgBtn4Click(btn: UIButton) {
        noticeOnlyText("开发中，敬请期待～")
    }
    
    @objc private func moreBtnClick(btn: UIButton) {
        let vc = GXMZTHVC()
        navigationController?.pushViewController(vc)
    }
    
    @objc private func arrowBtnClick(btn: UIButton) {
        navigationController?.popViewController()
    }
}


