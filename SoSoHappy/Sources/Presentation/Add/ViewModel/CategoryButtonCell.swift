//
//  CategoryButtonCell.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/13.
//

import UIKit
import SnapKit

class CategoryButtonCell: UICollectionViewCell {
    
    let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpButton() {
        button.backgroundColor = .clear
        button.contentMode = .scaleAspectFit
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(categoryButtonTapped(_:)), for: .touchUpInside)
        
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.top.bottom.right.left.equalToSuperview().inset(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
        }
    }
    
    func setImage(_ image: UIImage) {
        button.setImage(image, for: .normal)
    }
    
    @objc func categoryButtonTapped(_ sender: UIButton) {
        print("Cateogory Button is clicked? => \(sender.isSelected)")
        sender.isSelected.toggle()
    }
}
