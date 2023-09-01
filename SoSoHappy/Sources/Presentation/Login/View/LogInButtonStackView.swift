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
import AuthenticationServices
import RxCocoa

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
    
    private lazy var kakaoLoginVM = KakaoLoginViewModel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//
//    func setEnterWithoutLoginButtonTarget(target: Any?, action: Selector) {
//        enterWithoutLoginButton.addTarget(target, action: action, for: .touchUpInside)
//    }
//
    func setKakaoButtonTarget(target: Any?, action: Selector) {
        kakaoLoginButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setAppleButtonTarget(target: Any?, action: Selector) {
        appleLoginButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
//    func setLoginProblemButtonTarget(target: Any?, action: Selector) {
//        loginProblemButton.addTarget(target, action: action, for: .touchUpInside)
//    }
//
//    func setAcceptPrivacyTextViewLinkAction(tapLink: @escaping (URL) -> Bool) {
//        acceptPrivacyTextView.onLinkTap = tapLink
//    }
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



//
//private extension AuthView {
//    enum Style {
//        enum LogoImageView {
//            static let size = CGSize(width: 135, height: 46)
//            static let margin: CGFloat = 80
//            static let image = CommonAsset.Images.fitftyLogoImage.image
//        }
//
//        enum LoginProblemLabel {
//            static let margin: CGFloat = 72
//            static let text = "로그인에 문제가 있나요?"
//            static let textColor = CommonAsset.Colors.gray04
//            static let font = FitftyFont.appleSDMedium(size: 13).font
//        }
//
//        enum EnterWithoutLoginButton {
//            static let size = CGSize(width: 166, height: 38)
//            static let margin: CGFloat = 42
//            static let borderColor = CommonAsset.Colors.gray02
//            static let borderWidth: CGFloat = 1
//            static let textColor = CommonAsset.Colors.gray05
//            static let radius: CGFloat = 16
//            static let font = FitftyFont.appleSDMedium(size: 13).font
//            static let title = "둘러보기"
//        }
//
//        enum AcceptPrivacyTextView {
//            static let margin: CGFloat = 20
//            static let text = "서비스 가입 시 이용약관 및 개인정보취급방침에 동의하게 돼요."
//            static let privacy = "개인정보이용방침"
//            static let privacyLink = "https://maze-mozzarella-6e5.notion.site/ed1e98c3fee5417b89f85543f4a398d2"
//            static let termsOfUse = "이용약관"
//            static let termsOfUseLink = "https://maze-mozzarella-6e5.notion.site/dd559e6017ee499fa569148b8621966d"
//            static let textColor = CommonAsset.Colors.gray04
//            static let font = FitftyFont.appleSDBold(size: 12).font
//        }
//
//        enum SnsImageStackView {
//            static let margin: CGFloat = 20
//            static let spacing: CGFloat = 16
//            static let axis: NSLayoutConstraint.Axis = .horizontal
//            static let alignment: UIStackView.Alignment = .center
//        }
//
//        enum KakaoButton {
//            static let size = CGSize(width: 56, height: 56)
//            static let image = CommonAsset.Images.kakaoLoginImage.image
//        }
//
//        enum AppleButton {
//            static let size = CGSize(width: 56, height: 56)
//            static let image = CommonAsset.Images.appleLoginImage.image
//        }
//
//        enum SnsLabel {
//            static let margin: CGFloat = 16
//            static let text = "SNS 계정으로 간편 가입하기"
//            static let textColor = CommonAsset.Colors.gray05
//            static let font = FitftyFont.appleSDBold(size: 13).font
//        }
//    }
//}
// MARK: - Actions
extension LogInButtonStackView {
    @objc private func kakaoLoginButtonTapped() {
        // Button tapped action
        print("kakaoLoginButton tapped!")
        kakaoLoginVM.handleKakaoLogin()
    }
}
