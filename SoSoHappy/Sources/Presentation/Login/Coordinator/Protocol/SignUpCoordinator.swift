//
//  SignUpCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 10/21/23.
//

import UIKit

public protocol SignUpCoordinatorProtocol {
    func showSignUpView()
    func pushMainView()
}

final class SignUpCoordinator: Coordinator {
    var type: CoordinatorType { .signup }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(false, animated: true)
        navigationController.navigationBar.topItem?.title = ""
    }
    
    func start() {
        showSignUpView()
    }
    
    func finish() {
        print("SignUpCoordinator finish()")
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension SignUpCoordinator: SignUpCoordinatorProtocol {
    func showSignUpView() {
        let viewController = makeSignUpViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushMainView() {
        print("SignUpCoordinator pushMainView")
        let mainCoordinator = TabCoordinator(self.navigationController)
        self.childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
    
    
    
}

extension SignUpCoordinator {
    func makeSignUpViewController() -> UIViewController {
        let viewController = SignUpViewController(reactor: SignUpViewReactor())
        return viewController
    }
}



