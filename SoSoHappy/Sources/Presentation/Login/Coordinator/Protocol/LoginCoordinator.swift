//
//  LoginCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

public protocol LoginCoordinatorProtocol {
    func pushAuthView()
    func pushMainView()
}

final class LoginCoordinator: Coordinator {
    var type: CoordinatorType { .login }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
       pushAuthView()
    }
}

extension LoginCoordinator: LoginCoordinatorProtocol {
    func pushAuthView() {
        let viewController = makeAuthViewController()
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func pushMainView() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension LoginCoordinator {
    func makeAuthViewController() -> UIViewController {
        let viewController = LoginViewController(coordinator: self)
        return viewController
    }
}

