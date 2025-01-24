//
//  THAreaPicker.swift
//  YZB_Company
//
//  Created by yzb_ios on 2018/4/1.
//  Copyright © 2018年 WZKJ. All rights reserved.
//

import UIKit

protocol THPickerDelegate : NSObjectProtocol {
    func pickerViewSelectArea(pickerView:THAreaPicker, selectModel: CityModel, component: Int)
}

class THAreaPicker: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var areaDelegate: THPickerDelegate?
    
    var maskBackView: UIView!
    var areaBackView: UIView!
    var picker: UIPickerView!
    
    var provArray: Array<CityModel> = []        //省
    var cityArray: Array<CityModel> = []        //市
    var distArray: Array<CityModel> = []        //区
    
    var currentRow: Int = 0
    var currentCommpont: Int = 0
    
    var dataArray: Array<Array<CityModel>> {
        get {
//            return [provArray, cityArray, distArray]
            return [cityArray]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        
        maskBackView = UIView()
        maskBackView.alpha = 0
        maskBackView.isUserInteractionEnabled = true
        maskBackView.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        self.addSubview(maskBackView)
        
        maskBackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(hiddenPicker))
        tapOne.numberOfTapsRequired = 1
        maskBackView.addGestureRecognizer(tapOne)
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //灰色背景
        areaBackView = UIView()
        areaBackView.backgroundColor = UIColor.init(red: 249.0/255, green: 248.0/255, blue: 248.0/255, alpha: 1)
        self.addSubview(areaBackView)
        
        areaBackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(260)
            make.bottom.equalTo(260)
        }
        
        //取消
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.k2FD4A7, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        cancelBtn.borderColor(.kColor220).borderWidth(0.5)
        areaBackView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(39)
        }
        
        //确定
        let sureBtn = UIButton(type: .custom)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.backgroundColor(.k2FD4A7)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        areaBackView.addSubview(sureBtn)
        
        sureBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.bottom.width.equalTo(cancelBtn)
        }
        
        //选择器
        picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        areaBackView.addSubview(picker)
        
        picker.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(cancelBtn.snp.bottom).offset(5)
        }
    }
    
    func prepareCityData(parentId: String = "100000", type: Int = 1) {
        
        if type == 1 {
            //省
            if let provList = THFMDB.querySubData(parentId) {
                
                provArray = provList
                let firstProv = provArray.first
                areaDelegate?.pickerViewSelectArea(pickerView:self, selectModel: firstProv!, component: 0)
                
                //市
                if let cityList = THFMDB.querySubData((firstProv?.id)!) {
                    
                    cityArray = cityList
                    let firstCity = cityArray.first
                    areaDelegate?.pickerViewSelectArea(pickerView:self, selectModel: firstCity!, component: 1)
                    
                    //区
                    if let distList = THFMDB.querySubData((firstCity?.id)!) {
                        
                        distArray = distList
                        let firstDist = distArray.first
                        areaDelegate?.pickerViewSelectArea(pickerView:self, selectModel: firstDist!, component: 2)
                    }
                }
            }
        }else if type == 2 {
            //市
            if let cityList = THFMDB.querySubData(parentId) {
                
                cityArray = cityList
                let firstCity = cityArray.first
                areaDelegate?.pickerViewSelectArea(pickerView:self, selectModel: firstCity!, component: 1)
                
                //区
                if let distList = THFMDB.querySubData((firstCity?.id)!) {
                    
                    distArray = distList
                    let firstDist = distArray.first
                    areaDelegate?.pickerViewSelectArea(pickerView:self, selectModel: firstDist!, component: 2)
                }
            }
        }else {
            //区
            if let distList = THFMDB.querySubData(parentId) {
                
                distArray = distList
                let firstDist = distArray.first
                areaDelegate?.pickerViewSelectArea(pickerView:self, selectModel: firstDist!, component: 2)
            }
        }
        
        picker.reloadAllComponents()
    }
    
    //MARK: - 触发事件
    
    @objc func cancelAction() {
        
        hiddenPicker()
    }
    
    @objc func sureAction() {
        let componentList = dataArray[currentCommpont]
        let cityModel = componentList[currentRow]
        areaDelegate?.pickerViewSelectArea(pickerView:self, selectModel: cityModel, component: currentCommpont)
        hiddenPicker()
    }
    
    func showPicker() {
        
//        if provArray.count <= 0 {
//            prepareCityData()
//        }
        
        self.isHidden = false
        
        areaBackView.snp.updateConstraints({ (make) in
            make.bottom.equalToSuperview()
        })
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.maskBackView.alpha = 1
            self.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
        }
    }
    
    @objc func hiddenPicker() {
        
        areaBackView.snp.updateConstraints({ (make) in
            make.bottom.equalTo(260)
        })
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.maskBackView.alpha = 0
            self.layoutIfNeeded()
            
        }) { (finished: Bool) in
           self.isHidden = true
        }
    }
    
    
    //MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let componentList = dataArray[component]
        return componentList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let componentList = dataArray[component]
        let cityModel = componentList[row]
        if cityModel.name == nil {
            return cityModel.shortName
        }
        return cityModel.name
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let componentList = dataArray[component]
        let cityModel = componentList[row]
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        if cityModel.name == nil {
            titleLabel.text = cityModel.shortName
        } else {
            titleLabel.text = cityModel.name
        }
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        
        return titleLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentRow = row
        currentCommpont = component
    }
}


