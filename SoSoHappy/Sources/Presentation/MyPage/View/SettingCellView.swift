//
//  SettingCellView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/19.
//

import UIKit

final class SettingCellView: UIView {
    
    // MARK: - Properties
    private lazy var imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private lazy var textLabel = UILabel().then {
        $0.font = UIFont.customFont(size: 16, weight: .medium)
        $0.textColor = UIColor(named: "DarkGrayTextColor")
    }
    
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
    
    // MARK: - Layout
    func setup() {
        setLayout()
    }
    
    func setLayout() {
        self.addSubviews(imageView, textLabel)
        
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.width.equalTo(25)
        }
        
        textLabel.snp.makeConstraints {
            $0.left.equalTo(imageView.snp.right).offset(15)
            $0.centerY.equalTo(imageView)
        }
    }
    
    func setUI(imageName: String, text: String) {
        self.imageView.image = UIImage(systemName: imageName)
        self.textLabel.text = text
    }
    
}
