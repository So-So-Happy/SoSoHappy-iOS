//
//  AuthCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

public protocol AuthCoordinatorProtocol {
    func pushLoginView()
    func pushSignUpView()
    func pushMainView()
}

final class AuthCoordinator: Coordinator {
    var type: CoordinatorType { .auth }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    func start() {
        print("🗂️ 쌓여 있는 VC: \(navigationController.viewControllers.count)개")
        pushLoginView()
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension AuthCoordinator: AuthCoordinatorProtocol {
    func pushLoginView() {
        let viewController = makeLoginViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushSignUpView() {
        let viewController = makeSignUpViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushMainView() {
        let appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator.start()
    }
}

extension AuthCoordinator {
    func makeLoginViewController() -> UIViewController {
        let viewController = LoginViewController(reactor: LoginViewReactor(userRepository: UserRepository(), kakaoManager: KakaoSigninManager(), appleManager: AppleSigninManager(), googleMagager:GoogleSigninManager()), coordinator: self)
        return viewController
    }
    
    func makeSignUpViewController() -> UIViewController {
        let viewController = SignUpViewController(reactor: SignUpViewReactor(), coordinator: self)
        return viewController
    }
}
