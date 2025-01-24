//
//  ZBBUserEvaluateViewController.swift
//  JCD_Company
//
//  Created by YJ on 2025/1/22.
//

import UIKit
import JXSegmentedView

class ZBBUserEvaluateViewController: BaseViewController {

    private var segmentDataSource: JXSegmentedTitleDataSource!
    private var segmentView: JXSegmentedView!
    private var scrollView: UIScrollView!
    private var fakeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "用户评价"
        createViews()
        refreshViews()
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
        segmentDataSource.titles = ["品牌产品", "品牌商", "装饰公司", "设计师", "项目经理", "工匠", "配送"]
        segmentDataSource.titleNormalFont = .systemFont(ofSize: 14)
        segmentDataSource.titleNormalColor = .hexColor("#999999")
        segmentDataSource.titleSelectedFont = .systemFont(ofSize: 14, weight: .bold)
        segmentDataSource.titleSelectedColor = .hexColor("#131313")
        segmentDataSource.isTitleColorGradientEnabled = true
        
        segmentView = JXSegmentedView()
        segmentView.backgroundColor = .white
        segmentView.delegate = self
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
        
        scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.mj_header = MJRefreshGifCustomHeader(refreshingBlock: {[weak self] in
            self?.refreshData()
        })
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(segmentView.snp.bottom)
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        fakeImageView = UIImageView()
        scrollView.addSubview(fakeImageView)
        fakeImageView.snp.makeConstraints { make in
            make.top.left.equalTo(10)
            make.right.bottom.equalTo(-10)
            make.width.equalTo(SCREEN_WIDTH - 20)
        }
    }
    
    private func refreshViews() {
        let imageNames = ["zbbt_evaluate_1",
                          "zbbt_evaluate_2",
                          "zbbt_evaluate_3",
                          "zbbt_evaluate_4",
                          "zbbt_evaluate_5",
                          "zbbt_evaluate_6",
                          "zbbt_evaluate_7"]
        
        if let image = UIImage(named: imageNames[segmentView.selectedIndex]) {
            fakeImageView.image = image
            fakeImageView.snp.remakeConstraints { make in
                make.top.left.equalTo(10)
                make.right.bottom.equalTo(-10)
                make.width.equalTo(SCREEN_WIDTH - 20)
                make.height.equalTo(image.size.height/image.size.width*(SCREEN_WIDTH - 20))
            }
        } else {
            fakeImageView.image = nil
            fakeImageView.snp.remakeConstraints { make in
                make.top.left.equalTo(10)
                make.right.bottom.equalTo(-10)
                make.width.equalTo(SCREEN_WIDTH - 20)
            }
        }
    }
    
    private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.scrollView.mj_header?.endRefreshing()
        }
    }
}

extension ZBBUserEvaluateViewController: JXSegmentedViewDelegate {
    
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        refreshViews()
    }
}
