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
    
    private let selectedScale: CGFloat = 1.1 // Adjust the scale factor as needed

    
    // MARK: - UI Components
    private lazy var categoryImageView = UIImageView().then {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFit
        //        $0.isEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        //        print("cell enabled: \(categoryButton.isEnabled)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
//MARK: -  Set layout
extension CategoryCell {
    private func setLayout() {
        self.contentView.addSubview(categoryImageView)
        
        categoryImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
    }
    
    func setImage(category: String) {
        let image = UIImage(named: category)
        categoryImageView.image = image
    }
}

extension CategoryCell {
//    func configure(category: String, isSelected: Bool) {
//        // Configure the cell with the category data
//        setImage(category: category)
//        // You can also update other cell elements based on the selected state if needed
//    }
    
    override var isSelected: Bool {
        didSet {
            // Adjust the appearance of the cell when its selection state changes
            if isSelected {
                // Increase the cell size and add a shadow
                categoryImageView.transform = CGAffineTransform(scaleX: selectedScale, y: selectedScale)
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 1
                layer.shadowOffset = CGSize(width: 0, height: 6) //3
                layer.shadowRadius = 5
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
