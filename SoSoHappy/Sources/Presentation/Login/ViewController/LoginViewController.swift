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

/*
 1. 나중에 로그인 이미지 다시 바꿔줄 필요있음 (나름 규정이 있었던 것 같음)
 */

final class LoginViewController: UIViewController, View {
    
    private let coordinator: LoginCoordinator?
    private let reactor: LoginViewReactor?
    
    // MARK: - UI Components
    private lazy var appDescriptionStackView = AppDescriptionStackView()
    private lazy var appIconImageView = UIImageView().then {
        $0.image = UIImage(named: "naviIcon")
        $0.contentMode = .scaleAspectFit    // 비율 유지
    }
    private lazy var logInButtonStackView = LogInButtonStackView()
    
    var disposeBag = DisposeBag()
    
    // MARK: - Init
    public init(reactor: LoginViewReactor, coordinator: LoginCoordinator) {
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
                guard let self = self else { return }
                coordinator?.presentErrorAlert(error)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.goToMain }
            .subscribe(onNext: { [weak self] result in
                guard let self = self else { return }
                if result {
                    print("👤 UserDefaults의 userNickName:", UserDefaults.standard.string(forKey: "userNickName") ?? "nil (회원가입 필요)")
                    if UserDefaults.standard.string(forKey: "userNickName") == nil {
                        coordinator?.pushSignUpView()
                    } else { coordinator?.pushCalenderView() }
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
//        configureButtonTarget() // coordinator 테스트를 위한 메서드 호출입니다. 
    }
    
    // Add SubViews & Contstraints
    private func setLayout() {
        self.view.addSubviews(appDescriptionStackView, appIconImageView, logInButtonStackView)
        
        appDescriptionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(90)
            make.width.equalTo(appDescriptionStackView.appDescriptionStackView.snp.width)
        }
        
        appIconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(150)
            make.top.equalTo(appDescriptionStackView.snp.bottom).offset(25)
        }
        
        logInButtonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(appIconImageView.snp.bottom).offset(100)
            make.width.equalTo(appDescriptionStackView.snp.width)
        }
        
        
    }
    // ViewController의 전체적인 속성 설정
    private func setAttribute() {
        self.view.backgroundColor = UIColor(named: "loginColor")
    }
}


//// MARK: - Coordinator TestCode
///// 카카오 버튼 눌렸을때 바로 TabBarController 로 넘어감.
//extension LoginViewController {
//    
//    private func configureButtonTarget() {
//        logInButtonStackView.setKakaoButtonTarget(target: self, action: #selector(didTapKakaoButton))
//        logInButtonStackView.setAppleButtonTarget(target: self, action: #selector(didTapAppleButton))
//    }
//
//    @objc private func didTapKakaoButton() {
//        print("카카오 눌림")
//    }
//    
//    @objc private func didTapAppleButton() {
//        print("애플 눌림")
//    }
//    
//}
