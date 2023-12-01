//
//  MyFeedDetailViewController.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/11/04.
//

import UIKit
import SnapKit
import ImageSlideshow
import Then
import ReactorKit
import RxGesture

/*
 리팩토링
 1. heartbutton throttle, debouce 적용, 날씨 bacgkround 이미지 적용

 */

final class MyFeedDetailViewController: BaseDetailViewController {
    
    // MARK: - UI Components

    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    init(reactor: MyFeedDetailViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setFeed(feed: FeedType) {
        super.setFeed(feed: feed)
    }
}


//MARK: - bind func
extension MyFeedDetailViewController: View {
    func bind(reactor: MyFeedDetailViewReactor) {
        
        self.rx.viewWillAppear
            .map { Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map{ $0.feed }
            .subscribe { [weak self] feed in
                guard let `self` = self else { return }
                guard let feed = feed else { return }
                self.setFeed(feed: feed)
            }.disposed(by: disposeBag)
        
        
//        self.rx.viewWillAppear
//            .map { return Reactor.Action.fetchFeed }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//        
//        imageSlideView.tapObservable
//            .subscribe(onNext: { [weak self] in
//                guard let `self` = self else { return }
//                self.imageSlideView.slideShowView.presentFullScreenController(from: self)
//            })
//            .disposed(by: disposeBag)
//    
//        reactor.state
//            .map { $0.userFeed }
//            .bind { [weak self] userFeed in
//                guard let `self` = self else { return }
//                print("1. FeedDetailViewController reactor.state USERFEED")
//                setFeed(feed: userFeed)
//            }
//            .disposed(by: disposeBag)
        
       
    }
}

