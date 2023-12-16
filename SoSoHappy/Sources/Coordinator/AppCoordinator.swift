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
//        let newAccess = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJBY2Nlc3NUb2tlbiIsImV4cCI6MTcwMjY5MTg4OCwiZW1haWwiOiJwa2t5dW5nMjZAZ21haWwuY29tK2dvb2dsZSJ9.93ScptD534uZX1FxkVxlGqtSR1V7fiG2sWyr_Ti9JB52hwHZDM2bdptkwUzY2Irt8sIgGeqY7FGbEfWwhR4QXw"
//        let newRefresh = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJSZWZyZXNoVG9rZW4iLCJleHAiOjE3MTQ3NTE4ODgsImVtYWlsIjoicGtreXVuZzI2QGdtYWlsLmNvbStnb29nbGUifQ.OJgeU1gO6AJ5keiQecozWKHcy8ZvUb4TmWlDAzqYk9yYfZZgk3gBXqRCLF6f46ZLmyTamhRff8XaL_FKqDGjaA"
//        
//        KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "accessToken", data: newAccess)
//        KeychainService.saveData(serviceIdentifier: "sosohappy.tokens", forKey: "refreshToken", data: newRefresh)


        let accessToken = KeychainService.loadData(serviceIdentifier: "sosohappy.tokens", forKey: "accessToken") ?? ""
        let refreshToken = KeychainService.loadData(serviceIdentifier: "sosohappy.tokens", forKey: "refreshToken") ?? ""
        let provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
        let userEmail = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userEmail") ?? ""
        let nickName = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName") ?? ""
        
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
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
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
