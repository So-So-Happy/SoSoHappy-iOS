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
    var backgroundCircleViewSize: CGFloat
    var profileImageViewwSize: CGFloat
    
    // MARK: - UI Components
    private lazy var backgroundCircleView = UIView().then {     // 프로필 이미지 백그라운드
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 0.4
    }
    
    lazy var profileImageView = UIImageView().then {            // 프로필 이미지
        $0.contentMode = .scaleAspectFit     //
        $0.image = UIImage(named: "profile")
    }
    
    init(backgroundCircleViewSize: CGFloat, profileImageViewwSize: CGFloat) {
        self.backgroundCircleViewSize = backgroundCircleViewSize
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
        backgroundCircleView.layer.cornerRadius = backgroundCircleViewSize / 2
        profileImageView.layer.cornerRadius = profileImageViewwSize / 2
    }
    
    private func setLayout() {
        addSubview(backgroundCircleView)
        backgroundCircleView.addSubview(profileImageView)
        
        backgroundCircleView.snp.makeConstraints { make in
            make.size.equalTo(backgroundCircleViewSize)
            make.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(profileImageViewwSize)
        }
    }
}

