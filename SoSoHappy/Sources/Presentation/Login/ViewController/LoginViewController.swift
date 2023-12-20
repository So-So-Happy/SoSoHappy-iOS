//
//  LoginViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import Foundation
import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit
import GoogleSignIn

final class LoginViewController: UIViewController, View {
    
    private let coordinator: AuthCoordinatorProtocol?
    private let reactor: LoginViewReactor?
    
    // MARK: - UI Components
    private lazy var appDescriptionStackView = AppDescriptionStackView()
    private lazy var appIconImageView = UIImageView().then {
        $0.image = UIImage(named: "loginImage")
        $0.contentMode = .scaleAspectFit
    }
    private lazy var loginLabel = UILabel().then {
        $0.text = "SNS 계정으로 간편 가입하기"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 17, weight: .medium)
    }
    private lazy var logInButtonStackView = LogInButtonStackView()
    
    var disposeBag = DisposeBag()
    
    // MARK: - Init
    public init(reactor: LoginViewReactor, coordinator: AuthCoordinatorProtocol) {
        self.reactor = reactor
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind(reactor: self.reactor ?? LoginViewReactor(userRepository: UserRepository(), kakaoManager: KakaoSigninManager(), appleManager: AppleSigninManager(), googleMagager: GoogleSigninManager()))
    }

    // MARK: - Reactor를 설정하는 메서드
    func bind(reactor: LoginViewReactor) {
        bindActions(reactor)
        bindState(reactor)
    }
    
    // MARK: - bindActions
    private func bindActions(_ reactor: LoginViewReactor) {
        logInButtonStackView.kakaoLoginButton.rx.tap
            .map { Reactor.Action.tapKakaoLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        logInButtonStackView.googleLoginButton.rx.tap
            .map { Reactor.Action.tapGoogleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        logInButtonStackView.appleLoginButton.rx.tap
            .map { Reactor.Action.tapAppleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    // MARK: - bindState (Reactor의 상태를 바탕으로 로딩 상태 및 다른 UI 업데이트)
    private func bindState(_ reactor: LoginViewReactor) {
        reactor.state.map { $0.isKakaoLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] shouldRun in
                guard let self = self else { return }
                logInButtonStackView.kakaoLoginButton.isEnabled = !shouldRun
                shouldRun ? logInButtonStackView.kakaoSpinner.startAnimating() : logInButtonStackView.kakaoSpinner.stopAnimating()
                logInButtonStackView.googleLoginButton.isEnabled = !shouldRun
                logInButtonStackView.appleLoginButton.isEnabled = !shouldRun
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isGoogleLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] shouldRun in
                guard let self = self else { return }
                logInButtonStackView.googleLoginButton.isEnabled = !shouldRun
                shouldRun ? logInButtonStackView.googleSpinner.startAnimating() : logInButtonStackView.googleSpinner.stopAnimating()
                logInButtonStackView.kakaoLoginButton.isEnabled = !shouldRun
                logInButtonStackView.appleLoginButton.isEnabled = !shouldRun
            })
            .disposed(by: disposeBag)

        reactor.state.map { $0.isAppleLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] shouldRun in
                guard let self = self else { return }
                logInButtonStackView.appleLoginButton.isEnabled = !shouldRun
                shouldRun ? logInButtonStackView.appleSpinner.startAnimating() : logInButtonStackView.appleSpinner.stopAnimating()
                logInButtonStackView.kakaoLoginButton.isEnabled = !shouldRun
                logInButtonStackView.appleLoginButton.isEnabled = !shouldRun
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.showErrorAlert }
            .subscribe(onNext: { [weak self] error in
                guard self != nil else { return }
                CustomAlert.presentErrorAlert(error: error)
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.goToSignUp }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                if KeychainService.getNickName() == "" {
                    coordinator?.pushSignUpView()
                } else {
                    coordinator?.pushMainView()
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: -  Layout( Add Subviews, Constraints) & Attribute
extension LoginViewController {
    private func setup() {
        setLayout()
        setAttribute()
    }

    private func setLayout() {
        self.view.addSubviews(appDescriptionStackView, appIconImageView, loginLabel, logInButtonStackView)
        
        appDescriptionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(100)
            make.width.equalTo(appDescriptionStackView.appDescriptionStackView.snp.width)
        }
        
        appIconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(100)
            make.top.equalTo(appDescriptionStackView.snp.bottom).offset(45)
        }
        
        loginLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(appIconImageView.snp.bottom).offset(190)
        }
        
        logInButtonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(loginLabel.snp.bottom).offset(23)
            make.width.equalTo(appDescriptionStackView.snp.width)
        }
        
        
    }
    
    private func setAttribute() {
        self.view.backgroundColor = UIColor(named: "loginColor")
    }
}
