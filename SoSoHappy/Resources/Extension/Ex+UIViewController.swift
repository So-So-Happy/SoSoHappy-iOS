//
//  Ex+UIViewController.swift
//  SoSoHappy
//
//  Created by Sue on 11/8/23.
//

import UIKit
import Then

// https://www.youtube.com/watch?v=SxBP271AuWI
extension UIViewController {
    func showToast(_ message : String, withDuration: Double, delay: Double) {
//        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-700, width: 150, height: 35))
        let toastLabel = UILabel()
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.customFont(size: 14, weight: .medium)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 16
        toastLabel.clipsToBounds  =  true
        
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
