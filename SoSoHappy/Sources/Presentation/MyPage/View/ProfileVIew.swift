//
//  ProfileView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/19.
//

import UIKit
import SnapKit
import Then

final class ProfileView: UIView {
    
    // MARK: - UI Components
    lazy var profileImage = ImageEditButtonView(image: "pencil")
    lazy var nickNameLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 25, weight: .bold)
    }
    lazy var emailLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .light)
        $0.textColor = .gray
    }
    lazy var introLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15, weight: .regular)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
    }

    // MARK: Initializing
    override init(frame: CGRect) {
        super.init(frame: frame)
        setProfileView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: -  Layout (Add Subviews, Constraints) & Attribute
extension ProfileView {
    func setProfileView() {
        addSubviews(profileImage, nickNameLabel, emailLabel, introLabel)
        
        profileImage.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.size.equalTo(150)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nickNameLabel.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
        }
        
        introLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(13)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

