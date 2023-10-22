//
//  SignUpCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/21/23.
//

import UIKit

public protocol SignUpCoordinatorProtocol {
    func pushSignUpView()
}

final class SignUpCoordinator: Coordinator {
    var type: CoordinatorType { .signUp }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        pushSignUpView()
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension SignUpCoordinator: SignUpCoordinatorProtocol {
    func pushSignUpView() {
        let viewController = makeSignUpViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension SignUpCoordinator {
    func makeSignUpViewController() -> UIViewController {
        let viewController = SignUpViewController(reactor: SignUpViewReactor())
        return viewController
    }
}



