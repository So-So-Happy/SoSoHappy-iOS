//
//  AppCoordinator.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/28.
//

import UIKit
import Alamofire

protocol AppCoordinatorProtocol: Coordinator {
    func showAuthFlow()
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

        let accessToken = KeychainService.getAccessToken()
        let refreshToken = KeychainService.getRefreshToken()
        let userEmail = KeychainService.getUserEmail()
        let nickName = KeychainService.getNickName()
        
        if nickName.isEmpty || accessToken.isEmpty {
            showAuthFlow()
        } else {
            // TODO: 수월한 개발을 위한 print문입니다. 추후 제거 예정
            print("================= 사용자 정보 (개발용) =================")
            print("👤 accessToken: \(String(describing: accessToken))")
            print("👤 refreshToken: \(String(describing: refreshToken))")
            print("👤 userEmail: \(String(describing: userEmail))")
            print("👤 nickName: \(String(describing: nickName))")
            print("===================================================")
            showMainFlow()
            
            // MARK: - 처음에 여기에서 세팅해주면 마이페이지 알림에도 적용해줘야할 것 같음
            let authOptions: UNAuthorizationOptions = [.alert, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
              options: authOptions,
              completionHandler: { granted, error in
                  if granted {
                      print("알림이 등록되었습니다.")
                  }
              }
            )
        }
        
    }
    
    func showAuthFlow() {
        let coordinator = makeAuthCoordinator()
        coordinator.start()
    }
    
    func showMainFlow() {
        let coordinator = makeTabBarCoordinator()
        coordinator.start()
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
        case .auth:
            showMainFlow()
            childCoordinators.removeAll()
        case .tabBar:
            showAuthFlow()
        default:
            break
        }
    }
}
