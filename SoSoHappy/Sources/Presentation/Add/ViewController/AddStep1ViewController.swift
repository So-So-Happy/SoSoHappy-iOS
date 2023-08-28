//
//  AddStep1ViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/09.
//

import UIKit
import SnapKit
import Then

final class AddStep1ViewController: UIViewController {
    // MARK: - Properties
    private lazy var statusBarStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually // 뷰를 동일한 크기로 분배
    }
    
    private lazy var statusBarStep1 = UIView().then {
        $0.backgroundColor = UIColor(named: "AccentColor")
    }
    
    private lazy var statusBarStep2 = UIView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var statusBarStep3 = UIView().then {
        $0.backgroundColor = .white
    }
    
    private lazy var weatherLabel = UILabel().then {
        $0.text = "오늘의 날씨는 어땠나요?"
        $0.textColor = .darkGray
    }
    
    private lazy var weatherButtonStack = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 30 // 원하는 가로 간격으로 설정
    }
    
    private lazy var weatherButtons = [UIButton]()
    private lazy var sunnyButton = UIButton()
    private lazy var partlyCloudyButton = UIButton()
    private lazy var cloudyButton = UIButton()
    private lazy var rainyButton = UIButton()
    private lazy var snowyButton = UIButton()
    
    private lazy var happinessLabel = UILabel().then {
        $0.text = "OO님, 오늘 얼마나 행복하셨나요?"
        $0.textColor = .darkGray
    }
    
    private lazy var happinessButtonStack = UIStackView().then {
        $0.axis = .horizontal
    }
    private lazy var happinessButtons = [UIButton]()
    private lazy var happiness20Button = UIButton()
    private lazy var happiness40Button = UIButton()
    private lazy var happiness60Button = UIButton()
    private lazy var happiness80Button = UIButton()
    private lazy var happiness100Button = UIButton()
    
    private lazy var nextButton = UIButton().then {
        $0.backgroundColor = UIColor(named: "AccentColor")
        $0.layer.cornerRadius = 40
    }
    
    private lazy var arrowImage = UIImage(systemName: "arrow.right")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    private lazy var arrowImageView = UIImageView()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BGgrayColor")
        
        setUpValue()
        setUpView()
        setConstraints()
    }
    
    // MARK: - 요소 내용 설정
    func setUpValue() {
        weatherButtons = [sunnyButton, partlyCloudyButton, cloudyButton, rainyButton, snowyButton]
        
        happinessButtons = [happiness20Button, happiness40Button, happiness60Button, happiness80Button, happiness100Button]
    }
}

// MARK: - Layout & Attribute
private extension AddStep1ViewController {
    
    //  MARK: 뷰 구성요소 세팅
    private func setUpView() {
        statusBarStack.addArrangedSubview(statusBarStep1)
        statusBarStack.addArrangedSubview(statusBarStep2)
        statusBarStack.addArrangedSubview(statusBarStep3)
        view.addSubview(statusBarStack)
        
        view.addSubview(weatherLabel)
        view.addSubview(happinessLabel)

        for button in weatherButtons {
            weatherButtonStack.addArrangedSubview(button) // 스택에 추가
            button.addTarget(self, action: #selector(weatherButtonTapped(_:)), for: .touchUpInside) // 이미지 버튼 액션 설정
            
            if button == sunnyButton { // 이미지 버튼에 이미지 설정
                button.setImage(UIImage(named: "sunny"), for: .normal)
            } else if button == partlyCloudyButton {
                partlyCloudyButton.setImage(UIImage(named: "partlyCloudy"), for: .normal)
            } else if button == cloudyButton {
                cloudyButton.setImage(UIImage(named: "cloudy"), for: .normal)
            } else if button == rainyButton {
                rainyButton.setImage(UIImage(named: "rainy"), for: .normal)
            } else { snowyButton.setImage(UIImage(named: "snowy"), for: .normal) }
        }
        view.addSubview(weatherButtonStack)
        
        happinessButtonStack.spacing = 10
        
        for button in happinessButtons {
            happinessButtonStack.addArrangedSubview(button) // 스택에 추가
            button.addTarget(self, action: #selector(happinessButtonTapped(_:)), for: .touchUpInside) // 이미지 버튼 액션 설정
            switch button {
            case happiness20Button:
                button.setImage(UIImage(named: "happy20"), for: .normal)
            case happiness40Button:
                button.setImage(UIImage(named: "happy40"), for: .normal)
            case happiness60Button:
                button.setImage(UIImage(named: "happy60"), for: .normal)
            case happiness80Button:
                button.setImage(UIImage(named: "happy80"), for: .normal)
            default:
                button.setImage(UIImage(named: "happy100"), for: .normal)
            }
            view.addSubview(happinessButtonStack)
        }
        
        view.addSubview(nextButton)
        arrowImageView = UIImageView(image: arrowImage)
        nextButton.addSubview(arrowImageView)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    //  MARK: 뷰 구성요소 제약 설정
    private func setConstraints() {
        statusBarStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(5) // 높이 설정
        }
        
        weatherLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview() // 수평 중앙 정렬
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(UIEdgeInsets(top: 110, left: 0, bottom: 0, right: 0))
        }
        
        // 날씨 버튼 설정
        for button in weatherButtons {
            if let image = button.imageView?.image {
                let aspectRatio = image.size.width / image.size.height // 이미지 비율 계산
                
                // 버튼 크기 제약 설정
                button.snp.makeConstraints { make in
                    make.width.equalTo(button.snp.height).multipliedBy(aspectRatio) // 이미지 비율에 맞게 너비 설정
                }
            }
        }
          
        weatherButtonStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
            make.top.equalTo(weatherLabel).inset(UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0))
        }
        
        happinessLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview() // 수평 중앙 정렬
            make.top.equalTo(weatherLabel).inset(UIEdgeInsets(top: 190, left: 0, bottom: 0, right: 0))
        }
        
        // 행복 수치 버튼 설정
        for button in happinessButtons {
            if let image = button.imageView?.image {
                let aspectRatio = image.size.width / image.size.height // 이미지 비율 계산
                
                // 버튼 크기 제약 설정
                button.snp.makeConstraints { make in
                    make.width.equalTo(button.snp.height).multipliedBy(aspectRatio) // 이미지 비율에 맞게 너비 설정
                }
            }
        }
          
        happinessButtonStack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
            make.top.equalTo(happinessLabel).inset(UIEdgeInsets(top: 45, left: 0, bottom: 0, right: 0))
        }
        
        // Next Button 설정
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview() // 수평 중앙 정렬
            make.bottomMargin.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
            make.width.height.equalTo(80) // Set arrow image size
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.center.equalTo(nextButton)
            make.width.height.equalTo(30) // Set arrow image size
        }
        
    }
}

// MARK: - Action
private extension AddStep1ViewController {
    
    // MARK: 버튼이 클릭될 때 호출되는 메서드
    @objc private func weatherButtonTapped(_ sender: UIButton) {
        if sender == sunnyButton {
            // Sunny Button 클릭 시 동작
            print("Sunny Button is clicked...")
        } else if sender == partlyCloudyButton {
            // PartlyCloudy Button 클릭 시 동작
            print("PartlyCloudy Button is clicked...")
        } else if sender == cloudyButton {
            // Cloudy Button 클릭 시 동작
            print("Cloudy Button is clicked...")
        } else if sender == rainyButton {
            // Rainy Button 클릭 시 동작
            print("Rainy Button is clicked...")
        } else {
            // Snowy Button 클릭 시 동작
            print("Snowy Button is clicked...")
        }
    }
    
    // MARK: 버튼이 클릭될 때 호출되는 메서드
    @objc private func happinessButtonTapped(_ sender: UIButton) {
        if sender == happiness20Button {
            // Sunny Button 클릭 시 동작
            print("happiness20Button is clicked...")
        } else if sender == happiness40Button {
            // PartlyCloudy Button 클릭 시 동작
            print("happiness40Button is clicked...")
        } else if sender == happiness60Button {
            // Cloudy Button 클릭 시 동작
            print("happiness60Button is clicked...")
        } else if sender == happiness80Button {
            // Rainy Button 클릭 시 동작
            print("happiness80Button is clicked...")
        } else {
            // Snowy Button 클릭 시 동작
            print("happiness100Button is clicked...")
        }
    }
    
    // MARK: 다음 버튼 클릭될 때 호출되는 메서드
    @objc private func nextButtonTapped() {
        // Button tapped action
        print("NextButton tapped!")
        let addStep2VC = AddStep2ViewController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(addStep2VC, animated: true)
    }
}
