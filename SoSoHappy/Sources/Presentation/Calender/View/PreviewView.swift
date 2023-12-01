//
//  PreviewView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/18.
//

import UIKit

// 날씨이미지, 날짜, 스택뷰, 내용텍스트, 이미지탭뷰
final class PreviewView: UIView { 
    
    // cell Id
    static var identifier: String {
        return String(describing: Self.self)
    }
    
    // 날씨 이미지
    private lazy var weatherImage = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "weather")
    }
    
    // 날짜
    private lazy var dateLabel = UILabel().then {
        $0.text = "2023.07.18 화요일"
        $0.font = UIFont.customFont(size: 13, weight: .medium)
        $0.textColor = UIColor(named: "LightGrayTextColor")
    }
    
    // 카테고리, 행복지수 스택뷰
    private lazy var categoryStackView = CategoryStackView()
    
    // 내용 텍스트
    private lazy var contentsLabel = UILabel().then {
        $0.text = """
오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다.
커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다...
사진은 의미 없는 하루콩 ㅋ😄
"""
        $0.font = UIFont.customFont(size: 15, weight: .medium)
        $0.numberOfLines = 4
        $0.sizeToFit()
        $0.textColor = UIColor(named: "GrayTextColor")
    }
    
    // 이미지 탭뷰
    var imageSlideView = ImageSlideView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setLayout()
    }
    
    private func setLayout() {
        configureWeatherImage()
        configureDateLabel()
        configureCategoryStackView()
        configureContentsLabel()
//        configureImageSlideView()
    }
    
    // update UI 
    private func setUI(_ happy: Happy) {
        var images: [String] = []
//        images.append(happy.charactor)
        images = ["sohappy", "coffe", "donut"]
        self.categoryStackView.addImageViews(images: images)
    }

    
    private func configureWeatherImage() {
        self.addSubview(weatherImage)
        weatherImage.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(15)
        }
    }
    
    private func configureDateLabel() {
        self.addSubview(dateLabel)
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(weatherImage.snp.bottom).offset(4)
            $0.height.equalTo(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func configureCategoryStackView() {
        self.addSubview(categoryStackView)
        categoryStackView.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func configureContentsLabel() {
        self.addSubview(contentsLabel)
        contentsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(categoryStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(17)
        }
    }
    
    private func configureImageSlideView() {
        self.addSubview(imageSlideView)
        imageSlideView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(contentsLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(17)
            $0.height.equalTo(250)
            $0.bottom.equalToSuperview().inset(17)
        }
    }
}

