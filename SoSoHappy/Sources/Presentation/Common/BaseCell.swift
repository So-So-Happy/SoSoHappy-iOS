//
//  BaseCell.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/24.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then
import ReactorKit

class BaseCell: UITableViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    private var imageSlideViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    lazy var cellBackgroundView = UIView().then {
        $0.backgroundColor = UIColor(named: "CellColor")
        $0.layer.cornerRadius = 16
    }
    
    lazy var weatherDateStackView = WeatherDateStackView()
    
    private lazy var categoryStackView = CategoryStackView()
    
    private lazy var contentLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIFont.customFont(size: 15, weight: .medium)
        $0.textColor = UIColor(named: "DarkGrayTextColor")
        $0.numberOfLines = 4
    }
    
    lazy var imageSlideView = ImageSlideView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setFeedCell(_ feed: FeedType) {
        weatherDateStackView.setContents(feed: feed)
        categoryStackView.addImageViews(images: feed.happinessAndCategoryArray, imageSize: 45)
        contentLabel.text = feed.text
        
        if feed.imageIdList.isEmpty {
            imageSlideViewHeightConstraint?.isActive = false
            
        } else {
            imageSlideViewHeightConstraint?.isActive = true
            imageSlideView.setImages(ids: feed.imageIdList)
        }
                
        func prepareForReuse() {
            super.prepareForReuse()
            disposeBag = DisposeBag()
        }
    }
}

//MARK: - setCellAttributes & Add Subviews & Constraints
extension BaseCell {
    private func setup() {
        setCellAttributes()
        addSubViews()
        setConstraints()
    }
    
    private func setCellAttributes() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func addSubViews() {
        self.contentView.addSubview(cellBackgroundView)
        self.contentView.addSubview(weatherDateStackView)
        self.contentView.addSubview(categoryStackView)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(imageSlideView)
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
        
        imageSlideViewHeightConstraint = imageSlideView.heightAnchor.constraint(equalToConstant: 200)
        imageSlideViewHeightConstraint?.priority = .defaultLow
    }
}
