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
    // Create a PublishSubject to emit tap events
    // Subject : Observable이자 Observer
    // Hot Observable :  구독한 시점부터 방출되는 이벤트만 받을 수 있고, 내가 구독하기 전에 이미 방출되어버린 이벤트는 받을 수 없음!!
    
    // 값을 동적으로 스트림에 추가할 수 있음
    //PublishSubject - 어떤 항목을 방출할 것인에 대한 정의가 없음
    let tapSubject = PublishSubject<Void>()
    
    // Expose an Observable property for tap events
    // Observable을 사용하여 tapSubject를 노출하는 것이 RxSwift 및 ReactorKit의 일반적인 관용적인 사용법에 더 부합
    var tapObservable: Observable<Void> {
        return tapSubject.asObservable()
    }
    
    private lazy var kingfisherSources: [KingfisherSource] = []
    private lazy var imageSources: [ImageSource] = []
    
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
            return KingfisherSource(urlString: "\(Bundle.main.baseURL)\(Bundle.main.findFeedImage)/\(id)")!
        }
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
