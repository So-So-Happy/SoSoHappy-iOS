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
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
//        let mainVC = LoginViewController(coordinator: LoginCoordinator())
//        mainVC.reactor = LoginViewReactor(repository: UserRepository(), userDefaults: UserDefaults(), kakaoManager: KakaoSigninManager(), appleManager: AppleSigninManager())
//        window.rootViewController = mainVC // 시작 VC 작성해주기
        let mainVC = LoginViewController(coordinator: LoginCoordinator())
        mainVC.reactor = LoginViewReactor(userRepository: UserRepository(), userDefaults: UserDefaults(), kakaoManager: KakaoSigninManager(), appleManager: AppleSigninManager(), googleMagager: GoogleSigninManager())


        // let mainVC = UINavigationController(rootViewController: AddStep1ViewController())
//        let mainVC = EditProfileViewController(reactor: SignUpViewReactor())
//        mainVC.reactor = LoginViewReactor(repository: UserRepository(), userDefaults: UserDefaults(), kakaoManager: KakaoSigninManager(), appleManager: AppleSigninManager())

//        let mainVC = UINavigationController(rootViewController: AddStep1ViewController())
        
//        let mainVC = LoginViewController(coordinator: LoginCoordinator())
//        mainVC.reactor = LoginViewReactor(repository: UserRepository(), userDefaults: UserDefaults(), kakaoManager: KakaoSigninManager(), appleManager: AppleSigninManager())
        
        self.window = window
        let navigationController = UINavigationController()
        self.window?.rootViewController = navigationController
        
        let coordinator = CalendarCoordinator(navigationController: navigationController)
        coordinator.start()

        let reactor = CalendarViewReactor(feedRepository: FeedRepository(), userRepository: UserRepository())
        
        let calendarVC = CalendarViewController(reactor: reactor, coordinator: CalendarCoordinator(navigationController: UINavigationController()))
        
//        let mainVM = AddStep3ViewController()
        window.rootViewController = mainVC // 시작 VC 작성해주기
        
        
        window.makeKeyAndVisible()
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
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

