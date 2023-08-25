//
//  ProfileImageWithBackgroundView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
/*
 1. 리팩토링 필요 - 클래스 init 함수 공부
 */

class ProfileImageWithBackgroundView: UIView {
    // MARK: - Properties
    var backgroundCircleViewSize: CGFloat!
    var profileImageViewwSize: CGFloat!
    
    // MARK: - UI Components
    // 1. 프로필 이미지
    private lazy var backgroundCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
//        view.layer.cornerRadius = 60
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.4
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit     //
        imageview.image = UIImage(named: "profile")
//        imageview.layer.cornerRadius = 45
        
        return imageview
    }()
    
    convenience init(backgroundCircleViewSize: CGFloat, profileImageViewwSize: CGFloat) {
        print("convenience")
            self.init(frame: .zero)  // Call the designated initializer
            self.backgroundCircleViewSize = backgroundCircleViewSize
            self.profileImageViewwSize = profileImageViewwSize
        }

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init ")
//        backgroundColor = .green
        setCornerRadius()
//        addSubViews()
//        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension ProfileImageWithBackgroundView {
    private func setCornerRadius() {
        print("backgroundCircleViewSize : \(backgroundCircleViewSize)")
//        backgroundCircleView.layer.cornerRadius = backgroundCircleViewSize / 2
//        profileImageView.layer.cornerRadius = profileImageViewwSize / 2
    }
    
    private func addSubViews() {
        addSubview(backgroundCircleView)
        backgroundCircleView.addSubview(profileImageView)
    }
    
    private func setConstraints() {
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
