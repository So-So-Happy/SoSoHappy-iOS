//
//  OwnerFeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/27.
//

import UIKit

final class OwnerFeedCoordinator: Coordinator {
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
        let ownerFeedVC = OwnerFeedViewController(reactor: ownerFeedViewReactor)
        ownerFeedVC.delegate = self
        navigationController.pushViewController(ownerFeedVC, animated: true)
    }
}


extension OwnerFeedCoordinator: OwnerFeedViewControllerDelegate {
    func showDetail(feed: FeedTemp) {
        print("OwnerFeedCoordinator didSelectCell 메서드 실행")
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController, feedData: feed)
        feedDetailCoordinator.navigationSource = .ownerFeedViewController
        feedDetailCoordinator.start()
        self.childCoordinators.append(feedDetailCoordinator)
    }
}
