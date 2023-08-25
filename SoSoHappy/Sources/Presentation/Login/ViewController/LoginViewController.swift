//
//  LoginViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit
import SnapKit

/*
 1. 나중에 로그인 이미지 다시 바꿔줄 필요있음 (나름 규정이 있었던 것 같음)
 */

final class LoginViewController: UIViewController {
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var appDescriptionStackView = AppDescriptionStackView()
    private lazy var appIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "happiness")
        imageView.contentMode = .scaleAspectFit // 비율 유지
        return imageView
    }()
    private lazy var logInButtonStackView = LogInButtonStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "loginColor")
        addSubViews()
        setConstraints()
    }
}

//MARK: - Add Subviews & Constraints
extension LoginViewController {
    private func addSubViews() {
        self.view.addSubview(appDescriptionStackView)
        self.view.addSubview(appIconImageView)
        self.view.addSubview(logInButtonStackView)
    }
    
    private func setConstraints() {
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
