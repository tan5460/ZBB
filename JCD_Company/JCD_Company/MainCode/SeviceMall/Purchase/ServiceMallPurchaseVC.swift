//
//  ServiceMallPurchaseVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/22.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import MJRefresh
import Alamofire
import ObjectMapper

class ServiceMallPurchaseVC: BaseViewController, UITextFieldDelegate {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    private var textField = UITextField()
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        let topIV = UIImageView().image(#imageLiteral(resourceName: "service_mall_top"))
        view.sv(topIV)
        view.layout(
           0,
           |topIV| ~ 156.5,
           >=0
        )
        let searchV = UIView().cornerRadius(15).masksToBounds().borderColor(.white).borderWidth(1)
        let searchImage = #imageLiteral(resourceName: "item_search").imageChangeColor(color: .white)
        let searchIV = UIImageView().image(searchImage)
        textField.placeholder("请输入商品名称")
        textField.placeholderColor = .white
        textField.font = .systemFont(ofSize: 12)
        textField.clearButtonMode = .whileEditing
        textField.delegate = self
        
        view.sv(searchV)
        view.layout(
            51,
            |-14-searchV-14-| ~ 30,
            >=0
        )
        searchV.sv(searchIV, textField)
        searchV.layout(
            7.5,
            |-15-searchIV.size(15).centerVertically()-5-textField.height(30)-5-|,
            7.5
        )
        configCollectionViews()
        
//        if !UserDefaults.standard.bool(forKey: UserDefaultStr.firstGuide3) {
//            UserDefaults.standard.set(true, forKey: UserDefaultStr.firstGuide3)
//            loadGuideView()
//        }
    }
    
    func loadGuideView() {
        let guideView = UIView()
        guideView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        guideView.backgroundColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5))
        UIApplication.shared.windows.first?.addSubview(guideView)
        let searchV = UIView().cornerRadius(15).masksToBounds().borderColor(.white).borderWidth(1)
        let searchImage = #imageLiteral(resourceName: "item_search").imageChangeColor(color: .white)
        let searchIV = UIImageView().image(searchImage)
        let textField1 = UITextField()
        textField1.placeholder("请输入商品名称")
        textField1.placeholderColor = .white
        textField1.font = .systemFont(ofSize: 12)
        textField1.clearButtonMode = .whileEditing
        
        guideView.sv(searchV)
        guideView.layout(
            51,
            |-14-searchV-14-| ~ 30,
            >=0
        )
        searchV.sv(searchIV, textField1)
        searchV.layout(
            7.5,
            |-15-searchIV.size(15).centerVertically()-5-textField1.height(30)-5-|,
            7.5
        )
        let guideIV = UIImageView().image(#imageLiteral(resourceName: "guide_2_1"))
        let nextBtn = UIButton().text("下一步").textColor(.white).font(14).borderColor(.white).borderWidth(1).cornerRadius(15)
        guideView.sv(guideIV, nextBtn)
        guideView.layout(
            90.5,
            |-58-guideIV.width(154).height(63),
            5,
            |-95-nextBtn.width(90).height(30),
            PublicSize.kTabBarHeight-8,
            >=0
        )
        nextBtn.tapped {  [weak self] (btn) in
            guideView.removeFromSuperview()
            self?.tabBarController?.selectedIndex = 2
        }
    }
    
    //MARK: - 网络请求
    private var current = 1
    private var itemsData: Array<MaterialsModel> = []
    func loadData() {
        let pageSize = 20
        var parameters: Parameters = [:]
        parameters["current"] = "\(current)"
        parameters["size"] = pageSize
        parameters["cityId"] = UserData.shared.substationModel?.cityId
        parameters["substationId"] = UserData.shared.substationModel?.id
        parameters["name"] = textField.text
        parameters["isOneSell"] = ""
        parameters["materialsType"] = 2
        if current == 1 {
            pleaseWait()
        }
        let urlStr = APIURL.getMaterials
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            //结束刷新
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            self.collectionView.mj_footer?.isHidden = false
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" || errorCode == "015" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                var dataArray = [Any]()
                if UserData.shared.userType == .yys {
                    let dataDic1 = Utils.getReadDic(data: dataDic, field: "page")
                    dataArray = Utils.getReadArr(data: dataDic1, field: "records") as! [Any]
                } else {
                    dataArray = Utils.getReadArr(data: dataDic, field: "records") as! [Any]
                }
                
                let modelArray = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                if self.current > 1 {
                    self.itemsData += modelArray
                }
                else {
                    self.itemsData = modelArray
                }
                
                if modelArray.count < pageSize {
                    self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                }else {
                    self.collectionView.mj_footer?.resetNoMoreData()
                }
                
            }else if errorCode == "008" {
                self.itemsData.removeAll()
            }
            
            self.collectionView.reloadData()
            
            if self.itemsData.count <= 0 {
                self.collectionView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.noDataView.isHidden = true
            }
            self.collectionView.mj_footer?.isHidden = false
        }) { (error) in
            
            //结束刷新
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            
            if self.itemsData.count <= 0 {
                self.collectionView.mj_footer?.isHidden = true
                self.noDataView.isHidden = false
            }else {
                self.collectionView.mj_footer?.isHidden = false
                self.noDataView.isHidden = true
            }
            self.collectionView.mj_footer?.isHidden = false
        }
    }
    
    @objc func headerRefresh() {
        collectionView.mj_footer?.resetNoMoreData()
        current = 1
        loadData()
    }
    
    @objc func footerRefresh() {
        current += 1
        loadData()
    }
    
    private var collectionView: UICollectionView!
    func configCollectionViews() {
        let layout = UICollectionViewFlowLayout.init()
        let w: CGFloat = (view.width-41)/2
        layout.itemSize = CGSize(width: w, height: 205)
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 14, bottom: 15, right: 14)
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 13.0
        collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout).backgroundColor(.clear)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(cellWithClass: ServiceMallPurchaseCell.self)
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        view.sv(collectionView)
        view.layout(
            96,
            |collectionView|,
            0
        )
        collectionView.mj_header = MJRefreshGifCustomHeader()
        collectionView.mj_header?.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        collectionView.mj_footer = MJRefreshAutoNormalFooter()
        collectionView.mj_footer?.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        collectionView.mj_footer?.isHidden = true
        prepareNoDateView("暂无数据")
        noDataView.isHidden = true
        loadData()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        headerRefresh()
    }
}


