//
//  SelfIntroductionStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then

/*
 1. TextView에 clear button 추가
 */

final class SelfIntroductionStackView: UIView {
    private lazy var selfIntroductionView = UIStackView(
        axis: .vertical,
        alignment: .fill,
        distribution: .fill,
        spacing: 6
    )
    
    private lazy var selfIntroductionGuideLabel = UILabel().then {
        $0.text = "한 줄 소개를 입력해주세요."
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 15, weight: .medium)
    }

    lazy var selfIntroductionTextView = UITextView().then {
        $0.backgroundColor = UIColor(named: "CellColor")
        // clear button?
        $0.font = UIFont.customFont(size: 15, weight: .medium)
        $0.layer.cornerRadius = 8
        $0.snp.makeConstraints { make in
            make.height.equalTo(90)
        }
    }
    
    lazy var addKeyboardToolBar = AddKeyboardToolBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
    
    lazy var textCountLabel = UILabel().then {
        $0.font = UIFont.customFont(size: 13, weight: .medium)
        $0.textColor = UIColor(named: "LightGrayTextColor")
        $0.textAlignment = .right
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension SelfIntroductionStackView {
    private func setStackView() {
        addSubview(selfIntroductionView)
        selfIntroductionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        selfIntroductionView.addArrangedSubview(selfIntroductionGuideLabel)
        selfIntroductionView.addArrangedSubview(selfIntroductionTextView)
        selfIntroductionView.addArrangedSubview(textCountLabel)
        
        selfIntroductionTextView.isUserInteractionEnabled = true
    }
    
    func checkIsTextViewFirstResponder() {
        if selfIntroductionTextView.isFirstResponder {
            selfIntroductionTextView.resignFirstResponder()
        }
    }
}
