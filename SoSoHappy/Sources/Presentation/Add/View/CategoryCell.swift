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
        
        layer.shadowColor = nil
        layer.shadowOpacity = 0
        layer.shadowOffset = .zero
        layer.shadowRadius = 0
    }
}
//MARK: -  Set layout
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
            // Adjust the appearance of the cell when its selection state changes
            if isSelected {
                // Increase the cell size and add a shadow
                categoryImageView.transform = CGAffineTransform(scaleX: selectedScale, y: selectedScale)
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.7
                layer.shadowOffset = CGSize(width: 8, height: 10) //0, 3
                layer.shadowRadius = 5 // 5
            } else {
                // Reset the cell's appearance
                categoryImageView.transform = CGAffineTransform.identity
                
                layer.shadowColor = nil
                layer.shadowOpacity = 0
                layer.shadowOffset = .zero
                layer.shadowRadius = 0
            }
        }
    }
}
