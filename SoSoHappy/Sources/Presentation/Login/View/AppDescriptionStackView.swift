//
//  AppDescriptionStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import Then

/*
 1.appDescriptionStackView layout 준거 한번만 더 고민해보기 (intrinsicContentSize)
 */

final class AppDescriptionStackView: UIView {
    // MARK: - UI Components
    lazy var appDescriptionStackView = UIStackView(
        axis: .vertical,
        alignment: .center,
        distribution: .fill,
        spacing: 16
    )
    
    private lazy var appNameLabel = UILabel().then {
        $0.text = "소소해피"
        $0.font = UIFont.customFont(size: 50, weight: .bold)
        $0.setLineSpacing(kernValue: 1, alignment: .center)
    }
    
    private lazy var appDescription = UILabel().then {
        $0.text = "소확행을 모아 대확행을 만든다.\n하루하루 소소한 행복을 찾아 기록해보세요!"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 14, weight: .medium)
        $0.numberOfLines = 2
        $0.setLineSpacing(lineSpacing: 5, alignment: .center)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppDescriptionStackView {
    private func setStackView() {
        addSubview(appDescriptionStackView)
        appDescriptionStackView.snp.makeConstraints { make in
            make.width.equalTo(appDescription.intrinsicContentSize.width)
            make.top.bottom.equalToSuperview()
        }
        
        appDescriptionStackView.addArrangedSubview(appNameLabel)
        appDescriptionStackView.addArrangedSubview(appDescription)
    }
}

