//
//  ZBBSelectPopView.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/13.
//

import UIKit

class ZBBSelectPopView: UIView {

    private(set) var titles: [String] = [] {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    private var selectClosure: ((_ index: Int) -> Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createViews()
    }
    
    
    private var containerView: UIView!
    private var cancelBtn: UIButton!
    private var sureBtn: UIButton!
    private var pickerView: UIPickerView!
    
    private func createViews() {
        backgroundColor = .init(white: 0, alpha: 0.5)
        
        containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        containerView.backgroundColor = .white
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(10)
        }
        
        cancelBtn = UIButton(type: .custom)
        cancelBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        cancelBtn.setTitle("取消", for: .normal)
        cancelBtn.setTitleColor(.hexColor("#666666"), for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.top.left.equalTo(0)
            make.height.equalTo(50)
            make.width.equalTo(60)
        }
        
        sureBtn = UIButton(type: .custom)
        sureBtn.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        sureBtn.setTitle("确定", for: .normal)
        sureBtn.setTitleColor(.hexColor("#131313"), for: .normal)
        sureBtn.addTarget(self, action: #selector(sureBtnAction(_:)), for: .touchUpInside)
        containerView.addSubview(sureBtn)
        sureBtn.snp.makeConstraints { make in
            make.top.right.equalTo(0)
            make.height.equalTo(50)
            make.width.equalTo(60)
        }
        
        let separatorLine = UIView()
        separatorLine.backgroundColor = .hexColor("#F0F0F0")
        containerView.addSubview(separatorLine)
        separatorLine.snp.makeConstraints { make in
            make.top.equalTo(cancelBtn.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(0.5)
        }
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        containerView.addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(200)
            make.bottom.equalTo(-PublicSize.kBottomOffset)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let touch = touch {
            let point = touch.location(in: self)
            if !CGRectContainsPoint(containerView.frame, point) {
                hide()
            }
        }
    }
    
    
    @objc private func cancelBtnAction(_ sender: UIButton) {
        hide()
    }
    
    @objc private func sureBtnAction(_ sender: UIButton) {
        selectClosure?(pickerView.selectedRow(inComponent: 0))
        hide()
    }
    
}

extension ZBBSelectPopView {
    
    static func show(titles: [String], select: ((_ index: Int) -> Void)?) {
        let view = ZBBSelectPopView()
        view.titles = titles
        view.selectClosure = select
        view.show()
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25) {
            self.alpha = 0
            self.containerView.transform = CGAffineTransformMakeTranslation(0, self.containerView.height)
        } completion: { isFinished in
            self.removeFromSuperview()
        }
    }
    
    func show() {
        getWindow().addSubview(self)
        frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
        setNeedsLayout()
        layoutIfNeeded()
        
        alpha = 0
        containerView.transform = CGAffineTransformMakeTranslation(0, self.containerView.height)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.containerView.transform = .identity
        } completion: { isFinished in
           
        }
    }
}

extension ZBBSelectPopView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        titles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        45
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = view as? UILabel
        if label == nil {
            label = UILabel()
            label?.font = .systemFont(ofSize: 16, weight: .medium)
            label?.textColor = .hexColor("#131313")
            label?.textAlignment = .center
        }
        label?.text = titles[row]
        return label!
    }

}
