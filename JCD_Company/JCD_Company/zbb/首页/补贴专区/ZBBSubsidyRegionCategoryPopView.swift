//
//  ZBBSubsidyRegionCategoryPopView.swift
//  JCD_Company
//
//  Created by 谈亚健 on 2025/1/8.
//

import UIKit
import ObjectMapper

class ZBBSubsidyRegionCategoryPopView: UIView {

    var hideClosure: (() -> Void)?
    
    private var containerView: UIView!
    private var leftTableView: UITableView!
    private var rightTableView: UITableView!
    private var resetBtn: UIButton!
    private var sureBtn: UIButton!
    
    private var topHideBtn: UIButton!
    
    
    
    private var categoryId: String?
    private var leftList: [HoStoreModel]?
    private var leftIndex = -1
    private var rightList: [HoStoreModel]?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    private func createViews() {
        isHidden = true
        clipsToBounds = true
        backgroundColor = .init(white: 0, alpha: 0.5)
        
        containerView = UIView()
        containerView.backgroundColor = .white
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.equalTo(240)
        }
        
        leftTableView = UITableView(frame: .zero, style: .plain)
        leftTableView.backgroundColor = .clear
        leftTableView.delegate = self
        leftTableView.dataSource = self
        leftTableView.showsVerticalScrollIndicator = false
        leftTableView.alwaysBounceVertical = true
        leftTableView.tableFooterView = UIView()
        leftTableView.separatorStyle = .none
        leftTableView.rowHeight = 50
        leftTableView.register(ZBBSubsidyRegionCategoryCell.self, forCellReuseIdentifier: "Cell")
        containerView.addSubview(leftTableView)
        leftTableView.snp.makeConstraints { make in
            make.top.left.equalTo(0)
            make.right.equalTo(self.snp.centerX)
            make.bottom.equalTo(-40)
        }
        
        rightTableView = UITableView(frame: .zero, style: .plain)
        rightTableView.backgroundColor = .clear
        rightTableView.delegate = self
        rightTableView.dataSource = self
        rightTableView.showsVerticalScrollIndicator = false
        rightTableView.alwaysBounceVertical = true
        rightTableView.tableFooterView = UIView()
        rightTableView.separatorStyle = .none
        rightTableView.rowHeight = 50
        rightTableView.register(ZBBSubsidyRegionCategoryCell.self, forCellReuseIdentifier: "Cell")
        containerView.addSubview(rightTableView)
        rightTableView.snp.makeConstraints { make in
            make.top.right.equalTo(0)
            make.left.equalTo(self.snp.centerX)
            make.bottom.equalTo(-40)
        }
        
        let centerLine = UIView()
        centerLine.backgroundColor = .hexColor("#CCCCCC")
        containerView.addSubview(centerLine)
        centerLine.snp.makeConstraints { make in
            make.top.bottom.equalTo(leftTableView)
            make.left.equalTo(leftTableView.snp.right)
            make.width.equalTo(0.5)
        }
        
        resetBtn = UIButton(type: .custom)
        resetBtn.layer.borderWidth = 0.5
        resetBtn.layer.borderColor = UIColor.hexColor("#CCCCCC").cgColor;
        resetBtn.titleLabel?.font = .systemFont(ofSize: 14)
        resetBtn.setTitle("重置", for: .normal)
        resetBtn.setTitleColor(.hexColor("#666666"), for: .normal)
        resetBtn.addTarget(self, action: #selector(resetBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(resetBtn)
        resetBtn.snp.makeConstraints { make in
            make.top.equalTo(leftTableView.snp.bottom)
            make.left.bottom.equalTo(0)
            make.right.equalTo(leftTableView)
        }
        
        sureBtn = UIButton(type: .custom)
        sureBtn.isEnabled = false
        sureBtn.titleLabel?.font = .systemFont(ofSize: 14)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.white, for: .normal)
        sureBtn.setBackgroundImage(UIImage(color: .hexColor("#007E41"), size: CGSizeMake(1, 1)), for: .normal)
        sureBtn.setBackgroundImage(UIImage(color: .hexColor("#CCCCCC"), size: CGSizeMake(1, 1)), for: .disabled)
        sureBtn.addTarget(self, action: #selector(sureBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { make in
            make.top.equalTo(rightTableView.snp.bottom)
            make.right.bottom.equalTo(0)
            make.left.equalTo(rightTableView)
        }
        
