//
//  OwnerFeedHeaderView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then

class OwnerFeedHeaderView: UIView {
    // MARK: - UI Components
    lazy var stackView = UIStackView(
        axis: .vertical,
        alignment: .center,
        distribution: .fill,
        spacing: 20
    )
    
    // 프로필 사진
    lazy var profileImageWithBackgroundView = ProfileImageWithBackgroundView(profileImageViewwSize: 150)
    
    // 닉네임
    lazy var profileNickNameLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 22, weight: .bold)
    }
    
    // 자기소개
    lazy var profileSelfIntroduction = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .light)
        $0.textColor = .gray
        $0.numberOfLines = 0
    }

    lazy var dashImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("OwnerHeaderView init")
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with profile: Profile) {
//        print("OwnerFeedHeaderView - update function")
        profileImageWithBackgroundView.profileImageView.image = profile.profileImg
        profileNickNameLabel.text = profile.nickName
        profileSelfIntroduction.text = profile.introduction
        profileSelfIntroduction.setLineSpacing(lineSpacing: 6, alignment: .center) //위에 쓰면 적용이 안되길래 여기에 씀
        dashImageView.image = UIImage(named: "dashImage4")
    }
    
//    func update(selfIntro: String) {
//        print("OwnerHeaderView update(selfIntro: String) called")
//        profileSelfIntroduction.text = selfIntro
//        profileSelfIntroduction.setLineSpacing(lineSpacing: 6, alignment: .center) //위에 쓰면 적용이 안되길래 여기에 씀
//        dashImageView.image = UIImage(named: "dashImage4")
//    }
}

//MARK: - Add Subviews & Constraints
extension OwnerFeedHeaderView {
    private func setup() {
        setStackView()
    }
    
    private func setStackView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20))
        }
        
        stackView.addArrangedSubview(profileImageWithBackgroundView)
        stackView.addArrangedSubview(profileNickNameLabel)
        profileNickNameLabel.snp.makeConstraints { make in
            make.height.equalTo(25)
        }
        
        stackView.addArrangedSubview(profileSelfIntroduction)
        profileSelfIntroduction.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(10)
        }
        
        stackView.addArrangedSubview(dashImageView)
    }
}

