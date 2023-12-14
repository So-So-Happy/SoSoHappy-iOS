//
//  RecommendView.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/28.
//

import UIKit
import SnapKit
import Then

final class RecommendView: UIView {
    
    // MARK: - Properties
    private lazy var recommendLabel = UILabel().then {
        $0.text = "좋아하실 만한 소확행을 찾아봤어요! 👀"
        $0.font = UIFont.customFont(size: 16, weight: .semibold)
    }

    private lazy var speechBubbleView = UIView().then {
        $0.backgroundColor = UIColor(named: "CellColor")
        $0.layer.cornerRadius = 20
        $0.addSubview(recommendedHappinessLabel)
        $0.addSubview(refreshButton)
    }
    
    lazy var recommendedHappinessLabel = UILabel().then {
        $0.text = "비 오는 날 산책하기 ☔️🚶🏻‍♀️"
        $0.font = UIFont.customFont(size: 15, weight: .medium)
        $0.textColor = UIColor(named: "DarkGrayTextColor")
    }
    
    lazy var refreshButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        $0.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Layout & Attribute
private extension RecommendView {
    
    //  MARK: 뷰 구성요소 세팅
    private func setUpView() {
        addSubview(recommendLabel)
        addSubview(speechBubbleView)
    }
    
    //  MARK: 뷰 구성요소 제약 설정
    private func setConstraints() {
        recommendLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.top.equalToSuperview()
        }
        
        speechBubbleView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.top.equalTo(recommendLabel).inset(30)
            make.height.equalTo(60)
        }
        
        // Set constraints for recommendedHappinessLabel within speechBubbleView
        recommendedHappinessLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendedHappinessLabel.leadingAnchor.constraint(equalTo: speechBubbleView.leadingAnchor, constant: 20).isActive = true
        recommendedHappinessLabel.centerYAnchor.constraint(equalTo: speechBubbleView.centerYAnchor).isActive = true
        
        // Set constraints for refreshButton next to recommendedHappinessLabel
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        refreshButton.trailingAnchor.constraint(equalTo: speechBubbleView.trailingAnchor, constant: -20).isActive = true
        refreshButton.centerYAnchor.constraint(equalTo: speechBubbleView.centerYAnchor).isActive = true
    }
}

private extension RecommendView {
    func setRecommendText() {
        
    }
}

// MARK: - Action
private extension RecommendView {
    
    // MARK: 새로고침 버튼 클릭될 때 호출되는 메서드
    @objc private func refreshButtonTapped() {
        // Button tapped action
        print("refreshButton tapped!")
    }
}
