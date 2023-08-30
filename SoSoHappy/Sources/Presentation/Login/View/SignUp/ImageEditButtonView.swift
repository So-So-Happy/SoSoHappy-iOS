//
//  ImageEditButtonView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then

/*
 1. private(set)이 적합한지 한번 더 고민해보기 - profileImageView
 */

final class ImageEditButtonView: UIView {
    private lazy var profileImageWithBackgroundView = ProfileImageWithBackgroundView(backgroundCircleViewSize: 160, profileImageViewwSize: 110)
    
    private lazy var cameraIconView = UIView().then {
        $0.backgroundColor = UIColor(named: "cameraColor")
        $0.layer.cornerRadius = 20
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 2
        $0.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.tintColor = .white
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        
        $0.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ImageEditButtonView {
    private func setView() {
        addSubviews()
        setLayout()
    }
    
    private func addSubviews() {
        self.addSubview(profileImageWithBackgroundView)
        self.addSubview(cameraIconView)
    }
    
    private func setLayout() {
        profileImageWithBackgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        cameraIconView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
        }
    }
}

