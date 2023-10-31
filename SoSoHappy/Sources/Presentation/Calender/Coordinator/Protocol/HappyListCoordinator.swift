//
//  HappyListCellCoordinator.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/21.
//

import UIKit

protocol HappyListCoordinatorInterface: Coordinator {
    func pushDetailView(item: MyFeed)
    func dismiss()
    func finished()
}

final class HappyListCoordinator: Coordinator {
    
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {

    }
 
}

extension HappyListCoordinator: HappyListCoordinatorInterface {
    
    func pushDetailView(item: MyFeed) {
        let viewController = makeDetailViewController(item: item)
        navigationController.pushViewController(viewController, animated: false)
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
    
    func makeHappyListViewController(date: Date) {
        let reactor = HappyListViewReactor(feedRepository: FeedRepository(), userRepository: UserRepository(), currentPage: date)
        
        let viewController = HappyListViewController(reactor: reactor,
                                                     coordinator: self,
                                                     currentPage: date)
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func makeDetailViewController(item: MyFeed) -> UIViewController {
//        let viewController = HappyDetailViewController(item: item)
//        return viewController
        let viewController = FeedListViewController() // 임의로 해둠 **
        return viewController
    }
  
}

