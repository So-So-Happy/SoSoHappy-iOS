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
 1. heartbutton throttle, debouce 적용, 날씨 bacgkround 이미지 적용
 2. OwnerFeedViewController에서 여기에서 보여주는 피드를 좋아요했을 때 반영이 안될 것 같은데 확인해보고 코드 수정해주기
 */
// MARK: FeedViewControllerDelegate -> Interface 코드로 대체
protocol FeedDetailViewControllerDelegate: AnyObject {
    func showOwner(ownerNickName: String)
}
 
final class FeedDetailViewController: UIViewController {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    private weak var coordinator: FeedDetailCoordinatorInterface?
    
    // MARK: - UI Components
    private lazy var scrollView = UIScrollView().then {
        let image = UIImage(named: "rainBackground")!
        $0.backgroundColor = UIColor(patternImage: image)
//        $0.refreshControl = refreshControl
    }
    
    private lazy var contentView = UIView()
    private lazy var profileImageNameTimeStackView = ProfileImageNameTimeStackView(imageSize: 44)
    private lazy var heartButton = HeartButton()
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

    private lazy var imageSlideView = ImageSlideView().then {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        $0.slideShowView.addGestureRecognizer(tapGesture)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("FeedDetailViewController viewDidLoad ---------------")
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("FeedDetailViewController viewWillAppear ---------------")
    }
    
    init(reactor: FeedReactor, coordinator: FeedDetailCoordinatorInterface) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension FeedDetailViewController {
    private func setup() {
        self.navigationItem.title = ""
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
            make.bottom.equalTo(imageSlideView).offset(40)
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
        self.rx.viewWillAppear
            .map {
                print("viewWillAppear - fetch feeds")
                return Reactor.Action.fetchFeed
            } // default today
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
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
        
        profileImageNameTimeStackView.profileImageView.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let `self` = self, let nickName = profileImageNameTimeStackView.profileNickNameLabel.text else { return }
                self.coordinator?.showOwner(ownerNickName: nickName)
            })
            .disposed(by: disposeBag)
        

        reactor.state
            .map { $0.feed }
            .bind { [weak self] feed in
                guard let `self` = self, let feed = feed else { return }
//                print("여기 : \(type(of: feed))")
                setFeed(feed)
                
            }
            .disposed(by: disposeBag)
    }
    
    private func setFeed(_ feed: FeedTemp) {
        profileImageNameTimeStackView.setContents(feed: feed)
        // 날씨에 대한 background 이미지 설정해주는 코드 필요
        heartButton.setHeartButton(feed.isLike)
        categoryStackView.addImageViews(images: feed.categories)
        dateLabel.text = feed.feedDate
        contentLabel.text = feed.content
        contentLabel.setLineSpacing(lineSpacing: 9)
        
        if feed.images.isEmpty {
            imageSlideView.isHidden = true
        } else {
            imageSlideView.isHidden = false
            imageSlideView.setContents(feed: feed)
        }
    }
}

// MARK: - Action
extension FeedDetailViewController {
    @objc func didTap(sender: UITapGestureRecognizer? = nil) {
        print("ViewController - didTap() called")
        imageSlideView.slideShowView.presentFullScreenController(from: self)
    }
}
