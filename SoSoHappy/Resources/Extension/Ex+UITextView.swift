//
//  Ex+UITextView.swift
//  SoSoHappy
//
//  Created by Sue on 10/16/23.
//

import UIKit

extension UITextView {
    func setAttributedTextWithLineHeight(_ text: String, fontSize: CGFloat) {
        let style = NSMutableParagraphStyle() //  텍스트의 문단 스타일을 설정 (Line height)
        let lineheight = fontSize * 1.6
        style.minimumLineHeight = lineheight
        style.maximumLineHeight = lineheight

        let attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: style]) // 문단 스타일이 적용된 text

        self.attributedText = attributedText // UITextView의 속성을 지정
        self.font = UIFont.systemFont(ofSize: fontSize, weight: .thin)
    }
}
