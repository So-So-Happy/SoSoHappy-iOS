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
    
    // TODO: - 텅뷰 만들기
    private lazy var awardsLabel = UILabel().then {
        $0.text = "이번 달 베스트 소확행 어워즈 🏆"
        $0.font = UIFont.customFont(size: 16, weight: .semibold)
    }
    
    private lazy var awardsImageView = UIImageView(image: UIImage(named: "awards"))
    private lazy var image1 = UIImageView(image: UIImage(named: "food"))
    private lazy var image2 = UIImageView(image: UIImage(named: "dessert"))
    private lazy var image3 = UIImageView(image: UIImage(named: "trip"))
    private lazy var emptyView = FeedExceptionView()

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
        
        awardsLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview()
        }
        
        // FIXME: -
        awardsImageView.snp.makeConstraints {
            $0.height.equalTo(100) // height fix
            $0.top.equalTo(awardsLabel.snp.bottom).offset(85)
            //            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.width.equalToSuperview().offset(-60)
            $0.centerX.equalToSuperview()
        }
        
        image1.snp.makeConstraints {
            $0.width.height.equalTo(60)
            $0.centerX.equalToSuperview().offset(-110)
            $0.bottom.equalTo(awardsImageView.snp.top).offset(35)
            //            $0.centerX.equalTo(awardsImageView.snp.width).multipliedBy(3.0 / 1.0)
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
//        self.image1 = UIImageView(image: UIImage(named: "\(categories[1])"))
//        self.image2 = UIImageView(image: UIImage(named: "\(categories[0])"))
//        self.image3 = UIImageView(image: UIImage(named: "\(categories[2])"))
    }
}
