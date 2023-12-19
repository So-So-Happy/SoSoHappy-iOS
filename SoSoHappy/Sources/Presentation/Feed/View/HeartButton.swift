//
//  HeartButton.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/25.
//

import UIKit

final class HeartButton: UIButton {
    private let heartImageConfiguration = UIImage.SymbolConfiguration(pointSize: 21, weight: .light)
    
    func setHeartButton(_ isLike: Bool) {
        let image: UIImage = isLike ? UIImage(systemName: "heart.fill", withConfiguration: heartImageConfiguration)! : UIImage(systemName: "heart", withConfiguration: heartImageConfiguration)!
        let color: UIColor = isLike ? UIColor.systemRed : UIColor.systemGray
        
        setImage(image, for: .normal)
        tintColor = color
    }
}
