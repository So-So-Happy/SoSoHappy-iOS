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
// MARK:
protocol FeedCoordinatorInterface: Coordinator {
    func showdDetails(feed: FeedTemp) // feed 넘겨주기만 하면 됨 (따로 서버 통신 필요 없음)
    func showOwner(ownerNickName: String) // 조회대상 닉네임이 필요 ('특정 유저 피드 조회'는 서버통신 필요)
}

final class FeedCoordinator: FeedCoordinatorInterface {
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
        let feedVC = FeedViewController(reactor: feedReactor, coordinator: self)
        navigationController.pushViewController(feedVC, animated: true)
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension FeedCoordinator {
    func showdDetails(feed: FeedTemp) {
        print("1. cell 선택함")
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController, feed: feed, navigatingFrom: .feedViewController)
        self.childCoordinators.append(feedDetailCoordinator)
        feedDetailCoordinator.start()
    }
    
    func showOwner(ownerNickName: String) {
        print("2. 프로필 이미지 선택")
        print("ownerNickName : \(ownerNickName)")
        let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController, ownerNickName: ownerNickName)
        self.childCoordinators.append(ownerFeedCoordinator)
        ownerFeedCoordinator.start()
    }
}




