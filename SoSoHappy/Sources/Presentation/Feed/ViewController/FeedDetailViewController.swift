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
 1. heartbutton throttle  적용
 */

final class FeedDetailViewController: BaseDetailViewController {
    // MARK: - Properties
    private weak var coordinator: FeedDetailCoordinatorInterface?
    
    // MARK: - UI Components
    private lazy var profileImageNameTimeStackView = ProfileImageNameTimeStackView(imageSize: 44)
    private lazy var heartButton = HeartButton()
    
    private lazy var backButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.setPreferredSymbolConfiguration(.init(scale: .large), forImageIn: .normal)
    }
    
    // 피드가 삭제되었습니다 (empty view)
    lazy var exceptionView = FeedExceptionView(
        title: "피드가 삭제되었습니다.",
        inset: 200
    ).then {
        $0.isHidden = true
        $0.backgroundColor = UIColor(named: "BGgrayColor")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutForDetail()
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
extension FeedDetailViewController {
    private func setLayoutForDetail() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.view.addSubview(exceptionView)
        self.contentView.addSubview(profileImageNameTimeStackView)
        self.contentView.addSubview(heartButton)
        
        exceptionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileImageNameTimeStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30)
            make.left.equalTo(contentView.safeAreaLayoutGuide).inset(30)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(contentView.safeAreaLayoutGuide).inset(30)
            make.top.equalTo(profileImageNameTimeStackView)
        }
        
        imageSlideView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
    }
}

//MARK: - bind func
extension FeedDetailViewController: View {
    func bind(reactor: FeedReactor) {
        self.rx.viewWillAppear
            .map { Reactor.Action.fetchFeed }
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
                coordinator?.dismiss()
            })
            .disposed(by: disposeBag)

        reactor.state
            .skip(1) // 바로 넣어준 거 제외 skip (서버로부터 받아온 것만 처리)
            .map { $0.userFeed }
            .distinctUntilChanged()
            .bind { [weak self] userFeed in
                guard let `self` = self else { return }
                if let userFeed = userFeed {
                    setFeed(feed: userFeed)
                } else {
                    exceptionView.isHidden = false
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isLike } // Optional 벗기고 nil 값 filter
            .bind { [weak self] isLike in
                guard let `self` = self else { return }
//                print("FeedReactor - FeedDetailViewController - ISLIKE : \(isLike)")
                heartButton.setHeartButton(isLike)
            }
            .disposed(by: disposeBag)
    }
}
