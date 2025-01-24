//
//  SelectMapPlaceController.swift
//  YZB_Company
//
//  Created by liuyi on 2018/11/9.
//  Copyright © 2018 WZKJ. All rights reserved.
//

import UIKit
import MapKit
import Eureka
import MJRefresh

class SelectMapPlaceController: BaseViewController , MAMapViewDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, AMapSearchViewDelegate {
    
    var selectPlaceModel : PlotModel?           //选择的地址
    var onDismissback: ((_ : PlotModel?) -> ())?
    
    var isLookMap: Bool = false       //是否查看地图
    var isSearchBiotope: Bool = false //是否搜索小区
    
    var mapView: MAMapView!
    var pinView: UIImageView!               //大头针
    var ellipsisLayer: CAShapeLayer!        //大头针阴影
    
    var tableView: UITableView!
    var rowsData: Array<AMapPOI> = []
    var selectedPoint: AMapPOI?             //选中坐标
    let identifier = "AMapViewCell"
    var selectedIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
    
    var searchController: UISearchController!     //搜索控制器
    var searchViewController: AMapSearchController!
    
    var mapSearch: AMapSearchAPI!           //搜索对象
    var isFirstLocated = true               //第一次定位标记
    var searchPage: Int = 1                 //搜索页数
    var centralPoint: AMapGeoPoint?         //中心坐标
    var isSearching = false                 //是否正在搜索
    var isTouchCell = false                 //是否点击单元格
    
    let pinHeight: CGFloat = 40
    var mapHeight: CGFloat = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "位置"
        
        mapHeight = PublicSize.screenHeight*11/20
        
        if !isLookMap {
            
            let doneBtn = UIButton(type: .custom)
            doneBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
            doneBtn.setTitle("完成", for: .normal)
            doneBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            doneBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
            doneBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
            doneBtn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
            
            let doneItem = UIBarButtonItem.init(customView: doneBtn)
            navigationItem.rightBarButtonItems = [doneItem]
        }
        
