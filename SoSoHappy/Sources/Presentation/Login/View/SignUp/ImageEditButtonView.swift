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
    private lazy var backgroundCircleView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 80
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 0.4
    }
    
    private(set) lazy var profileImageView = UIImageView().then {
//        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "profile")
        $0.layer.cornerRadius = 55
    }
    
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
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ImageEditButtonView {
    private func setupStackView() {
        self.addSubview(backgroundCircleView)
        backgroundCircleView.addSubview(profileImageView)
        self.addSubview(cameraIconView)
    
        backgroundCircleView.snp.makeConstraints { make in
            make.size.equalTo(160)
            make.center.equalToSuperview()
        }
 
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(110)
            make.center.equalToSuperview()
        }
        
        cameraIconView.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
        }
    }
}

