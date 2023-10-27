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

final class FeedDetailViewController: BaseDetailViewController {
    // MARK: - Properties
    private weak var coordinator: FeedDetailCoordinatorInterface?
    
    // MARK: - UI Components
    private lazy var profileImageNameTimeStackView = ProfileImageNameTimeStackView(imageSize: 44)
    private lazy var heartButton = HeartButton()


    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutForDetail()
        print("FeedDetailViewController viewDidLoad ---------------")
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
    
    override func setFeed(feed: FeedType) {
        super.setFeed(feed: feed)
        
        if let userFeed = feed as? UserFeed {
            profileImageNameTimeStackView.setContents(userFeed: userFeed)
            heartButton.setHeartButton(userFeed.isLiked)
        }
    }
}

//MARK: -  setLayoutForDetail
extension FeedDetailViewController {
    private func setLayoutForDetail() {
        print("FeedDetailViewController - setLayoutForDetail")
        self.contentView.addSubview(profileImageNameTimeStackView)
        self.contentView.addSubview(heartButton)
        
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
extension FeedDetailViewController: View {
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
                self.coordinator?.showOwner(ownerNickName: nickName)
            })
            .disposed(by: disposeBag)
        

        reactor.state
            .map { $0.userFeed }
            .bind { [weak self] userFeed in
                guard let `self` = self else { return }
                print("1. FeedDetailViewController reactor.state USERFEED")
                setFeed(feed: userFeed)
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
