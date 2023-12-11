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
//        print("OwnerFeedCoordinator START")
        let ownerFeedViewReactor = OwnerFeedViewReactor(ownerNickName: self.ownerNickName, feedRepository: FeedRepository(), userRepository: UserRepository())
        let ownerFeedVC = OwnerFeedViewController(reactor: ownerFeedViewReactor, coordinator: self)
        navigationController.pushViewController(ownerFeedVC, animated: true)
//        print("🗂️ START owner navigationcontroller count : \(navigationController.viewControllers.count)") 
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}


extension OwnerFeedCoordinator {
    func dismiss() {
//        print("OwnerFeedCoorindator dismissed")
        parentCoordinator?.childDidFinish(self, parent: parentCoordinator)
        navigationController.popViewController(animated: true)
//        print("🗂️OwnerFeedCoorindator dismissed - controller count : \(navigationController.viewControllers.count)")
    }
    
    func showDetails(feedReactor: FeedReactor) {
//        print("OwnerFeedCoordinator didSelectCell 메서드 실행")
//        print("cell 선택함")
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController, feedReactor: feedReactor, navigatingFrom: .ownerFeedViewController)
        feedDetailCoordinator.parentCoordinator = self
        
        self.childCoordinators.append(feedDetailCoordinator)
//        print("🗂️ (OWNER) Owner Feed coordinator childCoordinator count : \(childCoordinators.count), controller count : \(navigationController.viewControllers.count)")
        feedDetailCoordinator.start()
    }
}
