//
//  FeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit

/*
 궁금한 점
 1. FeedCoordinatorInterface 용도
 2. FeedCoordinator type을 .feed로 해야하는게 맞지?
 */

/*
 1. 중복되는 코드 리팩토링 - didSelectCell 자체가 많이 중복됨
 2. 데이터 넘겨주는 거 작성하기 (Reactor에 API request 해야할 때 보내야하는것들이 잘 챙겨져 있는지 확인하고 작성하기)
 */

public protocol FeedCoordinatorInterface {
    func dismiss()
    func finished()
}

final class FeedCoordinator: Coordinator {
    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    // 실행했을 때 나오는 화면
    func start() {
        let feedReactor = FeedViewReactor()
        let feedVC = FeedViewController(reactor: feedReactor)
        feedVC.delegate = self
        navigationController.pushViewController(feedVC, animated: true)
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension FeedCoordinator: FeedViewControllerDelegate {
    func showdDetails(feed: FeedTemp) {
        print("cell 선택함")
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController, feedData: feed, navigatingFrom: .feedViewController)
        self.childCoordinators.append(feedDetailCoordinator)
        feedDetailCoordinator.start()
    }
    
    func showOwner(ownerNickName: String) {
        print("프로필 이미지 선택")
        print("ownerNickName : \(ownerNickName)")
        let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController, ownerNickName: ownerNickName)
        self.childCoordinators.append(ownerFeedCoordinator)
        ownerFeedCoordinator.start()
    }
}




