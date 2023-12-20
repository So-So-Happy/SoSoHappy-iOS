//
//  Ex+UIView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/18.
//

import UIKit
import Combine
import SnapKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
