//
//  AMapSearchController.swift
//  YZB_Company
//
//  Created by yzb_ios on 2017/12/22.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import MapKit
import MJRefresh

protocol AMapSearchViewDelegate: NSObjectProtocol {
    func selectedLocation(point: AMapPOI!)
}

class AMapSearchController: BaseViewController, UITableViewDelegate, UITableViewDataSource, AMapSearchDelegate, UISearchResultsUpdating {
    
    weak var delegate: AMapSearchViewDelegate?
    
    var tableView: UITableView!
    var rowsData: Array<AMapPOI> = []
    let identifier = "AMapSearchCell"
    
    var mapSearch: AMapSearchAPI!           //搜索对象
    var searchPage: Int = 1                 //搜索页数
    var searchString = ""
    var city = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareTableView()
        
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
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
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
    
    @objc func headerRefresh() {
        AppLog("下拉刷新")
        searchPage = 1
        searchAround()
    }
    
    @objc func footerRefresh() {
        AppLog("上拉加载")
        if rowsData.count > 1 {
            searchPage += 1
        }else {
            searchPage = 1
        }
        searchAround()
    }
    
    //搜索周边
    func searchAround() {
        
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = searchString
        request.city = city
        // 当前页数
        request.page = searchPage
        mapSearch.aMapPOIKeywordsSearch(request)
    }
    
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        
        searchString = searchController.searchBar.text!
        searchPage = 1
        searchAround()
    }
    
    
    //MARK: - AMapSearchDelegate
    
    //搜索周边回调
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        
        tableView.mj_header?.endRefreshing()
        
        if response.pois.count <= 0 {
            tableView.mj_footer?.endRefreshingWithNoMoreData()
        }else {
            tableView.mj_footer?.resetNoMoreData()
        }
        
        if searchPage == 1 {
            
            if rowsData.count > 0 {
                rowsData.removeAll()
                tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    self.rowsData = response.pois
                    self.tableView.reloadData()
                }
            }else {
                rowsData = response.pois
                tableView.reloadData()
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
        
        if indexPath.row == 0 {
            cell!.textLabel?.textColor = PublicColor.emphasizeTextColor
        }
        
        if searchString.count > 0 {
            
            let point = rowsData[indexPath.row]
            
            let name = NSMutableAttributedString.init(string: point.name)
            name.addAttributes([NSAttributedString.Key.foregroundColor: PublicColor.commonTextColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], range: NSMakeRange(0, name.length))
            cell!.textLabel?.attributedText = name
            
            if let nameHighlightRang = point.name.range(of: searchString) {
                
                let nameHighlightNSRang = point.name.nsRange(from: nameHighlightRang)
                name.addAttributes([NSAttributedString.Key.foregroundColor: PublicColor.emphasizeTextColor], range: nameHighlightNSRang)
                cell!.textLabel?.attributedText = name
            }
            
            let address = NSMutableAttributedString.init(string: point.address)
            address.addAttributes([NSAttributedString.Key.foregroundColor: PublicColor.minorTextColor, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)], range: NSMakeRange(0, address.length))
            cell!.detailTextLabel?.attributedText = address
            
            if let addressHighlightRang = point.address.range(of: searchString) {
                
                let addressHighlightNSRang = point.address.nsRange(from: addressHighlightRang)
                address.addAttributes([NSAttributedString.Key.foregroundColor: PublicColor.emphasizeTextColor], range: addressHighlightNSRang)
                cell!.detailTextLabel?.attributedText = address
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let point = rowsData[indexPath.row]
        
        delegate?.selectedLocation(point: point)
        self.dismiss(animated: true, completion: nil)
    }
    
}
