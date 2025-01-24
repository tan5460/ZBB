//
//  DistStoreDetailVC.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/7.
//

import UIKit
import ObjectMapper

class DistStoreDetailVC: BaseViewController {
    var brandId: String?
    private var tableView = UITableView.init(frame: .zero, style: .plain)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor(.clear)
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
    private var storeDetailModel: DistStoreDetailModel?
    func loadData() {
        
        pleaseWait()
        var parameters = Parameters()
        parameters["brandId"] = brandId
        YZBSign.shared.request(APIURL.getRegionBrand, method: .get, parameters: parameters) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.storeDetailModel = Mapper<DistStoreDetailModel>().map(JSON: dataDic as! [String : Any])
                self.tableView.reloadData()
                self.title = self.storeDetailModel?.brandName ?? ""
                self.tableView.endHeaderRefresh()
            }
        } failure: { (error) in
            self.tableView.endHeaderRefresh()
        }

    }

    func configSection0(cell: UITableViewCell) {
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            10,
            |-14-v-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        let titleLabel = UILabel().text("品牌介绍").textColor(.kColor33).fontBold(16)
        
        let detailLabel = UILabel().textColor(.kColor33).font(12)
        detailLabel.numberOfLines(0).lineSpace(2)
        let attr = try! NSAttributedString.init(data: storeDetailModel?.brandContent?.data(using: .unicode) ?? Data(), options: [.documentType : NSAttributedString.DocumentType.html], documentAttributes: nil)
        detailLabel.attributedText = attr
        v.sv(titleLabel, detailLabel)
        v.layout(
            15,
            |-15-titleLabel.height(22.5),
            10,
            |-15-detailLabel-15-|,
            15.5
        )
    }

    //MARK: - 菜单栏
    func configSection1(cell: UITableViewCell) {
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v.height(50)-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        let titleLabel = UILabel().text("资质证书").textColor(.kColor33).fontBold(16)
        v.sv(titleLabel)
        v.layout(
            15,
            |-15-titleLabel.height(22.5),
            >=0
        )
        [1, 2].enumerated().forEach { (item) in
            let index = item.offset
            let btn = UIButton().cornerRadius(5).masksToBounds().borderWidth(0.5).borderColor(UIColor.hexColor("#DEDEDE"))
            
            let btnW: CGFloat = CGFloat(view.width-69)/2
            let btnH: CGFloat = 106
            
            let offsetX: CGFloat = 15 + CGFloat(btnW+11) * CGFloat(index%2)
            v.sv(btn)
            v.layout(
                48,
                |-offsetX-btn.width(btnW).height(btnH),
                15
            )
            let iv = UIImageView().image(#imageLiteral(resourceName: "loading"))
            iv.cornerRadius(3).masksToBounds()
            iv.contentMode = .scaleAspectFill
            btn.sv(iv)
            btn.layout(
                3,
                |-3-iv-3-|,
                3
            )
            if index == 0 {
                if !iv.addImage(storeDetailModel?.brandCertpicUrl) {
                    iv.image(#imageLiteral(resourceName: "loading"))
                }
            } else {
                if !iv.addImage(storeDetailModel?.brandManageQualifi) {
                    iv.image(#imageLiteral(resourceName: "loading"))
                }
            }
            btn.tapped { [weak self] (tapBtn) in
                if index == 0 {
                    if let imageUrl = URL.init(string: APIURL.ossPicUrl + (self?.storeDetailModel?.brandCertpicUrl ?? "")) {
                        let phoneVC = IMUIImageBrowserController()
                        phoneVC.imageArr = [imageUrl]
                        phoneVC.imgCurrentIndex = 0
                        phoneVC.modalPresentationStyle = .overFullScreen
                        self?.present(phoneVC, animated: true, completion: nil)
                    }
                } else {
                    if let imageUrl = URL.init(string: APIURL.ossPicUrl + (self?.storeDetailModel?.brandManageQualifi ?? "")) {
                        let phoneVC = IMUIImageBrowserController()
                        phoneVC.imageArr = [imageUrl]
                        phoneVC.imgCurrentIndex = 0
                        phoneVC.modalPresentationStyle = .overFullScreen
                        self?.present(phoneVC, animated: true, completion: nil)
                    }
                }
                 
            }
        }
    }



    //MARK: - VIP会员升级
    func configSection2(cell: UITableViewCell) {
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |-14-v-14-|,
            5
        )
        v.cornerRadius(5).addShadowColor()
        
        let titleLabel = UILabel().text("店铺信息").textColor(.kColor33).fontBold(16)
        let kfLabel = UILabel().text("客服电话：\(storeDetailModel?.servicePhone ?? "")").textColor(.kColor33).font(12)
        let addressLabel = UILabel().text("店铺地址：").textColor(.kColor33).font(12)
        let addressLabel1 = UILabel().text("\(storeDetailModel?.address ?? "未知")").textColor(.kColor33).font(12)
        v.sv(titleLabel, kfLabel, addressLabel, addressLabel1)
        v.layout(
            15,
            |-15-titleLabel.height(22.5),
            10,
            |-15-kfLabel.height(16.5),
            5,
            |-15-addressLabel.width(61).height(16.5),
            >=0
        )
        addressLabel1.numberOfLines(0).lineSpace(2)
        v.layout(
            >=0,
            addressLabel1-15-|,
            15
        )
        addressLabel1.Top == addressLabel.Top + 1
        addressLabel1.Left == addressLabel.Right
        
    }
    
    
}



extension DistStoreDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell().backgroundColor(.clear)
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            configSection0(cell: cell)
        case 1:
            configSection1(cell: cell)
        case 2:
            configSection2(cell: cell)
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.01
        default:
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return UIView()
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return PublicSize.kBottomOffset
        }
        return 0.01
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}


class DistStoreDetailModel : NSObject, Mappable{

    var address : String?
    var brandCertpicUrl : String?
    var brandContent : String?
    var brandManageQualifi : String?
    var brandName : String?
    var servicePhone : String?

    required init?(map: Map){}
    private override init(){
        super.init()
    }

    func mapping(map: Map)
    {
        address <- map["address"]
        brandCertpicUrl <- map["brandCertpicUrl"]
        brandContent <- map["brandContent"]
        brandManageQualifi <- map["brandManageQualifi"]
        brandName <- map["brandName"]
        servicePhone <- map["servicePhone"]
        
    }
}
