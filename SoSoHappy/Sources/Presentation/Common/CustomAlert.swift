//
//  CustomAlert.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/31/23.
//

import UIKit

final class CustomAlert {
    static func presentErrorAlert(error: Error) {
        let alert = UIAlertController(title: "⚠️ 네트워크 오류 ⚠️", message: "잠시 후에 다시 시도해주세요.\n\(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        let keyWindow = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow }
        if let window = keyWindow, let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    static func presentCheckAlert(title: String, message: String, buttonTitle: String, okActionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            okActionHandler()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        let keyWindow = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow }
        if let window = keyWindow, let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
}
