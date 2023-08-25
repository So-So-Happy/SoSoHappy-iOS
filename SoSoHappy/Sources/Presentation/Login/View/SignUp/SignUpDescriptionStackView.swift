//
//  SignUpDescriptionStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit

class SignUpDescriptionStackView: UIView {
    lazy var signUpDescriptionStackView: UIStackView = {
        let stackView = UIStackView(axis: .vertical,
                                    alignment: .center,
                                    distribution: .fill,
                                    spacing: 18
        )
        return stackView
    }()
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "소소해피"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.setLineSpacing(kernValue: 9, alignment: .center)
        return label
    }()
    
    private lazy var setProfileGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "서비스 이용을 위해 프로필을 설정해주세요."
        label.textColor = .darkGray
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSignUpDescriptionStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SignUpDescriptionStackView {
    private func setSignUpDescriptionStackView() {
        addSubview(signUpDescriptionStackView)
        signUpDescriptionStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        signUpDescriptionStackView.addArrangedSubview(appNameLabel)
        signUpDescriptionStackView.addArrangedSubview(setProfileGuideLabel)
    }
}

