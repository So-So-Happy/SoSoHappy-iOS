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
    var feedReactor: FeedReactor
    var navigatingFrom: FeedNavigationSource
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController(), feedReactor: FeedReactor, navigatingFrom: FeedNavigationSource) {
        self.navigationController = navigationController
        self.feedReactor = feedReactor
        self.navigatingFrom = navigatingFrom
    }
    
    func start() {
        print("---- FeedDetailCoordinator START")
//        let feedReactor = FeedReactor(userFeed: userFeed, feedRepository: FeedRepository(), userRepository: UserRepository())
//        let feedDetailVC = FeedDetailViewController(reactor: feedReactor, coordinator: self)
        let feedDetailVC = FeedDetailViewController(reactor: feedReactor, coordinator: self)


        navigationController.pushViewController(feedDetailVC, animated: true)
//        print("🗂️ START detail navigationcontroller count : \(navigationController.viewControllers.count)")
    }
    
//    func finish() {
//        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
//    }
}

extension FeedDetailCoordinator {
    func dismiss() {
//        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
        parentCoordinator?.childDidFinish(self, parent: parentCoordinator)
        navigationController.popViewController(animated: true)
//        print("🗂️ dismissed - controller count : \(navigationController.viewControllers.count)")
    }
    
    func showOwner(ownerNickName: String) {
//        print("FeedDetailViewController에서 프로필 이미지 선택함")
        switch navigatingFrom {
        case .feedViewController:
            let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController, ownerNickName: ownerNickName)
            ownerFeedCoordinator.parentCoordinator = self
            self.childCoordinators.append(ownerFeedCoordinator)
//            print("🗂️ (DETAIL) Feed Detail Coordinator childCoordinator count : \(childCoordinators.count), controller count : \(navigationController.viewControllers.count)")
            
            ownerFeedCoordinator.start()
        default: break
        }
    }
}
