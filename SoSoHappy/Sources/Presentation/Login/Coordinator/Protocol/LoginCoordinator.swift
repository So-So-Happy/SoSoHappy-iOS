//
//  LoginCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

public protocol LoginCoordinatorProtocol {
    func pushAuthView()
    func presentErrorAlert(_ error: Error)
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
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension LoginCoordinator: LoginCoordinatorProtocol {
    func pushAuthView() {
        let viewController = makeAuthViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushCalenderView() {
        print("pushCalenderView() started...")
        let calenderCoordinator = CalendarCoordinator(navigationController: self.navigationController)
        self.childCoordinators.append(calenderCoordinator)
        calenderCoordinator.start()
    }
    
    func pushSignUpView() {
        print("pushSignUpView() started...")
        let signUpCoordinator = SignUpCoordinator(navigationController: self.navigationController)
        self.childCoordinators.append(signUpCoordinator)
        signUpCoordinator.start()
        self.finish()
    }
}

extension LoginCoordinator {
    func makeAuthViewController() -> UIViewController {
        let viewController = LoginViewController(reactor: LoginViewReactor(userRepository: UserRepository(), kakaoManager: KakaoSigninManager(), appleManager: AppleSigninManager(), googleMagager: GoogleSigninManager()), coordinator: self)
        return viewController
    }
    
    func presentErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "⚠️ 네트워크 오류 ⚠️", message: "잠시 후에 다시 시도해주세요.\n\(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        let keyWindow = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow }
        if let window = keyWindow, let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
}


