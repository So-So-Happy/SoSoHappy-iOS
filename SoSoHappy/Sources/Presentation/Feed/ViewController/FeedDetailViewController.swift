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
import ReactorKit
import RxGesture

/*
 1. Category가 계속 누적되는 문제 있음
 2. imageSlideShow tapObservable로 했을 때 full screen 되는게 좀 이상함
 */


final class FeedDetailViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    private let heartImageConfiguration = UIImage.SymbolConfiguration(pointSize: 21, weight: .light)
    
    // MARK: - UI Components
//    private lazy var refreshControl = UIRefreshControl().then {
//        $0.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
//    }
    
    private lazy var scrollView = UIScrollView().then {
        let image = UIImage(named: "rainBackground")!
        $0.backgroundColor = UIColor(patternImage: image)
//        $0.refreshControl = refreshControl
    }
    
    private lazy var contentView = UIView()
    private lazy var profileImageNameTimeStackView = ProfileImageNameTimeStackView(imageSize: 44)
    
    private lazy var heartButton = UIButton()
    
    private lazy var categoryStackView = CategoryStackView(imageSize: 40)
    
    private lazy var dateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 15, weight: .light)
        $0.textColor = .gray
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
//        $0.setLineSpacing(lineSpacing: 9)
    }
//
//    private lazy var imageSlideView = ImageSlideView().then {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
//        $0.slideShowView.addGestureRecognizer(tapGesture)
//    }
//
    private lazy var imageSlideView = ImageSlideView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    init(reactor: FeedReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension FeedDetailViewController: View {
    func bind(reactor: FeedReactor) {
        imageSlideView.tapObservable
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.imageSlideView.slideShowView.presentFullScreenController(from: self)
            })
            .disposed(by: disposeBag)
        
        heartButton.rx.tap // debouce ? throttle
            .map { Reactor.Action.toggleLike}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        imageSlideView.tapObservable
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                imageSlideView.slideShowView.presentFullScreenController(from: self)
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.feed }
            .bind { [weak self] feed in
                guard let `self` = self, let feed = feed else { return }
                print("here")
                print("여기 : \(type(of: feed))")
                profileImageNameTimeStackView.setContents(feed: feed)
                // 날씨에 대한 background 이미지 설정해주는 코드 필요
                setHeartButton(feed.isLike)
                categoryStackView.addImageViews(images: feed.categories)
                dateLabel.text = feed.date
                contentLabel.text = feed.content
                contentLabel.setLineSpacing(lineSpacing: 9)
                imageSlideView.setContents(feed: feed)
            }
            .disposed(by: disposeBag)
        
        // 아래 코드가 오류를 띄우면서 Build Success되는 이상한...
//        reactor.state
//            .compactMap { $0.feed }
//            .bind { [weak self] feed in
//                guard let `self` = self else { return }
//                print("here")
//                print("여기 : \(type(of: feed))")
//                profileImageNameTimeStackView.setContents(feed: feed)
//                // 날씨에 대한 background 이미지 설정해주는 코드 필요
//                heartButton.setImage( setImageForHeartButton(feed.isLike), for: .normal)
//                heartButton.tintColor = feed.isLike ? .systemRed : .systemGray
//                categoryStackView.addImageViews(images: feed.categories)
//                dateLabel.text = feed.date
//                contentLabel.text = feed.content
//                imageSlideView.setContents(feed: feed)
//            }
//            .disposed(by: disposeBag)
    }
    

    private func setHeartButton(_ isLike: Bool) {
        let image: UIImage = isLike ? UIImage(systemName: "heart.fill", withConfiguration: heartImageConfiguration)! : UIImage(systemName: "heart", withConfiguration: heartImageConfiguration)!
        let color: UIColor =  isLike ? UIColor.systemRed : UIColor.systemGray
        
        heartButton.setImage(image, for: .normal)
        heartButton.tintColor = color
    }
}

// MARK: - Action
extension FeedDetailViewController {
//    @objc func didTap(sender: UITapGestureRecognizer? = nil) {
//        print("ViewController - didTap() called")
//        let _ = imageSlideView.slideShowView.presentFullScreenController(from: self)
//    }
    //
    //    // 실제로 서버로부터 다시 데이터를 받아오는 작업을 해보면서 수정하면 될 것 같음
    //    @objc func handleRefreshControl() {
    //        print("refreshTable")
    //        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // .main ? .global?
    //            // 새로운 들어온 데이터를 바탕으로 scrollview를 다시 그려줘야 함
    //            // scrollView는 마땅히 reloadData 같은 function이 없음
    //            // https://stackoverflow.com/questions/43583051/scrollview-not-working-after-reload-view-swift-3
    //
    //            self.scrollView.refreshControl?.endRefreshing() // Refresh 작업이 끝났음을 control에 알림 (이 타이밍도 다시 한번 확인 필요할 듯)
    //        }
    //    }
    //}
    //
}
