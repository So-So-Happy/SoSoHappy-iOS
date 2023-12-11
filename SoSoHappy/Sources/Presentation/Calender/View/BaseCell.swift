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

/*
 1. 한번 더 리팩토링하면 좋을 듯 - imageslideshow height
 */

// MARK: - BaseCell 리팩토링 필요
class BaseCell: UITableViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    private var imageSlideViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    lazy var cellBackgroundView =  UIView().then {
        $0.backgroundColor = UIColor(named: "CellColor")
        $0.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        $0.layer.borderWidth = 1
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
        
//        
//        if let imageList = feed.imageList, !imageList.isEmpty { // image가 있으면
//            print("BaseCell 사진 있음(O)")
////            imageSlideView.setContents(feed: feed)
//            imageSlideView.setContentsWithImageList(imageList: imageList)
//            imageSlideViewHeightConstraint?.isActive = true // 제약조건 활성화
//        } else { //image가 없다면
//            print("BaseCell 사진 없음(X)")
//            imageSlideViewHeightConstraint?.isActive = false // 제약조건 비활성화
//        }
        
        // TODO: 이 부분에서 레이아웃 에러가 나는 것 같아서 다시 한번 봐야 함
        if feed.imageList.isEmpty { //image가 없다면
            imageSlideViewHeightConstraint?.isActive = false // 제약조건 비활성화
        
        } else { // image가 있으면
            imageSlideView.setContents(feed: feed)
            imageSlideViewHeightConstraint?.isActive = true // 제약조건 활성화
            
        }
    }
    
    // BaseCell을 상속받는 Cell은 자동으로 호출됨
    // 속성을 초기화 (content는 여기에서 해주는게 적합하지 않음)
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
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
        backgroundColor = .clear // tableView의 backgroundColor가 보이도록 cell은 .clear
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
        // 이 코드가 없어도 잘 동작하긴 함
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
