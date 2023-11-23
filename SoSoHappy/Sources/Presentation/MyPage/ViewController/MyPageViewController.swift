//
//  MyPageViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class MyPageViewController: UIViewController {
    // MARK: - Properties
    private let coordinator: MyPageCoordinatorProtocol?
    let tabController = TabBarController()
    var disposeBag = DisposeBag()
    
    // MARK: - Init
    init(reactor: MypageViewReactor, coordinator: MyPageCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    private lazy var profileView = ProfileView()
    private lazy var stackView = SettingStackView()

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindEvent()
    }
}

// MARK: - Reactor (bind func)
extension MyPageViewController: View {
    // MARK: Reactor를 설정하는 메서드
    func bind(reactor: MypageViewReactor) {
        bindActions(reactor)
        bindState(reactor)
    }
    
    // MARK: bind actions
    private func bindActions(_ reactor: MypageViewReactor) {
        self.rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: bind state (Reactor의 상태를 바탕으로 로딩 상태 및 다른 UI 업데이트)
    private func bindState(_ reactor: MypageViewReactor) {
        reactor.state.compactMap { $0.profile }
            .subscribe(onNext: { [weak self] image in
                guard let self = self else { return }
                profileView.profileImage.profileImageWithBackgroundView.profileImageView.image = image
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.intro }
            .subscribe(onNext: { [weak self] intro in
                guard let self = self else { return }
                profileView.introLabel.text = intro
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.email }
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                profileView.emailLabel.text = text
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.nickName }
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                profileView.nickNameLabel.text = text
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isProfileLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] shouldRun in
                guard let self = self else { return }
                profileView.introLabel.backgroundColor = shouldRun ? UIColor(named: "skeleton2") : .clear
                profileView.emailLabel.backgroundColor = shouldRun ? UIColor(named: "skeleton1") : .clear
                profileView.nickNameLabel.backgroundColor = shouldRun ? UIColor(named: "skeleton3") : .clear
                
                if shouldRun {
                    profileView.introLabel.text = "\t\t\t\t"
                    profileView.emailLabel.text = "\t\t\t\t\t"
                    profileView.nickNameLabel.text = "\t\t\t"
                }
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension MyPageViewController {
    private func setup() {
        setLayout()
    }
    
    private func setLayout() {
        view.addSubviews(profileView, stackView)
        view.backgroundColor = UIColor(named: "BGgrayColor")
        
        profileView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(25)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(25)
        }
    }
}

// MARK: - Set RxSwift without Reactor
extension MyPageViewController {
    // Reactor를 거치지 않고 바로 바인딩 되는 단순 이벤트를 정의합니다.
    // 보통 coordinator로 네비게이션하는 일은 reactor가 필요 X
    func bindEvent() {
        self.profileView.profileImage.editButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.pushProfileEditView()
            })
            .disposed(by: disposeBag)
        
        self.stackView.alarmCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.coordinator?.pushNotificationView()
            })
            .disposed(by: disposeBag)
        
        self.stackView.termsCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.coordinator?.pushToSView()
            })
            .disposed(by: disposeBag)
        
        self.stackView.policyCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.coordinator?.pushPrivatePolicyView()
            })
            .disposed(by: disposeBag)
        
        self.stackView.accountCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.coordinator?.pushAccountManagementView()
            })
            .disposed(by: disposeBag)
    }
}
