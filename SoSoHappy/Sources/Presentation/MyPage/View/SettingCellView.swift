//
//  SettingCellView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/19.
//

import UIKit

final class SettingCellView: UIView {
    
    private lazy var imageView = UIImageView()
    private lazy var textLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}


extension SettingCellView {
    
    func setup() {
        setLayout()
        setAttribute()
    }
    
    func setLayout() {
        self.addSubviews(imageView, textLabel)
        
        imageView.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(3)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(21.5)
        }
        
        textLabel.snp.makeConstraints {
            $0.left.equalTo(imageView.snp.right).offset(15)
            $0.centerY.equalTo(imageView)
        }
        
    }
    
    func setAttribute() {
        self.textLabel.font = .systemFont(ofSize: 18)
        self.textLabel.textColor = UIColor(rgb: 0x626262)
    }
    
    func setUI(imageName: String, text: String) {
        self.imageView.image = UIImage(named: imageName)
        self.textLabel.text = text
    }
    
}

