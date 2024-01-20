//
//  ImageSlideView.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/13.
//

import UIKit
import ImageSlideshow
import RxSwift
import RxCocoa
import Kingfisher

final class ImageSlideView: UIView {
    let tapSubject = PublishSubject<Void>()
    
    var tapObservable: Observable<Void> {
        return tapSubject.asObservable()
    }
    
    private lazy var kingfisherSources: [KingfisherSource] = []
    private lazy var imageSources: [ImageSource] = []
    
    struct MyIndicator: Indicator {
        let view: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        func startAnimatingView() { print("start"); view.isHidden = false }
        func stopAnimatingView() { view.isHidden = true }
        
        init() {
            view.backgroundColor = UIColor.blue
        }
    }
            
    var slideShowView = ImageSlideshow().then {
        $0.isUserInteractionEnabled = true
        $0.contentScaleMode = .scaleAspectFill
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
        addImageViews(self.kingfisherSources)
        setupTapGesture()
    }
    
    // Step 1: Define a tap gesture and add it to the slideShowView
      private func setupTapGesture() {
          let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
          slideShowView.addGestureRecognizer(tapGesture)
      }
      
      // Step 1: Handle the tap gesture and emit a tap event
      @objc private func handleTapGesture() {
          tapSubject.onNext(())
          // .onNext : 내가 원할 때마다 항목을 발행 할 수 있음!!!
          // Subject만 onNext 사용 가능
      }
}

extension ImageSlideView {
    func addImageViews(_ imageResources: [KingfisherSource]) {
        self.slideShowView.setImageInputs(imageResources)
    }
    
    func setImages(ids: [Int]) {
        kingfisherSources = []
        kingfisherSources = ids.map { id in
            let imageURLString = "\(Bundle.main.baseURL)\(Bundle.main.findFeedImage)/\(id)"
            let placeholderColor = UIColor(named: "skeleton2") // Placeholder로 사용할 색상
            let placeholderImage = UIImage(color: placeholderColor ?? UIColor.gray )
//            let placeholderImage = UIImage(named: "happy1")
            return KingfisherSource(
                urlString: imageURLString,
                placeholder: placeholderImage,
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ]
            )!
        }
        
        self.slideShowView.activityIndicator = DefaultActivityIndicator(style: .large, color: nil)
        self.slideShowView.setImageInputs(kingfisherSources)
    }
}

// MARK: Setting할 수 있는 functions
extension ImageSlideView {
//    func setContents(feed: FeedType) {
//        imageResources = []
//        feed.imageList.forEach { img in
//            imageResources.append(ImageSource(image: img))
//        }
//        self.slideShowView.setImageInputs(imageResources)
//    }
//
    // MARK: 나중에 리팩토링해줘야 함 (일단 만들어 놓음)
    func setContentsWithImageList(imageList: [UIImage]) {
        imageSources = []
        imageList.forEach { img in
            imageSources.append(ImageSource(image: img))
        }
        self.slideShowView.setImageInputs(imageSources)
    }
    
}
