//
//  FeedDetailViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then
/*
 1. heartButton 토글 적용
 */

final class FeedDetailViewController: UIViewController {
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var refreshControl = UIRefreshControl().then {
        $0.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    private lazy var scrollView = UIScrollView().then {
        let image = UIImage(named: "rainBackground")!
        $0.backgroundColor = UIColor(patternImage: image)
        $0.refreshControl = refreshControl
    }
    
    private lazy var contentView = UIView()
    private lazy var profileImageNameTimeStackView = ProfileImageNameTimeStackView(imageSize: 44)
    
    private lazy var heartButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        
        $0.setImage(image, for: .normal)
        $0.tintColor = .red
    }
    
    private lazy var categoryStackView = CategoryStackView(imageSize: 40)
    
    private lazy var dateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 15, weight: .light)
        $0.textColor = .gray
        $0.text = "2023.07.18 화요일"
    }
    
    private lazy var contentBackground = UIView().then {
        $0.layer.backgroundColor = UIColor.white.cgColor
        $0.layer.opacity = 0.4
        $0.layer.cornerRadius = 16
    }
    
    private lazy var contentLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 16, weight: .thin)
        $0.textColor = .black
        $0.numberOfLines = 0
        $0.text = "오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다. 커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다. 휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다.오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다. 커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다. \n\n휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다.\n\n휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다. \n\n오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다. 커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다. 휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다."
        $0.setLineSpacing(lineSpacing: 9)
    }
    
    private lazy var imageSlideView = ImageSlideView().then {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        $0.slideShowView.addGestureRecognizer(tapGesture)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

//MARK: - Add Subviews & Constraints
extension FeedDetailViewController {
    private func setup() {
        setLayout()
    }

    private func setLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubviews(contentView, profileImageNameTimeStackView, heartButton, categoryStackView, dateLabel, contentBackground, contentLabel, imageSlideView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(imageSlideView).offset(30)
        }
        
        profileImageNameTimeStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.left.equalTo(contentView.safeAreaLayoutGuide).inset(30)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(contentView.safeAreaLayoutGuide).inset(30)
            make.top.equalTo(profileImageNameTimeStackView)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageNameTimeStackView.snp.bottom).offset(40)
            
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categoryStackView.snp.bottom).offset(20)
        }
        
        contentBackground.snp.makeConstraints { make in
            make.left.right.equalTo(contentView.safeAreaLayoutGuide).inset(20)
            make.top.equalTo(dateLabel.snp.bottom).offset(26)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(contentBackground).inset(12)
            make.left.right.equalTo(contentView.safeAreaLayoutGuide).inset(40)
            make.bottom.equalTo(contentBackground).inset(12)
        }
        
        imageSlideView.snp.makeConstraints { make in
            make.top.equalTo(contentBackground.snp.bottom).offset(22)
            make.left.right.equalTo(contentView.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(300)
        }
    }
}

// MARK: - Action
extension FeedDetailViewController {
    @objc func didTap(sender: UITapGestureRecognizer? = nil) {
        print("ViewController - didTap() called")
        let _ = imageSlideView.slideShowView.presentFullScreenController(from: self)
    }
    
    // 실제로 서버로부터 다시 데이터를 받아오는 작업을 해보면서 수정하면 될 것 같음
    @objc func handleRefreshControl() {
        print("refreshTable")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // .main ? .global?
            // 새로운 들어온 데이터를 바탕으로 scrollview를 다시 그려줘야 함
            // scrollView는 마땅히 reloadData 같은 function이 없음
            // https://stackoverflow.com/questions/43583051/scrollview-not-working-after-reload-view-swift-3
            
            self.scrollView.refreshControl?.endRefreshing() // Refresh 작업이 끝났음을 control에 알림 (이 타이밍도 다시 한번 확인 필요할 듯)
        }
    }
}

#if DEBUG
import SwiftUI
struct FeedDetailViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        FeedDetailViewController()
    }
}
@available(iOS 13.0, *)
struct FeedDetailViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            FeedDetailViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
        }
        
    }
} #endif

