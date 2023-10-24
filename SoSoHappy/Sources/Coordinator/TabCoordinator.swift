//
//  AuthCoordinator.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/28.
//

import UIKit

enum TabBarPage: String, CaseIterable {
    
    case home
    case add
    case chart
    case feed
    case profile
    
    init?(index: Int) {
        switch index {
        case 0: self = .home
        case 1: self = .feed
        case 2: self = .add
        case 3: self = .chart
        case 4: self = .profile
        default:
            return nil
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .home: return 0
        case .feed: return 1
        case .add: return 2
        case .chart: return 3
        case .profile: return 4
        }
    }
    
    func pageTitleValue() -> String? {
        switch self {
        case .home: return "캘린더"
        case .feed: return "피드"
        case .add: return nil
        case .chart: return "차트"
        case .profile: return "마이페이지"
        }
    }
    
    func pageIconImage() -> UIImage? {
        switch self {
        case .home: return UIImage(named: "calendarTab")
        case .feed: return UIImage(named: "feedTab")
        case .add: return UIImage(named: "happy40")
        case .chart: return UIImage(named: "chartTab")
        case .profile: return UIImage(named: "profileTab")
        }
    }
    
    // Add tab icon value
       
    // Add tab icon selected / deselected color
    
    // etc
    
}


protocol TabCoordinatorProtocol {
    var tabBarController: UITabBarController { get set }
    
    func selectPage(_ page: TabBarPage)
    
    func setSelectedIndex(_ index: Int)
    
    func currentPage() -> TabBarPage?
}


final class TabCoordinator: NSObject, Coordinator {

    var type: CoordinatorType { .tabBar }
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    var tabBarController: UITabBarController
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    required init(
        _ navigationController: UINavigationController,
        tabBarController: UITabBarController = TabBarController()
    ){
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    
    /// 탭바 아이템 생성
    private func createTabBarItem(of page: TabBarPage) -> UITabBarItem {
        return UITabBarItem(title: page.pageTitleValue(),
                            image: page.pageIconImage(),
                            tag: page.pageOrderNumber()
        )
    }
    
    /// 탭바 페이지대로 탭바 생성
    private func createTabNavigationController(tabBarItem: UITabBarItem) -> UINavigationController {
        let tabNavigationController = UINavigationController()
        
        /// 상단에서 NavigationBar 숨김 해제
        tabNavigationController.setNavigationBarHidden(false, animated: false)
        tabNavigationController.tabBarItem = tabBarItem
        
        return tabNavigationController
    }
    
    private func startTabCoordinator(tabNavigationController: UINavigationController) {
        // tag 번호로 TabBarPage로 변경
        let tabBarItemTag: Int = tabNavigationController.tabBarItem.tag
        guard let tabBarItemType: TabBarPage = TabBarPage(index: tabBarItemTag) else { return }
        
        switch tabBarItemType {
        case .home:
            print("home started ...")
            let calendarCoordinator = CalendarCoordinator(navigationController: tabNavigationController)
            calendarCoordinator.finishDelegate = self
            self.childCoordinators.append(calendarCoordinator)
            calendarCoordinator.start()
        case .feed:
            let feedCoordinator = FeedCoordinator(navigationController: tabNavigationController)
            feedCoordinator.finishDelegate = self
            self.childCoordinators.append(feedCoordinator)
            feedCoordinator.start()
        case .add:
            let addCoordinator = AddCoordinator(navigationController: tabNavigationController, tabBarController: UITabBarController())
            addCoordinator.finishDelegate = self
            self.childCoordinators.append(addCoordinator)
            addCoordinator.start()
        case .chart:
            let chartCoordinator = ChartCoordinator(navigationController: tabNavigationController)
            chartCoordinator.finishDelegate = self
            self.childCoordinators.append(chartCoordinator)
            chartCoordinator.start()
        case .profile:
            let profileCoordinator = MyPageCoordinator(navigationController: tabNavigationController)
            profileCoordinator.finishDelegate = self
            self.childCoordinators.append(profileCoordinator)
            profileCoordinator.start()
        }
    }

    /// 탭바 스타일 지정 및 초기화
    private func configureTabBarController(tabNavigationControllers: [UIViewController]) {
        self.tabBarController.setViewControllers(tabNavigationControllers, animated: false)
        self.tabBarController.selectedIndex = TabBarPage.home.pageOrderNumber()
        
        self.tabBarController.view.backgroundColor = .systemBackground
        self.tabBarController.tabBar.backgroundColor = .systemBackground
        self.tabBarController.tabBar.tintColor = UIColor.black
    }
    
    private func addTabBarController() {
        // 화면에 추가
        self.navigationController.pushViewController(self.tabBarController, animated: true)
    }
    
    func start() {
        // 1. 탭바 아이템 리스트 생성
        let pages: [TabBarPage] = TabBarPage.allCases
        
        // 2. 탭바 아이템 생성
        let tabBarItems: [UITabBarItem] = pages.map {
            self.createTabBarItem(of: $0)
        }
        // 3. 탭바별 navigation controller 생성
        let controllers: [UINavigationController] = tabBarItems.map {
            self.createTabNavigationController(tabBarItem: $0)
        }
        
        // 4. 탭바 별로 코디네이터 생성
        let _ = controllers.map {
            self.startTabCoordinator(tabNavigationController: $0)
        }
        
        // 5. 탭바 스타일 지정 및 VC 연결
        self.configureTabBarController(tabNavigationControllers: controllers)
        
        self.addTabBarController()
    }
    
    
 
}

// MARK: - CoordinatorFinishDelegate
extension TabCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        self.childCoordinators.removeAll()
        self.navigationController.viewControllers.removeAll()
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

// MARK: - UITabBarControllerDelegate
extension TabCoordinator: UITabBarControllerDelegate {
    
    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Some implementation
    }
}




