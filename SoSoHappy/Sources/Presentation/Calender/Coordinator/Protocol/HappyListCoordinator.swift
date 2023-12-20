//
//  HappyListCellCoordinator.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/21.
//

import UIKit

protocol HappyListCoordinatorInterface: Coordinator {
    func pushDetailView(feed: MyFeed)
    func dismiss()
    func finished()
}

final class HappyListCoordinator: Coordinator {
    
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var date: Date
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController(), date: Date ) {
        self.navigationController = navigationController
        self.date = date
    }
    
}

extension HappyListCoordinator: HappyListCoordinatorInterface {
    
    func start() {
        makeHappyListViewController()
    }
    
    func pushDetailView(feed: MyFeed) {
        let coordinator = MyFeedDetailCoordinator(navigationController: self.navigationController)
        coordinator.parentCoordinator = self
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.showDetailView(feed: feed)
    }
    
    func dismiss() {
        self.navigationController.dismiss(animated: false)
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
    
    func finished() {
        navigationController.popViewController(animated: true)
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension HappyListCoordinator {
    
    func makeHappyListViewController() {
        let reactor = HappyListViewReactor(
            feedRepository: FeedRepository(),
            userRepository: UserRepository(),
            currentPage: date)
        
        let viewController = HappyListViewController(reactor: reactor,
                                                     coordinator: self,
                                                     currentPage: date)
    
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension HappyListCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childDidFinish(childCoordinator, parent: self)
    }
}
