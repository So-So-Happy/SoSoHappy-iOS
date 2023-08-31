//
//  LogInButtonStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import AuthenticationServices
import Then

import RxKakaoSDKAuth
import KakaoSDKAuth
import RxKakaoSDKUser
import KakaoSDKUser
import RxSwift

final class LogInButtonStackView: UIView {
    private lazy var buttonStackView = UIStackView(
        axis: .vertical,
        alignment: .fill,
        distribution: .fill,
        spacing: 10
    )
    
    private lazy var googleLoginButton = UIButton().then {
        let image = UIImage(named: "googlelogin")
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    private lazy var kakaoLoginButton = UIButton().then {
        let image = UIImage(named: "kakaoLoginLargeWide")
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
    }
    
    private lazy var appleLoginButton = ASAuthorizationAppleIDButton(type: .continue, style: .black)
    
    private lazy var loginVM = LoginViewModel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogInButtonStackView {
    private func setStackView() {
        addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        // 각 버튼의 높이 46 고정
        for button in [googleLoginButton, kakaoLoginButton, appleLoginButton] {
            button.snp.makeConstraints { make in
                make.height.equalTo(46)
            }
        }
        
        buttonStackView.addArrangedSubview(googleLoginButton)
        buttonStackView.addArrangedSubview(kakaoLoginButton)
        buttonStackView.addArrangedSubview(appleLoginButton)
    }
}

// MARK: - Actions
extension LogInButtonStackView {
    @objc private func kakaoLoginButtonTapped() {
        // Button tapped action
        print("kakaoLoginButton tapped!")
        loginVM.handleKakaoLogin()
    }
}
