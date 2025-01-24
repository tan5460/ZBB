//
//  ZBBDelegationOrderDetailInfoViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/30.
//

import UIKit

class ZBBDelegationOrderDetailInfoViewController: BaseViewController {
    
    var model: ZBBPlatformDelegationOrderModel?
    
    private var scrollView: UIScrollView!
    
    private var statusView: ZBBDelegationOrderDetailInfoItemView!
    private var reasonView: ZBBDelegationOrderDetailInfoItemView!
    private var orderSnView: ZBBDelegationOrderDetailInfoItemView!
    private var orderSnCopyBtn: UIButton!
    private var serviceView: ZBBDelegationOrderDetailInfoItemView!
    private var busiTypeView: ZBBDelegationOrderDetailInfoItemView!
    private var totalFeeView: ZBBDelegationOrderDetailInfoItemView!
    private var userNameView: ZBBDelegationOrderDetailInfoItemView!
    private var phoneView: ZBBDelegationOrderDetailInfoItemView!
    private var locationView: ZBBDelegationOrderDetailInfoItemView!
    private var areaView: ZBBDelegationOrderDetailInfoItemView!
    private var houseView: ZBBDelegationOrderDetailInfoItemView!
    private var timeView: ZBBDelegationOrderDetailInfoItemView!
    private var contractView: ZBBDelegationOrderDetailInfoItemView!
    private var contractDownBtn: UIButton!
    private var contractShareBtn: UIButton!
    
    private var applyEndBtn: UIButton!
    
    private lazy var popVC: ZBBDelegationOrderApplyEndViewController? = {
        let vc = ZBBDelegationOrderApplyEndViewController()
        vc.completeClosure = {[weak self] text in
            self?.requestEnd(text)
        }
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "详细信息"
        createViews()
        refreshViews()
    }
    
    private func createViews() {
        scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(0);
        }

