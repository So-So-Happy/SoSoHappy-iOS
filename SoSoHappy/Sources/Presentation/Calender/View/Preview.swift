//
//  Preview.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/11/29.
//


import UIKit
import RxSwift
import ReactorKit

class Preview: UIView {
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    private var imageSlideViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    lazy var cellBackgroundView =  UIView().then {
        $0.backgroundColor = UIColor(named: "CellColor")
        $0.layer.cornerRadius = 16
    }
    
    // 날씨 이미지 + 작성 날짜
    lazy var weatherDateStackView = WeatherDateStackView()
    
    // 행복 + 카테고리
    private lazy var categoryStackView = CategoryStackView()
    
    // 피드 작성 글
    private lazy var contentLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 15, weight: .medium)
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.numberOfLines = 4
    }
    
    // 피드 이미지
    lazy var imageSlideView = ImageSlideView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setFeedCell(_ feed: MyFeed) {
        weatherDateStackView.setContents(feed: feed)
        categoryStackView.addImageViews(images: feed.happinessAndCategoryArray, imageSize: 35)
        contentLabel.text = feed.text
        
        if feed.imageList.isEmpty {
            imageSlideViewHeightConstraint?.isActive = false
        
        } else {
            imageSlideView.setContents(feed: feed)
            imageSlideViewHeightConstraint?.isActive = true
        }
    }
    
}

//MARK: - setCellAttributes & Add Subviews & Constraints
extension Preview {
    private func setup() {
        setCellAttributes()
        addSubViews()
        setConstraints()
    }
    
    private func setCellAttributes() {
        backgroundColor = .clear
    }
    
    private func addSubViews() {
        addSubview(cellBackgroundView)
        addSubview(weatherDateStackView)
        addSubview(categoryStackView)
        addSubview(contentLabel)
        addSubview(imageSlideView)
    }
    
    private func setConstraints() {
        cellBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.bottom.equalTo(imageSlideView.snp.bottom).offset(40)
        }
        
        weatherDateStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cellBackgroundView).inset(40)
            make.height.equalTo(56)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(weatherDateStackView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(cellBackgroundView).inset(15)
        }
        
        imageSlideView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalTo(cellBackgroundView).inset(15)
        }
        
        // Set up the height constraint but do not activate it
        imageSlideViewHeightConstraint = imageSlideView.heightAnchor.constraint(equalToConstant: 200)
        imageSlideViewHeightConstraint?.priority = .defaultLow // 상대적으로 낮은 중요도
        // .defaultLow한 이유
        // 이미지가 없는 경우에는 이 제약조건을 무시하고 0으로 만들 수 있도록 하기 위함
    }
}

    

