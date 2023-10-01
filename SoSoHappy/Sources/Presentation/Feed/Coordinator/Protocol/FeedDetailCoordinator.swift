//
//  DetailFeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/27.
//

import UIKit

enum FeedNavigationSource {
    case feedViewController
    case ownerFeedViewController
}


final class FeedDetailCoordinator: Coordinator {
    var type: CoordinatorType { .feed }
    var navigationSource: FeedNavigationSource = .feedViewController
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var feedData: FeedTemp
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController(), feedData: FeedTemp) {
        self.navigationController = navigationController
        self.feedData = feedData // Initialize the feedData property
    }
    
    func start() {
        print("FeedDetailCoordinator START")
        print("-----------feedData: \(feedData)") // feedTemp type
        let feedReactor = FeedReactor(feed: feedData)
        let feedDetailVC = FeedDetailViewController(reactor: feedReactor)
        feedDetailVC.delegate = self
        navigationController.pushViewController(feedDetailVC, animated: true)
    }
}

extension FeedDetailCoordinator: FeedDetailViewControllerDelegate {
    func showOwner(ownerNickName: String) {
        print("FeedDetailViewController에서 프로필 이미지 선택함")
        switch navigationSource {
        case .feedViewController:
            let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController, ownerNickName: ownerNickName)
            ownerFeedCoordinator.start()
            self.childCoordinators.append(ownerFeedCoordinator)
        default: break
        }
    }
}
