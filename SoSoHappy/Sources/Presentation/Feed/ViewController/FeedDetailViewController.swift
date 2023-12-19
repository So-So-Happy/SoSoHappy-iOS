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
    
    lazy var exceptionView = ExceptionView(
        title: "",
        inset: 200
    ).then {
        $0.isHidden = true
    }
    
    private lazy var networkNotConnectedView = NetworkNotConnectedView(inset: 300).then {
        $0.isHidden = true
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
        self.view.addSubview(networkNotConnectedView)
        
        self.contentView.addSubview(profileImageNameTimeStackView)
        self.contentView.addSubview(heartButton)
        
        exceptionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        networkNotConnectedView.snp.makeConstraints { make in
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
                guard let self = self else { return }
                imageSlideView.slideShowView.presentFullScreenController(from: self)
            })
            .disposed(by: disposeBag)
        
        heartButton.rx.tap
            .map { Reactor.Action.toggleLike}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        profileImageNameTimeStackView.profileImageView.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, let nickName = profileImageNameTimeStackView.profileNickNameLabel.text else { return }
                coordinator?.showOwner(ownerNickName: nickName)
            })
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                coordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        networkNotConnectedView.retryButton.rx.tap
            .map { Reactor.Action.fetchFeed }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(2) // 첫 2개 제거
            .compactMap { $0.userFeed }
            .subscribe(onNext: { [weak self] userFeed in
                guard let self = self else { return }
                if let showNetworkErrorView = reactor.currentState.showNetworkErrorView,  !showNetworkErrorView {
                    setFeed(feed: userFeed)
                    networkNotConnectedView.isHidden = true
                    exceptionView.isHidden = true
                }
                
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showNetworkErrorView }
            .distinctUntilChanged()
            .debug()
            .subscribe(onNext: { [weak self] showNetworkErrorView in
                guard let self = self else { return }
                if showNetworkErrorView {
                    exceptionView.isHidden = true
                    networkNotConnectedView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showServerErrorAlert }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] showServerErrorAlert in
                guard let self = self else { return }
                if showServerErrorAlert {
                    exceptionView.isHidden = false
                    exceptionView.titleLabel.text = ""
                    networkNotConnectedView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
}
