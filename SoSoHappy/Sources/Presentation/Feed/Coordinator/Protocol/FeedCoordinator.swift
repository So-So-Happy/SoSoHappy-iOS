//
//  FeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit

// MARK: - FeedCoordinatorInterface
protocol FeedCoordinatorInterface: Coordinator {
    func showdDetails(feedReactor: FeedReactor)
    func showOwner(ownerNickName: String)
}

// MARK: - FeedCoordinator
final class FeedCoordinator: FeedCoordinatorInterface {
    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    // MARK: Tab Coordinator에서 한번 딱 실행됨
    func start() {
        let feedViewReactor = FeedViewReactor(
            feedRepository: FeedRepository(),
            userRepository: UserRepository())
        
        let feedVC = FeedViewController(reactor: feedViewReactor, coordinator: self)
        navigationController.pushViewController(feedVC, animated: true)
//        print("🗂️ START - Feed Coordinator -  childCoordinator count : \(childCoordinators.count), navigationcontroller count : \(navigationController.viewControllers.count)")
    }
}

extension FeedCoordinator {
    func showdDetails(feedReactor: FeedReactor) {
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController, feedReactor: feedReactor, navigatingFrom: .feedViewController)
        feedDetailCoordinator.parentCoordinator = self
//        feedDetailCoordinator.finishDelegate = self
        self.childCoordinators.append(feedDetailCoordinator)
//        print("🗂️ (detail) Feed Coordinator childCoordinator count : \(childCoordinators.count), controller count : \(navigationController.viewControllers.count)")
        feedDetailCoordinator.start()
    }
    
    func showOwner(ownerNickName: String) {
        let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController, ownerNickName: ownerNickName, navigatingFrom: .feedViewController)
        ownerFeedCoordinator.parentCoordinator = self
        self.childCoordinators.append(ownerFeedCoordinator)
//        print("🗂️ (owner) Feed Coordinator childCoordinator count : \(childCoordinators.count), controller count : \(navigationController.viewControllers.count)")
        ownerFeedCoordinator.start()
    }
}