        statusView = ZBBDelegationOrderDetailInfoItemView()
        statusView.leftLabel.text = "状态"
        scrollView.addSubview(statusView)
        statusView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.right.equalTo(0)
            make.width.equalTo(view.snp.width)
        }

        reasonView = ZBBDelegationOrderDetailInfoItemView()
        reasonView.leftLabel.text = "申诉原因"
        scrollView.addSubview(reasonView)
        reasonView.snp.makeConstraints { make in
            make.top.equalTo(statusView.snp.bottom)
            make.left.right.equalTo(0)
        }

        orderSnView = ZBBDelegationOrderDetailInfoItemView()
        orderSnView.leftLabel.text = "订单号"
        scrollView.addSubview(orderSnView)
        orderSnView.snp.makeConstraints { make in
            make.top.equalTo(reasonView.snp.bottom)
            make.left.right.equalTo(0)
        }

        orderSnCopyBtn = UIButton(type: .custom)
        orderSnCopyBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        orderSnCopyBtn.setTitle("复制", for: .normal)
        orderSnCopyBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        orderSnCopyBtn.addTarget(self, action: #selector(orderSnCopyBtnAction(_:)), for: .touchUpInside)
        orderSnView.addSubview(orderSnCopyBtn)
        orderSnCopyBtn.snp.makeConstraints { make in
            make.top.right.bottom.equalTo(0)
            make.width.equalTo(58)
        }
        
        orderSnView.rightLabel.snp.remakeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(100)
            make.right.lessThanOrEqualTo(orderSnCopyBtn.snp.left)
            make.height.greaterThanOrEqualTo(20)
            make.bottom.equalTo(-15)
        }

        serviceView = ZBBDelegationOrderDetailInfoItemView()
        serviceView.leftLabel.text = "服务商"
        scrollView.addSubview(serviceView)
        serviceView.snp.makeConstraints { make in
            make.top.equalTo(orderSnView.snp.bottom)
            make.left.right.equalTo(0)
        }

        busiTypeView = ZBBDelegationOrderDetailInfoItemView()
        busiTypeView.leftLabel.text = "业务类型"
        scrollView.addSubview(busiTypeView)
        busiTypeView.snp.makeConstraints { make in
            make.top.equalTo(serviceView.snp.bottom)
            make.left.right.equalTo(0)
        }

        totalFeeView = ZBBDelegationOrderDetailInfoItemView()
        totalFeeView.leftLabel.text = "总费用"
        scrollView.addSubview(totalFeeView)
        totalFeeView.snp.makeConstraints { make in
            make.top.equalTo(busiTypeView.snp.bottom)
            make.left.right.equalTo(0)
        }

        userNameView = ZBBDelegationOrderDetailInfoItemView()
        userNameView.leftLabel.text = "客户姓名"
        scrollView.addSubview(userNameView)
        userNameView.snp.makeConstraints { make in
            make.top.equalTo(totalFeeView.snp.bottom)
            make.left.right.equalTo(0)
        }

        phoneView = ZBBDelegationOrderDetailInfoItemView()
        phoneView.leftLabel.text = "手机号"
        scrollView.addSubview(phoneView)
        phoneView.snp.makeConstraints { make in
            make.top.equalTo(userNameView.snp.bottom)
            make.left.right.equalTo(0)
        }

        locationView = ZBBDelegationOrderDetailInfoItemView()
        locationView.leftLabel.text = "地区"
        scrollView.addSubview(locationView)
        locationView.snp.makeConstraints { make in
            make.top.equalTo(phoneView.snp.bottom)
            make.left.right.equalTo(0)
        }

        areaView = ZBBDelegationOrderDetailInfoItemView()
        areaView.leftLabel.text = "小区"
        scrollView.addSubview(areaView)
        areaView.snp.makeConstraints { make in
            make.top.equalTo(locationView.snp.bottom)
            make.left.right.equalTo(0)
        }

        houseView = ZBBDelegationOrderDetailInfoItemView()
        houseView.leftLabel.text = "楼栋房号"
        scrollView.addSubview(houseView)
        houseView.snp.makeConstraints { make in
            make.top.equalTo(areaView.snp.bottom)
            make.left.right.equalTo(0)
        }

        timeView = ZBBDelegationOrderDetailInfoItemView()
        timeView.leftLabel.text = "创建时间"
        scrollView.addSubview(timeView)
        timeView.snp.makeConstraints { make in
            make.top.equalTo(houseView.snp.bottom)
            make.left.right.equalTo(0)
        }

        contractView = ZBBDelegationOrderDetailInfoItemView()
        contractView.leftLabel.text = "合同附件"
        contractView.separatorLine.isHidden = true
        scrollView.addSubview(contractView)
        contractView.snp.makeConstraints { make in
            make.top.equalTo(timeView.snp.bottom)
            make.left.right.equalTo(0)
        }

        contractDownBtn = UIButton(type: .custom)
        contractDownBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        contractDownBtn.setTitle("下载", for: .normal)
        contractDownBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        contractDownBtn.addTarget(self, action: #selector(contractDownBtnAction(_:)), for: .touchUpInside)
        contractView.addSubview(contractDownBtn)
        contractDownBtn.snp.makeConstraints { make in
            make.centerY.equalTo(contractView)
            make.height.equalTo(40)
            make.right.equalTo(-58)
            make.width.equalTo(58)
        }
        
        let contractLine = UIView()
        contractLine.backgroundColor = .hexColor("#F0F0F0")
        contractView.addSubview(contractLine)
        contractLine.snp.makeConstraints { make in
            make.left.equalTo(contractDownBtn.snp.right)
            make.centerY.equalTo(contractDownBtn)
            make.height.equalTo(10)
            make.width.equalTo(0.5)
        }
        
        contractShareBtn = UIButton(type: .custom)
        contractShareBtn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        contractShareBtn.setTitle("分享", for: .normal)
        contractShareBtn.setTitleColor(.hexColor("#007E41"), for: .normal)
        contractShareBtn.addTarget(self, action: #selector(contractShareBtnAction(_:)), for: .touchUpInside)
        contractView.addSubview(contractShareBtn)
        contractShareBtn.snp.makeConstraints { make in
            make.centerY.equalTo(contractView)
            make.height.equalTo(40)
            make.right.equalTo(0);
            make.width.equalTo(58)
        }
        
        contractView.rightLabel.snp.remakeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(100)
            make.right.lessThanOrEqualTo(contractDownBtn.snp.left)
            make.height.greaterThanOrEqualTo(20)
            make.bottom.equalTo(-15)
        }
        
        applyEndBtn = UIButton(type: .custom)
        applyEndBtn.layer.cornerRadius = 22
        applyEndBtn.layer.masksToBounds = true
        applyEndBtn.backgroundColor = .hexColor("#007E41")
        applyEndBtn.titleLabel?.font = .systemFont(ofSize: 15)
        applyEndBtn.setTitle("申请结束托管", for: .normal)
        applyEndBtn.setTitleColor(.white, for: .normal)
        applyEndBtn.addTarget(self, action: #selector(applyEndBtnAction(_:)), for: .touchUpInside)
        scrollView.addSubview(applyEndBtn)
        applyEndBtn.snp.makeConstraints { make in
            make.top.equalTo(contractView.snp.bottom).offset(10)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(44)
            make.bottom.equalTo(-34)
        }
    }
    
    private func refreshViews() {
        let status = model?.orderStatus ?? ""
        
        switch status {
        case "1":
            statusView.rightLabel.text = "待签约"
        case "2":
            statusView.rightLabel.text = "托管中"
        case "3":
            statusView.rightLabel.text = "已完成"
        case "4":
            statusView.rightLabel.text = "已终止"
        case "5":
            statusView.rightLabel.text = "申述中"
        default:
            break
        }
        reasonView.isHidden = (model?.appealReason ?? "").count == 0
        reasonView.rightLabel.text = model?.appealReason
        
        orderSnView.rightLabel.text = model?.orderNo
        orderSnView.snp.makeConstraints { make in
            if reasonView.isHidden {
                make.top.equalTo(reasonView)
            } else {
                make.top.equalTo(reasonView.snp.bottom)
            }
            make.left.right.equalTo(0)
        }
        
        serviceView.rightLabel.text = model?.serviceMerchantName
        busiTypeView.rightLabel.text = model?.businessType == "1" ? "半包" : "全包"
        totalFeeView.rightLabel.text = String(format: "¥%.2f", CGFloat(model?.totalAmount ?? 0)/100.0)
        userNameView.rightLabel.text = model?.customerName
        phoneView.rightLabel.text = model?.phoneNumber
        locationView.rightLabel.text = (model?.provName ?? "") + (model?.cityName ?? "") + (model?.regionName ?? "")
        areaView.rightLabel.text = model?.communityName
        houseView.rightLabel.text = model?.buildNo
        timeView.rightLabel.text = model?.createDate
        contractView.rightLabel.text = "装修合同.PDF"
        
        applyEndBtn.isHidden = status != "2"
    }
    
    //MARK: - Action
    
    @objc private func orderSnCopyBtnAction(_ sender: UIButton) {
        UIPasteboard.general.string = model?.orderNo
        noticeOnlyText("复制成功")
    }
    
    @objc private func contractDownBtnAction(_ sender: UIButton) {
        
    }
    
    @objc private func contractShareBtnAction(_ sender: UIButton) {
        
    }
    
    @objc private func applyEndBtnAction(_ sender: UIButton) {
        //
        let popDialog = PopupDialog(viewController: popVC!, transitionStyle: .zoomIn, preferredWidth: 280.0/375.0*SCREEN_WIDTH, tapGestureDismissal: false, panGestureDismissal: false)
        present(popDialog, animated: true)
    }
    
    private func requestEnd(_ reason: String) {
        var param = Parameters()
        param["id"] = model?.id
        param["reason"] = reason
        YZBSign.shared.request(APIURL.zbbOrderApplyTerminate, method: .post, parameters: param) {[weak self] response in
            let code = Utils.getReadInt(dir: response as NSDictionary, field: "code")
            if code == 0 {
                self?.navigationController?.popViewController(animated: true)
                self?.noticeOnlyText("申请成功")
            } else {
                let msg = Utils.getReadString(dir: response as NSDictionary, field: "msg")
                self?.noticeOnlyText(msg)
            }
        } failure: { error in
            
        }
    }
}


//MARK: -

fileprivate class ZBBDelegationOrderDetailInfoItemView: UIView {
    
    var leftLabel: UILabel!
    var rightLabel: UILabel!
    var separatorLine: UIView!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        leftLabel = UILabel()
        leftLabel.font = .systemFont(ofSize: 14)
        leftLabel.textColor = .hexColor("#131313")
        addSubview(leftLabel)
        leftLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(15)
            make.height.equalTo(20)
        }
        
        rightLabel = UILabel()
        rightLabel.font = .systemFont(ofSize: 14, weight: .medium)
        rightLabel.textColor = .hexColor("#131313")
        rightLabel.numberOfLines = 0
        addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(100)
            make.right.lessThanOrEqualTo(-15)
            make.height.greaterThanOrEqualTo(20)
            make.bottom.equalTo(-15)
        }
        
        separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.bottom.equalTo(0)
            make.height.equalTo(0.5)
        }
    }
    
    
    
}
