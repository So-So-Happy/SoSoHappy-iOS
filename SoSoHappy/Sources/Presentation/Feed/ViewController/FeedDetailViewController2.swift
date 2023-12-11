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
 리팩토링
 1. heartbutton throttle, debouce 적용, 날씨 bacgkround 이미지 적용

 */

final class FeedDetailViewController2: BaseDetailViewController {
    // MARK: - Properties
    private weak var coordinator: FeedDetailCoordinatorInterface?
    
    // MARK: - UI Components
    private lazy var profileImageNameTimeStackView = ProfileImageNameTimeStackView(imageSize: 44)
    private lazy var heartButton = HeartButton()
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
    }
    
    private lazy var exceptionView = FeedExceptionView(
        title: "피드가 삭제되었습니다.",
        inset: 40
    ).then {
        $0.isHidden = true
    }
    

//    override func viewDidLoad() {
//        print("FeedDetailViewController viewDidLoad ---------------")
//        super.viewDidLoad()
//        setLayoutForDetail()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.setLayout()
        setLayoutForDetail()

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
    
    override func setFeed(feed: FeedType) {
        super.setFeed(feed: feed)
        
        if let userFeed = feed as? UserFeed {
            profileImageNameTimeStackView.setContents(userFeed: userFeed)
            heartButton.setHeartButton(userFeed.isLiked)
            textView.font = UIFont.customFont(size: 16, weight: .medium)
        }
    }
}

//MARK: -  setLayoutForDetail
extension FeedDetailViewController2 {
    private func setLayoutForDetail() {
        print("FeedDetailViewController - setLayoutForDetail")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.view.addSubview(exceptionView)
        self.contentView.addSubview(profileImageNameTimeStackView)
        self.contentView.addSubview(heartButton)
        
        exceptionView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        profileImageNameTimeStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.left.equalTo(contentView.safeAreaLayoutGuide).inset(30)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(contentView.safeAreaLayoutGuide).inset(30)
            make.top.equalTo(profileImageNameTimeStackView)
        }
    }
}

//MARK: - bind func
extension FeedDetailViewController2: View {
    func bind(reactor: FeedReactor) {
        self.rx.viewWillAppear
            .map {
                print("FeedDetailViewController -viewWillAppear - fetch feeds")
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
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self, let nickName = profileImageNameTimeStackView.profileNickNameLabel.text else { return }
                coordinator?.showOwner(ownerNickName: nickName)
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
//                print("back button tapped")
                coordinator?.dismiss()
            })
            .disposed(by: disposeBag)

        reactor.state
            .map { $0.userFeed }
            .bind { [weak self] userFeed in
                guard let `self` = self else { return }
                print("FeedDetailViewController- userFeed : \(userFeed)")
                if let userFeed = userFeed {
                    print("FeedDetailViewController-  excenption FALSE")
//                    scrollView.isHidden = true
//                    exceptionView.isHidden = false
                    setFeed(feed: userFeed)
                } else {
                    scrollView.isHidden = true
                    exceptionView.isHidden = false
                    print("FeedDetailViewController-  excenption TRUE")
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .compactMap { $0.isLike } // Optional 벗기고 nil 값 filter
            .bind { [weak self] isLike in
                guard let `self` = self else { return }
                print("1. FeedDetailViewController reactor.state ISLIKE")
                heartButton.setHeartButton(isLike)
            }
            .disposed(by: disposeBag)
    }
}
