//
//  OwnerFeedCell.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then
import ReactorKit
import RxSwift
import RxCocoa

final class OwnerFeedCell: UITableViewCell {
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    static var cellIdentifer: String {
        return String(describing: Self.self)
    }
    
    private let heartImageConfiguration = UIImage.SymbolConfiguration(pointSize: 21, weight: .light)
    
    // MARK: - UI Components
    // 피드 cell background
    private lazy var cellBackgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 16
    }
    
    // 날짜 - '2023.07.18 화요일'
    private lazy var dateLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 12, weight: .light)
        $0.textColor = .gray
        $0.text = "2023.07.18 화요일"
    }
    
    // 좋아요 버튼
    private lazy var heartButton = UIButton().then {
        let image = UIImage(systemName: "heart")
        $0.setImage(image, for: .normal)
        $0.tintColor = .red
    }
    
    private lazy var categoryStackView = CategoryStackView(imageSize: 40)
    // 작성 글 - 문장 2줄 제한
    private lazy var contentLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = .systemFont(ofSize: 15, weight: .light)
        $0.textColor = .darkGray
        $0.numberOfLines = 2
        $0.text = "오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다. 커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다. 휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다."
    }
    
    lazy var imageSlideView = ImageSlideView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add Subviews & Constraints
extension OwnerFeedCell {
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
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(heartButton)
        self.contentView.addSubview(categoryStackView)
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(imageSlideView)
    }
    
    private func setConstraints() {
        cellBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.bottom.equalTo(imageSlideView.snp.bottom).offset(40)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.left.equalTo(cellBackgroundView).inset(15)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(cellBackgroundView).inset(15)
            make.top.equalTo(dateLabel)
        }
        
        categoryStackView.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(32)
            make.centerX.equalToSuperview()
        }
    
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryStackView.snp.bottom).offset(24)
            make.left.right.equalTo(cellBackgroundView).inset(15)
        }
        
        imageSlideView.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(18) // Adjust the spacing as needed
            make.left.right.equalTo(cellBackgroundView).inset(15) // width 설정 완료
            make.height.equalTo(200)
        }
    }
}

extension OwnerFeedCell: View {
    func bind(reactor: OwnerFeedCellReactor) {
        guard let currentFeed = reactor.currentState.feed else { return }
        setFeedCell(currentFeed)
        
        heartButton.rx.tap // debouce ? throttle
            .map { Reactor.Action.toggleLike}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        reactor.state
            .compactMap { $0.feed?.isLike }
            // .compactMap : Optional 벗기고 nil 값 filter
            // nil 다 제외하고 isLike 값만 남게 됨
            .map {
                let image = self.setImageForHeartButton($0)
                let color = $0 ? UIColor.red : UIColor.gray
                return (image, color)
            }
            .bind { [weak heartButton] image, color in
                heartButton?.setImage(image, for: .normal)
                heartButton?.tintColor = color
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setFeedCell(_ feed: Feed) {
        
    }
    
    
    private func setImageForHeartButton(_ isLike: Bool) -> UIImage {
        return isLike ? UIImage(systemName: "heart.fill", withConfiguration: heartImageConfiguration)! : UIImage(systemName: "heart", withConfiguration: heartImageConfiguration)!
    }
}
