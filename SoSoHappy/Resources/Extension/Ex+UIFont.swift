//
//  Ex+UIFont.swift
//  SoSoHappy
//
//  Created by 박민주 on 11/26/23.
//

import UIKit

extension UIFont {
    static func customFont(size fontSize: CGFloat, weight: UIFont.Weight) -> UIFont {
            let familyName = "Dovemayo"

            var weightString: String
            switch weight {
            case .bold:
                weightString = "Bold"
            case .light:
                weightString = "Light"
            default:
                weightString = "Medium"
            }

            return UIFont(name: "\(familyName)-\(weightString)", size: fontSize) ?? .systemFont(ofSize: fontSize, weight: weight)
        }
}
