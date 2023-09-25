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
    
    // MARK: - UI Components
    lazy var cellBackgroundView =  UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 16
    }
    
    lazy var weatherDateStackView = WeatherDateStackView()
    private lazy var categoryStackView = CategoryStackView(imageSize: 45)
    private lazy var contentLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 15, weight: .light)
        $0.textColor = .darkGray
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
    
    func setFeedCell(_ feed: FeedTemp) {
        weatherDateStackView.setContents(feed: feed)
        categoryStackView.addImageViews(images: feed.categories)
        contentLabel.text = feed.content
    
        if feed.images.isEmpty { //image가 없다면
            imageSlideView.isHidden = true
            cellBackgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
                make.bottom.equalTo(contentLabel.snp.bottom).offset(40)
            }
        } else { // image가 있으면
            imageSlideView.isHidden = false
            imageSlideView.setContents(feed: feed)
            cellBackgroundView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
                make.bottom.equalTo(imageSlideView.snp.bottom).offset(40)
            }
        }
    }
    
    // BaseCell을 상속받는 Cell은 자동으로 호출됨
    // 속성을 초기화 (content는 여기에서 해주는게 적합하지 않음)
    override func prepareForReuse() {
        print("prepareForReuse - BaseCell")
        super.prepareForReuse()
        imageSlideView.isHidden = true
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
//        cellBackgroundView.snp.makeConstraints { make in
//            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
//            make.bottom.equalTo(imageSlideView.snp.bottom).offset(40)
//        }
        
        weatherDateStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cellBackgroundView).inset(40)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(weatherDateStackView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(cellBackgroundView).inset(15)
        }
        
        imageSlideView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(18) // Adjust the spacing as needed
            make.horizontalEdges.equalTo(cellBackgroundView).inset(15) // width 설정 완료
            make.height.equalTo(200)
        }
    }
}
