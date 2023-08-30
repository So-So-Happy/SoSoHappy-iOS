//
//  ProfileVIew.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/19.
//

import UIKit
import SnapKit

final class ProfileView: UIView {
    
    // MARK: - Properties
    private lazy var profileImage: UIImageView = {
        // UIImageView 생성
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
//        label.font = .boldSystemFont(ofSize: 22)
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private lazy var introLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(rgb: 0x6D6D6D)
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var stackView = UIStackView(axis: .vertical, alignment: .center, distribution: .fillEqually, spacing: 5)
    
    private lazy var editProfileButton: UIButton = {
        let button = AutoAddPaddingButtton()
        button.setTitle("프로필 설정", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        //        button.addTarget(, action: , for: )
        button.frame = CGRect(x: 100, y: 200, width: 220, height: 50)
        button.backgroundColor = UIColor(rgb: 0xFAAB78)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 13
        button.addTarget(self, action: #selector(test), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var dividerLine: UIImageView = {
        let image = UIImage(named: "dividerLine")
        let imageView = UIImageView(image: image)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
}

extension ProfileView {
    
    // MARK: - Layout & Attribute
    func setup() {
        setLayout()
        setAttribute()
    }
    
    func setLayout() {
        
        self.addSubviews(profileImage, stackView, editProfileButton, dividerLine)
        self.stackView.addArrangedSubview(nickNameLabel)
        self.stackView.addArrangedSubview(introLabel)
        
        profileImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide).inset(40)
            $0.width.height.equalTo(100)
        }
        
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(profileImage.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        editProfileButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
//            $0.bottom.equalTo(dividerLine.snp.top).offset(-10)
            $0.top.equalTo(stackView.snp.bottom).offset(13)

        }
        
        dividerLine.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(2)
            $0.bottom.equalToSuperview()
        }
        
    }
    
    func setAttribute() {
        self.profileImage.image = UIImage(named: "happy2")
        self.nickNameLabel.text = "소소해"
        self.introLabel.text = "나는야 소소해. 디저트 러버지"
    }
    
//    @objc func
    
    @objc private func test() {
       
    }
}


// MARK: - AutoAddPaddingButton 
class AutoAddPaddingButtton : UIButton
{
    override var intrinsicContentSize: CGSize {
       get {
           let baseSize = super.intrinsicContentSize
           return CGSize(width: baseSize.width + 30,//ex: padding 40
                         height: baseSize.height )
           }
    }
}

