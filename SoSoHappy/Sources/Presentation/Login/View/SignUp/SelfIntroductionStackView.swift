//
//  SelfIntroductionStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

class SelfIntroductionStackView: UIView {
    private lazy var selfIntroductionView: UIStackView = {
        let view = UIStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 4)
        return view
    }()
    
    private lazy var selfIntroductionGuideLabel: UILabel = {
        let label = UILabel()
        label.text = "한 줄 소개를 입력해주세요."
        label.textColor = .darkGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .light)
        return label
    }()

    private lazy var selfIntroductionTextField: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        // clear button?
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.layer.cornerRadius = 8
        textView.snp.makeConstraints { make in
            make.height.equalTo(90)
        }
        return textView
    }()
    
    private var textCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 60"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSelfIntroductionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SelfIntroductionStackView {
    private func setSelfIntroductionView() {
        addSubview(selfIntroductionView)
        selfIntroductionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selfIntroductionView.addArrangedSubview(selfIntroductionGuideLabel)
        selfIntroductionView.addArrangedSubview(selfIntroductionTextField)
        selfIntroductionView.addArrangedSubview(textCountLabel)

    }
}

//extension SelfIntroductionStackView: UITextFieldDelegate {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let char = string.cString(using: String.Encoding.utf8) {
//            let isBackSpace = strcmp(char, "\\b")
//            if isBackSpace == -92 {
//                return true
//            }
//        }
//        guard textField.text!.count < 60 else { return false }
//        return true
//    }
//}

