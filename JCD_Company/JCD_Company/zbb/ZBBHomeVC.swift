//
//  ZBBHomeVC.swift
//  JCD_Company
//
//  Created by 巢云 on 2024/12/23.
//


import UIKit
import ObjectMapper

class ZBBHomeVC: BaseViewController, LLCycleScrollViewDelegate {
    
    private var tableView = UITableView.init(frame: .zero, style: .plain)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        
        let topIV = UIImageView().image(#imageLiteral(resourceName: "home_top_bg"))
        view.sv(topIV)
        view.layout(
            0,
            |topIV.height(160)|,
            >=0
        )
        
        topToolsView()
        
        tableView.backgroundColor(.clear)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.sv(tableView)
        view.layout(
            PublicSize.kNavBarHeight,
            |tableView|,
            0
        )
        tableView.refreshHeader { [weak self] in
            self?.loadData()
            self?.requestAdvertList()
            self?.loadCaseData()
        }
        
        //获取用户本地信息
        AppUtils.getLocalUserData()
        loadData()
        requestAdvertList()
        loadCaseData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    
    
    func topToolsView() {
        let logo = UIImageView.init(image: UIImage(named: "zbb_logo"))
        view.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.top.equalTo(PublicSize.kStatusBarHeight + 6.5)
            make.left.equalTo(14)
            make.width.equalTo(31)
            make.height.equalTo(31)
        }
        
        let searchBgView = UIView.init().backgroundColor(.white)
        view.addSubview(searchBgView)
        searchBgView.snp.makeConstraints { make in
            make.centerY.equalTo(logo)
            make.left.equalTo(logo.snp_right).offset(10)
            make.right.equalToSuperview().offset(-40)
            make.height.equalTo(31)
        }
        searchBgView.corner(radii: 15.5)
        
        let msgBtn = UIButton.init(action: {[weak self] btn in
            let vc = ZBBHomeViewController()
            self?.navigationController?.pushViewController(vc, animated: true)
        }).image(UIImage.init(named: "zbb_msg"))
        view.addSubview(msgBtn)
        msgBtn.snp.makeConstraints { make in
            make.centerY.equalTo(logo)
            make.right.equalToSuperview().offset(-3)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
    }
    
    //MARK: - 获取广告图列表
    private var advertModel: AdvertModel?
    func requestAdvertList()  {
        YZBSign.shared.request(APIURL.advertList, method: .get, parameters: Parameters()) { (response) in
            let code = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if code == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.advertModel = Mapper<AdvertModel>().map(JSON: dataDic as! [String : Any])
                self.tableView.reloadData()
            }
            self.tableView.endHeaderRefresh()
        } failure: { (error) in
            self.tableView.endHeaderRefresh()
        }
    }
    
