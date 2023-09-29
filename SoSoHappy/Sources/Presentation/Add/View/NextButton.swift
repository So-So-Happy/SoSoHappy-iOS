//
//  NextButton.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/29.
//

import UIKit
import SnapKit

final class NextButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let image = UIImage(systemName: "arrow.right", withConfiguration: largeConfig)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        self.layer.cornerRadius = 40
        self.setImage(image, for: .normal)
        self.backgroundColor = UIColor(named: "AccentColor")
        
        self.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
    }
}
