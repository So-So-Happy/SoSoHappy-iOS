//
//  CustomAlert.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/31/23.
//

import UIKit

final class CustomAlert {
    static func presentErrorAlert(error: Error) {
        let title = "⚠️ Internal Server Error ⚠️"
        let message = "잠시 후에 다시 시도해주세요.\n\(error.localizedDescription)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        applyFontToAlert(alert, title: title, message: message)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        okAction.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        
        alert.addAction(okAction)
        
        presentAlert(alert)
    }
    
    static func presentCheckAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        applyFontToAlert(alert, title: title, message: message)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        okAction.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        
        alert.addAction(okAction)
        
        presentAlert(alert)
    }
    
    static func presentCheckAndCancelAlert(title: String, message: String, buttonTitle: String, okActionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        applyFontToAlert(alert, title: title, message: message)
        
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            okActionHandler()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        okAction.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        cancelAction.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        presentAlert(alert)
    }
    
    static func presentErrorAlertWithoutDescription() {
        let alert = makeAlertController()
        presentAlert(alert)
    }
    
    static func presentInternarServerAlert() {
        let alert = makeInternarServerAlert()
        presentAlert(alert)
    }
    
    static func makeInternarServerAlert() -> UIAlertController {
        let title = "⚠️ Internal Server Error ⚠️"
        let message = "잠시 후에 다시 시도해주세요."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        applyFontToAlert(alert, title: title, message: message)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        okAction.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        
        alert.addAction(okAction)
        return alert
    }
    
    static func makeAlertController() -> UIAlertController {
        let title = "⚠️ Internal Server Error ⚠️"
        let message = "잠시 후에 다시 시도해주세요."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        applyFontToAlert(alert, title: title, message: message)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        okAction.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        
        alert.addAction(okAction)
        return alert
    }
    
    private static func applyFontToAlert(_ alert: UIAlertController, title: String, message: String) {
        let attributedTitle = NSAttributedString(string: title, attributes: [
            NSAttributedString.Key.font: UIFont.customFont(size: 16, weight: .bold)
        ])
        
        let attributedMessage = NSAttributedString(string: message, attributes: [
            NSAttributedString.Key.font: UIFont.customFont(size: 13, weight: .medium)
        ])
        
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        alert.setValue(attributedMessage, forKey: "attributedMessage")
    }
    
    private static func presentAlert(_ alert: UIAlertController) {
        let keyWindow = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow }
        if let window = keyWindow, let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    static func createReportAlert(with handler: (() -> Void)?) -> UIAlertController {
        let title = "신고 사유를 선택해주세요."
        let message = "신고 사유에 맞지 않는 신고일 경우, 해당 신고는 처리되지 않습니다."
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        applyFontToAlert(alert, title: title, message: message)
        
        let action1 = UIAlertAction(title: "상업적 광고",
                                    style: .default,
                                    handler: { _ in handler?() })
        action1.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        alert.addAction(action1)
        
        let action2 = UIAlertAction(title: "폭력성",
                                    style: .default,
                                    handler: { _ in handler?() })
        action2.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        alert.addAction(action2)
        
        let action3 = UIAlertAction(title: "음란물",
                                    style: .default,
                                    handler: { _ in handler?() })
        action3.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        alert.addAction(action3)
        
        let action4 = UIAlertAction(title: "기타",
                                    style: .default,
                                    handler: { _ in handler?() })
        action4.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        alert.addAction(action4)
        
        let action5 = UIAlertAction(title: "취소",
                                    style: .cancel,
                                    handler: nil)
        action5.setValue(UIColor(named: "AccentColor"), forKey: "titleTextColor")
        alert.addAction(action5)
        
        return alert
    }
}
