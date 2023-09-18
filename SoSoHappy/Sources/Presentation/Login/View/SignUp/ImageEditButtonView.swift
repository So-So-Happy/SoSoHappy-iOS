//
//  ImageEditButtonView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxCocoa

final class ImageEditButtonView: UIView {
    lazy var profileImageWithBackgroundView = ProfileImageWithBackgroundView(backgroundCircleViewSize: 160, profileImageViewwSize: 110)
    
    lazy var cameraButton = UIButton().then {
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

extension ImageEditButtonView {
    private func setView() {
        addSubviews()
        setLayout()
    }
    
    private func addSubviews() {
        self.addSubview(profileImageWithBackgroundView)
        self.addSubview(cameraButton)
    }
    
    private func setLayout() {
        profileImageWithBackgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        cameraButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
        }
    }
}

