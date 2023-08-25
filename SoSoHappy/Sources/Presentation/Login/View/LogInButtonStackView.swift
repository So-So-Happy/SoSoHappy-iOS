//
//  LogInButtonStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import AuthenticationServices

final class LogInButtonStackView: UIView {
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(axis: .vertical,
                                    alignment: .fill,
                                    distribution: .fillEqually,
                                    spacing: 10
        )
        return stackView
    }()
    
    private lazy var googleLoginButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "googlelogin")
        button.setImage(image, for: .normal)
        button.snp.makeConstraints { make in
            make.height.equalTo(46)
        }
        return button
    }()
    
    private lazy var kakaoLoginButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "kakotalklogin")
        button.setImage(image, for: .normal)
        button.snp.makeConstraints { make in
            make.height.equalTo(46)
        }
        return button
    }()
    
    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .continue, style: .black)
        button.snp.makeConstraints { make in
            make.height.equalTo(46)
        }
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setLogInStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LogInButtonStackView {
    private func setLogInStackView() {
        addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buttonStackView.addArrangedSubview(googleLoginButton)
        buttonStackView.addArrangedSubview(kakaoLoginButton)
        buttonStackView.addArrangedSubview(appleLoginButton)
    }
}
