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
    func presentErrorAlert(error: Error)
    func presentCheckAlert(title: String, message: String, okActionHandler: @escaping () -> Void)
}

final class AuthCoordinator: Coordinator {
    var type: CoordinatorType { .login }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
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
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
    
    func presentErrorAlert(error: Error) {
        let alert = UIAlertController(title: "⚠️ 네트워크 오류 ⚠️", message: "잠시 후에 다시 시도해주세요.\n\(error.localizedDescription)", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        let keyWindow = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow }
        if let window = keyWindow, let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentCheckAlert(title: String, message: String, okActionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "계속", style: .default) { _ in
            okActionHandler()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        let keyWindow = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }.first { $0.isKeyWindow }
        if let window = keyWindow, let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
}

extension AuthCoordinator {
    func makeLoginViewController() -> UIViewController {
        let viewController = LoginViewController(reactor: LoginViewReactor(userRepository: UserRepository(), kakaoManager: KakaoSigninManager(), appleManager: AppleSigninManager(), googleMagager: GoogleSigninManager()), coordinator: self)
        return viewController
    }
    
    func makeSignUpViewController() -> UIViewController {
        let viewController = SignUpViewController(reactor: SignUpViewReactor(), coordinator: self)
        return viewController
    }
}
