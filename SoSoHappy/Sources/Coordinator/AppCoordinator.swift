//
//  AppCoordinator.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/28.
//

import UIKit

protocol AppCoordinatorProtocol: Coordinator {
    func showAuthFlow(needsIntroView: Bool)
    func showMainFlow()
}

final public class AppCoordinator: AppCoordinatorProtocol {
    
    var type: CoordinatorType { .app }
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    func start() {
        showAuthFlow(needsIntroView: true)
    }
    
    func showAuthFlow(needsIntroView: Bool) {
        let coordinator = makeAuthCoordinator()
        coordinator.start()
    }
    
    func showMainFlow() {
        let coordinator = makeTabBarCoordinator()
        coordinator.start()
    }
    
    func reloadWindow() {
        childCoordinators.removeAll()
        self.navigationController.viewControllers.removeAll()
        
        showAuthFlow(needsIntroView: false)
    }
    
}


private extension AppCoordinator {
    func makeAuthCoordinator() -> Coordinator {
        let coordinator = LoginCoordinator(navigationController: navigationController)
        coordinator.finishDelegate = self
        childCoordinators.append(coordinator)
        
        return coordinator
    }
    
    func makeTabBarCoordinator() -> Coordinator {
        let coordinator = TabCoordinator(navigationController)
        coordinator.finishDelegate = self
        childCoordinators.append(coordinator)
        
        return coordinator
    }
}


extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childCoordinators = childCoordinator.childCoordinators.filter({
            $0.type != childCoordinator.type
        })
        navigationController.viewControllers.removeAll()
        
        switch childCoordinator.type {
        case .login:
            showMainFlow()
        case .tabBar:
            showAuthFlow(needsIntroView: false)
        default:
            break
        }
    }
}
