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
        $0.font = .systemFont(ofSize: 28, weight: .bold)
    }
    lazy var emailLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .light)
        $0.textColor = .gray
    }
    lazy var introLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    lazy var skeletonNicknameView = UIView().then {
        $0.backgroundColor = UIColor(named: "skeleton3")
        $0.layer.cornerRadius = 5
    }
    
    lazy var skeletonEmailView = UIView().then {
        $0.backgroundColor = UIColor(named: "skeleton1")
        $0.layer.cornerRadius = 3
    }
    
    lazy var skeletonIntroView = UIView().then {
        $0.backgroundColor = UIColor(named: "skeleton2")
        $0.layer.cornerRadius = 4
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
        addSubviews(skeletonNicknameView, skeletonEmailView, skeletonIntroView)
        
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
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        skeletonNicknameView.snp.makeConstraints { make in
            make.center.equalTo(nickNameLabel)
            make.width.equalTo(150)
            make.height.equalTo(30)
        }
        
        skeletonEmailView.snp.makeConstraints { make in
            make.center.equalTo(emailLabel)
            make.width.equalTo(130)
            make.height.equalTo(16)
        }
        
        skeletonIntroView.snp.makeConstraints { make in
            make.center.equalTo(introLabel)
            make.width.equalTo(200)
            make.height.equalTo(22)
        }
    }
}

