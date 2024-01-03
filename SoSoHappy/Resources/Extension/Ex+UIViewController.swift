//
//  Ex+UIViewController.swift
//  SoSoHappy
//
//  Created by Sue on 11/8/23.
//

import UIKit
import Then

extension UIViewController {
    func showToast(_ message: String, withDuration: Double, delay: Double, isToastPlacedOnTop: Bool = true) {
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
            make.width.equalTo(toastLabel.intrinsicContentSize.width + 30)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            if isToastPlacedOnTop {
                make.top.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            } else {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(60)
            }
        }
        
        UIView.animate(withDuration: withDuration, delay: delay, options: .curveLinear, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
