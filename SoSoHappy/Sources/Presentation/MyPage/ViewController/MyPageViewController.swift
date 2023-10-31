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

final class MyPageViewController: UIViewController {
    // MARK: - Properties
    private let reactor: AccountManagementViewReactor?
    private let coordinator: MyPageCoordinatorProtocol?
    let tabController = TabBarController()
    
    var disposeBag = DisposeBag()
    var testProfile = Profile(email: "mlnjv016@gmail.com", nickName: "Riru", profileImg: UIImage(named: "happy4")!, introduction: "아 배고파")
    
    init(reactor: AccountManagementViewReactor, coordinator: MyPageCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Components
    private lazy var profileView = ProfileView()
    private lazy var stackView = SettingStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindEvent()
        profileView.update(with: testProfile) // test용
    }
}

//MARK: - Set Navigation & Add Subviews & Constraints
extension MyPageViewController {
    // MARK: - Layout
    private func setup() {
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubviews(profileView, stackView)
        self.view.backgroundColor = .white
        
        profileView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(25)
        }
    }
}

extension MyPageViewController {
    // Reactor를 거치지 않고 바로 바인딩 되는 단순 이벤트를 정의합니다.
    // 보통 coordinator로 네비게이션하는 일은 reactor가 필요 X
    func bindEvent() {
        self.profileView.profileSetButton.rx.tap
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
        
        self.stackView.languageCell.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.coordinator?.pushLanguageView()
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
