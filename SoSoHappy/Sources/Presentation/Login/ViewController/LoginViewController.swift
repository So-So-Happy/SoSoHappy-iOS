//
//  LoginViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit
import SnapKit
import Then

/*
 1. 나중에 로그인 이미지 다시 바꿔줄 필요있음 (나름 규정이 있었던 것 같음)
 */

final class LoginViewController: UIViewController {
    private let coordinator: LoginCoordinatorProtocol
    
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var appDescriptionStackView = AppDescriptionStackView()
    private lazy var appIconImageView = UIImageView().then {
        $0.image = UIImage(named: "happiness")
        $0.contentMode = .scaleAspectFit    // 비율 유지
    }
    private lazy var logInButtonStackView = LogInButtonStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    public init(coordinator: LoginCoordinatorProtocol) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: -  Layout( Add Subviews, Constraints) & Attribute
extension LoginViewController {
    private func setup() {
        setLayout()
        setAttribute()
        configureButtonTarget()
    }
    
    // Add SubViews & Contstraints
    private func setLayout() {
        self.view.addSubviews(appDescriptionStackView, appIconImageView, logInButtonStackView)
        
        appDescriptionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(70)
            make.width.equalTo(appDescriptionStackView.appDescriptionStackView.snp.width)
        }

        appIconImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(150)
            make.top.equalTo(appDescriptionStackView.snp.bottom).offset(20)
        }
        
        logInButtonStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(appIconImageView.snp.bottom).offset(70)
            make.width.equalTo(appDescriptionStackView.snp.width)
        }
    }
    // ViewController의 전체적인 속성 설정
    private func setAttribute() {
        self.view.backgroundColor = UIColor(named: "loginColor")
    }
    
    private func configureButtonTarget() {
        logInButtonStackView.setKakaoButtonTarget(target: self, action: #selector(didTapKakaoButton))
        logInButtonStackView.setAppleButtonTarget(target: self, action: #selector(didTapAppleButton))
    }
}

extension LoginViewController {
    
    @objc private func didTapKakaoButton() {
        coordinator.pushMainView()
        print("카카오 눌림")
    }
    
    @objc private func didTapAppleButton() {
        coordinator.pushMainView()
        print("애플 눌림")
    }
    
}
