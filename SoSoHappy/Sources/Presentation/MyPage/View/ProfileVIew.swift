//
//  ProfileVIew.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/19.
//

import UIKit
import SnapKit

final class ProfileView: OwnerFeedHeaderView {
    lazy var profileSetButton = HappyButton().then {
        $0.setTitle("프로필 설정", for: .normal)
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        $0.layer.cornerRadius = 16
        $0.setBackgroundColor(UIColor.orange, for: .enabled)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setProfileView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProfileView() {
        stackView.insertArrangedSubview(profileSetButton, at: 3)
        profileSetButton.snp.makeConstraints { make in
            make.height.equalTo(36)
            make.width.equalTo(90)
        }
        profileImageWithBackgroundView.updateProfileImageSize(background: 130, profile: 100)
        profileNickNameLabel.font = .systemFont(ofSize: 20, weight: .bold)
        profileSelfIntroduction.font = .systemFont(ofSize: 14, weight: .light)
    }
}
