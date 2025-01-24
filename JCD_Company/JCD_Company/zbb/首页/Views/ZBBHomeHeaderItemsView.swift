//
//  ZBBHomeHeaderItemsView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/20.
//

import UIKit

class ZBBHomeHeaderItemsView: UIView {

    private var itemBtn1: UIButton!
    private var itemBtn2: UIButton!
    private var itemBtn3: UIButton!
    private var itemBtn4: UIButton!
    private var itemBtn5: UIButton!
    private var itemBtn6: UIButton!

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        
        itemBtn1 = createItemBtn(image: "zbb_zxbt", title: "装修补贴")
        itemBtn1.addTarget(self, action: #selector(itemBtnAction(_:)), for: .touchUpInside)
        addSubview(itemBtn1)

        itemBtn2 = createItemBtn(image: "zbb_zxrz", title: "资信认证")
        itemBtn2.addTarget(self, action: #selector(itemBtnAction(_:)), for: .touchUpInside)
        addSubview(itemBtn2)

        itemBtn3 = createItemBtn(image: "zbb_aqjg", title: "安全监管")
        itemBtn3.addTarget(self, action: #selector(itemBtnAction(_:)), for: .touchUpInside)
        addSubview(itemBtn3)

        itemBtn4 = createItemBtn(image: "zbb_zxwq", title: "装修维权")
        itemBtn4.addTarget(self, action: #selector(itemBtnAction(_:)), for: .touchUpInside)
        addSubview(itemBtn4)

        itemBtn5 = createItemBtn(image: "zbb_pttg", title: "平台托管")
        itemBtn5.addTarget(self, action: #selector(itemBtnAction(_:)), for: .touchUpInside)
        addSubview(itemBtn5)

        itemBtn6 = createItemBtn(image: "zbb_xjpj", title: "星级评价")
        itemBtn6.addTarget(self, action: #selector(itemBtnAction(_:)), for: .touchUpInside)
        addSubview(itemBtn6)
        
        [itemBtn1, itemBtn2, itemBtn3, itemBtn4, itemBtn5, itemBtn6].snp.distributeSudokuViews(fixedLineSpacing: 0, fixedInteritemSpacing: 0, warpCount: 3, edgeInset: UIEdgeInsets(top: 10, left: -20, bottom: 10, right: -20))
    }
    
    private func createItemBtn(image: String, title: String) -> UIButton {
        let button = UIButton(type: .custom)
        
        let imageView = UIImageView(image: UIImage(named: image))
        button.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(60)
        }
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .hexColor("#131313")
        button.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.height.equalTo(15)
            make.centerX.equalToSuperview()
        }
        
        return button
    }
    
    @objc private func itemBtnAction(_ sender: UIButton) {
        switch sender {
            case itemBtn1:
                //装修补贴
                if UserData1.shared.tokenModel == nil {
                    getCurrentVC().navigationController?.pushViewController(ZBBLoginViewController(), animated: true)
                    return
                }
                let vc = ZBBDecorationSubsidyViewController()
                getCurrentVC().navigationController?.pushViewController(vc, animated: true)
            case itemBtn2:
                //资信认证
                if UserData1.shared.tokenModel == nil {
                    getCurrentVC().navigationController?.pushViewController(ZBBLoginViewController(), animated: true)
                    return
                }
                let vc = ZBBCreditAuthViewController()
                getCurrentVC().navigationController?.pushViewController(vc, animated: true)
            case itemBtn3:
                //安全监管
                let vc = ZBBSafeSupervisesViewController()
                getCurrentVC().navigationController?.pushViewController(vc, animated: true)
                break
            case itemBtn4:
                //装修维权
                if UserData1.shared.tokenModel == nil {
                    getCurrentVC().navigationController?.pushViewController(ZBBLoginViewController(), animated: true)
                    return
                }
                let vc = ZBBComplaintViewController()
                getCurrentVC().navigationController?.pushViewController(vc, animated: true)
            case itemBtn5:
                //平台托管
                if UserData1.shared.tokenModel == nil {
                    getCurrentVC().navigationController?.pushViewController(ZBBLoginViewController(), animated: true)
                    return
                }
                let vc = ZBBPlatformDelegationViewController()
                getCurrentVC().navigationController?.pushViewController(vc, animated: true)
            case itemBtn6:
                //星级评价
                let vc = ZBBUserEvaluateViewController()
                getCurrentVC().navigationController?.pushViewController(vc, animated: true)
                break
            default:
                break
        }
    }
}
