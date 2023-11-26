//
//  HappyListCellCoordinator.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/21.
//

import UIKit

protocol HappyListCoordinatorInterface: Coordinator {
    func pushDetailView(date: String)
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
    
    func start() {
        makeHappyListViewController()
    }
}

extension HappyListCoordinator: HappyListCoordinatorInterface {
    
    func pushDetailView(date: String) {
        let viewController = makeDetailViewController(date: date)
        navigationController.pushViewController(viewController, animated: true)
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
        let reactor = HappyListViewReactor(feedRepository: FeedRepository(), userRepository: UserRepository(), currentPage: date)
        
        let viewController = HappyListViewController(reactor: reactor,
                                                     coordinator: self,
                                                     currentPage: date)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func makeDetailViewController(date: String) -> UIViewController {
        let reactor = MyFeedDetailViewReactor(
            feedRepository: FeedRepository(),
            userRepository: UserRepository(),
            currentPage: Int64(date) ?? 0)
        
        let viewController = MyFeedDetailViewController(reactor: reactor)
        return viewController
    }
  
}

