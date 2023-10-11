//
//  Add2Coordinator.swift
//  SoSoHappy
//
//  Created by Sue on 10/11/23.
//

import UIKit

final class Add2Coordinator: Coordinator {
    var type: CoordinatorType { .add }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    var reactor: AddViewReactor
    
    init(navigationController: UINavigationController = UINavigationController(), reactor: AddViewReactor ) {
        self.navigationController = navigationController
        self.reactor = reactor
    }
    
    func start() {
        let viewController = AddStep2ViewController(reactor: reactor)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}
