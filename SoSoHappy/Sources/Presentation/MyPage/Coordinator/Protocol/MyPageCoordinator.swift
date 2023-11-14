//
//  MyPageCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit
import SafariServices

public protocol MyPageCoordinatorProtocol {
    func pushProfileEditView()
    func pushNotificationView()
    func pushLanguageView()
    func pushToSView()
    func pushPrivatePolicyView()
    func pushAccountManagementView()
    func goBackToLogin()
    func goBackToMypage()
}

final class MyPageCoordinator: Coordinator {
    var type: CoordinatorType { .mypage }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    let tabViewController = TabBarController()
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = MyPageViewController(reactor: MypageViewReactor(), coordinator: self)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension MyPageCoordinator: MyPageCoordinatorProtocol {
    func pushProfileEditView() {
        let viewController = makeProfileEditViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushNotificationView() {
        let viewController = makeNotificationViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushLanguageView() {
        let viewController = makeLanguageViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushToSView() {
        let viewController = makeToSViewController()
        navigationController.present(viewController, animated: true, completion: nil)
    }
    
    func pushPrivatePolicyView() {
        let viewController = makePrivatePolicyViewController()
        navigationController.present(viewController, animated: true, completion: nil)
    }
    
    func pushAccountManagementView() {
        let viewController = makeAccountManagementViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func goBackToLogin() {
        navigationController.viewControllers.removeAll()
        let coordinator = makeAuthCoordinator()
        coordinator.start()
    }
    
    func goBackToMypage() {
        navigationController.popToRootViewController(animated: true)
    }
}

extension MyPageCoordinator {
    func makeProfileEditViewController() -> UIViewController {
        let viewController = EditProfileViewController(reactor: EditProfileViewReactor(), coordinator: self)
        return viewController
    }
    
    func makeNotificationViewController() -> UIViewController {
        let viewController = NotificationSettingViewController(coordinator: self)
        return viewController
    }
    
    func makeLanguageViewController() -> UIViewController {
        let viewController = LanguageSettingViewController()
        return viewController
    }
    
    func makeToSViewController() -> UIViewController {
        let url = URL(string: Bundle.main.tosPath)!
        let safariViewController = SFSafariViewController(url: url)
        return safariViewController
    }
    
    func makePrivatePolicyViewController() -> UIViewController {
        let url = URL(string: Bundle.main.privatePolicyPath)!
        let safariViewController = SFSafariViewController(url: url)
        return safariViewController
    }
    
    func makeAccountManagementViewController() -> UIViewController {
        let viewController = AccountManagementViewController(reactor: AccountManagementViewReactor(), coordinator: self)
        return viewController
    }
    
    func makeAuthCoordinator() -> Coordinator {
        let coordinator = AuthCoordinator(navigationController: navigationController)
        childCoordinators.append(coordinator)
        
        return coordinator
    }
}


