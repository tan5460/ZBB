//
//  SharePosterVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/27.
//

import UIKit
import TLTransitions

class SharePosterVC: BaseViewController {
    private var shareImage: UIImageView = UIImageView()
    private var pop: TLTransition?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    var tableView = UITableView.init(frame: .zero, style: .grouped)
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
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
        
        let backBtn = UIButton().image(#imageLiteral(resourceName: "back_arrow_white")).backgroundColor(UIColor.hexColor("#000000", alpha: 0.3)).cornerRadius(15.5).masksToBounds()
        view.sv(backBtn)
        view.layout(
            50.5,
            |-14-backBtn.size(31),
            >=0
        )
        
        backBtn.tapped { [weak self] (tapBtn) in
            self?.navigationController?.popViewController()
        }
    }
}

extension SharePosterVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let iv = UIImageView().image(#imageLiteral(resourceName: "share_poster_bg"))
        shareImage = iv
        let ivH: CGFloat = 812 * view.width/375
        cell.sv(iv)
        cell.layout(
            0,
            |iv|,
            0
        )
        iv.height(ivH)
        
        let scanIV = UIImageView().image(#imageLiteral(resourceName: "share_scan"))
        let scanStr = APIURL.webUrl + "/other/jcd-active-h5/#/new-member?invitationCode=\(UserData.shared.storeModel?.invitationCode ?? "")"
        scanIV.image(UIImage.setupQRCodeImage(scanStr, image: nil))
        let shareBtn = UIButton().image(#imageLiteral(resourceName: "share_btn_share")).text(" 活动分享").textColor(UIColor.hexColor("#C2160A")).font(14, weight: .bold)
        
        let saveBtn = UIButton().image(#imageLiteral(resourceName: "share_btn_save")).text(" 保存图片").textColor(UIColor.hexColor("#C2160A")).font(14, weight: .bold)
        
        let scanY: CGFloat = 523 * view.width/375
        let btnY: CGFloat = 692 * view.width/375
        
        iv.sv(scanIV)
        iv.layout(
            scanY,
            scanIV.size(114).centerHorizontally(),
            >=0
        )
        let v = UIView()
        v.sv(shareBtn, saveBtn)
        v.layout(
            0,
            |shareBtn.height(40)-35-saveBtn|,
            0
        )
        shareBtn.width(135).height(40)
        saveBtn.width(135).height(40)
        cell.sv(v)
        cell.layout(
            btnY,
            v.centerHorizontally(),
            >=0
        )
        shareBtn.corner(radii: 23.5)
        fillYellowColor(v: shareBtn)
        
        saveBtn.corner(radii: 23.5)
        fillYellowColor(v: saveBtn)
        
        shareBtn.tapped { [weak self] (tapBtn) in
            self?.share()
        }
        
        saveBtn.tapped { [weak self] (tapBtn) in
            self?.saveImageToPhoto()
        }
        
        return cell
    }
    
    func share() {
        let shareView = ShareSelectView(frame: CGRect(x: 0, y: 0, width: view.width, height: 176)).backgroundColor(.white)
        shareView.shareSelectStyleBlock = { [weak self] (style) in
            self?.pop?.dismiss(completion: {
                let shareImage1 = UIImage.convertViewToImage(v: self?.shareImage ?? UIView())
                let shareImageData = shareImage1.jpegData(compressionQuality: 1)
                let manager = ShareManager.init(data: shareImageData, vc: self)
                manager.shareSelectStyle = style
                manager.share()
            })
        }
        shareView.cancelBtnBlock = { [weak self] in
            self?.pop?.dismiss()
        }
        pop = TLTransition.show(shareView, popType: TLPopTypeActionSheet)
        pop?.cornerRadius = 0
    }
    
    func saveImageToPhoto() {
            let image = UIImage.convertViewToImage(v: shareImage)
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func saveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error != nil{
            self.noticeOnlyText("保存失败")
        }else{
            self.noticeOnlyText("保存成功")
        }
    }
    
    func fillYellowColor(v: UIView) {
        v.layoutIfNeeded()
        v.layer.shadowColor = UIColor(red: 0.21, green: 0.01, blue: 0, alpha: 0.3).cgColor
        v.layer.shadowOffset = CGSize(width: 2, height: 2)
        v.layer.shadowOpacity = 1
        v.layer.shadowRadius = 8
        // fill
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.82, green: 0.49, blue: 0.09, alpha: 1).cgColor, UIColor(red: 0.98, green: 0.95, blue: 0.63, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = v.bounds
        bgGradient.startPoint = CGPoint(x: 0.59, y: 1)
        bgGradient.endPoint = CGPoint(x: 0.59, y: 0)
        v.layer.insertSublayer(bgGradient, at: 0)
        v.layer.cornerRadius = 23.5;
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
