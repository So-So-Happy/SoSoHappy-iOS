//
//  RecentTimeMessageCountStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

class RecentTimeMessageCountStackView: UIView {
    // MARK: - UI Components
    private lazy var stackview: UIStackView = {
        let stackView = UIStackView(axis: .vertical,
                                    alignment: .trailing,
                                    distribution: .fill,
                                    spacing: 5
        )
        return stackView
    }()
    
    private lazy var recentTimeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.text = "오전 14: 38"
//        label.text = "어제"
        label.textColor = UIColor(named: "DarkGrayTextColor")
        return label
    }()
    
    private lazy var newMessageCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.text = "2"
        label.textColor = .white
        label.backgroundColor = .orange
        label.layer.cornerRadius = 11
        label.clipsToBounds = true
        label.snp.makeConstraints { make in
            make.size.equalTo(22)
        }
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

extension RecentTimeMessageCountStackView {
    private func setLogInStackView() {
        addSubview(stackview)
        stackview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        stackview.addArrangedSubview(recentTimeLabel)
        stackview.addArrangedSubview(newMessageCountLabel)
    }
}

