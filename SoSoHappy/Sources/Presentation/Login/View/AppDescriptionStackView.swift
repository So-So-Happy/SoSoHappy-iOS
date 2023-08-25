//
//  AppDescriptionStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit

class AppDescriptionStackView: UIView {
    lazy var appDescriptionStackView: UIStackView = {
        let stackView = UIStackView(axis: .vertical,
                                    alignment: .center,
                                    distribution: .fill,
                                    spacing: 28
        )
        return stackView
    }()
    
    private lazy var appNameLabel: UILabel = {
        let label = UILabel()
        label.text = "소소해피"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 36, weight: .bold)
        label.setLineSpacing(kernValue: 9, alignment: .center)
        return label
    }()
    
    private lazy var appDescription: UILabel = {
        let label = UILabel()
        label.text = "소확행을 모아 대확행을 만든다.\n하루하루 소소한 행복을 찾아 기록해보세요 :)"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.numberOfLines = 2
        label.setLineSpacing(lineSpacing: 8, alignment: .center)
        return label
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        for i in 0...2 {
            let layer: CALayer = CALayer()
            layer.frame = .init(x: 26 * i, y: 0, width: 3, height: 3)
            layer.backgroundColor = UIColor.orange.cgColor
            layer.cornerRadius = 1.5
            view.layer.addSublayer(layer)
        }
        view.snp.makeConstraints { make in
            make.height.equalTo(3)
            make.width.equalTo(55)
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAppDescriptionStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppDescriptionStackView {
    private func setAppDescriptionStackView() {
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

