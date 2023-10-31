//
//  MyPageCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

public protocol MyPageCoordinatorProtocol {
    func pushProfileEditView()
    func pushNotificationView()
    func pushLanguageView()
    func pushToSView()
    func pushPrivatePolicyView()
    func pushAccountManagementView()
}

final class MyPageCoordinator: Coordinator {
    var type: CoordinatorType { .main }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    let tabViewController = TabBarController()
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = MyPageViewController(reactor: AccountManagementViewReactor(), coordinator: self)
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
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushPrivatePolicyView() {
        let viewController = makePrivatePolicyViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func pushAccountManagementView() {
        let viewController = makeAccountManagementViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
}

extension MyPageCoordinator {
    func makeProfileEditViewController() -> UIViewController {
        let viewController = EditProfileViewController(reactor: SignUpViewReactor())
        return viewController
    }
    
    func makeNotificationViewController() -> UIViewController {
        let viewController = NotificationSettingViewController()
        return viewController
    }
    
    func makeLanguageViewController() -> UIViewController {
        let viewController = LanguageSettingViewController()
        return viewController
    }
    
    func makeToSViewController() -> UIViewController {
        let viewController = ToSViewController()
        return viewController
    }
    
    func makePrivatePolicyViewController() -> UIViewController {
        let viewController = PrivatePolicyViewController()
        return viewController
    }
    
    func makeAccountManagementViewController() -> UIViewController {
        let viewController = AccountManagementViewController()
        return viewController
    }
}


