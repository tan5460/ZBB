//
//  ZBBBTVC.swift
//  JCD_Company
//
//  Created by 巢云 on 2024/12/24.
//

import UIKit

class ZBBBTVC: UIViewController {
    
    private var tableView = UITableView.init(frame: .zero, style: .plain)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "补贴申请"
        setupView()
    }
    
    func setupView() {
        view.backgroundColor(.kF7F7F7)
        
        let topImageView = UIImageView.init(image: UIImage(named: "zbb_bt_top"))
        view.addSubview(topImageView)
        topImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(256.5)
        }
        
        let stepBgView = UIView().backgroundColor(.white)
        view.addSubview(stepBgView)
        stepBgView.snp.makeConstraints { make in
            make.top.equalTo(topImageView.snp_bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(120)
        }
        
        
        let stepImageView = UIImageView.init(image: UIImage(named: "zbb_bt_step"))
        view.addSubview(stepImageView)
        stepImageView.snp.makeConstraints { make in
            make.top.equalTo(topImageView.snp_bottom).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
        }
        
        let line = UIView().backgroundColor(.kF0F0F0)
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.top.equalTo(stepImageView.snp_bottom).offset(15.5)
            make.width.equalTo(stepImageView)
            make.centerX.equalTo(stepImageView)
            make.height.equalTo(0.5)
        }
        
        // 查看补贴政策
        let btzcBtn = UIButton.init(action: { btn in
            print("点击了补贴政策")
        }).text("查看补贴政策 >").textColor(.k007E41).font(11, weight: .bold)
        view.addSubview(btzcBtn)
        btzcBtn.snp.makeConstraints { make in
            make.top.equalTo(line.snp_bottom)
            make.width.equalToSuperview()
            make.height.equalTo(34.5)
        }
        
        let slLabel = UILabel().text("待申领订单").textColor(.kColor13).fontBold(16)
        view.addSubview(slLabel)
        slLabel.snp.makeConstraints { make in
            make.top.equalTo(stepBgView.snp_bottom).offset(15)
            make.left.equalTo(15)
        }
        
        let recordBtn = UIButton.init(action: { btn in
            print("点击了申领补贴")
        }).text("申领记录 >").textColor(.kColor66).font(12)
        view.addSubview(recordBtn)
        recordBtn.snp.makeConstraints { make in
            make.centerY.equalTo(slLabel)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(30)
        }
        
        
        tableView.backgroundColor(.clear)
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
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(stepBgView.snp_bottom).offset(30.5)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-15)
        }
        
        tableView.refreshHeader { [weak self] in
//            self?.loadData()
//            self?.requestAdvertList()
//            self?.loadCaseData()
        }
        
    }
    
    
    
    


}

extension ZBBBTVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor(.kF7F7F7)
        cell.selectionStyle = .none
        let bgView = UIView().backgroundColor(.white)
        cell.contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalTo(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(175)
            make.bottom.equalToSuperview().offset(-10)
        }
        bgView.cornerRadius(10)
        
        let icon = UIImageView.init(image: UIImage.init(named: "zbb_bt_record_icon"))
        bgView.addSubview(icon)
        icon.snp.makeConstraints { make in
            make.top.equalTo(16.5)
            make.left.equalTo(15)
            make.width.height.equalTo(18)
        }
        
        let title = UILabel().text("马可波罗").textColor(.kColor13).fontBold(15)
        bgView.addSubview(title)
        title.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.left.equalTo(icon.snp_right).offset(2)
        }
        
        let time = UILabel().text("2024-10-03").textColor(.kColor66).font(12)
        bgView.addSubview(time)
        time.snp.makeConstraints { make in
            make.centerY.equalTo(icon)
            make.right.equalToSuperview().offset(-15)
        }
        
        let centIcon = UIImageView.init(image: UIImage(named: "home_case_btn_iv4"))
        bgView.addSubview(centIcon)
        centIcon.snp.makeConstraints { make in
            make.left.equalTo(icon)
            make.top.equalTo(icon.snp_bottom).offset(11.5)
            make.width.height.equalTo(65)
        }
        
//        let centTitle = UILabel().text("客厅花纹砖 600*600 抛釉砖").textColor(.kColor13).fontBold(14)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
