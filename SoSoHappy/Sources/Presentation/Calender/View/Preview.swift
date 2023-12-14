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
    
    // 행복 + 카테고리
    private lazy var categoryStackView = CategoryStackView()
    
    // 작성 날짜
    private lazy var dateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIFont.customFont(size: 10, weight: .medium)
        $0.textColor = UIColor(named: "DarkGrayTextColor") // .gray -> .darkGray
    }
    
    // 피드 작성 글
    private lazy var contentLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 12, weight: .medium)
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.numberOfLines = 3
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setFeedCell(_ feed: MyFeed) {
        categoryStackView.addImageViews(images: feed.happinessAndCategoryArray, imageSize: 35)
        dateLabel.text = feed.dateFormattedString
        contentLabel.text = feed.text
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
//        addSubview(weatherDateStackView)
        addSubview(dateLabel)
        addSubview(categoryStackView)
        addSubview(contentLabel)
//        addSubview(imageSlideView)
    }
    
    private func setConstraints() {
        cellBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.bottom.equalTo(contentLabel.snp.bottom).offset(20)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(45)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(categoryStackView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(cellBackgroundView).inset(15)
            make.centerX.equalToSuperview()
        }
        
    }
}

    

