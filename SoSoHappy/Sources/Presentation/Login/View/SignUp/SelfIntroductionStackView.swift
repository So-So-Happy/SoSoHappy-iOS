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
        spacing: 4
    )
    
    private lazy var selfIntroductionGuideLabel = UILabel().then {
        $0.text = "한 줄 소개를 입력해주세요."
        $0.textColor = .darkGray
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 15, weight: .light)
    }

    lazy var selfIntroductionTextView = UITextView().then {
        $0.backgroundColor = .white
        // clear button?
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.layer.cornerRadius = 8
        $0.snp.makeConstraints { make in
            make.height.equalTo(90)
        }
    }
    
    lazy var textCountLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .lightGray
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

    }
}

