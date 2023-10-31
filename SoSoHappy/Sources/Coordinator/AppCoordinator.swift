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
        // TODO: 수월한 개발을 위한 print문입니다. 추후 제거 예정
        let accessToken = KeychainService.loadData(serviceIdentifier: "sosohappy.tokens", forKey: "accessToken") ?? "없음"
        let refreshToken = KeychainService.loadData(serviceIdentifier: "sosohappy.tokens", forKey: "refreshToken") ?? "없음"
        let userEmail = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "userEmail") ?? "없음"
        let nickName = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "userNickName") ?? "없음"

        if KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "userNickName") == nil {
            showAuthFlow(needsIntroView: true)
        } else {
            // TODO: 수월한 개발을 위한 print문입니다. 추후 제거 예정
            print("================= 사용자 정보 (개발용) =================")
            print("👤 accessToken: \(String(describing: accessToken))")
            print("👤 refreshToken: \(String(describing: refreshToken))")
            print("👤 userEmail: \(String(describing: userEmail))")
            print("👤 nickName: \(String(describing: nickName))")
            print("===================================================")
//            KeychainService.deleteTokenData(identifier: "sosohappy.userInfo", account: "userNickName")
            showMainFlow()
        }
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
        let coordinator = AuthCoordinator(navigationController: navigationController)
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
        switch childCoordinator.type {
        case .login:
            showMainFlow()
            childCoordinators.removeAll()
        case .tabBar:
            showAuthFlow(needsIntroView: false)
            
        default:
            break
        }
    }
}
