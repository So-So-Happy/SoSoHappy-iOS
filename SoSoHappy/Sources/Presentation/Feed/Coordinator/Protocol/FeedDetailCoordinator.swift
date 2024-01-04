//
//  DetailFeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/27.
//

import UIKit

protocol FeedDetailCoordinatorInterface: Coordinator {
    func dismiss()
    func showOwner(ownerNickName: String)
    func goBackToRoot()
}

enum FeedNavigationSource {
    case feedViewController
    case feedDetailViewController
    case ownerFeedViewController
}

final class FeedDetailCoordinator: FeedDetailCoordinatorInterface {
    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var feedReactor: FeedReactor
    var navigatingFrom: FeedNavigationSource
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController(), feedReactor: FeedReactor, navigatingFrom: FeedNavigationSource) {
        self.navigationController = navigationController
        self.feedReactor = feedReactor
        self.navigatingFrom = navigatingFrom
    }
    
    func start() {
        let feedDetailVC = FeedDetailViewController(reactor: feedReactor, coordinator: self)
        navigationController.pushViewController(feedDetailVC, animated: true)
    }
}

extension FeedDetailCoordinator {
    func dismiss() {
        parentCoordinator?.childDidFinish(self, parent: parentCoordinator)
        navigationController.popViewController(animated: true)
    }
    
    func showOwner(ownerNickName: String) {
        switch navigatingFrom {
        case .feedViewController:
            let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController, ownerNickName: ownerNickName, navigatingFrom: .feedDetailViewController)
            
            ownerFeedCoordinator.parentCoordinator = self
            ownerFeedCoordinator.finishDelegate = finishDelegate
            self.childCoordinators.append(ownerFeedCoordinator)
        
            ownerFeedCoordinator.start()
        
        default: break
        }
    }
    
    func goBackToRoot() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        navigationController.popToRootViewController(animated: true)
    }
}
