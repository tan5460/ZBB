//
//  CompanyCertificateVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/8/12.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import ObjectMapper

class CompanyCertificateVC: BaseViewController {
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    var storeId: String?
    var detailModel: CertificateListModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "企业证书"
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
        tableView.refreshHeader { [weak self] in
            self?.loadData()
        }
        loadData()
    }
    
    func loadData() {
        var parameters = Parameters()
        parameters["storeId"] = storeId
        YZBSign.shared.request(APIURL.getCertificateList, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.detailModel = Mapper<CertificateListModel>().map(JSON: dataDic as! [String : Any])
            }
            self.tableView.reloadData()
            self.tableView.endHeaderRefresh()
        }) { (error) in
            self.tableView.endHeaderRefresh()
        }
    }

}


extension CompanyCertificateVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.kBackgroundColor)
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            configSection0(cell)
        case 1:
            configSection1(cell, indexPath: indexPath)
        case 2:
            configSection2(cell, indexPath: indexPath)
        default:
            break
        }
        return cell
    }
    
    func configSection0(_ cell: UITableViewCell) {
        let v = UIView().cornerRadius(5).backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        let title = UILabel().text("营业执照").textColor(.kColor33).fontBold(14)
        let icon = UIImageView().image(#imageLiteral(resourceName: "loading")).cornerRadius(5)
        v.sv(title, icon)
        v.layout(
            15,
            |-15-title.height(20),
            10,
            |-15-icon.height(219)-15-|,
            15
        )
        icon.contentMode = .scaleAspectFit
        icon.masksToBounds()
        if !icon.addImage(detailModel?.licenseUrl) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        icon.isUserInteractionEnabled = true
        icon.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapSection0)))
    }
    
    @objc private func tapSection0() {
        let phoneVC = IMUIImageBrowserController()
        let urlStr = APIURL.ossPicUrl + (detailModel?.licenseUrl ?? "")
        let url = URL.init(string: urlStr)
        if let url1 = url {
            phoneVC.imageArr = [url1]
            phoneVC.imgCurrentIndex = 0
            phoneVC.title = "查看大图"
            phoneVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(phoneVC)
        }
    }
    
    @objc private func tapSection1(tap: UITapGestureRecognizer) {
        let phoneVC = IMUIImageBrowserController()
        let urlStr = APIURL.ossPicUrl + (detailModel?.qualificationCertificate?[tap.view?.tag ?? 0].fileUrl ?? "")
        let url = URL.init(string: urlStr)
        if let url1 = url {
            phoneVC.imageArr = [url1]
            phoneVC.imgCurrentIndex = 0
            phoneVC.title = "查看大图"
            phoneVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(phoneVC)
        }
    }
    
    
    @objc private func tapSection2(tap: UITapGestureRecognizer) {
        let phoneVC = IMUIImageBrowserController()
        let urlStr = APIURL.ossPicUrl + (detailModel?.other?[tap.view?.tag ?? 0].fileUrl ?? "")
        let url = URL.init(string: urlStr)
        if let url1 = url {
            phoneVC.imageArr = [url1]
            phoneVC.imgCurrentIndex = 0
            phoneVC.title = "查看大图"
            phoneVC.modalPresentationStyle = .overFullScreen
            navigationController?.pushViewController(phoneVC)
        }
    }
    
    func configSection1(_ cell: UITableViewCell, indexPath: IndexPath) {
        if detailModel?.qualificationCertificate?.count == 0 {
            return
        }
        let v = UIView().cornerRadius(5).backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        let title = UILabel().text("资质证书").textColor(.kColor33).fontBold(14)
        v.sv(title)
        v.layout(
            15,
            |-15-title.height(20),
            >=15
        )
        
        let btnW: CGFloat = view.width-58
        let btnH: CGFloat = 219
        detailModel?.qualificationCertificate?.enumerated().forEach { (item) in
            let index = item.offset
            let model = item.element
            let offsetY: CGFloat = 45 + CGFloat(btnH + 10) * CGFloat(index)
            let offsetX: CGFloat = 15
            let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
            v.sv(icon)
            v.layout(
                offsetY,
                |-offsetX-icon.width(btnW).height(btnH),
                >=15
            )
            icon.contentMode = .scaleAspectFit
            icon.cornerRadius(5).masksToBounds()
            if !icon.addImage(model.fileUrl) {
                icon.image(#imageLiteral(resourceName: "loading"))
            }
            icon.isUserInteractionEnabled = true
            icon.tag = index
            icon.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapSection1(tap:))))
        }
    }
    
    func configSection2(_ cell: UITableViewCell, indexPath: IndexPath) {
        if detailModel?.other?.count == 0 {
            return
        }
        let v = UIView().cornerRadius(5).backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        let title = UILabel().text("其他").textColor(.kColor33).fontBold(14)
        v.sv(title)
        v.layout(
            15,
            |-15-title.height(20),
            >=15
        )
        
        let btnW: CGFloat = view.width-58
        let btnH: CGFloat = 219
        detailModel?.other?.enumerated().forEach { (item) in
            let index = item.offset
            let model = item.element
            let offsetY: CGFloat = 45 + CGFloat(btnH + 10) * CGFloat(index)
            let offsetX: CGFloat = 15
            let icon = UIImageView().image(#imageLiteral(resourceName: "loading"))
            v.sv(icon)
            v.layout(
                offsetY,
                |-offsetX-icon.width(btnW).height(btnH),
                >=15
            )
            icon.contentMode = .scaleAspectFit
            icon.cornerRadius(5).masksToBounds()
            if !icon.addImage(model.fileUrl) {
                icon.image(#imageLiteral(resourceName: "loading"))
            }
            icon.isUserInteractionEnabled = true
            icon.tag = index
            icon.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapSection2(tap:))))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return PublicSize.kBottomOffset + 5
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

