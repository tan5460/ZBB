//
//  ZBBDelegationOrderCompleteViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit

class ZBBDelegationOrderCompleteViewController: BaseViewController {
    
    ///是否节点验收
    var isCheck: Bool = false
    ///
    var model: ZBBPlatformDelegationOrderNodeModel? {
        didSet {
            tableView.reloadData()
        }
    }

    private var tableView: UITableView!
    
    private var headerView: UIView!
    private var headerContentView: UIView!
    private var headerTitleLabel: UILabel!
    private var headerDescLabel: UILabel!
    
    private var refuseBtn: UIButton?
    private var sureBtn: UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = isCheck ? "节点验收" : "完工照片"
        createViews()
    }
    
    private func createViews() {
        
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .hexColor("#F7F7F7")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = CGFLOAT_MIN
        }
        tableView.register(ZBBDelegationOrderCompleteTimeTableViewCell.self, forCellReuseIdentifier: "TimeCell")
        tableView.register(ZBBDelegationOrderCompletePhotoTableViewCell.self, forCellReuseIdentifier: "PhotoCell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.bottom.equalTo(0)
        }
        
        headerView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, 55))
        tableView.tableHeaderView = headerView
        
        headerContentView = UIView()
        headerContentView.backgroundColor = .white
        headerView.addSubview(headerContentView)
        headerContentView.snp.makeConstraints { make in
            make.top.equalTo(5);
            make.left.bottom.right.equalTo(0)
        }
        
        headerTitleLabel = UILabel()
        headerTitleLabel.text = "节点名称"
        headerTitleLabel.font = .systemFont(ofSize: 14);
        headerTitleLabel.textColor = .hexColor("#131313")
        headerContentView.addSubview(headerTitleLabel)
        headerTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalTo(headerContentView)
        }
        
        headerDescLabel = UILabel()
        headerDescLabel.font = .systemFont(ofSize: 14, weight: .medium)
        headerDescLabel.textColor = .hexColor("#131313")
        headerContentView.addSubview(headerDescLabel)
        headerDescLabel.snp.makeConstraints { make in
            make.left.equalTo(100)
            make.right.lessThanOrEqualTo(-15)
            make.centerY.equalTo(headerContentView)
        }
        
        if isCheck {
            let footerView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, 104))
            tableView.tableFooterView = footerView
            
            refuseBtn = UIButton(type: .custom)
            refuseBtn?.layer.cornerRadius = 22
            refuseBtn?.layer.masksToBounds = true
            refuseBtn?.backgroundColor = .hexColor("#F22C1E")
            refuseBtn?.titleLabel?.font = .systemFont(ofSize: 16)
            refuseBtn?.setTitle("拒绝验收", for: .normal)
            refuseBtn?.setTitleColor(.white, for: .normal)
            refuseBtn?.addTarget(self, action: #selector(refuseBtnAction(_:)), for: .touchUpInside)
            footerView.addSubview(refuseBtn!)
            refuseBtn?.snp.makeConstraints { make in
                make.top.equalTo(30)
                make.left.equalTo(15)
                make.right.equalTo(footerView.snp.centerX).offset(-7.5)
                make.height.equalTo(44)
            }
            
            sureBtn = UIButton(type: .custom)
            sureBtn?.layer.cornerRadius = 22
            sureBtn?.layer.masksToBounds = true
            sureBtn?.backgroundColor = .hexColor("#007E41")
            sureBtn?.titleLabel?.font = .systemFont(ofSize: 16)
            sureBtn?.setTitle("确认验收", for: .normal)
            sureBtn?.setTitleColor(.white, for: .normal)
            sureBtn?.addTarget(self, action: #selector(sureBtnAction(_:)), for: .touchUpInside)
            footerView.addSubview(sureBtn!)
            sureBtn?.snp.makeConstraints { make in
                make.top.equalTo(30)
                make.left.equalTo(footerView.snp.centerX).offset(7.5)
                make.right.equalTo(-15)
                make.height.equalTo(44)
            }
        }
    }
    
    @objc private func refuseBtnAction(_ sender: UIButton) {
        requestOrderAcceptance(false)
    }
    
    @objc private func sureBtnAction(_ sender: UIButton) {
        requestOrderAcceptance(true)
    }
    
    private func requestOrderAcceptance(_ isAcceptance: Bool) {
        var param = Parameters()
        param["id"] = model?.id
        param["acceptanceStatus"] = isAcceptance ? 1 : 2
        YZBSign.shared.request(APIURL.zbbOrderAcceptance, method: .post, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                self?.navigationController?.popViewController(animated: true)
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            
        }

    }
}

extension ZBBDelegationOrderCompleteViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (model?.repairTime ?? "").count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell") as! ZBBDelegationOrderCompleteTimeTableViewCell
                cell.leftLabel.text = "节点名称"
                cell.rightLabel.text = model?.nodeName
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell") as! ZBBDelegationOrderCompleteTimeTableViewCell
                cell.leftLabel.text = "完工时间"
                cell.rightLabel.text = model?.finishTime
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! ZBBDelegationOrderCompletePhotoTableViewCell
                cell.leftLabel.text = "完工照片"
                cell.imgURLs = model?.finishPicture?.components(separatedBy: ",") ?? []
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TimeCell") as! ZBBDelegationOrderCompleteTimeTableViewCell
                cell.leftLabel.text = "整改时间"
                cell.rightLabel.text = model?.repairTime
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell") as! ZBBDelegationOrderCompletePhotoTableViewCell
                cell.leftLabel.text = "整改照片"
                cell.imgURLs = model?.repairPicture?.components(separatedBy: ",") ?? []
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFLOAT_MIN
    }
}
