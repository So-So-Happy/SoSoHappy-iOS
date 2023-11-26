//
//  StatusBarStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/29.
//

import UIKit
import SnapKit
import Then

final class StatusBarStackView: UIView {
    // MARK: Properties
    var step: Int
    
    // MARK: UI Components
    private lazy var statusBarStackView = UIStackView(
        axis: .horizontal,
        alignment: .fill,
        distribution: .fillEqually, // 뷰를 동일한 크기로 분배
        spacing: 0
    )
    
    private lazy var statusBarStep1 = UIView()
    private lazy var statusBarStep2 = UIView()
    private lazy var statusBarStep3 = UIView()
    
    init(step: Int) {
        self.step = step
        super.init(frame: .zero)
        setStackView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Layout
extension StatusBarStackView {
    private func setStackView() {
        setStatusBarColor()
        setLayout()
    }
    
    // MARK: 들어온 step에 따라서 statusBar background에 색상을 설정하는 메서드
    private func setStatusBarColor() {
        let statusBars = [statusBarStep1, statusBarStep2, statusBarStep3]
        
        for (index, statusBar) in statusBars.enumerated() {
            statusBar.backgroundColor = (index + 1 == step) ? UIColor(named: "AccentColor") : UIColor(named: "CellColor")
        }
    }

    private func setLayout() {
        addSubview(statusBarStackView)
        statusBarStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(5)
        }
        
        statusBarStackView.addArrangedSubview(statusBarStep1)
        statusBarStackView.addArrangedSubview(statusBarStep2)
        statusBarStackView.addArrangedSubview(statusBarStep3)
    }
}
