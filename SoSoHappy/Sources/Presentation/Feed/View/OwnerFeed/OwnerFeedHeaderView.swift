//
//  OwnerFeedHeaderView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit


/*
 1. tableView.tableHeaderView?.frame.size.height를 어떻게 설정해줄 것인지?
 2. autolayout error 해결 필요
 */

final class OwnerFeedHeaderView: UIView {
    // MARK: - Properties
    // MARK: - UI Components
    // 1. 프로필 이미지
    private lazy var backgroundCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 60
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.4
        return view
    }()

    private lazy var profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit     //
        imageview.image = UIImage(named: "profile")
        imageview.layer.cornerRadius = 45

        return imageview
    }()
    
//    private lazy var profileImagView = ProfileImageWithBackgroundView(backgroundCircleViewSize: 120, profileImageViewwSize: 90)
    
    // 2. 닉네임
    private lazy var profileNickNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = "소해피456789"
        return label
    }()
    
    // 2. 자기소개
    private lazy var profileSelfIntroduction: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.textColor = .gray
        label.numberOfLines = 0
        label.text = "나는야 소해피. 디저트 러버. 크로플, 도넛, 와플이 내 최애 디저트다. 음료는 아이스아메리카노 좋아함 !"
        label.setLineSpacing(lineSpacing: 4, alignment: .center)
        
        return label
    }()
    
    // 3. DM 버튼
    private lazy var dmButton: UIButton = {
        let button = UIButton()
        button.setTitle("메시지", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.orange, for: .normal)
        button.layer.borderColor = UIColor.orange.cgColor
        button.layer.borderWidth = 1
        button.backgroundColor = .white
        button.layer.cornerRadius = 8

        return button
    }()
    
    // 4. 점선
    private lazy var dashImageView: UIImageView = {
        let image = UIImage(named: "line")
        let imageView = UIImageView(image: image)
        
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init ")
//        backgroundColor = .green
        addSubViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Add Subviews & Constraints
extension OwnerFeedHeaderView {
    private func addSubViews() {
        print("addSubViews")
        addSubview(backgroundCircleView)
        backgroundCircleView.addSubview(profileImageView)
        addSubview(profileNickNameLabel)
        addSubview(profileSelfIntroduction)
        addSubview(dmButton)
        addSubview(dashImageView)
    }
    
    private func setConstraints() {
        print("setConstraints")
        backgroundCircleView.snp.makeConstraints { make in
            make.size.equalTo(120)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }

        profileImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(90)
        }

        profileNickNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(backgroundCircleView.snp.bottom).offset(24)
        }

        profileSelfIntroduction.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileNickNameLabel.snp.bottom).offset(18)
            make.width.equalTo(profileImageView.intrinsicContentSize.width)
        }

        dmButton.snp.makeConstraints { make in
            make.top.equalTo(profileSelfIntroduction.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
            make.height.equalTo(34)
        }

        dashImageView.snp.makeConstraints { make in
            make.top.equalTo(dmButton.snp.bottom).offset(20)
            make.height.equalTo(1.4)
            make.leading.equalTo(safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(safeAreaLayoutGuide).offset(-16)
            make.bottom.equalToSuperview()
        }
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
