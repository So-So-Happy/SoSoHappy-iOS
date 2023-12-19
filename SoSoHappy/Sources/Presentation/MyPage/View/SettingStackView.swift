//
//  SettingStackView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/19.
//

import UIKit
import SnapKit

final class SettingStackView: UIView {
    // MARK: - UI Components
    lazy var alarmCell = SettingCellView()
    lazy var termsCell = SettingCellView()
    lazy var policyCell = SettingCellView()
    lazy var accountCell = SettingCellView()
    lazy var inquiryCell = SettingCellView()
    
    private lazy var stackView = UIStackView(
        axis: .vertical,
        alignment: .fill,
        distribution: .fillEqually,
        spacing: 20
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}

extension SettingStackView {

    // MARK: - Update UI & Layout
    func setup() {
        setLayout()
        setUI()
    }
    
    func setLayout() {
        let views: [SettingCellView] = [alarmCell, termsCell, policyCell, inquiryCell, accountCell]
        
        self.addSubviews(stackView)
        
        self.stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        
        addCells(views: views)
    }
    
    func setUI() {
        alarmCell.setUI(imageName: "bell", text: "알림")
        termsCell.setUI(imageName: "checkmark.shield", text: "이용약관")
        policyCell.setUI(imageName: "hand.raised", text: "개인정보 처리방침")
        accountCell.setUI(imageName: "lock.circle", text: "계정 관리")
        inquiryCell.setUI(imageName: "envelope", text: "문의하기")
    }
    
    func addCells(views: [SettingCellView]) {
        views.forEach { view in
            self.stackView.addArrangedSubview(view)
            view.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview()
                $0.height.equalTo(30)
            }
        }
    }
}
