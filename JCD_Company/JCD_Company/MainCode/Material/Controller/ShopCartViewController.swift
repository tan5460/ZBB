//
//  ShopCartViewController.swift
//  YZB_Company
//
//  Created by TanHao on 2017/7/25.
//  Copyright © 2017年 WZKJ. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import PopupDialog



class ShopCartViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    var classView: ClassificationSlidingView!//分类滑动视图
    var materialTableView: UITableView!
    let identifier = "CartCell"
    var rowsData: Array<MaterialsModel> = []
    var isRootVC = true
    var isFirstLoad = true
    
    var cartNullView: UIImageView!                  //购物车空提示
    var bottomView: UIView!                         //底部视图
    var placeOrderBtn: UIButton!                    //下一步
    var allSelectBtn: UIButton!                     //全选
    var materialCountLabel: UILabel!                //主材项数
    
    deinit {
        AppLog(">>>>>>>>>>>>>>>>>> 购物车界面释放 <<<<<<<<<<<<<<<<<<")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "购物车"
        
        prepareBottomView()
        prepareTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.isTranslucent = true
        }
        
        if isFirstLoad {
            isFirstLoad = false
            materialTableView.mj_header?.beginRefreshing()
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - 计算价格
    
    func getAllMaterialsCount() {
        var materialCount = 0
        for model in rowsData {
            if model.isCheckBtn {
                materialCount += 1
            }
        }
        materialCountLabel.text = "\(materialCount)"
        if materialCount == rowsData.count {
            allSelectBtn.isSelected = true
        } else {
            allSelectBtn.isSelected = false
        }
        //刷新选中状态
        materialTableView.reloadData()
        
        if self.rowsData.count <= 0 {
            cartNullView.isHidden = false
            navigationItem.rightBarButtonItems = nil
            
            bottomView.isHidden = false
            bottomView.snp.remakeConstraints { (make) in
                make.left.right.bottom.equalToSuperview()
                if #available(iOS 11.0, *) {
                    make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-54)
                } else {
                   make.height.equalTo(54)
                }
            }
        }
        else {
            cartNullView.isHidden = true
            if navigationItem.rightBarButtonItems == nil {
                doneAction()
            }
        }
    }
    
    
    //MARK: 按钮事件
    
    //编辑
    @objc func editAction() {
        
        //完成
        let doneBtn = UIButton(type: .custom)
        doneBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        doneBtn.setTitle("完成", for: .normal)
        doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        doneBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        doneBtn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        
        //删除
        let deleteBtn = UIButton(type: .custom)
        deleteBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        deleteBtn.setTitle("删除", for: .normal)
        deleteBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        deleteBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        deleteBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        deleteBtn.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        let doneItem = UIBarButtonItem.init(customView: doneBtn)
        let deleteItem = UIBarButtonItem.init(customView: deleteBtn)
        navigationItem.rightBarButtonItems = [doneItem, deleteItem]
        
        bottomView.isHidden = true
        bottomView.snp.remakeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    //完成
    @objc func doneAction() {
        
        let editBtn = UIButton(type: .custom)
        editBtn.frame = CGRect.init(x: 0, y: 0, width: 40, height: 30)
        editBtn.setTitle("编辑", for: .normal)
        editBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        editBtn.setTitleColor(PublicColor.minorTextColor, for: .normal)
        editBtn.setTitleColor(PublicColor.placeholderTextColor, for: .highlighted)
        editBtn.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        
        let editItem = UIBarButtonItem.init(customView: editBtn)
        navigationItem.rightBarButtonItems = [editItem]
        
        bottomView.isHidden = false        
        
        bottomView.snp.remakeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-54)
            } else {
                make.height.equalTo(54)
            }
        }
    }
    
    //删除
    @objc func deleteAction() {
        
        var ids = ""
        for cellModel in rowsData {
            if cellModel.isCheckBtn {
                if ids.count > 0 {
                    ids += ",\(cellModel.id!)"
                }else {
                    ids = cellModel.id!
                }
            }
        }
        
        if ids.count <= 0 {
            return
        }
        
        let popup = PopupDialog(title: "是否删除所有选中项?", message: nil,buttonAlignment: .horizontal)
        let sureBtn = DestructiveButton(title: "删除") {
            
            let parameters: Parameters = ["skuIds": ids]
            
            self.pleaseWait()
            let urlStr = APIURL.delBatchCartList
            
            YZBSign.shared.request(urlStr, method: .delete, parameters: parameters, success: { (response) in
                
                let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
                if errorCode == "0" {
                    self.pleaseWait()
                    self.loadData()
                }
                
            }) { (error) in
                
            }
        }
        let cancelBtn = CancelButton(title: "取消") {
        }
        
        popup.addButtons([cancelBtn,sureBtn])
        self.present(popup, animated: true, completion: nil)
    }
    
    // 点击全选
    @objc func allCheckBtnClick(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        rowsData.forEach({ (cellModel) in
            cellModel.isCheckBtn = btn.isSelected
        })
        getAllMaterialsCount()
    }
    
    //去结算
    @objc func placeOrderAction() {
        
        if rowsData.count <= 0 {
            self.noticeOnlyText("购物车为空")
            return
        }
        
        var selectedCount: Int = 0
        var materialCount: Int = 0
        
        
        var isCanSell = true
        var tmpModels = [MaterialsModel]()
        for cellModel in rowsData {
            if cellModel.isCheckBtn {
                if cellModel.materials?.isOneSell == 2 {
                    tmpModels.append(cellModel)
                }
                selectedCount += 1
                materialCount += 1
            }
        }
        // 这里主要判断同一品牌商下面组合购产品是否只有一个，只有一个，无法下单
        var sameCount = 0
        for cellModel in tmpModels {
            for cellModel1 in tmpModels {
                if cellModel.materialsId == cellModel1.materialsId {
                    sameCount += 1
                }
            }
            if sameCount == 1 {
                isCanSell = false
            }
            sameCount = 0
        }
        
        if isCanSell == false {
            self.noticeOnlyText("同一品牌的组合购产品不足两个")
            return
        }
        
        if selectedCount <= 0 {
            //未选择主材或施工
            let popup = PopupDialog(title: "未选择产品", message: nil, image: nil, buttonAlignment: .vertical, transitionStyle: PopupDialogTransitionStyle.bounceUp, preferredWidth: 300, tapGestureDismissal: false, panGestureDismissal: false, hideStatusBar: false, completion: nil)

            let sureBtn = AlertButton(title: "确定") {
                
            }
            popup.addButtons([sureBtn])
            self.present(popup, animated: true, completion: nil)
            return
        }
        
        var dataArray: Array<MaterialsModel> = []
        rowsData.forEach { (cartModel) in
            if cartModel.isCheckBtn {
                dataArray.append(cartModel)
            }
        }
        isFirstLoad = true
        let vc = PlaceOrderController()
        vc.rowsData = dataArray
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - 网络请求
    @objc func loadData() {
        
        let parameters: Parameters = Parameters()
        
        let urlStr = APIURL.getCartList
        
        YZBSign.shared.request(urlStr, method: .get, parameters: parameters, success: { [weak self] response in
            
            // 结束刷新
            self?.materialTableView.mj_header?.endRefreshing()
            
            let errorCode = Utils.getReadString(dir: response as NSDictionary, field: "code")
            if errorCode == "0" {
                let arr = Utils.getReadArr(data: response as NSDictionary, field: "data")
                if arr.count > 0 {
                    var modelArray = [MaterialsModel]()
                    arr.forEach { (item) in
                        let dataArray = Utils.getReadArr(data: item as! NSDictionary, field: "merchantProductList")
                        let modelArray1 = Mapper<MaterialsModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
                        modelArray += modelArray1
                    }
                    self?.rowsData = modelArray
                } else {
                    self?.rowsData.removeAll()
                }
            }
            else {
                if errorCode == "008" {
                    self?.rowsData.removeAll()
                }
            }
            
            self?.getAllMaterialsCount()
            
        }) { [weak self] error in
            
            // 结束刷新
            self?.materialTableView.mj_header?.endRefreshing()
            self?.getAllMaterialsCount()
        }
    }
    
    
    //MARK: - tableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //主材
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! ShopCartCell
        let cellModel = rowsData[indexPath.row]
        cell.materialsModel = cellModel
        cell.detailBlock = { [weak self] in
            if let materials = cellModel.materials {
                let rootVC = MaterialsDetailVC()
                rootVC.isDismiss = true
                rootVC.materialsModel = materials
                let vc = BaseNavigationController.init(rootViewController: rootVC)
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true, completion: nil)
            }
        }
        cell.selectedBlock = { [weak self] (isCheck) in
            cellModel.isCheckBtn = isCheck
            self?.getAllMaterialsCount()
        }
        cell.countBlock = {(count) in
            cellModel.count = count
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
}
