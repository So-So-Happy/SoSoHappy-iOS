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
        addSwipeGesture()
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
    
    private func addSwipeGesture() {
        let swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        swipeGestureRecognizerRight.direction = .right
        view.addGestureRecognizer(swipeGestureRecognizerRight)
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
        
        // 1. reactor 넣어주면서 - 1번
        // 2. (와이파이 연결되어 있다는 가정 하에) showNetWorkErrorView - false로 설정하면서 - 1번
        // 3 - 1. (잘 fetch) skip(2)하고 가져온게 최신 - 1번
        // 3 - 2. (서버 에러 나면) true했다가 false하기 때문에 - 2번
        reactor.state
            .skip(2) // 첫 2개 제거
            .map { $0.userFeed }
            .subscribe(onNext: { [weak self] userFeed in
                guard let self = self else { return }
                print("FeedDetailViewController userFeed 들어옴, userFeed : \(userFeed)")
                guard let userFeed = userFeed else {
                    // 피드가 삭제된 경우
                    exceptionView.isHidden = false
                    exceptionView.titleLabel.text = "피드가 삭제되었습니다."
                    networkNotConnectedView.isHidden = true
                    return
                }
                
                setFeed(feed: userFeed)
               
            })
            .disposed(by: disposeBag)
        
        // 네트워크 에러 나면 무조건 exceptionview는 hidden, networkNotConnectedView 보여주기
        reactor.state
            .compactMap { $0.showNetworkErrorView }
//            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] showNetworkErrorView in
                guard let self = self else { return }
                print("FeedDetailViewController 와이파이 연결 X : \(showNetworkErrorView)")
                if showNetworkErrorView {
                    exceptionView.isHidden = true
                    networkNotConnectedView.isHidden = false
                } else {
                    networkNotConnectedView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        // 서버 오류나면 exceptionView를 보여주고 networkConnectedView는 가려주고
        reactor.state
            .compactMap { $0.showServerErrorAlert }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] showServerErrorAlert in
                guard let self = self else { return }
                print("서버오류 \(showServerErrorAlert)")
                if showServerErrorAlert {
                    exceptionView.titleLabel.text = "서버로부터 피드를 불러오지 못했습니다.\n\n 지속적으로 발생할 경우 문의해주세요."
                    exceptionView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
}

extension FeedDetailViewController {
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        coordinator?.dismiss()
    }
}
