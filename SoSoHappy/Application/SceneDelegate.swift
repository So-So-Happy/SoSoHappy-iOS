//
//  SceneDelegate.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/01.
//

import UIKit
import RxKakaoSDKAuth
import KakaoSDKAuth
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var appCoordinator: AppCoordinator?
    
    var coordinator: AppCoordinator? 
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // ChartViewController start
        
        //MARK: 전체 Tab Bar 다 확인할 수 있는 코드
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let navigationController = UINavigationController()
        appCoordinator = AppCoordinator(navigationController: navigationController)
        appCoordinator?.start()
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

//         let window = UIWindow(windowScene: windowScene)
        
//         //MARK: 전체 Tab Bar 다 확인할 수 있는 코드
//         let navigationController = UINavigationController()
//         window.rootViewController = navigationController
//         let coordinator = AppCoordinator(navigationController: navigationController)
//         coordinator.start()

        // MARK: View 한 개씩 화인
//        let mainVC = UINavigationController(rootViewController: AddStep2ViewController(reactor: AddViewReactor()))
//        let mainVC = UINavigationController(rootViewController: AddStep3ViewController3())
//        let mainVC = UINavigationController(rootViewController: SignUpViewController(reactor: SignUpViewReactor()))

    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.rx.handleOpenUrl(url: url)
            } else {
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        checkAndUpdateIfNeeded()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

extension SceneDelegate {
    // 업데이트가 필요한지 확인하는 함수
     func checkAndUpdateIfNeeded() {
         // 현재 앱스토어에 있는 버전
         DispatchQueue.main.async { [weak self] in
             guard let self = self else { return }
             Task {
                 do {
                     let data = try await AppstoreCheck().latestVersionByFirebase()
                     guard let version = data.0, let forceUpdate = data.1 else { return }
                     let marketingVersion = version // 앱 스토어에 있는 버전
                     
                     // 현재 앱(프로젝트)의 버전
                     let currentProjectVersion = AppstoreCheck.appVersion ?? ""
                     
                     // 앱스토어에 있는 버전을 .마다 나눈 것 (예: 1.2.1 버전이라면 [1, 2, 1])
                     let splitMarketingVersion = marketingVersion.split(separator: ".").map { $0 }
                     
                     // 현재 프로젝트 버전을 .마다 나눈 것
                     let splitCurrentProjectVersion = currentProjectVersion.split(separator: ".").map { $0 }
                     
                     // [Major].[Minor].[Revision] 중 [Major]을 비교하여 앱스토어에 있는 버전이 높을 경우 알럿 띄우기
                     // major, minor에 변화가 있거나 forceupdate인 경우에만 update 시키면 됨
                     
                     if forceUpdate && (splitCurrentProjectVersion != splitMarketingVersion)  {
                         self.showUpdateAlert(version: marketingVersion, isForced: true)
                     }
                     else if splitCurrentProjectVersion[0] < splitMarketingVersion[0] {
                         self.showUpdateAlert(version: marketingVersion, isForced: false)
                         
                     // [Major].[Minor].[Revision] 중 [Minor]을 비교하여 앱스토어에 있는 버전이 높을 경우 알럿 띄우기
                     } else if splitCurrentProjectVersion[1] < splitMarketingVersion[1] {
                         self.showUpdateAlert(version: marketingVersion, isForced: false)
                         
                     // 나머지 상황에서는 업데이트 알럿을 띄우지 않음
                     } else {
                         print("현재 최신 버젼입니다.")
                     }
                     
                 } catch {
                     print("Error \(error)")
                 }
             }
         }
     }
     
    // 알럿을 띄우는 함수
    func showUpdateAlert(version: String, isForced: Bool) {
        let alert = UIAlertController(
            title: "업데이트 알림",
            message: "\(version)으로의 업데이트 사항이 있습니다. 앱스토어에서 앱을 업데이트 해주세요.",
            preferredStyle: .alert
        )
        
        // 업데이트 버튼을 누르면 앱스토어로 이동
        let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
            AppstoreCheck().openAppStore()
        }
        
        alert.addAction(updateAction)
        
        if !isForced {
            let laterAction = UIAlertAction(title: "나중에", style: .default)
            alert.addAction(laterAction)
        }
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
