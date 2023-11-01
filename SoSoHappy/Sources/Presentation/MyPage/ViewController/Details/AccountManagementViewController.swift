//
//  AccoutManagementViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/31/23.
//

import UIKit
import Then
import ReactorKit

class AccountManagementViewController: UIViewController {
    
    // MARK: - Properties
    private let coordinator: MyPageCoordinatorProtocol?
    private let reactor: AccountManagementViewReactor?
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
    }
    private lazy var logoutButton = UIButton().then {
        $0.setTitle("로그아웃", for: .normal)
        $0.contentHorizontalAlignment = .left
        $0.setTitleColor(.darkGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    }
    private lazy var resignButton = UIButton().then {
        $0.setTitle("회원탈퇴", for: .normal)
        $0.contentHorizontalAlignment = .left
        $0.setTitleColor(.systemRed, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    }
    
    // MARK: - Init
    public init(reactor: AccountManagementViewReactor, coordinator: MyPageCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind(reactor: self.reactor ?? AccountManagementViewReactor())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.addButton.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if let tabBarController = self.tabBarController as? TabBarController {
            tabBarController.addButton.isHidden = false
        }
    }
}

// MARK: - Reactor (bind func)
extension AccountManagementViewController: View {
    // MARK: Reactor를 설정하는 메서드
    func bind(reactor: AccountManagementViewReactor) {
        bindActions(reactor)
        bindState(reactor)
    }
    
    // MARK: bind actions
    private func bindActions(_ reactor: AccountManagementViewReactor) {
        logoutButton.rx.tap
            .map { Reactor.Action.tapLogoutButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        resignButton.rx.tap
            .map { Reactor.Action.tapResignButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: bind state (Reactor의 상태를 바탕으로 로딩 상태 및 다른 UI 업데이트)
    private func bindState(_ reactor: AccountManagementViewReactor) {
        reactor.state.compactMap { $0.showLogoutCheckAlert }
            .subscribe(onNext: { [weak self] isClicked in
                guard let self = self else { return }
                if isClicked {
                    CustomAlert.presentCheckAlert(title: "정말 로그아웃 하시겠습니까?", message: "이후에 재로그인이 가능해요.", buttonTitle: "확인") { self.reactor?.action.onNext(.logout) }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.goToLoginView }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                if result {
                    coordinator?.goBackToLogin()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.showResignCheckAlert }
            .subscribe(onNext: { [weak self] isClicked in
                guard let self = self else { return }
                if isClicked {
                    CustomAlert.presentCheckAlert(title: "정말 회원탈퇴 하시겠습니까?", message: "이후에 재로그인이 불가능해요.", buttonTitle: "확인") { self.reactor?.action.onNext(.resign) }
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.showErrorAlert }
            .subscribe(onNext: { [weak self] error in
                guard let self = self else { return }
                CustomAlert.presentErrorAlert(error: error)
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Add Subviews & Constraints
extension AccountManagementViewController {
    private func setup() {
        setAttribute()
        setLayout()
    }
    
    private func setAttribute() {
        view.backgroundColor = UIColor(named: "BGgrayColor")
    }

    private func setLayout() {
        stackView.addArrangedSubview(logoutButton)
        stackView.addArrangedSubview(resignButton)
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview().inset(30)
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(20)
        }
    }
}
