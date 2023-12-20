//
//  Ex+UIViewController.swift
//  SoSoHappy
//
//  Created by Sue on 11/8/23.
//

import UIKit
import Then

extension UIViewController {
    func showToast(_ message: String, withDuration: Double, delay: Double) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor(named: "AccentColor")
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.customFont(size: 14, weight: .medium)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 16
        toastLabel.clipsToBounds = true
        
        self.view.addSubview(toastLabel)
        
        toastLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            make.width.equalTo(toastLabel.intrinsicContentSize.width + 30)
            make.height.equalTo(40)
        }
        
        // TODO: .animate 이해해가
        UIView.animate(withDuration: withDuration, delay: delay, options: .curveLinear, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
