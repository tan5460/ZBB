//
//  ZBBDelegationFeeDetailViewController.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2024/12/29.
//

import UIKit

class ZBBDelegationFeeDetailViewController: BaseViewController {

    var model: ZBBPlatformDelegationOrderModel?
    private var additionNodes: [ZBBPlatformDelegationOrderNodeModel]?
    
    private var tableView: UITableView!
    
    private var contractView: UIView!
    private var contractLabel: UILabel!
    private var contractPriceLabel: UILabel!
    
    private var addedView: UIView!
    private var addedLabel: UILabel!
    private var addedPriceLabel: UILabel!
    
    private var footerIcon: UIImageView!
    private var totalLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "费用明细"
        createViews()
        
        contractPriceLabel.text = String(format: "¥%.2f", CGFloat(model?.contractAmount ?? 0)/100.0)
        addedPriceLabel.text = String(format: "¥%.2f", CGFloat(model?.totalAdditionalAmount ?? 0)/100.0)
        totalLabel.text = String(format: "合计：¥%.2f", CGFloat(model?.totalAmount ?? 0)/100.0)
        
        model?.orderNodes?.forEach({ nodeModel in
            if let amount = nodeModel.additionalAmount, amount > 0 {
                additionNodes?.append(nodeModel)
            }
        })
        tableView.reloadData()
    }
    
    private func createViews() {
        view.backgroundColor = .hexColor("#F7F7F7")
        
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH, 10))
        tableView.register(ZBBFeeTableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(10)
            make.right.equalTo(-10);
            make.bottom.equalTo(0)
        }
        
        contractView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH - 20, 40))
        contractView.backgroundColor = .white
        contractView.addRoundedCorners(corners: [.topLeft, .topRight], radii: CGSizeMake(10, 10), rect: CGRectMake(0, 0, contractView.width, 40))
        
        contractLabel = UILabel()
        contractLabel.text = "合同款"
        contractLabel.font = .systemFont(ofSize: 15, weight: .medium)
        contractLabel.textColor = .hexColor("#131313")
        contractView.addSubview(contractLabel)
        contractLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.equalTo(20)
        }

        contractPriceLabel = UILabel()
        contractPriceLabel.font = .systemFont(ofSize: 15, weight: .medium)
        contractPriceLabel.textColor = .hexColor("#131313")
        contractView.addSubview(contractPriceLabel)
        contractPriceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(contractLabel)
            make.right.equalTo(-15)
        }

        addedView = UIView(frame: CGRectMake(0, 0, SCREEN_WIDTH - 20, 40))
        addedView.backgroundColor = .white
        
        let addedLine = UIView()
        addedLine.backgroundColor = .hexColor("#F0F0F0")
        addedView.addSubview(addedLine)
        addedLine.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.height.equalTo(0.5)
        }

        addedLabel = UILabel()
        addedLabel.text = "增项费用"
        addedLabel.font = .systemFont(ofSize: 15, weight: .medium)
        addedLabel.textColor = .hexColor("#131313")
        addedView.addSubview(addedLabel)
        addedLabel.snp.makeConstraints { make in
            make.top.left.equalTo(15)
            make.height.equalTo(20)
        }

        addedPriceLabel = UILabel()
        addedPriceLabel.font = .systemFont(ofSize: 15, weight: .medium)
        addedPriceLabel.textColor = .hexColor("#131313")
        addedView.addSubview(addedPriceLabel)
        addedPriceLabel.snp.makeConstraints { make in
            make.centerY.equalTo(addedLabel)
            make.right.equalTo(-15)
        }
        
        footerIcon = UIImageView(image: UIImage(named: "zbbt_dbjc"))
        footerIcon.frame = CGRectMake(0, 0, SCREEN_WIDTH - 20, 65)
        tableView.tableFooterView = footerIcon

        totalLabel = UILabel()
        totalLabel.font = .systemFont(ofSize: 17, weight: .medium)
        totalLabel.textColor = .hexColor("#FF3C2F")
        footerIcon.addSubview(totalLabel)
        totalLabel.snp.makeConstraints { make in
            make.centerX.equalTo(footerIcon)
            make.top.equalTo(15)
            make.height.equalTo(24)
        }
    }
    

}

extension ZBBDelegationFeeDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (additionNodes?.count ?? 0) > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return model?.orderNodes?.count ?? 0
        }
        return additionNodes?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView .dequeueReusableCell(withIdentifier: "Cell") as! ZBBFeeTableViewCell

        if indexPath.section == 0 {
            let nodeModel = model?.orderNodes?[indexPath.row]
            cell.leftLabel.text = (nodeModel?.nodeName ?? "") + "(\(nodeModel?.nodeRatio ?? 0)%)"
            cell.rightLabel.text = String(format: "¥%.2f", CGFloat(nodeModel?.nodeAmount ?? 0)/100.0)
        } else {
            let nodeModel = additionNodes?[indexPath.row]
            cell.leftLabel.text = nodeModel?.nodeName
            cell.rightLabel.text = String(format: "¥%.2f", CGFloat(nodeModel?.additionalAmount ?? 0)/100.0)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return contractView
        }
        if section == 1 {
            return addedView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return contractView.height
        }
        if section == 1 {
            return addedView.height
        }
        return CGFLOAT_MIN
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectMake(0, 0, tableView.width, 10))
        view.backgroundColor = .white
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}





//MARK: -

fileprivate class ZBBFeeTableViewCell: UITableViewCell {
    var leftLabel: UILabel!
    var rightLabel: UILabel!
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createViews()
    }
    
    private func createViews() {
        selectionStyle = .none
        backgroundColor = .white
        
        leftLabel = UILabel()
        leftLabel.font = .systemFont(ofSize: 13, weight: .medium)
        leftLabel.textColor = .hexColor("#666666")
        contentView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.left.equalTo(25)
            make.height.equalTo(18.5)
            make.bottom.equalTo(-5)
        }
        
        rightLabel = UILabel()
        rightLabel.font = .systemFont(ofSize: 13, weight: .medium)
        rightLabel.textColor = .hexColor("#666666")
        contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalTo(contentView)
        }
    }
}
