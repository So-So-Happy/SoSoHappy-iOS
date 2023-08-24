//
//  CategoryStackView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/10.
//


import UIKit
import SnapKit


final class CategoryStackView: UIView {
    private var images: [String] = ["sohappy", "coffe", "donut"]
    private lazy var stackView = UIStackView(axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 8)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
        addImageViews(images: images)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
        addImageViews(images: images)
    }
    
    private func setupStackView() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.edges.equalToSuperview()
        }
    }
}

extension CategoryStackView {
    func addImageViews(images: [String]) {
        let images = images.map { imageName in
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints {
                $0.width.height.equalTo(30)
            }
            return imageView
        }
        
        self.stackView.addArrangedSubviews(images)
    }
}
