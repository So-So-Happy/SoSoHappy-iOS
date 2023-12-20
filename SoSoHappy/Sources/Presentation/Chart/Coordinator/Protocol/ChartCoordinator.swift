//
//  ChartCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

public protocol ChartCoordinatorInterface {
    func pushAwardsDetailView()
    func dismiss()
    func finished()
}

final class ChartCoordinator: Coordinator {
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = ChartViewController(reactor: ChartViewReactor(feedRepository: FeedRepository(), userRepository: UserRepository()))
        navigationController.pushViewController(viewController, animated: true)
    }
    
}

extension ChartCoordinator: ChartCoordinatorInterface {
    
    func pushAwardsDetailView() {
        let viewController = makeAwardsDetailViewController()
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

extension ChartCoordinator {
    func makeAwardsDetailViewController() -> UIViewController {
        let viewController = AwardsDetailViewController()
        return viewController

    }
}
