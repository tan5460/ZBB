//
//  ZBBSafeSupervisesViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/22.
//

import UIKit
import JXSegmentedView

class ZBBSafeSupervisesViewController: BaseViewController {

    private var segmentDataSource: JXSegmentedTitleDataSource!
    private var segmentView: JXSegmentedView!
    
    private var noDataIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "安全监管"
        createViews()
    }
    
    private func createViews() {
        
        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        indicator.indicatorHeight = 3
        indicator.indicatorCornerRadius = 1.5
        indicator.verticalOffset = 6
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = 1.5
        gradientLayer.masksToBounds = true
        gradientLayer.frame = CGRectMake(0, 0, 20, 3)
        gradientLayer.locations = [0, 1]
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 0)
        gradientLayer.colors = [UIColor.hexColor("#47DC94").cgColor, UIColor.hexColor("#007E41").cgColor]
        indicator.layer.addSublayer(gradientLayer)
        
        segmentDataSource = JXSegmentedTitleDataSource()
        segmentDataSource.titles = ["绿色产品", "设计图纸", "安全施工", "专家团队", "检测机构"]
        segmentDataSource.titleNormalFont = .systemFont(ofSize: 14)
        segmentDataSource.titleNormalColor = .hexColor("#999999")
        segmentDataSource.titleSelectedFont = .systemFont(ofSize: 14, weight: .bold)
        segmentDataSource.titleSelectedColor = .hexColor("#131313")
        segmentDataSource.isTitleColorGradientEnabled = true
        
        segmentView = JXSegmentedView()
        segmentView.backgroundColor = .white
        segmentView.dataSource = segmentDataSource
        segmentView.contentEdgeInsetLeft = 15
        segmentView.contentEdgeInsetRight = 15
        segmentView.indicators = [indicator]
        view.addSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.left.right.equalTo(0)
            make.height.equalTo(44)
        }
        
        noDataIcon = UIImageView(image: UIImage(named: "zbbt_no_data"))
        view.addSubview(noDataIcon)
        noDataIcon.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom).offset(65)
            make.centerX.equalToSuperview()
            make.width.equalTo(130)
            make.height.equalTo(170)
        }
    }

}
