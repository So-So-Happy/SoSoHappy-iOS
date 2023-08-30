//
//  SignUpViewController.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import RxSwift
import Then

/*
 1. 프로플 이미지 설정 (갤러리 연결)
 2. Button, TextField, TextView - RxGesture 연결
 3. textField에 입력할 때 키보드 위치 조정 필요
 */

final class SignUpViewController: UIViewController {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    // MARK: - UI Components
    private lazy var signUpDescriptionStackView = SignUpDescriptionStackView()
    private lazy var profileImageEditButton = ImageEditButtonView()
    private lazy var nickNameSection = NickNameStackView()
    private lazy var selfIntroductionSection = SelfIntroductionStackView()
    private lazy var signUpButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        $0.backgroundColor = UIColor(named: "buttonColor")
        $0.layer.cornerRadius = 8
    }
    
    private lazy var imagePickerController = UIImagePickerController().then {
        $0.sourceType = .photoLibrary
        $0.delegate = self
        $0.allowsEditing = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bindUI()
    }
}

//MARK: -  Layout( Add Subviews, Constraints) & Attribute
extension SignUpViewController {
    private func setup() {
        setLayout()
        setAttribute()
    }
    // Add SubViews & Contstraints
    private func setLayout() {
        self.view.addSubviews(signUpDescriptionStackView, profileImageEditButton, nickNameSection, selfIntroductionSection, signUpButton)
        
        signUpDescriptionStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).inset(36)
        }
        
        profileImageEditButton.snp.makeConstraints { make in
            make.top.equalTo(signUpDescriptionStackView.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.size.equalTo(150)
        }
        
        nickNameSection.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageEditButton.snp.bottom).offset(56)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        selfIntroductionSection.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nickNameSection.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
        
        signUpButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(selfIntroductionSection.snp.bottom).offset(40)
            make.width.equalTo(selfIntroductionSection)
            make.height.equalTo(44)
        }
    }
    
    // ViewController의 전체적인 속성 설정
    private func setAttribute() {
        self.view.backgroundColor = UIColor(named: "backgroundColor")
    }
}

extension SignUpViewController {
    func bindUI() {
    
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
}

#if DEBUG
import SwiftUI
struct SignUpViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        SignUpViewController()
    }
}
@available(iOS 13.0, *)
struct SignUpViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            SignUpViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
        }
        
    }
} #endif

