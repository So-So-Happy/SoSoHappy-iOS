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
    
    private lazy var blockButton = ServerReportButton().then {
        $0.delegate = self
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
            let nickName = KeychainService.getNickName()
            if nickName == userFeed.nickName {
                heartButton.isHidden = true
                blockButton.isHidden = true
            }
            profileImageNameTimeStackView.setContents(userFeed: userFeed)
            heartButton.setHeartButton(userFeed.isLiked)
            textView.font = UIFont.customFont(size: 16, weight: .medium)
            textView.textColor = UIColor(named: "MainTextColor")
            lockImageView.isHidden = true
        }
    }
}

//MARK: -  setLayoutForDetail
extension FeedDetailViewController {
    private func setLayoutForDetail() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: blockButton)
        
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
            make.top.equalToSuperview().inset(10)
            make.left.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(contentView.safeAreaLayoutGuide).inset(20)
            make.centerY.equalTo(profileImageNameTimeStackView)
        }
        
        imageSlideView.snp.makeConstraints { make in
            make.height.equalTo(0)
        }
        
        categoryStackView.snp.updateConstraints { make in
            make.top.equalToSuperview().inset(90)
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
        
        reactor.state
            .skip(2)
            .map { $0.userFeed }
            .subscribe(onNext: { [weak self] userFeed in
                guard let self = self else { return }
                
                guard let userFeed = userFeed else {
                    exceptionView.isHidden = false
                    exceptionView.titleLabel.text = "피드가 삭제되었습니다."
                    networkNotConnectedView.isHidden = true
                    return
                }
                
                setFeed(feed: userFeed)
               
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showNetworkErrorView }
            .subscribe(onNext: { [weak self] showNetworkErrorView in
                guard let self = self else { return }
                
                if showNetworkErrorView {
                    exceptionView.isHidden = true
                    networkNotConnectedView.isHidden = false
                } else {
                    networkNotConnectedView.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.showServerErrorAlert }
            .distinctUntilChanged()
            .bind(onNext: { [weak self] showServerErrorAlert in
                guard let self = self else { return }
                if showServerErrorAlert {
                    exceptionView.titleLabel.text = "서버로부터 피드를 불러오지 못했습니다.\n지속적으로 발생할 경우 문의해주세요."
                    exceptionView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.isReportProcessSucceded }
            .subscribe(onNext: { [weak self] isReportProcessSucceded in
                guard let self = self else { return }
                if isReportProcessSucceded{
                    coordinator?.goBackToRoot()
                }
            })
            .disposed(by: disposeBag)
    }
}

extension FeedDetailViewController: ServerReportButtonDelegate {
    func reportButtonDidTap(_ blockButton: ServerReportButton) {
        CustomAlert.presentCheckAndCancelAlert(title: "해당 작성자를 신고하시겠어요?", message: "", buttonTitle: "신고") {
            let alert = CustomAlert.createReportAlert { [weak self]  in
                self?.reactor?.action.onNext(.reportProblem(.report))
            }
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func blockButtonDidTap(_ blockButton: ServerReportButton) {
        CustomAlert.presentCheckAndCancelAlert(title: "작성자 차단", message: "차단하시겠습니까? 차단하면 차단한 작성자가 작성한 피드를 볼 수 없습니다.\n(차단 여부는 상대방이 알 수 없습니다.)", buttonTitle: "차단") { self.reactor?.action.onNext(.reportProblem(.block))
        }
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        coordinator?.dismiss()
    }
}