        prepareMapView()
        prepareTableView()
        prepareSearchController()
    }
    
    func prepareMapView() {
        
        //地图
        mapView = MAMapView(frame: CGRect.init(x: 0, y: 0, width: PublicSize.screenWidth, height: mapHeight))
        mapView.delegate = self
        mapView.showsScale = true
        mapView.zoomLevel = 14.5
        mapView.isShowsUserLocation = true
        mapView.showsCompass = false
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide)
                make.height.equalTo(view.safeAreaLayoutGuide.layoutFrame.size.height/2)
            } else {
                make.top.equalTo(0)
                make.height.equalTo(view.frame.size.height/2)
            }
            
            make.right.left.equalToSuperview()
            
        }
        
        //定位按钮
        let locationBtnWidth: CGFloat = 40
        let locationBtn = UIButton(type: .custom)
        locationBtn.frame = CGRect.init(x: PublicSize.screenWidth-locationBtnWidth-15, y: 15, width: locationBtnWidth, height: locationBtnWidth)
        locationBtn.setImage(UIImage.init(named: "gpsnormal"), for: .normal)
        locationBtn.isSelected = true
        locationBtn.backgroundColor = UIColor.white
        locationBtn.layer.borderWidth = 1
        locationBtn.layer.borderColor = UIColor.colorFromRGB(rgbValue: 0xd9d9d9).cgColor
        locationBtn.layer.cornerRadius = locationBtnWidth/2
        locationBtn.addTarget(self, action: #selector(locationAction), for: .touchUpInside)
        mapView.addSubview(locationBtn)
        
        locationBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(locationBtnWidth)
            make.top.equalTo(15)
        }
        
        //大头针
        pinView = UIImageView()
        pinView.frame = CGRect.init(x: 0, y: 0, width: pinHeight, height: pinHeight)
        pinView.image = UIImage.init(named: "map_pin")
        pinView.contentMode = .scaleAspectFit
        mapView.addSubview(pinView)
        
        pinView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(mapView.snp.centerY).offset(-pinHeight/2)
            make.width.height.equalTo(pinHeight)
        }
        
        //大头针阴影
        ellipsisLayer = CAShapeLayer()
        ellipsisLayer.bounds = CGRect(x: 0, y: 0, width: 8, height: 4)
        ellipsisLayer.path = UIBezierPath(ovalIn: ellipsisLayer.bounds).cgPath
        ellipsisLayer.fillColor = UIColor.gray.cgColor
        ellipsisLayer.fillRule = CAShapeLayerFillRule.nonZero
        ellipsisLayer.lineCap = CAShapeLayerLineCap.butt
        ellipsisLayer.lineDashPattern = nil
        ellipsisLayer.lineDashPhase = 0.0
        ellipsisLayer.lineJoin = CAShapeLayerLineJoin.miter
        ellipsisLayer.lineWidth = 1.0
        ellipsisLayer.miterLimit = 1.0
        ellipsisLayer.strokeColor = UIColor.gray.cgColor
        ellipsisLayer.position = CGPoint.init(x: mapView.center.x, y: mapView.center.y-pinView.frame.size.height/2+1)
        mapView.layer.insertSublayer(ellipsisLayer, below: pinView.layer)
        
        //搜索对象
        mapSearch = AMapSearchAPI()
        mapSearch.delegate = self
    }
    
    func prepareTableView() {
        
        tableView = UITableView()
        tableView.backgroundColor = UIColor.white
        tableView.rowHeight = 52
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        view.addSubview(tableView)
        
        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(mapView.snp.bottom)
            make.right.left.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        // 下拉刷新
        let header = MJRefreshGifCustomHeader()
        header.setRefreshingTarget(self, refreshingAction: #selector(headerRefresh))
        tableView.mj_header = header
        
        //上拉加载
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(footerRefresh))
        tableView.mj_footer = footer
    }
    
    func prepareSearchController() {
        
        self.definesPresentationContext  = true
        
        searchViewController = AMapSearchController()
        searchViewController.delegate = self
        searchController = UISearchController(searchResultsController: searchViewController)
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchResultsUpdater = searchViewController
        searchController.searchBar.placeholder = "搜索地点"
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            view.addSubview(searchController.searchBar)
        }
    }
    
    //MARK: - 按钮事件
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        searchPage = 1
        searchAround(location: centralPoint!)
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        if rowsData.count > 1 {
            searchPage += 1
        }else {
            searchPage = 1
        }
        searchAround(location: centralPoint!)
    }
    
    //定位到当前位置
    @objc func locationAction() {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    //完成
    @objc func doneAction() {
        
        if rowsData.count > 0 {
            let point = rowsData[0]
            let plot = PlotModel()
            plot.name = point.name
            plot.address = point.address
            plot.lon = "\(CLLocationDegrees(point.location.longitude))"
            plot.lat = "\(CLLocationDegrees(point.location.latitude))"
            plot.prov?.name = point.province
            plot.city?.name = point.city
            plot.dist?.name = point.district
            
            selectPlaceModel = plot
            if onDismissback != nil {
                 onDismissback?(selectPlaceModel)
            }
            
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - 地图搜索
    
    //逆地理编码（通过经纬度获取地理信息）
    func reGeoCoding(location: AMapGeoPoint) {
        
        let regeo = AMapReGeocodeSearchRequest()
        regeo.location = location
        // 返回扩展信息
        regeo.requireExtension = true
        mapSearch.aMapReGoecodeSearch(regeo)
    }
    
    //搜索周边
    func searchAround(location: AMapGeoPoint) {
        
        let request = AMapPOIAroundSearchRequest()
        if isSearchBiotope {
            
            request.keywords = "小区"
        }
        request.location = location
        // 搜索半径
        request.radius = 1000
        // 搜索结果排序
        request.sortrule = 1
        // 当前页数
        request.page = searchPage
        request.requireExtension = true
        mapSearch.aMapPOIAroundSearch(request)
    }
    
    //MARK: - AMapSearchDelegate
    func selectedLocation(point: AMapPOI!) {
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            
            self.isSearching = false
            self.isTouchCell = true
            self.selectedPoint = point
            
            let location = CLLocationCoordinate2DMake(CLLocationDegrees(point.location.latitude), CLLocationDegrees(point.location.longitude))
            self.mapView.setCenter(location, animated: false)
        }
    }
    
    //MARK: - UISearchControllerDelegate
    func willPresentSearchController(_ searchController: UISearchController) {
        
        isSearching = true
    }
    
    
    func didPresentSearchController(_ searchController: UISearchController) {
        AppLog("已经弹出搜索")
        
        
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        AppLog("已经收起搜索")
        
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        
        isSearching = false
    }
    
    //MARK: - MAMapViewDelegate
    //定位回调
    func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
        
        if updatingLocation && isFirstLocated {
            AppLog("首次定位")
            isFirstLocated = false
            
            if let plotLat = selectPlaceModel?.lat, let plotLon = selectPlaceModel?.lon {
                
                mapView.setCenter(CLLocationCoordinate2DMake(Double(string: plotLat)!, Double(string: plotLon)!), animated: true)
            }else {
                mapView.setCenter(userLocation.coordinate, animated: true)
            }
            
            let point = AMapGeoPoint.location(withLatitude: CGFloat(userLocation.coordinate.latitude), longitude: CGFloat(userLocation.coordinate.longitude))
            reGeoCoding(location: point!)
        }
    }
    
    //当MKMapView显示区域将要发生改变时激发该方法
    public func mapView(_ mapView: MAMapView, regionWillChangeAnimated animated: Bool) {
        
        AppLog("位置将要改变")
        
        if isSearching {
            AppLog("正在搜索，跳过响应")
            return
        }
        
        if isTouchCell {
            isTouchCell = false
        }else {
            selectedPoint = nil
        }
        
        ellipsisLayer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y - 10)
        })
    }
    
    //当MKMapView显示区域改变完成时激发该方法
    public func mapView(_ mapView: MAMapView, regionDidChangeAnimated animated: Bool) {
        
        AppLog("位置改变")
        
        if isSearching {
            AppLog("正在搜索，跳过周边查询")
            return
        }
        
        ellipsisLayer.transform = CATransform3DIdentity
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.pinView.center = CGPoint(x: self!.pinView.center.x, y: self!.pinView.center.y + 10)
        })
        
        let point = AMapGeoPoint.location(withLatitude: CGFloat(mapView.centerCoordinate.latitude), longitude: CGFloat(mapView.centerCoordinate.longitude))
        centralPoint = point
        
        if !isFirstLocated {
            
            if tableView.mj_header?.isRefreshing ?? false {
                tableView.mj_header?.endRefreshing()
            }
            self.pleaseWait()
            headerRefresh()
        }
    }
    
    //MARK: - AMapSearchDelegate
    
