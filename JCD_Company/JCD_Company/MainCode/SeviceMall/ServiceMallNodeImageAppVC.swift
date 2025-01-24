//
//  ServiceMallNodeImageAppVC.swift
//  YZB_Company
//
//  Created by CSCloud on 2020/6/15.
//  Copyright © 2020 WZKJ. All rights reserved.
//

import UIKit
import Stevia
import Alamofire
import TLTransitions

class ServiceMallNodeImageAppVC: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var refresh: (() -> Void)?
    var currentDeleteIndex = 0
    var nodeModel: NodeDataListModel? {
        didSet {
            if let fileUrls = nodeModel?.fileUrls {
                dataSource = fileUrls.components(separatedBy: ",")
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hideShadowImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.showShadowImage()
    }
    private var dataSource = [String]()
    private let tableView = UITableView.init(frame: .zero, style: .grouped)
    private var pop: TLTransition!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "节点图片"
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
        configDeletePopView(tag: 0)
    }

    private let deletePopView = UIView().backgroundColor(.white)
    
    func configDeletePopView(tag: Int) {
        deletePopView.frame = CGRect(x: 0, y: 0, width: 272, height: 115)
        let title = UILabel().text("确认是否删除该节点图片？").textColor(.kColor33).fontBold(14)
        let line1 = UIView().backgroundColor(.kColor220)
        let line2 = UIView().backgroundColor(.kColor220)
        let cancelBtn = UIButton().text("取消").textColor(.kColor33).font(14)
        let sureBtn = UIButton().text("确认").textColor(.kColor33).font(14)
        deletePopView.sv(title, line1, line2, cancelBtn, sureBtn)
        deletePopView.layout(
            22.5,
            title.height(20).centerHorizontally(),
            22.5,
            |line1| ~ 0.5,
            |cancelBtn-0-line2.width(0.5)-sureBtn|,
            0
        )
        equal(widths: cancelBtn,sureBtn)
        equal(heights: cancelBtn, line2, sureBtn)
        sureBtn.tag = tag
        sureBtn.addTarget(self, action: #selector(sureBtnClick(btn:)))
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(btn:)))
    }
}


extension ServiceMallNodeImageAppVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let imageStr = dataSource[indexPath.row]
        let cell = UITableViewCell().backgroundColor(.kBackgroundColor)
        let v = UIView().backgroundColor(.white)
        cell.sv(v)
        cell.layout(
            5,
            |v| ~ 50,
            0
        )
        let icon = UIImageView().image(#imageLiteral(resourceName: "loading_rectangle"))
        if !icon.addImage(imageStr) {
            icon.image(#imageLiteral(resourceName: "loading_rectangle"))
        }
        let title = UILabel().text(imageStr).textColor(.kColor33).font(14)
        let deleteBtn = UIButton().text("删除").textColor(.kColor66).font(12)
        v.sv(icon, title, deleteBtn)
        v.layout(
            8,
            |-14-icon.width(26).height(34)-10-title-(>=0)-deleteBtn.width(52).height(50)|,
            8
        )
        icon.contentMode = .scaleAspectFit
        icon.cornerRadius(1).masksToBounds()
        deleteBtn.tag = indexPath.row
        deleteBtn.addTarget(self, action: #selector(deleteBtnClick(btn:)))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if dataSource.count > 0 {
            return 140
        } else {
            return 240
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let v = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 140))
        if dataSource.count == 0 {
            v.frame = CGRect(x: 0, y: 0, width: view.width, height: 200)
        }
        let noDataBtn = UIButton().image(#imageLiteral(resourceName: "nodata_icon")).text("  暂无节点图").textColor(.kColor66).font(14)
        v.sv(noDataBtn)
        noDataBtn.width(200).height(100)
        v.layout(
            0,
            noDataBtn.centerHorizontally(),
            >=0
        )
        noDataBtn.isHidden = true
        let addBtn = UIButton().text("添加").textColor(.white).font(14).backgroundColor(.k2FD4A7).cornerRadius(2).masksToBounds()
        let sureBtn = UIButton().text("确认上传").textColor(.white).font(14).backgroundColor(.k2FD4A7).cornerRadius(2).masksToBounds()
        v.sv(addBtn, sureBtn)
        if dataSource.count == 0 {
            v.layout(
                100,
                |-47.5-addBtn.height(40)-47.5-|,
                20,
                |-47.5-sureBtn.height(40)-47.5-|,
                >=0
            )
            noDataBtn.isHidden = false
        } else {
            v.layout(
                40,
                |-47.5-addBtn.height(40)-47.5-|,
                20,
                |-47.5-sureBtn.height(40)-47.5-|,
                >=0
            )
            noDataBtn.isHidden = true
        }
        addBtn.addTarget(self, action: #selector(addBtnClick(btn:)))
        sureBtn.addTarget(self, action: #selector(sureUploadBtnClick(btn:)))
        
        return v
    }
}

// MARK: - 按钮点击方法
extension ServiceMallNodeImageAppVC {
    @objc private func addBtnClick(btn: UIButton) {
        picker.delegate = self
        let alertAction = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        alertAction.addAction(UIAlertAction.init(title: "选择相机", style: .default, handler: { (alertCamera) in
            self.judgeCameraAuthorization()
        }))
        
        alertAction.addAction(UIAlertAction.init(title: "选择相册", style:.default, handler: { (alertPhpto) in
            self.judgePhotoLibraryAuthorization()
        }))
        
        alertAction.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: { (alertCancel) in
            
        }))
        self.present(alertAction, animated: true, completion: nil)
    }
    
    @objc private func deleteBtnClick(btn: UIButton) {
        currentDeleteIndex = btn.tag
        pop = TLTransition.show(deletePopView, popType: TLPopTypeAlert)
    }
    
    @objc private func sureBtnClick(btn: UIButton) {
        pop.dismiss()
        dataSource.remove(at: currentDeleteIndex)
        tableView.reloadData()
    }
    
    @objc private func sureUploadBtnClick(btn: UIButton) {
        self.uploadRequest()
    }
    
    
    @objc private func cancelBtnClick(btn: UIButton) {
        pop.dismiss()
    }
    
    //MARK: ImagePicker Delegate 选择图片成功后代理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let chosenImage =  info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            picker.dismiss(animated: true) {
            }
            //处理传入后台
            var image = chosenImage
            AppLog("照片原尺寸: \(image.size)")
            image = image.resizeImage() ?? UIImage()
            AppLog("照片压缩后尺寸: \(image.size)")
            
            var imageType = ""
            
            if UserData.shared.userType == .jzgs || UserData.shared.userType == .cgy {
                
                imageType = "company/worker/header"
                
            }else if UserData.shared.userType == .gys || UserData.shared.userType == .fws {
                
                imageType = "merchant/header"
                
            }else if UserData.shared.userType == .yys {
                
                imageType = "substation/header"
            }
            
            YZBSign.shared.upLoadImageRequest(oldUrl: "", imageType: imageType, image: image, success: { (response) in
                
                let headStr = response.replacingOccurrences(of: "\"", with: "")
                
                print("头像原路径: \(response)")
                print("头像修改路径: \(headStr)")
                self.dataSource.append(headStr)
                self.tableView.reloadData()
                
                
            }, failture: { (error) in
                
                self.noticeError("上传失败", autoClear: true, autoClearTime: 1)
                
            })
        }
    }
    
    func uploadRequest() {
        if dataSource.count == 0 {
            noticeOnlyText("节点图片不能为空")
            return
        }
        var fileUrls = ""
        dataSource.forEach { (fileUrl) in
            if fileUrls == "" {
                fileUrls.append(fileUrl)
            } else {
                fileUrls.append(",")
                fileUrls.append(fileUrl)
            }
        }
        var parameters = Parameters()
        parameters["id"] = nodeModel?.id
        parameters["status"] = 2
        parameters["fileUrls"] = fileUrls
        YZBSign.shared.request(APIURL.updateNodeData, method: .put, parameters: parameters, success: { (response) in
            let model = BaseModel.deserialize(from: response)
            if model?.code == 0 {
                self.noticeSuccess("上传成功")
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    self.refresh?()
                    self.navigationController?.popViewController()
                }
            }
        }) { (error) in
            
        }
    }
}
