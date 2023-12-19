//
//  AwardsView.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/28.
//

import UIKit
import SnapKit
import Then

final class AwardsView: UIView {
    
    // MARK: - Properties
    
    private lazy var awardsLabel = UILabel().then {
        $0.text = "이번 달 베스트 소확행 어워즈 🏆"
        $0.font = UIFont.customFont(size: 16, weight: .semibold)
    }
    
    private lazy var awardsImageView = UIImageView(image: UIImage(named: "awards"))
    private lazy var image1 = UIImageView(image: UIImage(named: "food"))
    private lazy var image2 = UIImageView(image: UIImage(named: "dessert"))
    private lazy var image3 = UIImageView(image: UIImage(named: "trip"))
    private lazy var emptyView = ExceptionView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout & Attribute
private extension AwardsView {
    
    //  MARK: 뷰 구성요소 세팅
    private func setUpView() {
        addSubview(awardsLabel)
        addSubview(awardsImageView)
        addSubviews(image1, image2, image3)
    }
    
    //  MARK: 뷰 구성요소 제약 설정
    private func setConstraints() {
        addSubview(awardsLabel)
        addSubview(awardsImageView)
        addSubviews(image1, image2, image3)
        
        awardsLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview()
        }
        
        awardsImageView.snp.makeConstraints {
            $0.height.equalTo(100)
            $0.top.equalTo(awardsLabel.snp.bottom).offset(85)
            $0.width.equalToSuperview().offset(-60)
            $0.centerX.equalToSuperview()
        }
        
        image1.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.centerX.equalToSuperview().offset(-110)
            $0.bottom.equalTo(awardsImageView.snp.top).offset(35)
        }
        
        image2.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(awardsImageView.snp.top)
            
        }
        
        image3.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.centerX.equalToSuperview().offset(110)
            $0.bottom.equalTo(awardsImageView.snp.top).offset(61)
        }
    }
    
    func setEmptyView() {
        addSubview(emptyView)
        emptyView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AwardsView {
    func setAwardsCategories(categories: [String]) {
        if categories.count == 0 { return }

        switch categories.count {
        case 1:
            self.image2.image = UIImage(named: "\(categories[0])")
            self.image1.isHidden = true
            self.image2.isHidden = false
            self.image3.isHidden = true
        case 2:
            self.image2.image = UIImage(named: "\(categories[0])")
            self.image1.image = UIImage(named: "\(categories[1])")
            self.image1.isHidden = true
            self.image2.isHidden = true
            self.image3.isHidden = false
        default:
            self.image2.image = UIImage(named: "\(categories[0])")
            self.image1.image = UIImage(named: "\(categories[1])")
            self.image3.image = UIImage(named: "\(categories[2])")
            self.image1.isHidden = false
            self.image2.isHidden = false
            self.image3.isHidden = false
        }
    }
}


final class PrivateTop3View: UIView {
    // MARK: - UI Components
    lazy var cellBackgroundView = UIView().then {
//        $0.backgroundColor = UIColor(named: "CellColor")
        $0.backgroundColor = UIColor(named: "CellColor")
        $0.layer.cornerRadius = 16
    }
    
    // 날씨 이미지
    private lazy var emptyHappyImage = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "happy1")
    }
    
    // 내용 텍스트
    private lazy var contentsLabel = UILabel().then {
        $0.text = "아직 베스트 소확행 순위가 공개되지 않았어요!🤫"
        $0.font = UIFont.customFont(size: 17, weight: .medium)
        $0.numberOfLines = 4
        $0.sizeToFit()
        $0.textColor = UIColor(named: "GrayTextColor")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    private func setUp() {
        setCellAttributes()
        setConstraints()
    }
    
    private func setCellAttributes() {
        backgroundColor = .clear
    }

    private func setConstraints() {
        
        addSubview(cellBackgroundView)
        cellBackgroundView.addSubviews(emptyHappyImage, contentsLabel)
        
        cellBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }
         
        contentsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(30)
        }
        
        emptyHappyImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(contentsLabel).inset(30)
            $0.bottom.equalToSuperview().inset(30)
            $0.width.height.equalTo(30)
        }
        
    }
}
