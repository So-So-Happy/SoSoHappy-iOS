//
//  FeedCell.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit
import SnapKit
import ImageSlideshow


/*
 1. stack 처리 필요 (리팩토링할 때 해주면 될 듯)
 2. heartButton 토글 적용
 */

final class FeedCell: UITableViewCell {
    // MARK: - Properties
    static var cellIdentifer: String {
        return String(describing: Self.self)
    }
    // MARK: - UI Components
    
    // 1. 피드 cell background
    private lazy var cellBackgroundView: UIView = {
        let bv = UIView()
        bv.backgroundColor = .white
        bv.layer.borderColor = UIColor(white: 0.9, alpha: 1.0).cgColor
        bv.layer.borderWidth = 1
        bv.layer.cornerRadius = 16
        return bv
    }()
    
    // 2.  작성자 프로필 이미지
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "profile")
//        iv.contentMode = .scaleAspectFit
//        iv.clipsToBounds = true
        
        return iv
    }()
    
    // 3. 작성자 닉네임
    private lazy var profileNickNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.text = "소해피"
        return label
    }()
    
    // 4. 작성 시간 - '5분 전'
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 11, weight: .light)
        label.textColor = .gray
        label.text = "5분 전"
        
        return label
    }()
    
    // 5. 좋아요 버튼
    private lazy var heartButton: UIButton = {
        let image = UIImage(systemName: "heart")
        let btn = UIButton(type: .system)
        btn.setImage(image, for: .normal)
        btn.tintColor = .red
        return btn
    }()
    
    // 6. 날씨 이미지
    private lazy var weatherImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "cloudy")
        return iv
    }()
    
    // 7. 날짜 - '2023.07.18 화요일'
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.textColor = .gray
        label.text = "2023.07.18 화요일"
        
        return label
    }()
    
    // 스택에 들어갈 요소들
    private lazy var happinessImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "happiness")
        return iv
    }()
    
    private lazy var categoryImageView1: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "donut")
        return iv
    }()
    
    private lazy var categoryImageView2: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "coffee")
        return iv
    }()
    
    // 8. 이미지 스택 - 행복 이미지, 카테고리1, 카테고리2
    private lazy var imageStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        return sv
    }()
    
    
    // 9. 작성 글 - 문장 2줄 제한
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .light)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.text = "오늘 아아랑 휘낭시에를 머것다..그런데 아아를 먹다가 쏟아버렸다. 커피 냄새가 좋아서 괜찮아지만 옷에 묻은 얼룩은 슬펐다. 휘낭시애는 맛있어서 연달아서 5개를 앉은 자리에서 먹었다. 행복했다! 오늘 하루도 작은 행복을 느낄 수 있어서 너무 감사합니다."
        
        return label
    }()
    
    // 10. 게시물 대표 사진들
    private lazy var pageIndicator: UIPageControl = {
        let pageIndicator = UIPageControl()
        pageIndicator.currentPageIndicatorTintColor = UIColor.orange
        pageIndicator.pageIndicatorTintColor = UIColor.lightGray
        
        return pageIndicator
    }()
    
    private lazy var slideShow: ImageSlideshow = {
        let slideShow = ImageSlideshow()
        slideShow.pageIndicator = pageIndicator
        slideShow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center)
        slideShow.contentScaleMode = .scaleAspectFill
        slideShow.activityIndicator = DefaultActivityIndicator()
        return slideShow
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //        self.contentView.backgroundColor = .yellow // test용
        setCellAttributes()
        addSubViews()
        setConstraints()
        setDataForCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

//MARK: - setCellAttributes & Add Subviews & Constraints
extension FeedCell {
    private func setCellAttributes() {
        backgroundColor = .clear // tableView의 backgroundColor가 보이도록 cell은 .clear
        selectionStyle = .none
    }
    
    // 소소해피 1개 들어옴
    public func setDataForCell() {
        slideShow.setImageInputs([
            ImageSource(image: UIImage(named: "pic1")!),
            ImageSource(image: UIImage(named: "pic2")!),
            ImageSource(image: UIImage(named: "pic3")!)
        ])
        
    }
    
    private func addSubViews() {
        self.contentView.addSubview(cellBackgroundView)
        self.contentView.addSubview(profileImageView)
        self.contentView.addSubview(profileNickNameLabel)
        self.contentView.addSubview(timeLabel)
        
        self.contentView.addSubview(heartButton)
        
        self.contentView.addSubview(weatherImageView)
        self.contentView.addSubview(dateLabel)
        
        self.contentView.addSubview(happinessImageView)
        self.contentView.addSubview(categoryImageView1)
        self.contentView.addSubview(categoryImageView2)
        
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(slideShow)
    }
    
    
    private func setConstraints() {
        cellBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            make.bottom.equalTo(slideShow.snp.bottom).offset(40)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.top.left.equalTo(cellBackgroundView).inset(15)
            make.size.equalTo(38)
        }
        
        profileNickNameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(10)
            make.top.equalTo(cellBackgroundView).inset(17)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(profileNickNameLabel.snp.bottom)
            make.left.equalTo(profileNickNameLabel)
        }
        
        heartButton.snp.makeConstraints { make in
            make.right.equalTo(cellBackgroundView).inset(15)
            make.top.equalTo(profileNickNameLabel)
        }
        
        weatherImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(timeLabel.snp.bottom).offset(14)
            make.width.height.equalTo(32)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(weatherImageView.snp.bottom).offset(10)
        }
        
        categoryImageView1.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.top.equalTo(dateLabel.snp.bottom).offset(20)
            make.left.equalTo(happinessImageView.snp.right).offset(8)
            make.right.equalTo(categoryImageView2.snp.left).offset(-8)
            make.centerX.equalToSuperview()
        }
        
        happinessImageView.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.top.equalTo(categoryImageView1)
        }
        
        categoryImageView2.snp.makeConstraints { make in
            make.height.width.equalTo(45)
            make.top.equalTo(categoryImageView1)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryImageView1.snp.bottom).offset(24)
            make.left.right.equalTo(cellBackgroundView).inset(15)
        }

        slideShow.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(18) // Adjust the spacing as needed
            make.left.right.equalTo(cellBackgroundView).inset(15) // width 설정 완료
            make.height.equalTo(200)
        }

    }
}

/*
 // MARK: 선택되었을 때 메서드
 func select() {
     photoView.alpha = 0.7
     selectView.isHidden = false
 }
 
 // MARK: 선택 취소했을 때 메서드
 func deselect() {
     photoView.alpha = 1
     selectView.isHidden = true
 }
 */

