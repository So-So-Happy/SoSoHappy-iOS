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
    
    private let selectedScale: CGFloat = 1.2 // Adjust the scale factor as needed

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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        categoryImageView.transform = CGAffineTransform.identity
        self.categoryImageView.alpha = 0.5
    }
}
// MARK: -  Set layout
extension CategoryCell {
    private func setLayout() {
        self.contentView.addSubview(categoryImageView)
        
        categoryImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(3) // 2
        }
    }
    
    func setImage(category: String) {
        let image = UIImage(named: category)
        categoryImageView.image = image
    }
}
// MARK: Select됨에 따라 크기 변경과 그림자 설정
extension CategoryCell {
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                // Adjust the appearance of the cell when its selection state changes
                if self.isSelected {
                    // Increase the cell size and add a shadow
                    self.categoryImageView.transform = CGAffineTransform(scaleX: self.selectedScale, y: self.selectedScale)
                    self.categoryImageView.alpha = 1
                } else {
                    // Reset the cell's appearance
                    self.categoryImageView.transform = CGAffineTransform.identity
                    self.categoryImageView.alpha = 0.5
                }
            }
        }
    }
}
