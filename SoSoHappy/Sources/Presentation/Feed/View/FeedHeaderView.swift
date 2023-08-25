//
//  FeedHeaderView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

final class FeedHeaderView: UIView {
    // MARK: - Properties
    // MARK: - UI Components
    private lazy var feedSubtitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "소피들, 서로의 행복을 응원해보아요! 🫶🏻"
        label.textColor = .darkGray
        
        return label
    }()
    
    private lazy var sortTodayButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("오늘", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        return btn
    }()
    
    private lazy var divider: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.text = "|"
        return label
    }()
    
    private lazy var sortTotalButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("전체", for: .normal)
        btn.setTitleColor(.gray, for: .normal)
        
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension FeedHeaderView {
    private func addSubviews() {
        addSubview(feedSubtitle)
        addSubview(sortTotalButton)
        addSubview(divider)
        addSubview(sortTodayButton)
    }
    
    private func setConstraints() {
        feedSubtitle.snp.makeConstraints { make in
            make.left.equalTo(safeAreaLayoutGuide).inset(16)
            make.top.equalToSuperview()
        }

        sortTotalButton.snp.makeConstraints { make in
            make.right.equalTo(safeAreaLayoutGuide).inset(16)
            make.top.equalTo(feedSubtitle.snp.bottom).offset(12)
            make.bottom.equalToSuperview().inset(10)
        }
        
        divider.snp.makeConstraints { make in
            make.right.equalTo(sortTotalButton.snp.left).offset(-8)
            make.left.equalTo(sortTodayButton.snp.right).offset(8)
            make.centerY.equalTo(sortTotalButton)
        }
        
        sortTodayButton.snp.makeConstraints { make in
            make.centerY.equalTo(sortTotalButton)
        }
    }
}



