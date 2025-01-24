//
//  ZBBDelegationOrderViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/28.
//

import UIKit
import MJRefresh
import ObjectMapper

class ZBBDelegationOrderViewController: BaseViewController {
    
    var id: String?
    
    private var fakeNavi: UIView!
    
    private var tableView: UITableView!
    private var infoCell: ZBBDelegationOrderInfoCell?
    private var funcCell: ZBBDelegationOrderFuncsCell?

    private var model: ZBBPlatformDelegationOrderModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fakeNavi.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fakeNavi.isHidden = !(navigationController?.viewControllers.contains(self) ?? false)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fakeNavi.isHidden = false
    }
    
    
    
    private func createViews() {
        view.backgroundColor = .hexColor("#F7F7F7")
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 215)
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(0, 1)
        gradientLayer.colors = [UIColor.hexColor("#D1FFF9").cgColor, UIColor.hexColor("#F7F7F7", alpha: 0).cgColor]
        view.layer.addSublayer(gradientLayer)
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "back_nav"), for: .normal)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        view.addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.equalTo(PublicSize.kStatusBarHeight)
            make.left.equalTo(0)
            make.width.height.equalTo(44)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "托管订单"
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = .hexColor("#131313")
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(backBtn)
        }
        
        fakeNavi = UIView()
        fakeNavi.isHidden = true
        fakeNavi.backgroundColor = .white
        view.addSubview(fakeNavi)
        fakeNavi.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(PublicSize.kNavBarHeight)
        }
        
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(ZBBDelegationOrderNodeCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(PublicSize.kNavBarHeight)
            make.left.right.bottom.equalTo(0)
        }
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
    }
    
    @objc private func backAction() {
        navigationController?.popViewController(animated: true)
    }
}

extension ZBBDelegationOrderViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return model?.orderNodes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if infoCell == nil {
                    infoCell = ZBBDelegationOrderInfoCell(style: .default, reuseIdentifier: nil)
                    infoCell?.detailBtnActionClosure = {[weak self] in
                        let vc = ZBBDelegationOrderDetailInfoViewController()
                        vc.model = self?.model
                        self?.navigationController?.pushViewController(vc, animated: true)
                    }
                    infoCell?.protocolBtnActionClosure = {[weak self] in
                        let popVC = ZBBDelegationOrderProtoclPopViewController()
                        let naviVC = self?.getCurrentVC().navigationController
                        popVC.protocolBtnAction = {
                            if let path = Bundle.main.path(forResource: "zbbContract", ofType: "html") {
                                let vc = UIBaseWebViewController()
                                vc.urlStr = URL(fileURLWithPath: path).absoluteString
                                naviVC?.pushViewController(vc, animated: true)
                            }
                        }
                        popVC.sureBtnAction = {[weak self] in
                            self?.requestConfirm()
                        }
                        
                        let popDialog = PopupDialog(viewController: popVC, transitionStyle: .zoomIn, preferredWidth: 280.0/375.0*SCREEN_WIDTH)
                        self?.present(popDialog, animated: true)
                    }
                }
                infoCell?.model = model
                return infoCell!
            } else {
                if funcCell == nil {
                    funcCell = ZBBDelegationOrderFuncsCell(style: .default, reuseIdentifier: nil)
                    funcCell?.selectedFuncClosure = {[weak self] index in
                        switch index {
                            case 0:
                                let vc = ZBBDelegationFeeDetailViewController()
                                vc.model = self?.model
                                self?.navigationController?.pushViewController(vc, animated: true)
                            case 1:
                                let vc = ZBBDelegationPaidRecordViewController()
                                vc.id = self?.model?.id
                                self?.navigationController?.pushViewController(vc, animated: true)
                            case 2:
                                let vc = ZBBDelegationOrderProgressViewController()
                                vc.id = self?.model?.id
                                self?.navigationController?.pushViewController(vc, animated: true)
                            case 3:
                                let vc = ZBBDelegationOrderPaidChangedViewController()
                                vc.id = self?.model?.id
                                self?.navigationController?.pushViewController(vc, animated: true)
                            default:
                                break
                        }
                    }
                }
                return funcCell!
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBDelegationOrderNodeCell
        let nodeModel = model?.orderNodes?[indexPath.row] ?? nil
        cell.model = nodeModel
        cell.leftBtnActionClosure = {[weak self] in
            //查看完工照片
            let vc = ZBBDelegationOrderCompleteViewController()
            vc.model = nodeModel
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        cell.rightBtnActionClosure = {[weak self] in
            let status = nodeModel?.nodeStatus ?? "1"
            if status == "2" {
                //去支付
            } else {
                //去验收
                let vc = ZBBDelegationOrderCompleteViewController()
                vc.isCheck = true
                vc.model = nodeModel
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ZBBDelegationOrderViewController {
    
    private func refreshData() {
        YZBSign.shared.request(APIURL.zbbOrderInfo + (id ?? ""), method: .get) {[weak self] response in
            self?.tableView.mj_header?.endRefreshing()
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                let data = Utils.getReqDir(data: response as AnyObject)
                self?.model = Mapper<ZBBPlatformDelegationOrderModel>().map(JSONObject: data as! [String: Any])
                self?.tableView.reloadData()
                
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: {[weak self] error in
            self?.tableView.mj_header?.endRefreshing()
        }
    }
    
    private func requestConfirm() {
        YZBSign.shared.request(APIURL.zbbOrderConfirm + (id ?? ""), method: .post) {[weak self] response in
            self?.tableView.mj_header?.endRefreshing()
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                self?.refreshData()
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: {[weak self] error in
            self?.tableView.mj_header?.endRefreshing()
        }
    }
    
    
}
