//
//  GuideViewController.swift
//  JCD_Company
//
//  Created by CSCloud on 2021/1/28.
//

import UIKit

private let ScreenWidth: CGFloat = UIScreen.main.bounds.size.width
private let ScreenHeight: CGFloat = UIScreen.main.bounds.size.height
private let ScreenBounds: CGRect = UIScreen.main.bounds

class GuideViewController: BaseViewController {

    private var collectView: UICollectionView?
    private var imageNames = ["guide_page_1", "guide_page_2", "guide_page_3"]
    private let cellIdentifier = "GuideCell"
    private var isHiddenNextButton = true
    private var pageController = UIPageControl(frame: CGRect(x: 0, y: ScreenHeight - 66, width: ScreenWidth, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusStyle = .lightContent
        if !PublicSize.isX {
            imageNames = ["guide_page_1_1", "guide_page_2_1", "guide_page_3_1"]
        }
        buildCollectionView()
        buildPageController()
    }
    
    // MARK: - Build UI
    private func buildCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = ScreenBounds.size
        layout.scrollDirection = .horizontal

        collectView = UICollectionView(frame: ScreenBounds, collectionViewLayout: layout)
        collectView?.delegate = self
        collectView?.dataSource = self
        collectView?.showsVerticalScrollIndicator = false
        collectView?.showsHorizontalScrollIndicator = false
        collectView?.isPagingEnabled = true
        collectView?.bounces = false
        collectView?.register(GuideCell.self, forCellWithReuseIdentifier: cellIdentifier)
        view.addSubview(collectView!)
    }
    
    func buildPageController() {
        pageController.numberOfPages = imageNames.count
        pageController.currentPage = 0
        view.addSubview(pageController)
    }

}

extension GuideViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GuideCell
        cell.newImage = UIImage(named: imageNames[indexPath.row])
        if indexPath.row != imageNames.count - 1 { // 3
            cell.setNextButtonHidden(hidden: true) // 如果不是第三张就隐藏button
        }
        return cell
    }
    
   
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x == ScreenWidth * CGFloat(imageNames.count - 1) {
            let cell = collectView?.cellForItem(at: IndexPath(row: imageNames.count-1, section: 0)) as! GuideCell
            cell.setNextButtonHidden(hidden: false)
            isHiddenNextButton = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != ScreenWidth * CGFloat(imageNames.count - 1) && !isHiddenNextButton && scrollView.contentOffset.x > ScreenWidth * CGFloat(imageNames.count - 2) {
            let cell = collectView?.cellForItem(at: IndexPath(row: imageNames.count-1, section: 0)) as! GuideCell
            cell.setNextButtonHidden(hidden: true)
            isHiddenNextButton = true
        }
        pageController.currentPage = Int(scrollView.contentOffset.x / ScreenWidth + 0.5)
    }
}


class GuideCell: UICollectionViewCell {
    private let newImageView = UIImageView()
    private let nextButton = UIButton().text("立即体验").textColor(.white).font(14, weight: .bold).backgroundColor(UIColor.hexColor("#7DB98B")).cornerRadius(17).masksToBounds()
    
    var newImage: UIImage? {
        didSet {
            newImageView.image = newImage
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        newImageView.contentMode = .scaleAspectFill
        
        contentView.sv(newImageView, nextButton)
        
        contentView.layout(
            0,
            |newImageView|,
            0
        )
        contentView.layout(
            >=0,
            nextButton.width(110).height(34).centerHorizontally(),
            95
        )

        nextButton.addTarget(self, action: #selector(GuideCell.nextButtonClick), for: UIControl.Event.touchUpInside)
        nextButton.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNextButtonHidden(hidden: Bool) {
        nextButton.isHidden = hidden
    }
    
    // GuideViewControllerDidFinish 还有一处在app.delegate中 进入到主界面中使用的
    @objc func nextButtonClick() {
//        AppUtils.setUserType(type: .cgy)
        UIApplication.shared.windows.first?.rootViewController = MainViewController()
    }
}
