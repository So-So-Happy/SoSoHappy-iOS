//
//  CategoryCell.swift
//  SoSoHappy
//
//  Created by Sue on 10/10/23.
//

import UIKit
import Then
import SnapKit

class CategoryCell: UICollectionViewCell {
    // MARK: - Properties
    static var cellIdentifier: String {
        return String(describing: Self.self)
    }
    
    private let selectedScale: CGFloat = 1.2
    
    // MARK: - UI Components
    private lazy var categoryImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
        $0.alpha = 0.5
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        
//        // 선택 여부에 따라 알파 값을 설정합니다.
//        if isSelected {
//            // 선택된 경우 크기를 키우고 알파 값을 1로 설정합니다.
//            self.categoryImageView.transform = CGAffineTransform(scaleX: self.selectedScale, y: self.selectedScale)
//            self.categoryImageView.alpha = 1
//        } else {
//            // 선택되지 않은 경우 기본 알파 값을 0.5로 설정합니다.
//            self.categoryImageView.transform = CGAffineTransform.identity
//            self.categoryImageView.alpha = 0.5
//        }
//    }

}
// MARK: -  Set layout
extension CategoryCell {
    private func setLayout() {
        self.contentView.addSubview(categoryImageView)
        
        categoryImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3)
        }
    }
    
    func setImage(category: String) {
        let image = UIImage(named: category)
        categoryImageView.image = image
    }
}

// MARK: - Select됨에 따라 크기 변경과 그림자 설정
extension CategoryCell {
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                if self.isSelected {
                    self.categoryImageView.transform = CGAffineTransform(scaleX: self.selectedScale, y: self.selectedScale)
                    self.categoryImageView.alpha = 1
                } else {
                    self.categoryImageView.transform = CGAffineTransform.identity
                    self.categoryImageView.alpha = 0.5
                }
            }
        }
    }
}
