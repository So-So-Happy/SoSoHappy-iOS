//
//  OwnerFeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/27.
//

import UIKit

protocol OwnerFeedCoordinatorInterface: Coordinator {
    func showDetails(feed: FeedTemp)
}

final class OwnerFeedCoordinator: OwnerFeedCoordinatorInterface {
    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var ownerNickName: String
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController(), ownerNickName: String ) {
        self.navigationController = navigationController
        self.ownerNickName = ownerNickName
    }
    
    func start() {
        print("OwnerFeedCoordinator START")
        let ownerFeedViewReactor = OwnerFeedViewReactor(ownerNickName: self.ownerNickName)
        let ownerFeedVC = OwnerFeedViewController(reactor: ownerFeedViewReactor, coordinator: self)
        navigationController.pushViewController(ownerFeedVC, animated: true)
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}


extension OwnerFeedCoordinator {
    func showDetails(feed: FeedTemp) {
        print("OwnerFeedCoordinator didSelectCell 메서드 실행")
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController, feed: feed, navigatingFrom: .ownerFeedViewController)
        self.childCoordinators.append(feedDetailCoordinator)
        feedDetailCoordinator.start()
    }
}
