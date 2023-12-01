//
//  AwardsView.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/28.
//

import UIKit
import SnapKit
import Then

final class AwardsView: UIView {
    
    // MARK: - Properties
    private lazy var label = UILabel().then {
        $0.text = "오늘도 행복하셨나요?"
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.font = UIFont.customFont(size: 16, weight: .medium)
    }
    
    private lazy var titleStack = UIStackView().then {
        $0.spacing = 0
        $0.addArrangedSubview(nameLabel)
        $0.addArrangedSubview(label2)
        $0.distribution = .fillProportionally
        $0.axis = .horizontal
    }
    
    private lazy var nameLabel = UILabel().then {
        $0.text = "OO님"
        $0.textColor = UIColor(named: "AccentColor")
        $0.font = UIFont.customFont(size: 24, weight: .bold)
    }
    
    private lazy var label2 = UILabel().then {
        $0.text = "의 행복을 분석해봤어요!"
        $0.font = UIFont.customFont(size: 24, weight: .bold)
    }
    
    private lazy var awardsLabel = UILabel().then {
        $0.text = "이번 달 베스트 소확행 어워즈 🏆"
        $0.font = UIFont.customFont(size: 16, weight: .medium)
    }
    
    private lazy var awardsStack = UIStackView().then {
        $0.addArrangedSubview(firstPlaceView)
        $0.addArrangedSubview(secondPlaceView)
        $0.addArrangedSubview(thirdPlaceView)
        $0.distribution = .fillEqually // 뷰를 동일한 크기로 분배
    }
    
    private lazy var detailsAwardsButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        $0.addTarget(self, action: #selector(detailsAwardsButtonTapped), for: .touchUpInside)
    }
    
    private lazy var firstPlaceView = UIView()
    private lazy var secondPlaceView = UIView()
    private lazy var thirdPlaceView = UIView()
    
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
private extension AwardsView {
    
    func setCategory() {
        
    }
    
    //  MARK: 뷰 구성요소 세팅
    private func setUpView() {
        addSubview(label)
        addSubview(titleStack)
        addSubview(awardsLabel)
        
        firstPlaceView = createPodiumView(position: 2, color: UIColor(named: "AccentColor")!, categori: UIImage(named: "dessert")!)
        secondPlaceView = createPodiumView(position: 3, color: UIColor(named: "AccentColor")!, categori: UIImage(named: "home")!)
        thirdPlaceView = createPodiumView(position: 1, color: UIColor(named: "AccentColor")!, categori: UIImage(named: "drive")!)
        
        addSubview(awardsStack)
        addSubview(detailsAwardsButton)
    }
    
    //  MARK: 뷰 구성요소 제약 설정
    private func setConstraints() {
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalToSuperview()
        }
        
        titleStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalTo(label).inset(UIEdgeInsets(top: 25, left: 0, bottom: 0, right: 0))
        }
        
        awardsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0))
            make.top.equalTo(titleStack).inset(UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0))
        }
        
        detailsAwardsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 30))
            make.top.equalTo(titleStack).inset(UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0))
        }
        
        awardsStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30))
            make.top.equalTo(awardsLabel).inset(40)
        }
    }
}

// MARK: - Action
private extension AwardsView {
    
    // MARK: 다음 버튼 클릭될 때 호출되는 메서드
    @objc private func detailsAwardsButtonTapped() {
        // Button tapped action
        print("detailsAwardsButton tapped!")
    }
    
    // MARK: 어워즈 단상 뷰 생성 메서드
    private func createPodiumView(position: Int, color: UIColor, categori: UIImage) -> UIView {
        let stackView = UIStackView()
        let categoriImage = UIImageView(image: categori)
        let podiumView = UIView()
        
        stackView.axis = .vertical
        categoriImage.contentMode = .scaleAspectFit
        podiumView.backgroundColor = UIColor(named: "LightAccentColor")
        podiumView.layer.cornerRadius = 8
        
        stackView.addArrangedSubview(categoriImage)
        stackView.addArrangedSubview(podiumView)
        
        addSubview(stackView)
        
        categoriImage.snp.makeConstraints { make in
            make.height.equalTo(60) // 높이 설정
            make.top.equalTo(stackView).inset((3 - position) * 30)
        }
        
        podiumView.snp.makeConstraints { make in
            make.height.equalTo(position * 30) // 높이 설정 50 100 150 , 100 50 0
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        
        return stackView
    }
}

extension AwardsView {
    func setAwardsCategories() {
        
    }
}
