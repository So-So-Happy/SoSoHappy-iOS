//
//  DetailFeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/27.
//

import UIKit

protocol FeedDetailCoordinatorInterface: Coordinator {
    func showOwner(ownerNickName: String)
}

enum FeedNavigationSource {
    case feedViewController
    case ownerFeedViewController
}

final class FeedDetailCoordinator: FeedDetailCoordinatorInterface {
    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var userFeed: UserFeed
    var navigatingFrom: FeedNavigationSource
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController(), userFeed: UserFeed, navigatingFrom: FeedNavigationSource ) {
        self.navigationController = navigationController
        self.userFeed = userFeed
        self.navigatingFrom = navigatingFrom
    }
    
    func start() {
        print("FeedDetailCoordinator START")
        let feedReactor = FeedReactor(userFeed: userFeed, feedRepository: FeedRepository(), userRepository: UserRepository())
        let feedDetailVC = FeedDetailViewController(reactor: feedReactor, coordinator: self)

        navigationController.pushViewController(feedDetailVC, animated: true)
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension FeedDetailCoordinator {
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