//func start() {
//    let pages: [TabBarPage] = [.home, .feed, .add, .chart, .profile]
//
//    let controllers: [UINavigationController] = pages.map { getTabController($0) }
//
//    prepareTabBarController(withTabControllers: controllers)
//}

//
//
//private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
//    /// Set delegate for UITabBarController
//    tabBarController.delegate = self
//
//    tabBarController.setViewControllers(tabControllers, animated: true)
//
//    selectPage(.home)
//
//    tabBarController.tabBar.isTranslucent = false
//    tabBarController.view.backgroundColor = .white
//
//    navigationController.viewControllers = [tabBarController]
////        navigationController.setNavigationBarHidden(true, animated: false)
//}
//
//private func getTabController(_ page: TabBarPage) -> UINavigationController {
//
//    let navController = UINavigationController()
//    navController.setNavigationBarHidden(false, animated: false)
//
//    navController.tabBarItem = UITabBarItem.init(title: page.pageTitleValue,
//                                                 image: nil,
//                                                 tag: page.pageOrderNumber)
//
//    switch page {
//    case .home:
//        let coordinator = CalendarCoordinator()
//        childCoordinators.append(coordinator)
//        coordinator.parentCoordinator = self
//        coordinator.start()
//        let tabBarItem = UITabBarItem.init(
//            title: "캘린더",
//            image: UIImage(named: "calendarTab"),
//            selectedImage: UIImage(named: "calendarTab")
//        )
//        tabBarItem.imageInsets = UIEdgeInsets(top: 12, left: 40, bottom: -12, right: -40)
//        coordinator.navigationController.tabBarItem = tabBarItem
//        coordinator.parentCoordinator = self
//        tabBarController.addChild(coordinator.navigationController)
//
//    case .chart:
//        let coordinator = ChartCoordinator()
//        childCoordinators.append(coordinator)
//        coordinator.parentCoordinator = self
//        coordinator.start()
//        let tabBarItem = UITabBarItem.init(
//            title: "차트",
//            image: UIImage(named: "chartTab"),
//            selectedImage: UIImage(named: "chartTab")
//        )
//
//        tabBarItem.imageInsets = UIEdgeInsets(top: 12, left: -40, bottom: -12, right: 40)
//        coordinator.navigationController.tabBarItem = tabBarItem
//        coordinator.parentCoordinator = self
//        tabBarController.addChild(coordinator.navigationController)
//
//    case .add:
//        let coordinator = AddCoordinator()
//        childCoordinators.append(coordinator)
//        coordinator.parentCoordinator = self
//        coordinator.start()
//        let tabBarItem = UITabBarItem.init(
//            title: nil,
//            image: UIImage(named: "happy40"),
//            selectedImage: UIImage(named: "happy40")
//        )
//
////            tabBarItem.imageInsets = UIEdgeInsets(top: 12, left: -40, bottom: -12, right: 40)
//        coordinator.navigationController.tabBarItem = tabBarItem
//        coordinator.parentCoordinator = self
//        tabBarController.addChild(coordinator.navigationController)
//
//    case .profile:
//        let coordinator = MyPageCoordinator()
//        childCoordinators.append(coordinator)
//        coordinator.parentCoordinator = self
//        coordinator.start()
//        let tabBarItem = UITabBarItem.init(
//            title: "마이페이지",
//            image: UIImage(named: "myPageTab"),
//            selectedImage: UIImage(named: "myPageTab")
//        )
//
////            tabBarItem.imageInsets = UIEdgeInsets(top: 12, left: -40, bottom: -12, right: 40)
//        coordinator.navigationController.tabBarItem = tabBarItem
//        coordinator.parentCoordinator = self
//        tabBarController.addChild(coordinator.navigationController)
//
//    case .feed:
//        let coordinator = FeedCoordinator()
//        childCoordinators.append(coordinator)
//        coordinator.parentCoordinator = self
//        coordinator.start()
//        let tabBarItem = UITabBarItem.init(
//            title: "피드",
//            image: UIImage(named: "happy40"),
//            selectedImage: UIImage(named: "happy40")
//        )
//
////            tabBarItem.imageInsets = UIEdgeInsets(top: 12, left: -40, bottom: -12, right: 40)
//        coordinator.navigationController.tabBarItem = tabBarItem
//        coordinator.parentCoordinator = self
//        tabBarController.addChild(coordinator.navigationController)
//
//    }
//
//    return navigationController
//}
//
//func selectPage(_ page: TabBarPage) {
//    tabBarController.selectedIndex = page.pageOrderNumber
//}
//
////    func setSelectedIndex(_ index: Int) {
////        guard let page = TabBarPage.init(index: index) else { return }
////
////        tabBarController.selectedIndex = page.tabNumber
////        switch page {
////        case .home:
////            tabBarController
////        default:
////            break
////        }
////    }
