//
//  ImageEditButtonView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

final class ImageEditButtonView: UIView {
    private lazy var backgroundCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 80
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 0.4
        return view
    }()
    
    private(set) lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "profile")
        imageView.layer.cornerRadius = 55
        
        return imageView
    }()
    
    private lazy var cameraIconView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "cameraColor")
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "camera.fill")
        imageView.tintColor = .white
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ImageEditButtonView {
    private func addSubViews() {
        self.addSubview(backgroundCircleView)
        backgroundCircleView.addSubview(profileImageView)
        self.addSubview(cameraIconView)
    }
    
    private func setConstraints() {
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

