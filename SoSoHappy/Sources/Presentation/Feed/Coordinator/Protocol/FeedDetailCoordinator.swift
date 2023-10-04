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


protocol FeedDetailCoordinatorDelegate: AnyObject {
    func feedDetailCoordinator(_ coordinator: FeedDetailCoordinator, didToggleHeartButton newState: Bool)
}

final class FeedDetailCoordinator: Coordinator {
    weak var delegate: FeedDetailCoordinatorDelegate?
    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var feedData: FeedTemp
    var navigatingFrom: FeedNavigationSource
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController(), feedData: FeedTemp, navigatingFrom: FeedNavigationSource ) {
        self.navigationController = navigationController
        self.feedData = feedData // Initialize the feedData property
        self.navigatingFrom = navigatingFrom
    }
    
    func start() {
        print("FeedDetailCoordinator START")
//        print("-----------feedData: \(feedData)") // feedTemp type
        let feedReactor = FeedReactor(feed: feedData)
        let feedDetailVC = FeedDetailViewController(reactor: feedReactor)
        feedDetailVC.delegate = self
        navigationController.pushViewController(feedDetailVC, animated: true)
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension FeedDetailCoordinator: FeedDetailViewControllerDelegate {
    func showOwner(ownerNickName: String) {
        print("FeedDetailViewController에서 프로필 이미지 선택함")
        switch navigatingFrom {
        case .feedViewController:
            let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController, ownerNickName: ownerNickName)
            self.childCoordinators.append(ownerFeedCoordinator)
            ownerFeedCoordinator.start()
        default: break
        }
    }
}
