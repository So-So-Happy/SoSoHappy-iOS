//
//  SignUpDescriptionStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import Then

final class SignUpDescriptionStackView: UIView {
    private lazy var signUpDescriptionStackView = UIStackView(
        axis: .vertical,
        alignment: .center,
        distribution: .fill,
        spacing: 18
    )
    
    private lazy var setProfileGuideLabel = UILabel().then {
        $0.text = "서비스 이용을 위해 프로필을 설정해주세요."
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.textAlignment = .center
        $0.font = UIFont.customFont(size: 19, weight: .bold)
        $0.numberOfLines = 2
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SignUpDescriptionStackView {
    private func setStackView() {
        addSubview(signUpDescriptionStackView)
        signUpDescriptionStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        signUpDescriptionStackView.addArrangedSubview(setProfileGuideLabel)
    }
}


