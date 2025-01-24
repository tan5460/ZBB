//
//  SelectHouseCell.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/9/17.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit

class SelectHouseCell: UITableViewCell {

    public let containerView = UIView().backgroundColor(.white).borderColor(.white).borderWidth(0.5).cornerRadius(5)
    // 客户
    private let nameLabel = UILabel().text("客户姓名：张三").textColor(.kColor33).font(12)
    private let phoneLabel = UILabel().text("客户电话：15677778888").textColor(.kColor33).font(12)
    private let addressLabel = UILabel().text("小区：湖南省长沙市东风中路268号").textColor(.kColor33).font(12)
    // 收货
    private let nameLabel1 = UILabel().text("客户姓名：张三").textColor(.kColor33).font(12)
    private let phoneLabel1 = UILabel().text("客户电话：15677778888").textColor(.kColor33).font(12)
    private let addressLabel1 = UILabel().text("小区：湖南省长沙市东风中路268号").textColor(.kColor33).font(12)
    public let selectLabel = UILabel().text("已选").textColor(.white).font(10).backgroundColor(.k1DC597)
    private let lineView = UIView().backgroundColor(.k1DC597)
    private let editBtn = UIButton().image(#imageLiteral(resourceName: "house_edit_1")).text(" 编辑").textColor(.white).font(12).backgroundColor(.k2FD4A7)
    private let deleteBtn = UIButton().image(#imageLiteral(resourceName: "house_delete_1")).text(" 删除").textColor(.white).font(12).backgroundColor(.k2FD4A7)
    private let completionBtn = UIButton().text("补全收货信息").textColor(UIColor.hexColor("#FD9C3B")).font(12).borderColor(UIColor.hexColor("#FD9C3B")).borderWidth(0.5).cornerRadius(2)
    
    
    var deleteBlock: (()->())?          //删除block
    var editHouseBlock: (()->())?       //编辑block
    
    var isComplement: Bool = false {
        didSet {
            if isComplement {
                completionBtn.isHidden = false
                [nameLabel1, phoneLabel1, addressLabel1].forEach({
                    $0.isHidden = true
                })
            }else {
                completionBtn.isHidden = true
                [nameLabel1, phoneLabel1, addressLabel1].forEach({
                    $0.isHidden = false
                })
            }
        }
    }
    
    var houseModel: HouseModel? {
        
        didSet {
            nameLabel.text("客户姓名：\(houseModel?.customName ?? "")")
            phoneLabel.text("客户电话：\(houseModel?.customMobile ?? "")")
            addressLabel.text("小区：\(houseModel?.plotName ?? "")\(houseModel?.roomNo ?? "")")
            if let valueStr = houseModel?.expressName, !valueStr.isEmpty{
                isComplement = false
                nameLabel1.text("收货人：\(valueStr)")
            }else {
                isComplement = true
            }
            if let valueStr = houseModel?.expressTel {
                phoneLabel1.text("收货人电话：\(valueStr)")
            }
            if let valueStr = houseModel?.shippingAddress {
                addressLabel1.text("收货地址：\(valueStr)")
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configContainerView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    func configContainerView() {
        sv(containerView)
        layout(
            5,
            |-14-containerView-14-|,
            5
        )
        containerView.layoutIfNeeded()
        containerView.addShadowColor()
        containerView.sv(nameLabel, phoneLabel, addressLabel, nameLabel1, phoneLabel1, addressLabel1, selectLabel, lineView, editBtn, deleteBtn, completionBtn)
        containerView.layout(
            15,
            |-16-nameLabel.height(16.5)-25-phoneLabel,
            10,
            |-15-addressLabel.height(16.5),
            15.5,
            |-15-lineView.height(0.5)-15-|,
            14.5,
            |-16-nameLabel1.height(16.5)-25-phoneLabel1,
            10,
            |-15-addressLabel1-80-|,
            15
        )
        addressLabel1.numberOfLines(0).lineSpace(2)
        containerView.layout(
            0,
            selectLabel.width(40).height(20)-0-|,
            68,
            editBtn.width(55).height(20)-0-|,
            10,
            deleteBtn.width(55).height(20)-0-|,
            >=0
        )
        containerView.layout(
            88,
            |-16-completionBtn.width(90).height(26),
            >=0
        )
        completionBtn.isHidden = true
        selectLabel.corner(byRoundingCorners: [.topRight, .bottomLeft], radii: 5)
        selectLabel.textAligment(.center)
        editBtn.corner(byRoundingCorners: [.topLeft, .bottomLeft], radii: 10)
        deleteBtn.corner(byRoundingCorners: [.topLeft, .bottomLeft], radii: 10)
        editBtn.addTarget(self, action: #selector(editHouseAction))
        deleteBtn.addTarget(self, action: #selector(deleteAction))
        completionBtn.addTarget(self, action: #selector(editHouseAction))
    }
    
    //删除工地
    @objc func deleteAction() {
        
        if let block = deleteBlock {
            block()
        }
    }
    
    //编辑工地
    @objc func editHouseAction() {
        
        if let block = editHouseBlock {
            block()
        }
    }

}
