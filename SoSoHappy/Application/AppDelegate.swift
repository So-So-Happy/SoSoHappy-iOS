//
//  AppDelegate.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/01.
//

import Foundation
import CoreData
import RxKakaoSDKCommon
import RxKakaoSDKAuth
import KakaoSDKAuth
import GoogleSignIn
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let gcmMessageIDKey: String = "gcm.Message_ID"
    
    // MARK: - 앱이 켜졌을 때
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let nativeKakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        RxKakaoSDK.initSDK(appKey: nativeKakaoAppKey as! String)
        
        RxImagePickerDelegateProxy.register { RxImagePickerDelegateProxy(imagePicker: $0) }
    
        // MARK: 파이어베이스 설정
        FirebaseApp.configure()
        
        // MARK: 원격 알림 등록 - 앱이 foreground일 때도 푸시 메시지를 받도록
        UNUserNotificationCenter.current().delegate = self

        application.registerForRemoteNotifications()
        
        if let notification = launchOptions?[.remoteNotification] as? [String:AnyObject] {
            print("notification", notification)
        }

        // MARK: Messaging Delegate
        Messaging.messaging().delegate = self
        
        // MARK: Font Setting
        let fontAttributes = [NSAttributedString.Key.font: UIFont.customFont(size: 16, weight: .medium)]
        UIBarButtonItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)
        
        // MARK: NavigationBar Setting
        UINavigationBar.appearance().barTintColor = UIColor(named: "BGgrayColor")
        UINavigationBar.appearance().shadowImage = UIImage()
        
        // MARK: First Launch Setting
        removeKeychainAtFirstLaunch()
        
        return true
    }
    
    private func removeKeychainAtFirstLaunch() {
        guard UserDefaults.isFirstLaunch() else { return }
        KeychainService.deleteTokenData(identifier: "sosohappy.tokens", account: "accessToken")
    }
    
    // MARK: FCM 토큰이 등록 되었을 때 - apnsToken이랑 연결
    func application(_ application: UIApplication,
                        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("apnToken", Messaging.messaging().apnsToken!)
        Messaging.messaging().apnsToken = deviceToken
       }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.rx.handleOpenUrl(url: url)
        } else if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        
        return false
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SoSoHappy")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      UserDefaults.standard.setValue(fcmToken, forKey: "fcmToken")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
    -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        
        let isOnNotificationSetting = UserDefaults.standard.bool(forKey: "notificationSetting")
        return isOnNotificationSetting ? [[.alert, .sound]] : []
    }
    
    // MARK: 알림 탭했을 작동하는 곳
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
    
    }
    
    // MARK: Handles silent push notifications
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
      -> UIBackgroundFetchResult {
      if let messageID = userInfo[gcmMessageIDKey] {

      }

      return UIBackgroundFetchResult.newData
    }

}
