//
//  FeedHeaderView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//


import UIKit
import SnapKit
import Then

final class FeedHeaderView: UIView {
    // MARK: - UI Components
    private lazy var titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 32, weight: .bold)
        $0.text = "소피들의 소소해피"
        $0.textColor = .black
    }
    
    private lazy var feedSubtitle = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 18, weight: .semibold)
        $0.text = "소피들, 서로의 행복을 응원해보아요! 🫶🏻"
        $0.textColor = .darkGray
    }
    
    private lazy var sortTodayTotalStackView = UIStackView(
        axis: .horizontal,
        alignment: .fill,
        distribution: .fill,
        spacing: 8
    )
    
    lazy var sortTodayButton = UIButton().then {
        $0.setTitle("오늘", for: .normal)
        $0.setTitleColor(.black, for: .normal)
//        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    }
    
    private lazy var divider = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.text = "|"
    }
    
    lazy var sortTotalButton = UIButton().then {
        $0.setTitle("전체", for: .normal)
        $0.setTitleColor(.gray, for: .normal)
//        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension FeedHeaderView {
    private func setView() {
        addSubviews()
        setLayout()
    }
    
    private func addSubviews() {
        sortTodayTotalStackView.addArrangedSubview(sortTodayButton)
        sortTodayTotalStackView.addArrangedSubview(divider)
        sortTodayTotalStackView.addArrangedSubview(sortTotalButton)
        
        addSubview(titleLabel)
        addSubview(feedSubtitle)
        addSubview(sortTodayTotalStackView)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(safeAreaLayoutGuide).inset(16)
            make.top.equalToSuperview().inset(3)
            make.height.equalTo(39)
        }
        
        feedSubtitle.snp.makeConstraints { make in
            make.left.equalTo(safeAreaLayoutGuide).inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        sortTodayTotalStackView.snp.makeConstraints { make in
            make.right.equalTo(safeAreaLayoutGuide).inset(16)
            make.top.equalTo(feedSubtitle.snp.bottom).offset(40)
            make.bottom.equalToSuperview().inset(10)
        }
    }
}


extension FeedHeaderView {
    func updateButtonState(_ sortOption: SortOption) {
        switch sortOption {
        case .today:
            setSortTextColorAttribute(sortTodayButton, sortTotalButton)
        case .total:
            setSortTextColorAttribute(sortTotalButton, sortTodayButton)
        default: break
        }
    }
    
    private func setSortTextColorAttribute(_ selected: UIButton, _ notSelected: UIButton) {
        selected.setTitleColor(.black, for: .normal)
        selected.titleLabel?.font =  UIFont.systemFont(ofSize: 15, weight: .bold)
        notSelected.setTitleColor(.gray, for: .normal)
        notSelected.titleLabel?.font =  UIFont.systemFont(ofSize: 15, weight: .light)
    }
}
