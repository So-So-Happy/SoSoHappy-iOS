//
//  NickNameRecentMessageStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

class NickNameRecentMessageStackView: UIView {
    // MARK: - UI Components
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(axis: .vertical,
                                    alignment: .leading,
                                    distribution: .fill,
                                    spacing: 0
        )
        return stackView
    }()
    private lazy var profileNickNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.customFont(size: 18, weight: .bold)
        label.text = "소해피"
        return label
    }()
    
    private lazy var recentMessageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.customFont(size: 16, weight: .medium)
        label.textColor = .gray
        label.numberOfLines = 2
//        label.text = "오늘도오늘도오늘도오늘도오늘도오늘도오늘도오늘도오늘도오늘도오늘도오늘도"
        label.text = "오늘도"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLogInStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NickNameRecentMessageStackView {
    private func setLogInStackView() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackView.addArrangedSubview(profileNickNameLabel)
        stackView.addArrangedSubview(recentMessageLabel)
    }
}

