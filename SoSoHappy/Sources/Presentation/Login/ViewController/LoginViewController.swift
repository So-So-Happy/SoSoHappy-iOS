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
}

//MARK: -  Layout( Add Subviews, Constraints) & Attribute
extension LoginViewController {
    private func setup() {
        setLayout()
        setAttribute()
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
}


#if DEBUG
import SwiftUI
struct LoginViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        LoginViewController()
    }
}
@available(iOS 13.0, *)
struct LoginViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            LoginViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
        }
        
    }
} #endif
