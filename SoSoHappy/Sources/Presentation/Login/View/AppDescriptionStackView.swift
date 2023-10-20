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
        spacing: 35
    )
    
    private lazy var appNameLabel = UILabel().then {
        $0.text = "소소해피"
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 40, weight: .bold)
        $0.setLineSpacing(kernValue: 9, alignment: .center)
    }
    
    private lazy var appDescription = UILabel().then {
        $0.text = "소확행을 모아 대확행을 만든다.\n하루하루 소소한 행복을 찾아 기록해보세요 :)"
        $0.textColor = .darkGray
        $0.font = .systemFont(ofSize: 15, weight: .light)
        $0.numberOfLines = 2
        $0.setLineSpacing(lineSpacing: 5, alignment: .center)
    }
    
    private lazy var circleView = UIView().then {
        for i in 0...2 {
            let layer: CALayer = CALayer()
            layer.frame = .init(x: 26 * i, y: 0, width: 3, height: 3)
            layer.backgroundColor = UIColor.orange.cgColor
            layer.cornerRadius = 1.5
            $0.layer.addSublayer(layer)
        }
        $0.snp.makeConstraints { make in
            make.height.equalTo(3)
            make.width.equalTo(55)
        }
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
        appDescriptionStackView.addArrangedSubview(circleView)
        appDescriptionStackView.addArrangedSubview(appDescription)
    }
}