protocol CompanyTypePickerDelegate : NSObjectProtocol {
    func pickerViewSelectCompanyType(pickerView:CompanyTypePicker, selectIndex: Int , component: Int)
}

class CompanyTypePicker: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: CompanyTypePickerDelegate?
    
    var maskBackView: UIView!
    var companyTypeBackView: UIView!
    var picker: UIPickerView!
    
    var companyTypes: Array<String> = []        //类型
    var currentRow: Int = 0
    var currentCommpont: Int = 0
    var dataArray: Array<Array<String>> {
        get {
            return [companyTypes]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isHidden = true
        
        maskBackView = UIView()
        maskBackView.alpha = 0
        maskBackView.isUserInteractionEnabled = true
        maskBackView.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
        self.addSubview(maskBackView)
        
        maskBackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(hiddenPicker))
        tapOne.numberOfTapsRequired = 1
        maskBackView.addGestureRecognizer(tapOne)
        
        createSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubView() {
        
        //灰色背景
        companyTypeBackView = UIView()
        companyTypeBackView.backgroundColor = UIColor.init(red: 249.0/255, green: 248.0/255, blue: 248.0/255, alpha: 1)
        self.addSubview(companyTypeBackView)
        
        companyTypeBackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(260)
            make.bottom.equalTo(260)
        }
        
        //取消
        let cancelBtn = UIButton(type: .custom)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.k2FD4A7, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        cancelBtn.borderColor(.kColor220).borderWidth(0.5)
        companyTypeBackView.addSubview(cancelBtn)
        
        cancelBtn.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(39)
        }
        
        //确定
        let sureBtn = UIButton(type: .custom)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.backgroundColor(.k2FD4A7)
        sureBtn.addTarget(self, action: #selector(sureAction), for: .touchUpInside)
        companyTypeBackView.addSubview(sureBtn)
        
        sureBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.top.bottom.width.equalTo(cancelBtn)
        }
        
        //选择器
        picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        companyTypeBackView.addSubview(picker)
        
        picker.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.top.equalTo(cancelBtn.snp.bottom).offset(5)
        }
    }
    
    //MARK: - 触发事件
    
    @objc func cancelAction() {
        
        hiddenPicker()
    }
    
    @objc func sureAction() {
        delegate?.pickerViewSelectCompanyType(pickerView: self, selectIndex: currentRow, component: currentCommpont)
        hiddenPicker()
    }
    
    func showPicker() {
        self.isHidden = false
        
        companyTypeBackView.snp.updateConstraints({ (make) in
            make.bottom.equalToSuperview()
        })
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.maskBackView.alpha = 1
            self.layoutIfNeeded()
            
        }) { (finished: Bool) in
            
        }
    }
    
    @objc func hiddenPicker() {
        
        companyTypeBackView.snp.updateConstraints({ (make) in
            make.bottom.equalTo(260)
        })
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.maskBackView.alpha = 0
            self.layoutIfNeeded()
            
        }) { (finished: Bool) in
           self.isHidden = true
        }
    }
    
    
    //MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return dataArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        let componentList = dataArray[component]
        return componentList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let componentList = dataArray[component]
        return componentList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let componentList = dataArray[component]
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = componentList[row]
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        
        return titleLabel
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentCommpont = component
        currentRow = row
        
    }
}