extension ServiceMallPurchaseVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ServiceMallPurchaseCell.self, for: indexPath)
        cell.model = itemsData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let vc = MaterialsDetailVC()
        vc.materialsModel = itemsData[indexPath.row]
        navigationController?.pushViewController(vc)
    }
}


class ServiceMallPurchaseCell: UICollectionViewCell {
    var model: MaterialsModel? {
        didSet {
            configCell()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor(.white)
        cornerRadius(5).addShadowColor()
        
        sv(icon, titleLab, salePriceLabL, salePriceLabR, vipPriceLabL, vipPriceLabR)
        layout(
            0,
            |icon| ~ 120,
            5,
            |-5-titleLab-5-|,
            >=0,
            |-5-salePriceLabL.height(12.5)-5-salePriceLabR.height(12.5),
            5,
            |-5-vipPriceLabL.height(12.5)-5-vipPriceLabR.height(12.5),
            10
        )
        titleLab.numberOfLines(2).lineSpace(2)
        icon.contentMode = .scaleAspectFit
        icon.corner(byRoundingCorners: [.topLeft, .topRight], radii: 5)
        icon.masksToBounds()
    }
        
    private let icon = UIImageView().image(#imageLiteral(resourceName: "loading_rectangle"))
    private let titleLab = UILabel().text("壁灯安装服务全国师傅上门服务...").font(12).textColor(.kColor33)
    private let salePriceLabL = UILabel().text("¥/平方").textColor(.kColor66).font(12)
    private let salePriceLabR = UILabel().text("销售价").textColor(.kColor66).font(12)
    private let vipPriceLabL = UILabel().text("¥/平方").textColor(.kFFAB3D).font(12)
    private let vipPriceLabR = UILabel().text("会员价").textColor(.kFFAB3D).font(12)
    
    private func configCell() {
        if !icon.addImage(model?.imageUrl) {
            icon.image(#imageLiteral(resourceName: "loading"))
        }
        titleLab.text(model?.name ?? "")
        salePriceLabL.text("¥\(model?.priceSellMin ?? 0)/平方")
        vipPriceLabL.text("¥\(model?.priceSupplyMin1 ?? 0)/平方")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


