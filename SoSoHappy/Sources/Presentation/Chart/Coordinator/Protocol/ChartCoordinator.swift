//
//  ChartCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

public protocol ChartCoordinatorInterface {
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
        let viewController = ChartViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
}





