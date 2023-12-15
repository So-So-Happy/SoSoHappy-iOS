//
//  NextButton.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/29.
//

import UIKit
import SnapKit

final class NextButton: HappyButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .semibold)
        let image = UIImage(systemName: "arrow.right", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        layer.cornerRadius = 40
        setImage(image, for: .normal)
        setBackgroundColor(UIColor(named: "ReverseLightGrayColor"), for: .disabled)
        setBackgroundColor(UIColor(named: "AccentColor"), for: .enabled)
        
        self.snp.makeConstraints { make in
            make.width.height.equalTo(80)
        }
    }
}
