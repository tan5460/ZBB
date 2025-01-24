//
//  ZBBCreditAuthDesignPaperApplyViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/2.
//

import UIKit

class ZBBCreditAuthDesignPaperApplyViewController: BaseViewController {

    enum ViewType {
        case new
        case edit
        case check
    }
    
    var type: ViewType = .new
    
    var id: String?
    
    private var bottomView: UIView!
    private var applyBtn: UIButton!
    private var scrollView: UIScrollView!
    private var nameView: ZBBCreditAuthInputItemView!
    private var photoView: ZBBCreditAuthPhotoItemView!
    
    private var fileTitleLabel: UILabel!
    private var fileImageView: UIImageView!
    private var fileLine: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设计图认证"
        createViews()
        requestDesignPaperAuthInfo {[weak self] dict in
            if let fileName = dict["fileName"] as? String {
                self?.nameView.contentText = fileName
            }
            if let fileUrl = dict["fileUrl"] as? String {
                self?.photoView.imageURLs = fileUrl.components(separatedBy: ",")
            }
        }
    }
    
    private func createViews() {
        
        bottomView = UIView()
        bottomView.isHidden = type == .check
        bottomView.backgroundColor = .white
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(54+PublicSize.kBottomOffset)
        }
        
        let bottomLine = UIView()
        bottomLine.backgroundColor = .hexColor("#EFEFEF")
        bottomView.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        applyBtn = UIButton(type: .custom)
        applyBtn.layer.cornerRadius = 22
        applyBtn.layer.masksToBounds = true
        applyBtn.backgroundColor = .hexColor("#007E41")
        applyBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        applyBtn.setTitle("提交", for: .normal)
        applyBtn.setTitleColor(.white, for: .normal)
        applyBtn.addTarget(self, action: #selector(applyBtnAction(_:)), for: .touchUpInside)
        bottomView.addSubview(applyBtn)
        applyBtn.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
        }
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            if type == .check {
                make.bottom.equalTo(0)
            } else {
                make.bottom.equalTo(bottomView.snp.top)
            }
        }
        
        nameView = ZBBCreditAuthInputItemView()
        nameView.title = "图纸名称"
        nameView.placeText = "请输入图纸名称"
        nameView.isEditable = type != .check
        scrollView.addSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        photoView = ZBBCreditAuthPhotoItemView()
        photoView.isRequried = true
        photoView.title = "图纸文件"
        photoView.isEditable = type != .check
        photoView.hideSeparatorLine = true
        scrollView.addSubview(photoView)
        photoView.snp.makeConstraints { make in
            make.top.equalTo(nameView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        }
    }

    @objc private func applyBtnAction(_ sender: UIButton) {
        
        var param = [String : Any]()
        
        //图纸名称
        param["fileName"] = nameView.contentText
        //图纸文件
        param["fileUrl"] = photoView.imageURLs.joined(separator: ",")
        
        if type == .new || id == nil {
            requestApplyAuth(param) {[weak self] in
                let vc = ZBBCreditAuthApplyResultViewController(authType: .designPaper(id: self?.id), result: .wait)
                self?.navigationController?.pushViewController(vc, animated: true)
                //
                if var vcs = self?.navigationController?.viewControllers {
                    vcs.removeAll { $0 == self || $0.isKind(of: ZBBCreditAuthDesignPaperViewController.self) }
                    self?.navigationController?.viewControllers = vcs
                }
            }
        } else if type == .edit {
            param["id"] = id
            requestEditAuth(param) {[weak self] in
                if var vcs = self?.navigationController?.viewControllers {
                    vcs.removeAll { vc in
                        vc.isKind(of: ZBBCreditAuthApplyResultViewController.self)
                    }
                    self?.navigationController?.viewControllers = vcs
                }
                self?.navigationController?.popViewController(animated: true)
            }
        }
        
    }
}

extension ZBBCreditAuthDesignPaperApplyViewController {
    
    private func requestDesignPaperAuthInfo(complete: (([String : Any]) -> Void)?) {
        if let id = id {
            YZBSign.shared.request(APIURL.zbbDesignDrawInfo + id, method: .get) {[weak self] response in
                let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
                if code == 0 {
                    let dict = Utils.getReqDir(data: response as AnyObject) as! [String : Any]
                    complete?(dict)
                } else {
                    let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                    self?.noticeOnlyText(msg)
                    complete?([String : Any]())
                }
            } failure: { error in
                complete?([String : Any]())
            }
        }
    }
    
    private func requestApplyAuth(_ param: [String: Any], success: (() -> Void)?) {
        YZBSign.shared.request(APIURL.zbbDesignDrawApply, method: .post, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                success?()
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            
        }
    }
    
    private func requestEditAuth(_ param: [String: Any], success: (() -> Void)?) {
        YZBSign.shared.request(APIURL.zbbDesignDrawEdit, method: .post, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                success?()
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            
        }
    }
    
}
