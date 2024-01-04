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

protocol FeedCoordinatorDelegate: AnyObject {
    func showProcessClearedToastMessage()
}

// MARK: - FeedCoordinator
final class FeedCoordinator: FeedCoordinatorInterface {
    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    weak var delegate: FeedCoordinatorDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        let feedViewReactor = FeedViewReactor(
            feedRepository: FeedRepository(),
            userRepository: UserRepository())
        
        let feedVC = FeedViewController(reactor: feedViewReactor, coordinator: self)
        self.delegate = feedVC
        navigationController.pushViewController(feedVC, animated: true)
    }
}

extension FeedCoordinator {
    func showdDetails(feedReactor: FeedReactor) {
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController, feedReactor: feedReactor, navigatingFrom: .feedViewController)
        
        feedDetailCoordinator.parentCoordinator = self
        feedDetailCoordinator.finishDelegate = self
        self.childCoordinators.append(feedDetailCoordinator)
        
        feedDetailCoordinator.start()
    }
    
    func showOwner(ownerNickName: String) {
        let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController, ownerNickName: ownerNickName, navigatingFrom: .feedViewController)
        
        ownerFeedCoordinator.parentCoordinator = self
        ownerFeedCoordinator.finishDelegate = self
        self.childCoordinators.append(ownerFeedCoordinator)
        
        ownerFeedCoordinator.start()
    }
}

extension FeedCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators.removeAll()
        delegate?.showProcessClearedToastMessage()
    }
}
