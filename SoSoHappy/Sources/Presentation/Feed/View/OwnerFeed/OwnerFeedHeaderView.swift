//
//  OwnerFeedHeaderView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then

final class OwnerFeedHeaderView: UIView {
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var profileImageWithBackgroundView = ProfileImageWithBackgroundView(backgroundCircleViewSize: 120, profileImageViewwSize: 90)
    // 닉네임
    private lazy var profileNickNameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 22, weight: .bold)
        $0.text = "소해피456789"
    }
    
    // 자기소개
    private lazy var profileSelfIntroduction = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .light)
        $0.textColor = .gray
        $0.numberOfLines = 0
        $0.text = "나는야 소해피. 디저트 러버. 크로플, 도넛, 와플이 내 최애 디저트다. 음료는 아이스아메리카노 좋아함 !"
//        $0.text = "나는야 소해피. !"
        $0.setLineSpacing(lineSpacing: 4, alignment: .center)
    }
    
    // 3. DM 버튼 (2차 배포 보류)
//    private lazy var dmButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("메시지", for: .normal)
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
//        button.setTitleColor(.orange, for: .normal)
//        button.layer.borderColor = UIColor.orange.cgColor
//        button.layer.borderWidth = 1
//        button.backgroundColor = .white
//        button.layer.cornerRadius = 8
//
//        return button
//    }()
    
    private lazy var dashImageView = UIImageView().then {
        $0.image = UIImage(named: "line")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension OwnerFeedHeaderView {
    private func setup() {
        addSubViews()
        setConstraints()
    }
    
    private func addSubViews() {
        addSubview(profileImageWithBackgroundView)
        addSubview(profileNickNameLabel)
        addSubview(profileSelfIntroduction)
        addSubview(dashImageView)
//        addSubview(dmButton)
    }
    
    private func setConstraints() {
        profileImageWithBackgroundView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }
        
        profileNickNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageWithBackgroundView.snp.bottom).offset(24)
        }

        profileSelfIntroduction.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileNickNameLabel.snp.bottom).offset(18)
            make.width.equalTo(profileImageWithBackgroundView).multipliedBy(2)
        }


        dashImageView.snp.makeConstraints { make in
            make.top.equalTo(profileSelfIntroduction.snp.bottom).offset(20)
            make.height.equalTo(1.4)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(10)
        }
        
//        dmButton.snp.makeConstraints { make in
//            make.top.equalTo(profileSelfIntroduction.snp.bottom).offset(30)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(160)
//            make.height.equalTo(34)
//        }
    }
}

#if DEBUG
import SwiftUI
struct OwnerFeedViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        OwnerFeedViewController()
    }
}
@available(iOS 13.0, *)
struct OwnerFeedViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            OwnerFeedViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
        }
        
    }
} #endif
