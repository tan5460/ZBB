//
//  MyMoneyBagVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/19.
//

import UIKit
import ObjectMapper

class MyMoneyBagVC: UIViewController {

    private var tableView = UITableView.init(frame: .zero, style: .grouped).backgroundColor(.kBackgroundColor)
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "我的钱包"
        
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
    
    private var infoModel: MoneyBagInfoModel?
    func loadData() {
        let parameters = Parameters()
        let urlStr = APIURL.moneyBagInfo + (UserData1.shared.tokenModel?.userId ?? "")
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.infoModel = Mapper<MoneyBagInfoModel>().map(JSON: dataDic as! [String : Any])
                self.tableView.reloadData()
            }
            self.tableView.endHeaderRefresh()
        }) { (error) in
            self.tableView.endHeaderRefresh()
        }
    }
}

extension MyMoneyBagVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            configSection0(cell: cell)
        case 1:
            configSection1(cell: cell)
        default:
            break
        }
        return cell
    }
    
    
    func configSection0(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            14.5,
            |-14-v-14-|,
            10
        )
        v.width(view.width-28).height(170)
        v.cornerRadius(10).addShadowColor()
        
        
        let topView = UIView()
        let qbIV = UIImageView().image(#imageLiteral(resourceName: "bg_qb"))
        v.sv(topView, qbIV)
        v.layout(
            0,
            |topView.width(view.width-28).height(130)|,
            >=0
        )
        v.layout(
            50,
            qbIV.width(120).height(80)-0-|,
            >=0
        )
        topView.corner(byRoundingCorners: [.topLeft, .topRight], radii: 10)
        topView.fillGreenColorLF()
        
        let lab1 = UILabel().text("可用金额").textColor(.white).font(14)
        
        let priceLabel = UILabel().text("¥\(infoModel?.accountAmount?.doubleValue ?? 0)").textColor(.white).font(24)
        v.sv(lab1, priceLabel)
        v.layout(
            30,
            |-15-lab1.height(20),
            24,
            |-15-priceLabel.height(33.5),
            >=0
        )
        let circleView1 = UIView().cornerRadius(3).borderColor(.k1DC597).borderWidth(1)
        let allMoneyLabel = UILabel().text("总收益：¥\(infoModel?.accountTotalAmount?.doubleValue ?? 0)").textColor(.kColor66).font(14)
        let line = UIView().backgroundColor(UIColor.hexColor("#D6D6D6"))
        let circleView2 = UIView().cornerRadius(3).borderColor(.k1DC597).borderWidth(1)
        let txLabel = UILabel().text("已提现：¥\(infoModel?.withdrawAmount?.doubleValue ?? 0)").textColor(.kColor66).font(14)
        v.sv(circleView1, allMoneyLabel, line, circleView2, txLabel)
        v.layout(
            >=0,
            |-15-circleView1.size(6)-7-allMoneyLabel-(>=0)-line.width(0.5).height(13).centerHorizontally()-15-circleView2.size(6)-7-txLabel-(>=0)-|,
            17
        )
    }
    
    func configSection1(cell: UITableViewCell) {
        cell.backgroundColor(.kBackgroundColor)
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v.height(96)-14-|,
            10
        )
        v.cornerRadius(10).addShadowColor()
        
        let btnW: CGFloat = (view.width-28)/4
        let btnH: CGFloat = 96
        
 
        let images = [#imageLiteral(resourceName: "qb_tx"), #imageLiteral(resourceName: "qb_txjl"), #imageLiteral(resourceName: "qb_symx"), #imageLiteral(resourceName: "qb_share")]
        let titles = ["提现", "提现记录", "收益明细", "我要分享"]
        titles.enumerated().forEach { (item) in
            let index = item.offset
            let element = item.element
            let image = images[index]
            let offsetX: CGFloat = btnW * CGFloat(index)
            let btn = UIButton().image(image).text(element).textColor(.kColor33).font(14)
            
            v.sv(btn)
            v.layout(
                0,
                |-offsetX-btn.width(btnW).height(btnH),
                0
            )
            btn.layoutButton(imageTitleSpace: 10)
            btn.tapped { [weak self] (tapBtn) in
                self?.buttonClick(index: index)
            }
        }
    }
    
    private func buttonClick(index: Int) {
        switch index {
        case 0:
            let vc = MyMoneyBgTXVC()
            vc.infoModel = infoModel
            navigationController?.pushViewController(vc)
        case 1:
            let vc = MyMoneyBagTXRecordVC()
            navigationController?.pushViewController(vc)
        case 2:
            let vc = MyMoneyBagSYMXVC()
            navigationController?.pushViewController(vc)
        case 3:
            let vc = SharePosterVC()
            navigationController?.pushViewController(vc)
        default:
            break
        }
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



class MoneyBagInfoModel : NSObject, Mappable {
    
    var accountAmount : NSNumber? // 可用余额
    var accountName : String? // 账户名
    var accountStatus : Int? // 账户状态:0.关闭,1.开启,2.冻结
    var accountTotalAmount : NSNumber? // 总收益
    var accountType : Int? // 账户类型:1.供应商,2.家装公司
    var createDate : String?
    var delFlag : String?
    var id : String?
    var updateDate : String?
    var withdrawAmount : NSNumber? // 提现总金额

    required init?(map: Map){
    }
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        accountAmount <- map["accountAmount"]
        accountName <- map["accountName"]
        accountStatus <- map["accountStatus"]
        accountTotalAmount <- map["accountTotalAmount"]
        accountType <- map["accountType"]
        createDate <- map["createDate"]
        delFlag <- map["delFlag"]
        id <- map["id"]
        updateDate <- map["updateDate"]
        withdrawAmount <- map["withdrawAmount"]
        
    }

}
