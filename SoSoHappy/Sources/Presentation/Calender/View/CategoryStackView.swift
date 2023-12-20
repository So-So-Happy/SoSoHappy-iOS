//
//  CategoryStackView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/10.
//

import UIKit
import SnapKit

// MARK: - CategoryStackView에 이미지가 계속 쌓이는 문제 해결 필요

final class CategoryStackView: UIView {
    private var images: [String] = []
    lazy var stackView = UIStackView(axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 8)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStackView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    func addImageViews(images: [String], imageSize: CGFloat = 30) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let images = images.map { imageName in
            let imageView = UIImageView(image: UIImage(named: imageName))
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints {
                $0.width.height.equalTo(imageSize) // 30
            }
            return imageView
        }
        self.stackView.addArrangedSubviews(images)
    }
}
