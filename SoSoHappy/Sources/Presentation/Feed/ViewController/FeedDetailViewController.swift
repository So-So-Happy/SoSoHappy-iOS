//
//  FeedDetailViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import ImageSlideshow
/*
 1. stack 처리 필요 (리팩토링할 때 해주면 될 듯)
 2. heartButton 토글 적용
 5. device 눕혔을 때  scrollView.backgroundColor = UIColor(patternImage: image) 모양 한번 더 확인해보기.
 
    방법1) - scrollView.backgroundColor 를 이미지 배경과 비슷하게 주고
          - contentView에 UIColor(patternImage: UIImage(named: "rainBackground")!)
 
    방법2) - scrollView에 UIColor(patternImage: UIImage(named: "rainBackground")!)
          
 https://www.youtube.com/watch?v=-yjknIzf5KE
 */

final class FeedDetailViewController: UIViewController {
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        let image = UIImage(named: "rainBackground")!
        scrollView.backgroundColor = UIColor(patternImage: image)
//        scrollView.backgroundColor = .white
        return scrollView
    }()
    private lazy var contentView: UIView = {
        let view = UIView()
//        view.backgroundColor = UIColor(patternImage: UIImage(named: "rainBackground")!)
        return view
    }()
    
    // 1.  작성자 프로필 이미지
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "profile")
//        iv.contentMode = .scaleAspectFit
//        iv.clipsToBounds = true
        
        return iv
    }()
    
    // 2. 작성자 닉네임
    private lazy var profileNickNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "소해피"
        return label
    }()
    
    // 3. 작성 시간 - '5분 전'
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 11, weight: .light)
        label.textColor = .gray
        label.text = "5분 전"
        
        return label
    }()
    
    // 4. 좋아요 버튼
    private lazy var heartButton: UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.tintColor = .red
        return btn
        
    }()
    
    // 7. 날짜 - '2023.07.18 화요일'
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .gray
        label.text = "2023.07.18 화요일"
        
        return label
    }()
    
    
    // 스택에 들어갈 요소들
    private lazy var happinessImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "happiness")
        return iv
    }()
    
    private lazy var categoryImageView1: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "donut")
        return iv
    }()
    
    private lazy var categoryImageView2: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "coffee")
        return iv
    }()
    
    private lazy var contentBackground: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.opacity = 0.4
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.textColor = .black
        label.numberOfLines = 0
        label.text = "오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다. 커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다. 휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다.오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다. 커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다. \n\n휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다.\n\n휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다. \n\n오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다. 커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다. 휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다."
        label.setLineSpacing(lineSpacing: 9)
        
        return label
    }()
    
    private lazy var pageIndicator: UIPageControl = {
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.orange
        pageIndicator.pageIndicatorTintColor = UIColor.lightGray
        
        return pageIndicator
    }()
    
    private lazy var slideShow: ImageSlideshow = {
        let slideShow = ImageSlideshow()
        slideShow.pageIndicator = pageIndicator
        slideShow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center)
        slideShow.contentScaleMode = .scaleAspectFill
        slideShow.activityIndicator = DefaultActivityIndicator()
        return slideShow
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubViews()
        setConstraints()
        setImages()
        
    }
}

//MARK: - Add Subviews & Constraints & Set images for SlideShow
extension FeedDetailViewController {
    private func addSubViews() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(profileNickNameLabel)
        contentView.addSubview(timeLabel)

        contentView.addSubview(heartButton)
        
        contentView.addSubview(happinessImageView)
        contentView.addSubview(categoryImageView1)
        contentView.addSubview(categoryImageView2)

        contentView.addSubview(dateLabel)
        contentView.addSubview(contentBackground)
        contentView.addSubview(contentLabel)
        contentView.addSubview(slideShow)
    }
    
    public func setImages() {
        slideShow.setImageInputs([
            ImageSource(image: UIImage(named: "pic1")!),
            ImageSource(image: UIImage(named: "pic2")!),
            ImageSource(image: UIImage(named: "pic3")!)
        ])
       
    }
    
    private func setConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.bottom.equalTo(slideShow).offset(30)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.left.equalTo(contentView.safeAreaLayoutGuide).inset(30)
            make.size.equalTo(44)
        }
        
        profileNickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.top.equalTo(profileImageView).inset(5)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(profileNickNameLabel.snp.bottom)
            make.left.equalTo(profileNickNameLabel)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(contentView.safeAreaLayoutGuide).inset(30)
            make.top.equalTo(profileNickNameLabel)
        }
        
        categoryImageView1.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.width.equalTo(50)
            make.top.equalTo(profileImageView.snp.bottom).offset(40)
            make.left.equalTo(happinessImageView.snp.right).offset(8)
            make.right.equalTo(categoryImageView2.snp.left).offset(-8)
        }

        happinessImageView.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.centerY.equalTo(categoryImageView1)
        }

        categoryImageView2.snp.makeConstraints { make in
            make.height.width.equalTo(50)
            make.centerY.equalTo(categoryImageView1)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(categoryImageView1.snp.bottom).offset(20)
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
        
        slideShow.snp.makeConstraints { make in
            make.top.equalTo(contentBackground.snp.bottom).offset(22)
            make.left.right.equalTo(contentView.safeAreaLayoutGuide).inset(30)
            make.height.equalTo(300)
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
