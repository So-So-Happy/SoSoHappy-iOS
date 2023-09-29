//
//  WeatherStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/29.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class WeatherStackView: UIView {
    // 날씨 버튼이 탭될 때 버튼의 'tag'를 발행하는 데 사용
    let weatherButtonTappedSubject = PublishSubject<Int>()
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: UI Components
    private lazy var weatherStackView = UIStackView(
        axis: .horizontal,
        alignment: .fill,
        distribution: .fill,
        spacing: 30
    )
    
    private let buttonInfo: [(title: String, tag: Int)] = [
        ("sunny", 0),
        ("partlyCloudy", 1),
        ("cloudy", 2),
        ("rainy", 3),
        ("snowy", 4)
    ]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
//        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Layout
extension WeatherStackView {
    private func setStackView() {
        addSubview(weatherStackView)
        weatherStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for buttonInfo in buttonInfo {
            let button = createWeatherButton(title: buttonInfo.title, tag: buttonInfo.tag)
            weatherStackView.addArrangedSubview(button)
        }
    }
    
    private func createWeatherButton(title: String, tag: Int) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: title), for: .normal)
        button.tag = tag
        
        button.snp.makeConstraints { make in
            if let image = UIImage(named: title) {
                let aspectRatio = image.size.width / image.size.height
                make.width.equalTo(button.snp.height).multipliedBy(aspectRatio)
            }
        }
    
        // button이 tap되면 tag로 추출
        button.rx.tap
            .map { tag }
            .bind(to: weatherButtonTappedSubject)
            .disposed(by: disposeBag)
        
        return button
    }
    
}

// MARK: - WeatherStackView안의 버튼이 선택되는 효과를 담당하는 function
extension WeatherStackView {
    func updateButtonAppearance(_ selectedWeather: Int?) { // 0, 1, 2, 3, 4
        for (index, button) in weatherStackView.arrangedSubviews.enumerated() {
            guard let button = button as? UIButton else { continue }
            let isSelected = index == selectedWeather
            updateButton(button, isSelected: isSelected)
        }
    }
    
    private func updateButton(_ button: UIButton, isSelected: Bool) {
        UIView.animate(withDuration: 0.2) { // 0.2초 동안의 애니메이션 효과 설정
            if isSelected {
                // 버튼을 조금 더 크게 만들기 위해 1.1배 확대
                button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                
                // 버튼에 그림자 추가
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.9 // 0.5
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
                button.layer.shadowRadius = 4
            } else {
                // 버튼 크기를 원래 크기로 복원
                button.transform = .identity
                
                // 그림자 제거
                button.layer.shadowColor = nil
                button.layer.shadowOpacity = 0
                button.layer.shadowOffset = .zero
                button.layer.shadowRadius = 0
            }
        }
    }
}
