//
//  PayPopView.swift
//  YZB_Company
//
//  Created by Cloud on 2020/2/17.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Then

class PayPopView: UIView {

    let popView = UIView().backgroundColor(.white)
    var payType = 1
    var payBtnBlock: ((_ payType: Int) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3))
        popView.frame = CGRect(x: 0, y:PublicSize.kScreenHeight, width: PublicSize.kScreenWidth, height: 360)
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.popView.frame = CGRect(x: 0, y:PublicSize.kScreenHeight-360, width: PublicSize.kScreenWidth, height: 360)
        }
        
        popView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 20)
        addSubview(popView)
        createPopViewSubViews()
    }
    
    let payTypeBtn1 = UIButton()
    let line1 = UIView().backgroundColor(#colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1))
    let payTypeBtn2 = UIButton()
    let line2 = UIView().backgroundColor(#colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1))
    let payTypeBtn3 = UIButton()
    let line3 = UIView().backgroundColor(#colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1))
    let payBtn = UIButton().text("立即支付").textColor(.white).font(14, weight: .bold).backgroundColor(#colorLiteral(red: 0.9647058824, green: 0.4078431373, blue: 0.2901960784, alpha: 1)).cornerRadius(4)
    
    func createPopViewSubViews() {
        popView.sv(payTypeBtn1, payTypeBtn2, payTypeBtn3, line1, line2, line3, payBtn)
        popView.layout(
            0,
            |payTypeBtn1| ~ 69,
            0,
            |line1| ~ 1,
            0,
            |payTypeBtn2| ~ 69,
            0,
            |line2| ~ 1,
            0,
            |payTypeBtn3| ~ 69,
            0,
            |line3| ~ 1,
            40,
            payBtn.width(140).height(40).centerHorizontally(),
            >=0
        )
        payTypeBtn1.addTarget(self, action: #selector(payTypeBtn1Click))
        payTypeBtn2.addTarget(self, action: #selector(payTypeBtn2Click))
        payTypeBtn3.addTarget(self, action: #selector(payTypeBtn3Click))
        payBtn.addTarget(self, action: #selector(payBtnClick))
        createBtn1SubViews()
        createBtn2SubViews()
        createBtn3SubViews()
    }
    
    @objc func payTypeBtn1Click() {
        yinlianSelectImageView.isHidden = true
        wechatSelectImageView.isHidden = true
        alipaySelectImageView.isHidden = true
        
        yinlianSelectImageView.isHidden = false
        payType = 1
    }
    
    @objc func payTypeBtn2Click() {
        yinlianSelectImageView.isHidden = true
        wechatSelectImageView.isHidden = true
        alipaySelectImageView.isHidden = true
        
        wechatSelectImageView.isHidden = false
        
        payType = 2
    }
    
    @objc func payTypeBtn3Click() {
        yinlianSelectImageView.isHidden = true
        wechatSelectImageView.isHidden = true
        alipaySelectImageView.isHidden = true
        
        alipaySelectImageView.isHidden = false
        
        payType = 3
    }
    
    @objc func payBtnClick() {
        if let block = payBtnBlock {
            block(payType)
        }
        hide()
    }
    
    let yinlianImageView = UIImageView().image("pay_type_icon1")
    let yinlianLab = UILabel().text("银联支付").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(14, weight: .bold)
    let yinlianSelectView = UIView().cornerRadius(11).borderColor(#colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1)).borderWidth(1)
    let yinlianSelectImageView = UIImageView().image("pay_type_select1")
    private func createBtn1SubViews() {
        payTypeBtn1.sv(yinlianImageView, yinlianLab, yinlianSelectView)
        payTypeBtn1.layout(
            24,
            |-29-yinlianImageView-16-yinlianLab-(>=0)-yinlianSelectView.size(22)-50-|
        )
        yinlianSelectView.sv(yinlianSelectImageView)
        yinlianSelectImageView.followEdges(yinlianSelectView)
        yinlianSelectImageView.isHidden = false
        yinlianSelectView.isUserInteractionEnabled = false
        yinlianSelectImageView.isUserInteractionEnabled = false
    }
    
    let wechatImageView = UIImageView().image("pay_type_icon2")
    let wechatLab = UILabel().text("微信支付").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(14, weight: .bold)
    let wechatSelectView = UIView().cornerRadius(11).borderColor(#colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1)).borderWidth(1)
    let wechatSelectImageView = UIImageView().image("pay_type_select2")
    private func createBtn2SubViews() {
        payTypeBtn2.sv(wechatImageView, wechatLab, wechatSelectView)
        payTypeBtn2.layout(
            24,
            |-29-wechatImageView-16-wechatLab-(>=0)-wechatSelectView.size(22)-50-|
        )
        wechatSelectView.sv(wechatSelectImageView)
        wechatSelectImageView.followEdges(wechatSelectView)
        wechatSelectImageView.isHidden = true
        wechatSelectView.isUserInteractionEnabled = false
        wechatSelectImageView.isUserInteractionEnabled = false
    }
    
    let alipayImageView = UIImageView().image("pay_type_icon3")
    let alipayLab = UILabel().text("支付宝支付").textColor(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)).font(14, weight: .bold)
    let alipaySelectView = UIView().cornerRadius(11).borderColor(#colorLiteral(red: 0.8352941176, green: 0.8352941176, blue: 0.8352941176, alpha: 1)).borderWidth(1)
    let alipaySelectImageView = UIImageView().image("pay_type_select3")
    private func createBtn3SubViews() {
        payTypeBtn3.sv(alipayImageView, alipayLab, alipaySelectView)
        payTypeBtn3.layout(
            24,
            |-29-alipayImageView-16-alipayLab-(>=0)-alipaySelectView.size(22)-50-|
        )
        alipaySelectView.sv(alipaySelectImageView)
        alipaySelectImageView.followEdges(alipaySelectView)
        alipaySelectImageView.isHidden = true
        alipaySelectView.isUserInteractionEnabled = false
        alipaySelectImageView.isUserInteractionEnabled = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        hide()
    }
    
    private func hide() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.popView.frame = CGRect(x: 0, y:PublicSize.kScreenHeight, width: PublicSize.kScreenWidth, height: 360)
        }) { [weak self] (end) in
            self?.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
