//
//  AddCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/09.
//


import UIKit

public protocol AddCoordinatorInterface {
    func dismiss()
    func finished()
}

final class AddCoordinator: Coordinator {
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = AddStep1ViewController() 
        navigationController.pushViewController(viewController, animated: true)
    }
}




