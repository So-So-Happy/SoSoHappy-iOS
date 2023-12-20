//
//  EmptyPreviewView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/12/17.
//

import UIKit

final class EmptyPreviewView: UIView {
    
    // MARK: - UI Components
    lazy var cellBackgroundView = UIView().then {
//        $0.backgroundColor = UIColor(named: "CellColor")
        $0.backgroundColor = UIColor(named: "CellColor")
        $0.layer.cornerRadius = 16
    }
    
    // 날씨 이미지
    private lazy var emptyHappyImage = UIImageView().then {
        $0.layer.masksToBounds = true
        $0.image = UIImage(named: "emptyImage")
        $0.contentMode = .scaleAspectFit
    }
    
    // 내용 텍스트
    private lazy var contentsLabel = UILabel().then {
        $0.text = "이날 작성된 소소해피가 없어요!"
        $0.font = UIFont.customFont(size: 15, weight: .medium)
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
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16))
            $0.bottom.equalTo(contentsLabel.snp.bottom).offset(15)
        }
         
        emptyHappyImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(80)
        }
        
        contentsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(emptyHappyImage.snp.bottom).offset(1.5)
        }
        
    }
   
}