//    - (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error;
    func aMapSearchRequest(_ request: Any!, didFailWithError error: (any Error)!) {
        self.clearAllNotice()
        noticeOnlyText(error.localizedDescription)
    }
    
    //反编译回调
    func onReGeocodeSearchDone(_ request: AMapReGeocodeSearchRequest!, response: AMapReGeocodeSearchResponse!) {
        
        if response.regeocode != nil {
            
            searchViewController.city = response.regeocode.addressComponent.city
        }
    }
    
    //搜索周边回调
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        self.clearAllNotice()
        tableView.mj_header?.endRefreshing()
        
        if response.pois.count <= 0 {
            tableView.mj_footer?.endRefreshingWithNoMoreData()
        }else {
            tableView.mj_footer?.resetNoMoreData()
        }
        
        if searchPage == 1 {
            
            rowsData.removeAll()
            tableView.reloadData()
            tableView.mj_footer?.isHidden = true
            
            if selectedPoint == nil {
                rowsData = response.pois
            }else {
                rowsData.removeAll()
                rowsData.append(selectedPoint!)
                
                for mapPOI in response.pois {
                    
                    if mapPOI.location.latitude != selectedPoint?.location.latitude || mapPOI.location.longitude != selectedPoint?.location.longitude {
                        rowsData.append(mapPOI)
                    }
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.tableView.mj_footer?.isHidden = false
                self.tableView.reloadData()
            }
            
        }else {
            rowsData += response.pois
            tableView.reloadData()
        }
    }
    
    //MARK: - tableviewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: identifier)
        }
        
        cell!.textLabel?.text = ""
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell!.textLabel?.textColor = PublicColor.commonTextColor
        cell!.detailTextLabel?.text = ""
        cell!.detailTextLabel?.textColor = PublicColor.minorTextColor
        cell!.accessoryType = .none
        
        if indexPath.row == 0 {
            cell!.accessoryType = .checkmark
            cell!.textLabel?.textColor = PublicColor.emphasizeTextColor
        }
        
        let point = rowsData[indexPath.row]
        cell!.textLabel?.text = point.name
        cell!.detailTextLabel?.text = point.address
        
        selectedIndexPath = IndexPath.init(row: 0, section: 0)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        isTouchCell = true
        
        if indexPath.row != selectedIndexPath.row {
            let oldCell = tableView.cellForRow(at: selectedIndexPath)
            oldCell?.accessoryType = .none
            
            let newCell = tableView.cellForRow(at: indexPath)
            newCell?.accessoryType = .checkmark
        }
        
        let point = rowsData[indexPath.row]
        selectedPoint = point
        
        let location = CLLocationCoordinate2DMake(CLLocationDegrees(point.location.latitude), CLLocationDegrees(point.location.longitude))
        mapView.setCenter(location, animated: true)
    }
}
