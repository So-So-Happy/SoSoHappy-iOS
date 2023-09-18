//
//  FeedCell.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then
import ReactorKit

/*
 1. 코드 상속 처리
 2. 하트 버튼 연타 처리 (debounce, throttle)
 */

final class FeedCell: UITableViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    static var cellIdentifer: String {
        return String(describing: Self.self)
    }
    
    private let heartImageConfiguration = UIImage.SymbolConfiguration(pointSize: 21, weight: .light)
    // MARK: - UI Components
    // 피드 cell background
    private lazy var cellBackgroundView =  UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 16
    }
    
    private lazy var profileImageNameTimeStackView = ProfileImageNameTimeStackView(imageSize: 38)
    private lazy var heartButton = UIButton()
    private lazy var weatherDateStackView = WeatherDateStackView()
    private lazy var categoryStackView = CategoryStackView(imageSize: 45)
    
    // 작성 글 - 문장 2줄 제한
    private lazy var contentLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 15, weight: .light)
        $0.textColor = .darkGray
        $0.numberOfLines = 2
    }
    
    lazy var imageSlideView = ImageSlideView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Category StackView에 이미지가 계속 쌓이는 문제 해결
    // stackView안의 subview를 제거해주는 것보다 초기화해주는게 더 좋을 것 같아서
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryStackView = CategoryStackView(imageSize: 45)
    }
}

//MARK: - setCellAttributes & Add Subviews & Constraints
extension FeedCell {
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
        self.contentView.addSubview(profileImageNameTimeStackView)
        self.contentView.addSubview(heartButton)
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
        
        profileImageNameTimeStackView.snp.makeConstraints { make in
            make.top.left.equalTo(cellBackgroundView).inset(15)
//            make.top.left.equalToSuperview().inset(15)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(cellBackgroundView).inset(15)
//            make.right.equalToSuperview().inset(15)
            make.top.equalTo(profileImageNameTimeStackView)
        }
        
        weatherDateStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(profileImageNameTimeStackView.snp.bottom).offset(14)
//            make.height.equalTo(70)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(weatherDateStackView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(24)
            make.left.right.equalTo(cellBackgroundView).inset(15)
//            make.left.right.equalToSuperview().inset(15)
        }

        imageSlideView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(18) // Adjust the spacing as needed
            make.left.right.equalTo(cellBackgroundView).inset(15) // width 설정 완료
            make.height.equalTo(200)
            
//            make.left.right.equalToSuperview().inset(15) // width 설정 완료
//            make.bottom.equalToSuperview().inset(17)
        }
    }
}

extension FeedCell: View {
    func bind(reactor: FeedReactor) {
        guard let currentFeed = reactor.currentState.feed else { return }
        setFeedCell(currentFeed)
        
        heartButton.rx.tap // debouce ? throttle
            .map { Reactor.Action.toggleLike}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .skip(1)
            .compactMap { $0.feed?.isLike } // Optional 벗기고 nil 값 filter
            .bind { [weak self] isLike in
                guard let `self` = self else { return }
                setHeartButton(isLike)
            }
            .disposed(by: disposeBag)
    }
    
    private func setFeedCell(_ feed: Feed) {
        print("setCells")
        profileImageNameTimeStackView.setContents(feed: feed)
        setHeartButton(feed.isLike)
        weatherDateStackView.setContents(feed: feed)
        categoryStackView.addImageViews(images: feed.categories)
        contentLabel.text = feed.content
        imageSlideView.setContents(feed: feed)
    }
    
    private func setHeartButton(_ isLike: Bool) {
        let image: UIImage = isLike ? UIImage(systemName: "heart.fill", withConfiguration: heartImageConfiguration)! : UIImage(systemName: "heart", withConfiguration: heartImageConfiguration)!
        let color: UIColor =  isLike ? UIColor.systemRed : UIColor.systemGray
        
        heartButton.setImage(image, for: .normal)
        heartButton.tintColor = color
    }
}

