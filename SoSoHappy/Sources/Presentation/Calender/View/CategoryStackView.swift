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
    var imageSize: CGFloat
    private var images: [String] = []
    private lazy var stackView = UIStackView(axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 8)
    
    init(imageSize: CGFloat = 30) {
        self.imageSize = imageSize
        super.init(frame: .zero)
        setupStackView()
        addImageViews(images: images)
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
    func addImageViews(images: [String]) {
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

//// MARK: Setting할 수 있는 functions
//extension CategoryStackView {
//    func setContents(feed: Feed) {
//        images = feed.categories
//        addImageViews(images: images)
//    }
//}


