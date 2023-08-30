//
//  ProfileImageNameTimeStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/29.
//

import UIKit
import SnapKit
import Then

final class ProfileImageNameTimeStackView: UIView {
    var imageSize: CGFloat
    
    private lazy var profileImageNameTimeStackView = UIStackView(
        axis: .horizontal,
        alignment: .center,
        distribution: .fill,
        spacing: 10
    )
    // 피드 작성한 사람의 프로필 이미지
    private lazy var profileImageView =  UIImageView().then {
        $0.image = UIImage(named: "profile")
//        $0.contentMode = .scaleAspectFit
//        $0.clipsToBounds = true
    }
    
    private lazy var nickNameAndTimeStackView = UIStackView(
        axis: .vertical,
        alignment: .leading,
        distribution: .fill,
        spacing: 0
    )
    
    // 피드 작성한 사람의 닉네임
    private lazy var profileNickNameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.text = "소해피"
    }
    
    // 피드 올라온 시간
    private lazy var timeLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 11, weight: .light)
        $0.textColor = .gray
        $0.text = "5분 전"
    }
    
    init(imageSize: CGFloat) {
        self.imageSize = imageSize
        super.init(frame: .zero)
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProfileImageNameTimeStackView {
    private func setStackView() {
        setProfileImageSize()
        setLayout()
    }
    
    private func setProfileImageSize() {
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(imageSize) //38
        }
    }
    
    private func setLayout() {
        addSubview(profileImageNameTimeStackView)
        profileImageNameTimeStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        nickNameAndTimeStackView.addArrangedSubview(profileNickNameLabel)
        nickNameAndTimeStackView.addArrangedSubview(timeLabel)
        
        profileImageNameTimeStackView.addArrangedSubview(profileImageView)
        profileImageNameTimeStackView.addArrangedSubview(nickNameAndTimeStackView)
    }
}
