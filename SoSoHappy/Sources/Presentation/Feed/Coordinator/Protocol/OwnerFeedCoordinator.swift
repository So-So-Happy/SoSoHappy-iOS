//
//  OwnerFeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/27.
//

import UIKit

final class OwnerFeedCoordinator: Coordinator {
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("OwnerFeedCoordinator START")
        let ownerFeedViewReactor = OwnerFeedViewReactor()
        let ownerFeedVC = OwnerFeedViewController(reactor: ownerFeedViewReactor)
        ownerFeedVC.delegate = self
        navigationController.pushViewController(ownerFeedVC, animated: true)
    }
}


extension OwnerFeedCoordinator: OwnerFeedViewControllerDelegate {
    func didSelectCell() {
        print("OwnerFeedCoordinator didSelectCell 메서드 실행")
//        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController)
//        feedDetailCoordinator.navigationSource = .ownerFeedViewController
        
        let feedDetailCoordinator = FeedCoordinatorFactory.makeFeedDetailCoordinator(navigationController: self.navigationController, navigationSource: .ownerFeedViewController)
        
        feedDetailCoordinator.start()
        self.childCoordinators.append(feedDetailCoordinator)
    }
}
