//
//  SettingStackView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/19.
//

import UIKit
import SnapKit

final class SettingStackView: UIView {
    
    private lazy var alarmCell = SettingCellView()
    private lazy var darkmodeCell = SettingCellView()
    private lazy var languageCell = SettingCellView()
    private lazy var termsCell = SettingCellView()
    private lazy var policyCell = SettingCellView()
    private lazy var accountCell = SettingCellView()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(axis: .vertical,
                                    alignment: .fill,
                                    distribution: .fillEqually,
                                    spacing: 20
        )
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
//        addImageViews(images: images)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
//        addImageViews(images: images)
    }
}



extension SettingStackView {
    
    func setup() {
        setLayout()
        setAttribute()
        setUI()
    }
    
    func setLayout() {
        let views: [SettingCellView] = [alarmCell, darkmodeCell, languageCell, termsCell, policyCell, accountCell]
        
        self.addSubviews(stackView)
        
        self.stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        
        addCells(views: views)
    }
    
    func setAttribute() {
        
    }
    
    func setUI() {
        alarmCell.setUI(imageName: "alarm", text: "알림")
        darkmodeCell.setUI(imageName: "darkmode", text: "다크모드")
        languageCell.setUI(imageName: "language", text: "언어")
        termsCell.setUI(imageName: "terms", text: "이용약관")
        policyCell.setUI(imageName: "policy", text: "개인정보 처리방침")
        accountCell.setUI(imageName: "account", text: "계정 관리")
    }
    
    func addCells(views: [SettingCellView]) {
        views.forEach { view in
            self.stackView.addArrangedSubview(view)
            view.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview()
//                $0.width.equalToSuperview()
                $0.height.equalTo(30)
            }
        }
    }

}
