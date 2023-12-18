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
    
    // 피드가 삭제되었습니다 (empty view), Alert 띄울 때 배경이 되어줄 빈 화면
    lazy var exceptionView = ExceptionView(
        title: "",
        inset: 200
    ).then {
        $0.isHidden = true
    }
    
    // 네트워크에 연결할 수 없습니다.
    private lazy var networkNotConnectedView = NetworkNotConnectedView(inset: 300).then {
        $0.isHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayoutForDetail()
        print("FeedDetailViewController - viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("FeedDetailViewController - viewWillAppear")
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
        self.view.addSubview(exceptionView) // 피드가 삭제되었습니다, 빈 화면
        self.view.addSubview(networkNotConnectedView) // 피드가 삭제되었습니다, 빈 화면
        
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
        
        networkNotConnectedView.retryButton.rx.tap
            .map { Reactor.Action.fetchFeed }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        // skip(1) 했을 때 바로 nil/userFeed 만 들어왓다 (즉, 서버에서 받아온 값)
        // skip(1) 네트워크 에러 띄울 때 (nil)
        // skip(1) 서버 오류일 때 userFeed 들어왔다.
        
        // why? 처음에 skip하는데 이미 userFeed reactor에 저장이 되어 있고
        // showServerErrorAlert의 값을 변경하면 모든 reactor.state가 발동하면서
        // userFeed가 들어오게 된다.
        
        // 1. showServerErrorAlert true (서버 오류)
        //  exceptionView.isHidden = true
        //  exceptionViewForServerError.isHidden = false
        
        // 버그 - FeedDetail에서 .showServerAlert를 했는데 FeedDetailViewController의 FeedCell에서 동일하게 작동하는 문제
        
        
        reactor.state
            .skip(1) // 바로 넣어준 거 제외 skip (서버로부터 받아온 것만 처리)
            .map { $0.userFeed }
            .debug()
            .bind { [weak self] userFeed in
                guard let `self` = self else { return }
                print("FeedReactor - FeedDetailViewController - userFeed : \(userFeed)")
                if let userFeed = userFeed {
                    print("FeedReactor (138) setFeed : \(userFeed)")
                    setFeed(feed: userFeed)
                } else {
                    let text = "피드가 삭제되었습니다."
                    exceptionView.isHidden = false
                    exceptionView.titleLabel.text = text
                }
            }
            .disposed(by: disposeBag)
        
        
        reactor.state
            .compactMap { $0.handleFeedError }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] handleFeedError in
                guard let self = self else { return }
                print("FeedReactor - FeedDetailViewController - handleFeedError: \(handleFeedError)")
                var text: String = ""
                switch handleFeedError {
                case .showNetworkErrorView: //네트워크
                    networkNotConnectedView.isHidden = false
                    print("네트워크 에러")
                case .showServerErrorAlert: //서버에러
                    text = ""
                    exceptionView.isHidden = false
                    exceptionView.titleLabel.text = text
                    // showAlert는 FeedCell에서 처리를 하기 때문에 여기에는 present해줄 필요없다
                    // 왜냐하면 cell과 reactor를 공유하기 때문
                default: break
                }
                
            })
            .disposed(by: disposeBag)
        
       
    
//        reactor.state
//            .compactMap { $0.showServerErrorAlert }
//            .distinctUntilChanged()
//            .bind(onNext: { [weak self] showServerErrorAlert in
//                guard let self = self else { return }
//                print("FeedReactor - FeedVIewController - showServerErrorAlert")
//                print("++++ FeedReactor - FeedDetailViewController showServerErrorAlert \(showServerErrorAlert)")
//                if showServerErrorAlert {
//                    exceptionViewForServerError.isHidden = false
//                    exceptionView.isHidden = true
//                    contentView.isHidden = true
//                    CustomAlert.presentErrorAlertWithoutDescription()
//                }
//            })
//            .disposed(by: disposeBag)
        
//        reactor.state
//            .compactMap { $0.isLike } // Optional 벗기고 nil 값 filter
//            .bind { [weak self] isLike in
//                guard let `self` = self else { return }
////                print("FeedReactor - FeedDetailViewController - ISLIKE : \(isLike)")
//                heartButton.setHeartButton(isLike)
//            }
//            .disposed(by: disposeBag)
    }
}
