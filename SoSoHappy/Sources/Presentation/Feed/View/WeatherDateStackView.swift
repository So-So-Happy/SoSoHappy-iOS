//
//  WeatherDateStackView.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/29.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then

final class WeatherDateStackView: UIView {
    private lazy var weatherDateStackView = UIStackView(
        axis: .vertical,
        alignment: .center,
        distribution: .fill,
        spacing: 10
    )
    // 날씨 이미지
    private lazy var weatherImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "cloudy")
        $0.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
    }
    // 작성 날짜
    private lazy var dateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 12, weight: .light)
        $0.textColor = .gray
        $0.text = "2023.07.18 화요일"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WeatherDateStackView {
    private func setStackView() {
        addSubview(weatherDateStackView)
        weatherDateStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        weatherDateStackView.addArrangedSubview(weatherImageView)
        weatherDateStackView.addArrangedSubview(dateLabel)
    }
}