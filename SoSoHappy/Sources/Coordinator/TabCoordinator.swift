//
//  TabCoordinator.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/28.
//

import UIKit

//  MARK: .add에 UITabBarItem을 disable 시키고 tabBarController의 addButton이 핸들링하도록 함.
// MARK: - TabBarPage
enum TabBarPage: String, CaseIterable {
    case home
    case chart
    case add
    case feed
    case profile
    
    init?(index: Int) {
        switch index {
        case 0: self = .home
        case 1: self = .chart
        case 2: self = .add
        case 3: self = .feed
        case 4: self = .profile
        default: return nil
        }
    }
    
    func pageOrderNumber() -> Int {
        switch self {
        case .home: return 0
        case .chart: return 1
        case .add: return 2
        case .feed: return 3
        case .profile: return 4
        }
    }
    
    func pageTitleValue() -> String? {
        switch self {
        case .home: return "캘린더"
        case .chart: return "차트"
        case .add: return nil
        case .feed: return "피드"
        case .profile: return "마이페이지"
        }
    }
    
    func pageIconImage() -> UIImage? {
        switch self {
        case .home: return UIImage(systemName: "calendar")
        case .chart: return UIImage(systemName: "chart.bar.fill")
        case .add: return nil
        case .feed: return UIImage(systemName: "heart.fill")
        case .profile: return UIImage(systemName: "person.fill")
        }
    }
}

protocol TabCoordinatorProtocol {
    var tabBarController: UITabBarController { get set }
    
    func selectPage(_ page: TabBarPage)
    
    func setSelectedIndex(_ index: Int)
    
    func currentPage() -> TabBarPage?
}

// MARK: - TabCoordinator
final class TabCoordinator: NSObject, Coordinator {
    var type: CoordinatorType { .tabBar }
    var finishDelegate: CoordinatorFinishDelegate?
    var tabBarController: TabBarController
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var addButtonDelegate: TabBarAddButtonDelegate?
    
    required init(
        _ navigationController: UINavigationController,
        tabBarController: TabBarController = TabBarController()
    ){
        
        self.navigationController = navigationController
        self.tabBarController = tabBarController
        super.init()
        self.tabBarController.addDelegate = self
    }
    
    // UITabBarItem 생성
    private func createTabBarItem(of page: TabBarPage) -> UITabBarItem {
        // MARK: .add는 그냥 위치만 잡아주는 용
        switch page {
        case .add:
            let item = UITabBarItem(title: page.pageTitleValue(),
                                   image: page.pageIconImage(),
                                   tag: page.pageOrderNumber())
            item.isEnabled = false
            return item
        default:
            return UITabBarItem(title: page.pageTitleValue(),
                                image: page.pageIconImage(),
                                tag: page.pageOrderNumber())
        }
    }
    
    // 탭바 페이지대로 탭바 생성
    private func createTabNavigationController(tabBarItem: UITabBarItem) -> UINavigationController {
        let tabNavigationController = UINavigationController()
        
        // 상단에서 NavigationBar 숨김 해제
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
            let calendarCoordinator = CalendarCoordinator(navigationController: tabNavigationController)
            calendarCoordinator.finishDelegate = self
            self.childCoordinators.append(calendarCoordinator)
            calendarCoordinator.start()
            
        case .chart:
            let chartCoordinator = ChartCoordinator(navigationController: tabNavigationController)
            chartCoordinator.finishDelegate = self
            self.childCoordinators.append(chartCoordinator)
            chartCoordinator.start()
            
        case .add:
            break
            
        case .feed:
            let feedCoordinator = FeedCoordinator(navigationController: tabNavigationController)
            feedCoordinator.parentCoordinator = self
            feedCoordinator.finishDelegate = self
            self.childCoordinators.append(feedCoordinator)
            feedCoordinator.start()
            
        case .profile:
            let profileCoordinator = MyPageCoordinator(navigationController: tabNavigationController)
            profileCoordinator.finishDelegate = self
            self.childCoordinators.append(profileCoordinator)
            profileCoordinator.start()
        }
    }
    
    // 탭바 스타일 지정 및 초기화
    private func configureTabBarController(tabNavigationControllers: [UIViewController]) {
        self.tabBarController.setViewControllers(tabNavigationControllers, animated: false)
        self.tabBarController.selectedIndex = TabBarPage.home.pageOrderNumber()
        self.tabBarController.view.backgroundColor = .systemBackground
        self.tabBarController.tabBar.backgroundColor = .systemBackground
        self.tabBarController.tabBar.tintColor = UIColor(named: "accentColor")
    }
    
    private func addTabBarController() {
        // 화면에 추가
        print("🗂️ 쌓여 있는 VC: \(navigationController.viewControllers.count)개")
        self.navigationController.pushViewController(self.tabBarController, animated: true)
    }
    
    func start() {
        //  MARK: 탭바에 넣고 싶은 item들
        let pages: [TabBarPage] = TabBarPage.allCases
    
        
        // 2. pages에 해당하는 UITabBar item들 생성
        let tabBarItems: [UITabBarItem] = pages.map {
            self.createTabBarItem(of: $0)
        }
        // 3. UITabBar item별 navigation controller 생성
        let controllers: [UINavigationController] = tabBarItems.map {
            self.createTabNavigationController(tabBarItem: $0)
        }
        
        // 4. 탭바 별로 코디네이터 생성 후 start
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

// MARK: - TabBarAddButtonDelegate
extension TabCoordinator: TabBarAddButtonDelegate {
    func addButtonTapped() {
        print("add!!")
        
        let addCoordinator = AddCoordinator(navigationController: UINavigationController())
        addCoordinator.parentCoordinator = self
        addCoordinator.finishDelegate = self
        print("ADD coordinator count - \(self.childCoordinators.count)")
        self.childCoordinators.append(addCoordinator)
        addCoordinator.start()
        addCoordinator.navigationController.modalPresentationStyle = .fullScreen
        tabBarController.present(addCoordinator.navigationController, animated: true)
    }
}
