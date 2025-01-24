//
//  ZBBComplaintApplyViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/4.
//

import UIKit

class ZBBComplaintApplyViewController: BaseViewController {

    var applySuccess: (() -> Void)?
    
    private var bottomView: UIView!
    private var applyBtn: UIButton!
    private var scrollView: UIScrollView!
    
    private var typeView: ZBBCreditAuthSelectItemView!
    private var serviceView: ZBBCreditAuthInputItemView!
    private var descView: ZBBCreditAuthInputItemView!
    private var photoView: ZBBCreditAuthPhotoItemView!
    
    
    private var questionType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我要投诉"
        createViews()
    }
    
    private func createViews() {
        bottomView = UIView()
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
            make.bottom.equalTo(bottomView.snp.top)
        }
        
        
        typeView = ZBBCreditAuthSelectItemView()
        typeView.isRequried = true
        typeView.title = "问题类型"
        typeView.placeText = "请选择"
        typeView.selectedClosure = {
            let titles = ["质量问题", "费用问题", "其他问题"]
            ZBBSelectPopView.show(titles: titles) {[weak self] index in
                self?.questionType = index + 1
                self?.typeView.contentText = titles[index]
            }
        }
        scrollView.addSubview(typeView)
        typeView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
            make.width.equalTo(SCREEN_WIDTH)
        }
        
        serviceView = ZBBCreditAuthInputItemView()
        serviceView.isRequried = true
        serviceView.title = "投诉对象"
        serviceView.placeText = "请输入投诉对象"
        scrollView.addSubview(serviceView)
        serviceView.snp.makeConstraints { make in
            make.top.equalTo(typeView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        descView = ZBBCreditAuthInputItemView()
        descView.isRequried = true
        descView.title = "问题描述"
        descView.placeText = "请输入问题描述"
        scrollView.addSubview(descView)
        descView.snp.makeConstraints { make in
            make.top.equalTo(serviceView.snp.bottom)
            make.left.right.equalTo(0)
        }
        
        photoView = ZBBCreditAuthPhotoItemView()
        photoView.maxCount = 9
        photoView.title = "图片附件"
        photoView.hideSeparatorLine = true
        scrollView.addSubview(photoView)
        photoView.snp.makeConstraints { make in
            make.top.equalTo(descView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        }
    }

    
    @objc private func applyBtnAction(_ sender: UIButton) {
        if questionType <= 0 {
            noticeOnlyText("请选择问题类型")
            return
        }
        if serviceView.contentText.count <= 0 {
            noticeOnlyText("请输入投诉对象")
            return
        }
        if descView.contentText.count <= 0 {
            noticeOnlyText("请输入问题描述")
            return
        }
        var param = Parameters()
        param["problemType"] = questionType
        param["complaintObject"] = serviceView.contentText
        param["problemDescription"] = descView.contentText
        param["problemPicUrl"] = photoView.imageURLs.joined(separator: ",")
        param["phoneNumber"] = UserData.shared.workerModel?.mobile
        param["userId"] = UserData1.shared.tokenModel?.userId
        YZBSign.shared.request(APIURL.zbbDecorationApply, method: .post, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                self?.applySuccess?()
                self?.navigationController?.popViewController(animated: true)
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            
        }
    }
}
