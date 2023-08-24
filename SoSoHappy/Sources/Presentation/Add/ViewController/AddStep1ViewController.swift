//
//  AddStep1ViewController.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/09.
//

import UIKit
import SnapKit

class AddStep1ViewController: UIViewController {
    // MARK: - Properties
    let statusBarStack = UIStackView()
    let statusBarStep1 = UIView()
    let statusBarStep2 = UIView()
    let statusBarStep3 = UIView()
    
    let weatherLabel = UILabel()
    let weatherButtonStack = UIStackView()
    var weatherButtons = [UIButton]()
    let sunnyButton = UIButton()
    let partlyCloudyButton = UIButton()
    let cloudyButton = UIButton()
    let rainyButton = UIButton()
    let snowyButton = UIButton()
    
    let happinessLabel = UILabel()
    let happinessButtonStack = UIStackView()
    var happinessButtons = [UIButton]()
    let happiness20Button = UIButton()
    let happiness40Button = UIButton()
    let happiness60Button = UIButton()
    let happiness80Button = UIButton()
    let happiness100Button = UIButton()
    
    let nextButton = UIButton()
    let arrowImage = UIImage(systemName: "arrow.right")?.withTintColor(.white, renderingMode: .alwaysOriginal)
    var arrowImageView = UIImageView()
    
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
        statusBarStack.axis = .horizontal
        statusBarStep1.backgroundColor = UIColor(named: "AccentColor")
        statusBarStep2.backgroundColor = .white
        statusBarStep3.backgroundColor = .white
        
        weatherLabel.text = "오늘의 날씨는 어땠나요?"
        weatherLabel.textColor = .darkGray
        weatherButtonStack.axis = .horizontal
        weatherButtons = [sunnyButton, partlyCloudyButton, cloudyButton, rainyButton, snowyButton]
        
        happinessLabel.text = "OO님, 오늘 얼마나 행복하셨나요?"
        happinessLabel.textColor = .darkGray
        happinessButtonStack.axis = .horizontal
        happinessButtons = [happiness20Button, happiness40Button, happiness60Button, happiness80Button, happiness100Button]
        
        nextButton.backgroundColor = UIColor(named: "AccentColor")
        nextButton.layer.cornerRadius = 40
        
    }
    
    //  MARK: - 뷰 구성요소 세팅
    func setUpView() {
        statusBarStack.addArrangedSubview(statusBarStep1)
        statusBarStack.addArrangedSubview(statusBarStep2)
        statusBarStack.addArrangedSubview(statusBarStep3)
        statusBarStack.distribution = .fillEqually // 뷰를 동일한 크기로 분배
        view.addSubview(statusBarStack)
        
        view.addSubview(weatherLabel)
        view.addSubview(happinessLabel)
        
        weatherButtonStack.spacing = 30 // 원하는 가로 간격으로 설정
        
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
    
    //  MARK: - 뷰 구성요소 제약 설정
    func setConstraints() {
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
    
    // MARK: - 버튼이 클릭될 때 호출되는 메서드
    @objc func weatherButtonTapped(_ sender: UIButton) {
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
    
    // MARK: - 버튼이 클릭될 때 호출되는 메서드
    @objc func happinessButtonTapped(_ sender: UIButton) {
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
    
    // MARK: - 다음 버튼 클릭될 때 호출되는 메서드
    @objc func nextButtonTapped() {
        // Button tapped action
        print("NextButton tapped!")
        let addStep2VC = AddStep2ViewController(collectionViewLayout: UICollectionViewFlowLayout())
        navigationController?.pushViewController(addStep2VC, animated: true)
    }
}

#if DEBUG
import SwiftUI
struct AddStep1ViewControllerRepresentable: UIViewControllerRepresentable {
    
    func updateUIViewController(_ uiView: UIViewController,context: Context) {
        // leave this empty
    }
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> UIViewController{
        AddStep1ViewController()
    }
}
@available(iOS 13.0, *)
struct AddStep1ViewControllerRepresentable_PreviewProvider: PreviewProvider {
    static var previews: some View {
        Group {
            AddStep1ViewControllerRepresentable()
                .ignoresSafeArea()
                .previewDisplayName(/*@START_MENU_TOKEN@*/"Preview"/*@END_MENU_TOKEN@*/)
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
        }
        
    }
} #endif
