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
import RxSwift
import RxCocoa
import ReactorKit

final class LogInButtonStackView: UIView {
    private lazy var buttonStackView = UIStackView(
        axis: .horizontal,
        alignment: .fill,
        distribution: .fillEqually,
        spacing: 0
    )
    
    lazy var googleLoginButton = UIButton().then {
        let image = UIImage(named: "googleLoginStroke")
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    lazy var kakaoLoginButton = UIButton().then {
        let image = UIImage(named: "kakaoLogin")
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    lazy var appleLoginButton = UIButton().then {
        let image = UIImage(named: "appleLogin")
        $0.setImage(image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
    }
    
    lazy var kakaoSpinner = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = true
        $0.color = .black
    }
    
    lazy var googleSpinner = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = true
        $0.color = .black
    }
    
    lazy var appleSpinner = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = true
        $0.color = .black
    }

    private lazy var activityIndicatorView = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
        setLayout()
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
                make.height.equalTo(60)
            }
        }
        
        buttonStackView.addArrangedSubview(googleLoginButton)
        buttonStackView.addArrangedSubview(kakaoLoginButton)
        buttonStackView.addArrangedSubview(appleLoginButton)
        addSubview(kakaoSpinner)
        addSubview(googleSpinner)
        addSubview(appleSpinner)
    }
    
    private func setLayout() {
        kakaoLoginButton.addSubview(activityIndicatorView)
        googleLoginButton.addSubview(activityIndicatorView)
        appleLoginButton.addSubview(activityIndicatorView)
        
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        kakaoSpinner.snp.makeConstraints { make in
            make.center.equalTo(kakaoLoginButton)
        }
        
        googleSpinner.snp.makeConstraints { make in
            make.center.equalTo(googleLoginButton)
        }
        
        appleSpinner.snp.makeConstraints { make in
            make.center.equalTo(appleLoginButton)
        }
    }
}


// MARK: - Coordinator TestCode
/// Login -> Home으로 넘어가는 액션 타겟 정의 함수
extension LogInButtonStackView {
    func setKakaoButtonTarget(target: Any?, action: Selector) {
        kakaoLoginButton.addTarget(target, action: action, for: .touchUpInside)
    }
    
    func setAppleButtonTarget(target: Any?, action: Selector) {
        appleLoginButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
