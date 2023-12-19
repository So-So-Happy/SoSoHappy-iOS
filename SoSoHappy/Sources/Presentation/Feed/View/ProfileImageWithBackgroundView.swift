//
//  ProfileImageWithBackgroundView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then

final class ProfileImageWithBackgroundView: UIView {
    // MARK: - Properties
    var profileImageViewwSize: CGFloat
    
    // MARK: - UI Components
    lazy var profileImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
        $0.layer.masksToBounds = true
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 0.4
    }
    
    init(profileImageViewwSize: CGFloat) {
        self.profileImageViewwSize = profileImageViewwSize
        super.init(frame: .zero) // super class의 프로퍼티도 초기화
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension ProfileImageWithBackgroundView {
    private func setView() {
        setCornerRadius()
        setLayout()
    }
    
    private func setCornerRadius() {
        profileImageView.layer.cornerRadius = profileImageViewwSize / 2
    }
    
    private func setLayout() {
        addSubview(profileImageView)

        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(profileImageViewwSize)
            make.edges.equalToSuperview()
        }
    }
}

// MARK: Size update function
extension ProfileImageWithBackgroundView {
    func updateProfileImageSize(profile: CGFloat) {
        self.profileImageViewwSize = profile
        profileImageView.snp.removeConstraints()
        setView()
    }
}