    private var exchangeData: MaterialsCorrcetModel?
    private var exchangeImagePaths:Array<String> = []
    //MARK: - 网络请求
    func loadData() {
        let urlStr = APIURL.getMaterialsList
        YZBSign.shared.request(urlStr, method: .get, parameters: Parameters(), success: { (response) in
            self.tableView.endHeaderRefresh()
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReqDir(data: response as AnyObject)
                self.exchangeData = Mapper<MaterialsCorrcetModel>().map(JSON: dataDic as! [String : Any])
            }
            self.tableView.reloadData()
            
        }) { (error) in
            
            // 结束刷新
            self.tableView.endHeaderRefresh()
        }
    }
    
    private var caseModels: [HouseCaseModel] = []
    func loadCaseData() {
        var storeId = ""
        if let valueStr = UserData.shared.storeModel?.id {
            storeId = valueStr
        }
        let pageSize = 5
        var parameters: Parameters = ["userId": storeId, "size": "\(pageSize)", "current": "1"]
        parameters["citySubstation"] = UserData.shared.substationModel?.id
        let urlStr = APIURL.getHouseCase
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { (response) in
            // 结束刷新
            self.tableView.endHeaderRefresh()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let dataDic = Utils.getReadDic(data: response as AnyObject, field: "data")
                let dataArray = Utils.getReadArr(data: dataDic, field: "records")
                let modelArray = Mapper<HouseCaseModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                self.caseModels = modelArray
                
            }
            self.tableView.reloadData()
        }) { (error) in
            // 结束刷新
            self.tableView.endHeaderRefresh()
        }
    }
    
    //MARK: - banner栏目
    private var cycleScrollView = LLCycleScrollView().then { (cycleScrollView) in
        cycleScrollView.pageControlBottom = 15
        cycleScrollView.customPageControlStyle = .pill
        cycleScrollView.customPageControlTintColor = .k27A27D
        cycleScrollView.customPageControlInActiveTintColor = .white
        cycleScrollView.autoScrollTimeInterval = 4.0
        cycleScrollView.coverImage = UIImage.init(named: "zbb_banner")
        cycleScrollView.placeHolderImage = UIImage.init(named: "zbb_banner")
        cycleScrollView.imageViewContentMode = .scaleToFill
        cycleScrollView.backgroundColor = PublicColor.backgroundViewColor
        cycleScrollView.cornerRadius(10).masksToBounds()
    }
    
    func cycleScrollView(_ cycleScrollView: LLCycleScrollView, didSelectItemIndex index: NSInteger) {
        let model = advertModel?.carouselList?[index]
        if let advertLink = model?.advertLink {
            let vc = UIBaseWebViewController()
            vc.urlStr = advertLink
            if model?.whetherCanShare == "2" {
                vc.isShare = false
            } else {
                vc.isShare = true
            }
            navigationController?.pushViewController(vc)
        }
    }

    func configSection0(cell: UITableViewCell) {
        cell.sv(cycleScrollView)
        cell.layout(
            7,
            |-14-cycleScrollView.height(170)-14-|,
            5
        )
        cycleScrollView.delegate = self
//        var paths = [String]()
//        advertModel?.carouselList?.forEach({ (model) in
//            paths.append("\(APIURL.ossPicUrl)/\(model.advertImg ?? "")")
//        })
//        cycleScrollView.imagePaths = paths
    }
    func configSection1(cell: UITableViewCell) {
        
        // 装修补贴
        let zxbtBtn = UIButton.init { btn in
            
        }.image(UIImage.init(named: "zbb_zxbt"))
        cell.contentView.addSubview(zxbtBtn)
        zxbtBtn.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(30)
            make.width.equalTo(60)
            make.height.equalTo(60)
        }
        
        let zxbtLab = UIButton.init { btn in
            
        }.text("装修补贴").font(11).textColor(.kColor33)
        cell.contentView.addSubview(zxbtLab)
        zxbtLab.snp.makeConstraints { make in
            make.centerX.equalTo(zxbtBtn)
            make.top.equalTo(zxbtBtn.snp_bottom).offset(2)
        }
        
        // 资信认证
        let zxrzBtn = UIButton.init { btn in
            
        }.image(UIImage.init(named: "zbb_zxrz"))
        cell.contentView.addSubview(zxrzBtn)
        zxrzBtn.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(zxbtBtn)
        }
        
        let zxrzLab = UIButton.init { btn in
            
        }.text("资信认证").font(11).textColor(.kColor33)
        cell.contentView.addSubview(zxrzLab)
        zxrzLab.snp.makeConstraints { make in
            make.centerX.equalTo(zxrzBtn)
            make.top.equalTo(zxrzBtn.snp_bottom).offset(2)
        }
        
        
        
        // 安全监管
        let aqjgBtn = UIButton.init { btn in
            
        }.image(UIImage.init(named: "zbb_aqjg"))
        cell.contentView.addSubview(aqjgBtn)
        aqjgBtn.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.right.equalToSuperview().offset(-30)
            make.width.height.equalTo(zxbtBtn)
        }
        
        let aqjgLab = UIButton.init { btn in
            
        }.text("安全监管").font(11).textColor(.kColor33)
        cell.contentView.addSubview(aqjgLab)
        aqjgLab.snp.makeConstraints { make in
            make.centerX.equalTo(aqjgBtn)
            make.top.equalTo(aqjgBtn.snp_bottom).offset(2)
        }
        
        
        // 装修维权
        let zxwqBtn = UIButton.init { btn in
           
        }.image(UIImage.init(named: "zbb_zxwq"))
        cell.contentView.addSubview(zxwqBtn)
        zxwqBtn.snp.makeConstraints { make in
            make.top.equalTo(zxbtBtn.snp_bottom).offset(30)
            make.left.equalTo(30)
            make.width.equalTo(60)
            make.height.equalTo(60)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        let zxwqLab = UIButton.init { btn in
            
        }.text("装修维权").font(11).textColor(.kColor33)
        cell.contentView.addSubview(zxwqLab)
        zxwqLab.snp.makeConstraints { make in
            make.centerX.equalTo(zxwqBtn)
            make.top.equalTo(zxwqBtn.snp_bottom).offset(2)
        }
        
        
        // 平台托管
        let pttgBtn = UIButton.init { btn in
            
        }.image(UIImage.init(named: "zbb_pttg"))
        cell.contentView.addSubview(pttgBtn)
        pttgBtn.snp.makeConstraints { make in
            make.top.equalTo(zxbtBtn.snp_bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(zxbtBtn)
        }
        
        let pttgLab = UIButton.init { btn in
            
        }.text("平台托管").font(11).textColor(.kColor33)
        cell.contentView.addSubview(pttgLab)
        pttgLab.snp.makeConstraints { make in
            make.centerX.equalTo(pttgBtn)
            make.top.equalTo(pttgBtn.snp_bottom).offset(2)
        }
        
        
        // 星级评价
        let xjpjBtn = UIButton.init { btn in
            
        }.image(UIImage.init(named: "zbb_xjpj"))
        cell.contentView.addSubview(xjpjBtn)
        xjpjBtn.snp.makeConstraints { make in
            make.top.equalTo(zxbtBtn.snp_bottom).offset(30)
            make.right.equalToSuperview().offset(-30)
            make.width.height.equalTo(zxbtBtn)
        }
        let xjpjLab = UIButton.init { btn in
            
        }.text("星级评价").font(11).textColor(.kColor33)
        cell.contentView.addSubview(xjpjLab)
        xjpjLab.snp.makeConstraints { make in
            make.centerX.equalTo(xjpjBtn)
            make.top.equalTo(xjpjBtn.snp_bottom).offset(2)
        }
        
        
    }
    
    
    //  补贴专区
    func configSection2(cell: UITableViewCell) {
        let btzqBg = UIImageView.init(image: UIImage(named: "zbb_btzq_bg"))
        cell.contentView.addSubview(btzqBg)
        btzqBg.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalToSuperview().offset(-14)
        }
        
        let btIcon = UIImageView.init(image: UIImage(named: "zbb_bt_icon"))
        btzqBg.addSubview(btIcon)
        btIcon.snp.makeConstraints { make in
            make.top.equalTo(11.5)
            make.left.equalTo(10)
            make.width.height.equalTo(20)
        }
        
        let btLabel = UILabel().text("补贴专区").textColor(.white).fontBold(16)
        btzqBg.addSubview(btLabel)
        btLabel.snp.makeConstraints { make in
            make.left.equalTo(btIcon.snp_right).offset(1.5)
            make.centerY.equalTo(btIcon)
        }

        btzqBg.isUserInteractionEnabled = true
        let moreArrow = UIButton.init(action: { btn in
            
        }).image(UIImage(named: "zbb_more_arrow"))
        btzqBg.addSubview(moreArrow)
        moreArrow.snp.makeConstraints { make in
            make.top.equalTo(9.5)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(24)
        }
        moreArrow.isEnabled = true
        
        let btBtn1 = UIButton.init { btn in
            
        }.backgroundColor(.white)
        btzqBg.addSubview(btBtn1)
        btBtn1.snp.makeConstraints { make in
            make.top.equalTo(42)
            make.left.equalTo(8)
            make.height.equalTo(155)
        }
        btBtn1.cornerRadius(10)
        
        let btImg1 = UIImageView.init(image: UIImage(named: "home_case_btn_iv4"))
        btBtn1.addSubview(btImg1)
        btImg1.snp.makeConstraints { make in
            make.top.equalTo(4.5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(98)
        }
        
        let btRightIcon1 = UIImageView.init(image: UIImage.init(named: "zbb_bt_right"))
        btImg1.addSubview(btRightIcon1)
        btRightIcon1.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(34)
            make.height.equalTo(17)
        }
        
        let btLabel1 = UILabel.init().text("TCL电视机").fontBold(12).textColor(.kColor13).textAligment(.center)
        btBtn1.addSubview(btLabel1)
        btLabel1.snp.makeConstraints { make in
            make.top.equalTo(btImg1.snp_bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(16.5)
            make.width.equalToSuperview()
        }
        
        let btDetailLabel1 = UILabel.init().text("最高补¥2000").fontBold(10).textColor(.kFF3C2F).textAligment(.center)
        btBtn1.addSubview(btDetailLabel1)
        btDetailLabel1.snp.makeConstraints { make in
            make.top.equalTo(btLabel1.snp_bottom).offset(1.5)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalToSuperview()
        }
        
        
        
        
        
        let btBtn2 = UIButton.init { btn in
            
        }.backgroundColor(.white)
        btzqBg.addSubview(btBtn2)
        btBtn2.snp.makeConstraints { make in
            make.top.equalTo(42)
            make.left.equalTo(btBtn1.snp_right).offset(5)
            make.height.equalTo(155)
            make.width.equalTo(btBtn1)
        }
        btBtn2.cornerRadius(10)
        
        let btImg2 = UIImageView.init(image: UIImage(named: "home_case_btn_iv4"))
        btBtn2.addSubview(btImg2)
        btImg2.snp.makeConstraints { make in
            make.top.equalTo(4.5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(98)
        }
        
        let btRightIcon2 = UIImageView.init(image: UIImage.init(named: "zbb_bt_right"))
        btImg2.addSubview(btRightIcon2)
        btRightIcon2.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(34)
            make.height.equalTo(17)
        }
        
        
        let btLabel2 = UILabel.init().text("TCL电视机").fontBold(12).textColor(.kColor13).textAligment(.center)
        btBtn2.addSubview(btLabel2)
        btLabel2.snp.makeConstraints { make in
            make.top.equalTo(btImg2.snp_bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(16.5)
            make.width.equalToSuperview()
        }
        
        let btDetailLabel2 = UILabel.init().text("最高补¥2000").fontBold(10).textColor(.kFF3C2F).textAligment(.center)
        btBtn2.addSubview(btDetailLabel2)
        btDetailLabel2.snp.makeConstraints { make in
            make.top.equalTo(btLabel2.snp_bottom).offset(1.5)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalToSuperview()
        }
        
        
        let btBtn3 = UIButton.init { btn in
            
        }.backgroundColor(.white)
        btzqBg.addSubview(btBtn3)
        btBtn3.snp.makeConstraints { make in
            make.top.equalTo(42)
            make.left.equalTo(btBtn2.snp_right).offset(5)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(155)
            make.width.equalTo(btBtn1)
        }
        btBtn3.cornerRadius(10)
        
        let btImg3 = UIImageView.init(image: UIImage(named: "home_case_btn_iv4"))
        btBtn3.addSubview(btImg3)
        btImg3.snp.makeConstraints { make in
            make.top.equalTo(4.5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(98)
        }
        
        let btRightIcon3 = UIImageView.init(image: UIImage.init(named: "zbb_bt_right"))
        btImg3.addSubview(btRightIcon3)
        btRightIcon3.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(34)
            make.height.equalTo(17)
        }
        
        let btLabel3 = UILabel.init().text("TCL电视机").fontBold(12).textColor(.kColor13).textAligment(.center)
        btBtn3.addSubview(btLabel3)
        btLabel3.snp.makeConstraints { make in
            make.top.equalTo(btImg3.snp_bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(16.5)
            make.width.equalToSuperview()
        }
        
        let btDetailLabel3 = UILabel.init().text("最高补¥2000").fontBold(10).textColor(.kFF3C2F).textAligment(.center)
        btBtn3.addSubview(btDetailLabel3)
        btDetailLabel3.snp.makeConstraints { make in
            make.top.equalTo(btLabel3.snp_bottom).offset(1.5)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalToSuperview()
        }
    }
    

    
    
    //MARK: 新品专区
    func configSection3(cell: UITableViewCell) {
        let xpzqBg = UIView.init().backgroundColor(.kD9FFF4).cornerRadius(10)
        cell.contentView.addSubview(xpzqBg)
        xpzqBg.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(14)
            make.right.bottom.equalToSuperview().offset(-14)
            make.height.equalTo(213)
        }
        
        let xpzqTop = UIImageView.init(image: UIImage.init(named: "zbb_new_top_bg"))
        xpzqBg.addSubview(xpzqTop)
        xpzqTop.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(42)
        }
        
        let btLabel = UILabel().text("新品专区").textColor(.white).fontBold(16)
        xpzqBg.addSubview(btLabel)
        btLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(10)
        }

        xpzqTop.isUserInteractionEnabled = true
        xpzqBg.isUserInteractionEnabled = true
        let moreArrow = UIButton.init(action: {[weak self] btn in
            self?.toMaterialsVC(type: 1)
        }).image(UIImage(named: "zbb_more_arrow"))
        xpzqBg.addSubview(moreArrow)
        moreArrow.snp.makeConstraints { make in
            make.top.equalTo(9.5)
            make.right.equalToSuperview().offset(-10)
            make.width.height.equalTo(24)
        }
        
        let btBtn1 = UIButton.init { btn in
            
        }.backgroundColor(.white)
        xpzqBg.addSubview(btBtn1)
        btBtn1.snp.makeConstraints { make in
            make.top.equalTo(42)
            make.left.equalTo(8)
            make.height.equalTo(155)
        }
        btBtn1.cornerRadius(10)
        
        let btImg1 = UIImageView.init(image: UIImage(named: "home_case_btn_iv4"))
        btBtn1.addSubview(btImg1)
        btImg1.snp.makeConstraints { make in
            make.top.equalTo(4.5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(98)
        }
        
        let btRightIcon1 = UIImageView.init(image: UIImage.init(named: "zbb_new_right"))
        btImg1.addSubview(btRightIcon1)
        btRightIcon1.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(34)
            make.height.equalTo(17)
        }
        
        let btLabel1 = UILabel.init().text("TCL电视机").fontBold(12).textColor(.kColor13).textAligment(.center)
        btBtn1.addSubview(btLabel1)
        btLabel1.snp.makeConstraints { make in
            make.top.equalTo(btImg1.snp_bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(16.5)
            make.width.equalToSuperview()
        }
        
        let btDetailLabel1 = UILabel.init().text("最高补¥2000").fontBold(10).textColor(.kFF3C2F).textAligment(.center)
        btBtn1.addSubview(btDetailLabel1)
        btDetailLabel1.snp.makeConstraints { make in
            make.top.equalTo(btLabel1.snp_bottom).offset(1.5)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalToSuperview()
        }
        
        
        
        
        
        let btBtn2 = UIButton.init { btn in
            
        }.backgroundColor(.white)
        xpzqBg.addSubview(btBtn2)
        btBtn2.snp.makeConstraints { make in
            make.top.equalTo(42)
            make.left.equalTo(btBtn1.snp_right).offset(5)
            make.height.equalTo(155)
            make.width.equalTo(btBtn1)
        }
        btBtn2.cornerRadius(10)
        
        let btImg2 = UIImageView.init(image: UIImage(named: "home_case_btn_iv4"))
        btBtn2.addSubview(btImg2)
        btImg2.snp.makeConstraints { make in
            make.top.equalTo(4.5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(98)
        }
        
        let btRightIcon2 = UIImageView.init(image: UIImage.init(named: "zbb_new_right"))
        btImg2.addSubview(btRightIcon2)
        btRightIcon2.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(34)
            make.height.equalTo(17)
        }
        
        let btLabel2 = UILabel.init().text("TCL电视机").fontBold(12).textColor(.kColor13).textAligment(.center)
        btBtn2.addSubview(btLabel2)
        btLabel2.snp.makeConstraints { make in
            make.top.equalTo(btImg2.snp_bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(16.5)
            make.width.equalToSuperview()
        }
        
        let btDetailLabel2 = UILabel.init().text("最高补¥2000").fontBold(10).textColor(.kFF3C2F).textAligment(.center)
        btBtn2.addSubview(btDetailLabel2)
        btDetailLabel2.snp.makeConstraints { make in
            make.top.equalTo(btLabel2.snp_bottom).offset(1.5)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalToSuperview()
        }
        
        
        let btBtn3 = UIButton.init { btn in
            
        }.backgroundColor(.white)
        xpzqBg.addSubview(btBtn3)
        btBtn3.snp.makeConstraints { make in
            make.top.equalTo(42)
            make.left.equalTo(btBtn2.snp_right).offset(5)
            make.right.equalToSuperview().offset(-8)
            make.height.equalTo(155)
            make.width.equalTo(btBtn1)
        }
        btBtn3.cornerRadius(10)
        
        let btImg3 = UIImageView.init(image: UIImage(named: "home_case_btn_iv4"))
        btBtn3.addSubview(btImg3)
        btImg3.snp.makeConstraints { make in
            make.top.equalTo(4.5)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(98)
        }
        
        let btRightIcon3 = UIImageView.init(image: UIImage.init(named: "zbb_new_right"))
        btImg3.addSubview(btRightIcon3)
        btRightIcon3.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(34)
            make.height.equalTo(17)
        }
        
        let btLabel3 = UILabel.init().text("TCL电视机").fontBold(12).textColor(.kColor13).textAligment(.center)
        btBtn3.addSubview(btLabel3)
        btLabel3.snp.makeConstraints { make in
            make.top.equalTo(btImg3.snp_bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(16.5)
            make.width.equalToSuperview()
        }
        
        let btDetailLabel3 = UILabel.init().text("最高补¥2000").fontBold(10).textColor(.kFF3C2F).textAligment(.center)
        btBtn3.addSubview(btDetailLabel3)
        btDetailLabel3.snp.makeConstraints { make in
            make.top.equalTo(btLabel3.snp_bottom).offset(1.5)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
            make.width.equalToSuperview()
        }
    }
    
    func toMaterialsVC(type: Int) {
        let vc = MaterialsVC()
        vc.type = type
        navigationController?.pushViewController(vc)
    }
    
    
    
    func fillBottomViewColor(v: UIView) {
        // fill
        let bgGradient = CAGradientLayer()
        bgGradient.colors = [UIColor(red: 0.79, green: 0.83, blue: 0.5, alpha: 1).cgColor, UIColor(red: 0.44, green: 0.51, blue: 0.28, alpha: 1).cgColor]
        bgGradient.locations = [0, 1]
        bgGradient.frame = v.bounds
        bgGradient.startPoint = CGPoint(x: 0.5, y: 0.04)
        bgGradient.endPoint = CGPoint(x: 0.5, y: 0.99)
        v.layer.insertSublayer(bgGradient, at: 0)
    }
    
    func configXPZQBtn(btn: UIButton) {
        let lab1 = UILabel().text("新品专区").textColor(UIColor.hexColor("#01884D")).fontBold(14)
        let lab2 = UILabel().text("超多新品等你来").textColor(UIColor.hexColor("#39AE7B")).font(10)
        let iv1 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_2"))
        let iv2 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_5"))
        btn.sv(lab1, lab2, iv1, iv2)
        btn.layout(
            10,
            |-10-lab1.height(20),
            5,
            |-10-lab2.height(14),
            27,
            |iv2|,
            0
        )
        btn.layout(
            60,
            iv1.width(41.5).height(45).centerHorizontally(),
            >=0
        )
    }
    
    func configBQZTBtn(btn: UIButton) {
        let lab1 = UILabel().text("本期主推").textColor(UIColor.hexColor("#E55A28")).fontBold(14)
        let lab2 = UILabel().text("严选高性价比产品").textColor(UIColor.hexColor("#E57C56")).font(10)
        let iv1 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_3"))
        let iv2 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_6"))
        btn.sv(lab1, lab2, iv1, iv2)
        btn.layout(
            10,
            |-10-lab1.height(20),
            5,
            |-10-lab2.height(14),
            27,
            |iv2|,
            0
        )
        btn.layout(
            64.5,
            iv1.width(74).height(35).centerHorizontally(),
            >=0
        )
    }
    
    func configKBRXBtn(btn: UIButton) {
        let lab1 = UILabel().text("口碑热销").textColor(UIColor.hexColor("#AC7152")).fontBold(14)
        let lab2 = UILabel().text("买过的都说好").textColor(UIColor.hexColor("#CE9D83")).font(10)
        let iv1 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_4"))
        let iv2 = UIImageView().image(#imageLiteral(resourceName: "home_icon_5_7"))
        btn.sv(lab1, lab2, iv1, iv2)
        btn.layout(
            10,
            |-10-lab1.height(20),
            5,
            |-10-lab2.height(14),
            27,
            |iv2|,
            0
        )
        btn.layout(
            64.5,
            iv1.width(73).height(33).centerHorizontally(),
            >=0
        )
    }
    //MARK: - 特惠专区
    func configSection4(cell: UITableViewCell) {
        cell.backgroundColor(.clear)
        let topVw = UIImageView.init(image: UIImage.init(named: "zbb_new_top_bg"))
        cell.addSubview(topVw)
        topVw.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.left.equalTo(14)
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(42)
        }
        
        let title = UILabel().text("特惠专区").textColor(.white).fontBold(16).textAligment(.center)
        topVw.addSubview(title)
        title.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let array = [1, 2, 3, 4, 5]
        
        for (index, value) in array.enumerated() {
            
            print("Index: \(index), Value: \(value)")
            
            let thBtn = UIButton.init { btn in
                
            }
            thBtn.tag = index
            thBtn.backgroundColor(.white)
            cell.contentView.addSubview(thBtn)
            
            let offsetY = (index)/2*282
            let offsetWidth = (PublicSize.screenWidth-18)/2
            let offsetX = (CGFloat)(index % 2) * offsetWidth
            thBtn.snp.makeConstraints { make in
                make.top.equalTo(67+offsetY)
                make.left.equalTo(14 + offsetX)
                make.width.equalTo((PublicSize.screenWidth-38)/2)
                make.height.equalTo(272)
                make.bottom.lessThanOrEqualToSuperview().offset(-20)
            }
            thBtn.borderWidth(1).borderColor(.kB4D4C4)
            thBtn.cornerRadius(10)
            
            let thTopImage = UIImageView.init(image: UIImage.init(named: "home_case_btn_iv4"))
            thBtn.addSubview(thTopImage)
            thTopImage.snp.makeConstraints { make in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(168)
            }
            
            let title = UILabel().text("优步花园北欧轻奢122m³ 优雅现代好水龙头").textColor(.kColor13).fontBold(14).numberOfLines(2)
            title.lineSpace(2)
            thBtn.addSubview(title)
            title.snp.makeConstraints { make in
                make.top.equalTo(thTopImage.snp_bottom).offset(2)
                make.left.equalTo(5)
                make.right.equalToSuperview().offset(-5)
                make.height.equalTo(40)
            }
    
            
            let price = UILabel().text("市场价：¥529").textColor(.kColor66).font(10)
            thBtn.addSubview(price)
            price.snp.makeConstraints { make in
                make.left.equalTo(title)
                make.top.equalTo(title.snp_bottom).offset(3)
                make.height.equalTo(14)
            }
            price.setLabelUnderline()
            
            let lab1 = UILabel().text("￥").textColor(.kFF3C2F).fontBold(10)
            thBtn.addSubview(lab1)
            lab1.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-12.5)
                make.left.equalTo(5)
                make.height.equalTo(14)
            }
            
            let truePrice = UILabel().text("262").textColor(.kFF3C2F).fontBold(18)
            thBtn.addSubview(truePrice)
            truePrice.snp.makeConstraints { make in
                make.left.equalTo(lab1.snp_right).offset(2)
                make.centerY.equalTo(lab1)
                make.height.equalTo(25)
            }
            
            let truePriceDes = UILabel().text("销售价").textColor(.kFF3C2F).font(12)
            thBtn.addSubview(truePriceDes)
            truePriceDes.snp.makeConstraints { make in
                make.left.equalTo(truePrice.snp_right).offset(2)
                make.centerY.equalTo(truePrice)
                make.height.equalTo(16.5)
            }
            
            let purchaseBtn = UIButton.init(action: { btn in
                print("点击了购买按钮: ", index)
            }).image(UIImage(named: "zbb_purchase"))
            thBtn.addSubview(purchaseBtn)
            purchaseBtn.tag = index
            purchaseBtn.snp.makeConstraints { make in
                make.right.equalToSuperview().offset(-5)
                make.bottom.equalToSuperview().offset(-10)
                make.width.height.equalTo(26)
            }
            
        }
    }
}

extension ZBBHomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        switch indexPath.section {
        case 0:
            cell.backgroundColor(.clear)
            configSection0(cell: cell)
        case 1:
            configSection1(cell: cell)
        case 2:
            configSection2(cell: cell)
        case 3:
            configSection3(cell: cell)
        case 4:
            configSection4(cell: cell)
        default:
            break
        }
        return cell
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

