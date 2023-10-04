//
//  FeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit

public protocol FeedCoordinatorInterface {
    func dismiss()
    func finished()
}

final class FeedCoordinator: Coordinator {
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = FeedViewController(reactor: FeedViewReactor())
        navigationController.pushViewController(viewController, animated: true)
    }
    
}





