//
//  OwnerFeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/27.
//

import UIKit

protocol OwnerFeedCoordinatorInterface: Coordinator {
    func dismiss()
    func showDetails(feedReactor: FeedReactor)
    func goBackToRoot()
}

final class OwnerFeedCoordinator: OwnerFeedCoordinatorInterface {
    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var ownerNickName: String
    var navigatingFrom: FeedNavigationSource
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController(), ownerNickName: String, navigatingFrom: FeedNavigationSource) {
        self.navigationController = navigationController
        self.ownerNickName = ownerNickName
        self.navigatingFrom = navigatingFrom
    }
    
    func start() {
        let ownerFeedViewReactor = OwnerFeedViewReactor(ownerNickName: self.ownerNickName, feedRepository: FeedRepository(), userRepository: UserRepository())
        let ownerFeedVC = OwnerFeedViewController(reactor: ownerFeedViewReactor, coordinator: self)
        navigationController.pushViewController(ownerFeedVC, animated: true)
//        print("🗂️ START - Owner Coordinator -  childCoordinator count : \(childCoordinators.count), navigationcontroller count : \(navigationController.viewControllers.count)")
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}


extension OwnerFeedCoordinator {
    func dismiss() {
        parentCoordinator?.childDidFinish(self, parent: parentCoordinator)
        navigationController.popViewController(animated: true)
//        print("🗂️ dismissed - OwnerFeed Coordinator - childCoordinator count : \(childCoordinators.count), navigationcontroller count : \(navigationController.viewControllers.count)")
    }
    
    func showDetails(feedReactor: FeedReactor) {
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController, feedReactor: feedReactor, navigatingFrom: .ownerFeedViewController)
        feedDetailCoordinator.parentCoordinator = self
        self.childCoordinators.append(feedDetailCoordinator)
//        print("🗂️ (Detail) Owner Feed coordinator childCoordinator count : \(childCoordinators.count), controller count : \(navigationController.viewControllers.count)")
        feedDetailCoordinator.start()
    }
    
    // MARK: FeedViewController로 돌아가서 showToastMessage
    func goBackToRoot() {
    }
}