        topHideBtn = UIButton(type: .custom)
        topHideBtn.backgroundColor = .clear
        topHideBtn.addTarget(self, action: #selector(hide), for: .touchUpInside)
    }
    
    func show() {
        setNeedsLayout()
        layoutIfNeeded()
        
        
        
        isHidden = false
        alpha = 0
        containerView.transform = CGAffineTransformMakeTranslation(0, -containerView.height)
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.alpha = 1
            self.containerView.transform = .identity
        } completion: { isFinished in
            self.superview?.addSubview(self.topHideBtn)
            self.topHideBtn.snp.makeConstraints { make in
                make.top.left.right.equalTo(0)
                make.bottom.equalTo(self.snp.top)
            }
        }
        
    }
    
    @objc func hide() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut) {
            self.alpha = 0
            self.containerView.transform = CGAffineTransformMakeTranslation(0, -self.containerView.height)
        } completion: { isFinished in
            self.isHidden = true
            self.topHideBtn.removeFromSuperview()
        }
        hideClosure?()
    }
    
    func refreshData(for categoryId: String) {
        self.categoryId = categoryId
        var param = Parameters()
        param["parentId"] = categoryId
        param["categoryType"] = "1"
        YZBSign.shared.request(APIURL.getNewCategory, method: .get, parameters: param, success: {[weak self] (res) in
            let dataArray = Utils.getReqArr(data: res as AnyObject)
            //
            self?.leftList = Mapper<HoStoreModel>().mapArray(JSONArray: dataArray as! [[String : Any]])
            self?.leftIndex = 0
            self?.leftTableView.reloadData()
            self?.leftTableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            //
            self?.rightList = self?.leftList?.first?.categoryList
            self?.rightTableView.reloadData()

        }) { (error) in
            
        }
    }
    
    //MARK: - Action
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            if !CGRectContainsPoint(containerView.frame, point) {
                hide()
            }
        }
    }
    
    @objc private func resetBtnAction(_ sender: UIButton) {
        
        hide()
    }

    @objc private func sureBtnAction(_ sender: UIButton) {
        
        hide()
    }
}

extension ZBBSubsidyRegionCategoryPopView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTableView {
            return leftList?.count ?? 0
        } else {
            return rightList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ZBBSubsidyRegionCategoryCell
        if tableView == leftTableView {
            cell.title = leftList?[indexPath.row].name
        } else {
            cell.isRight = true
            cell.title = rightList?[indexPath.row].name
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == leftTableView {
            if leftIndex != indexPath.row {
                leftIndex = indexPath.row
                rightList = leftList?[indexPath.row].categoryList
                rightTableView.reloadData()
            }
        }
        sureBtn.isEnabled = leftIndex >= 0 && (rightTableView.indexPathsForSelectedRows?.count ?? 0) > 0
    }
}


//MARK: -

fileprivate class ZBBSubsidyRegionCategoryCell: UITableViewCell {
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var isRight = false {
        didSet {
            titleLabel.snp.remakeConstraints { make in
                make.left.equalTo(25)
                make.centerY.equalToSuperview()
                if isRight {
                    make.right.equalTo(-50)
                } else {
                    make.right.equalTo(-10)
                }
            }
            selectedIcon.isHidden = !isRight || !isSelected
        }
    }
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = .systemFont(ofSize: 14, weight: isSelected ? .medium : .regular)
            titleLabel.textColor = .hexColor(isSelected ? "#131313" : "#6F7A75")
            selectedIcon.isHidden = !isRight || !isSelected
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        titleLabel.font = .systemFont(ofSize: 14, weight: isSelected ? .medium : .regular)
        titleLabel.textColor = .hexColor(isSelected ? "#131313" : "#6F7A75")
        selectedIcon.isHidden = !isRight || !isSelected
    }
    
    private var titleLabel: UILabel!
    private var selectedIcon: UIImageView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .hexColor("#6F7A75")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(25)
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
        
        selectedIcon = UIImageView(image: UIImage(named: "zbbt_category_select"))
        selectedIcon.isHidden = true
        contentView.addSubview(selectedIcon)
        selectedIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-25)
        }
    }
}
