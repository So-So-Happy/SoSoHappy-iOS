//
//  ImageSlideView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/13.
//

import UIKit
import ImageSlideshow

final class ImageSlideView: UIView {
    private lazy var imageResources = [
        // 로컬에 이미지가 있을경우
        ImageSource(image: UIImage(named: "bagel")!),
        ImageSource(image: UIImage(named: "churros")!),
        ImageSource(image: UIImage(named: "cafe")!)
        
        
        //  KingfisherSource(urlString: "https://images.unsplash.com/photo-1601408594761-e94d31023591?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60", placeholder: UIImage(systemName: "photo")?.withTintColor(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1), renderingMode: .alwaysOriginal), options: .none)!,
    ]
    
    var slideShowView = ImageSlideshow().then {
        $0.isUserInteractionEnabled = true
        $0.contentScaleMode = .scaleAspectFill // default value = scaleAspectFill
        $0.layer.cornerRadius = 10
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageSlideView()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageSlideView()
    }
    
    private func setupImageSlideView() {
        addSubview(slideShowView)
        slideShowView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        addImageViews(self.imageResources)
    }
}

extension ImageSlideView {
    func addImageViews(_ imageResources: [ImageSource]) {
        self.slideShowView.setImageInputs(imageResources)
    }
}
