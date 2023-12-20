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
    // MARK: - Properties
    var image: String
    
    lazy var profileImageWithBackgroundView = ProfileImageWithBackgroundView(profileImageViewwSize: 130)
    
    lazy var editButton = UIButton().then {
        $0.backgroundColor = UIColor(named: "AccentColor")
        $0.layer.cornerRadius = 20
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 2
        $0.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: image)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(23)
        }
        
        $0.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    init(image: String) {
        self.image = image
        super.init(frame: .zero)
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
        self.addSubview(editButton)
    }
    
    private func setLayout() {
        profileImageWithBackgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        editButton.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview().inset(7)
        }
    }
}
