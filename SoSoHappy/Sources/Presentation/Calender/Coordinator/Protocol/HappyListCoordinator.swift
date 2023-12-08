//
//  HappyListCellCoordinator.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/21.
//

import UIKit

protocol HappyListCoordinatorInterface: Coordinator {
    func pushDetailView(feed: MyFeed)
    func showAdd1Modal(reactor: MyFeedDetailViewReactor)
    func showAdd2Modal(reactor: MyFeedDetailViewReactor)
    func dismiss()
    func finished()
}

final class HappyListCoordinator: Coordinator {
    
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var date: Date
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController(), date: Date ) {
        self.navigationController = navigationController
        self.date = date
    }
    
    func start() {
        makeHappyListViewController()
    }
}

extension HappyListCoordinator: HappyListCoordinatorInterface {
    
    func pushDetailView(feed: MyFeed) {
        let viewController = makeDetailViewController(feed: feed)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func dismiss() {
        self.navigationController.dismiss(animated: false)
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
    
    func finished() {
        navigationController.popViewController(animated: true)
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension HappyListCoordinator {
    
    func makeHappyListViewController() {
        let reactor = HappyListViewReactor(
            feedRepository: FeedRepository(),
            userRepository: UserRepository(),
            currentPage: date)
        
        let viewController = HappyListViewController(reactor: reactor,
                                                     coordinator: self,
                                                     currentPage: date)
    
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func makeDetailViewController(feed: MyFeed) -> UIViewController {
        let reactor = MyFeedDetailViewReactor(feedRepository: FeedRepository())
        let viewController = MyFeedDetailViewController(reactor: reactor, coordinator: self, feed: feed)
        
        return viewController
    }
    
}

extension HappyListCoordinator {
    
    // MARK: - MyFeedDetailViewController 에서 사용되는 메서드 입니다.
    func showAdd1Modal(reactor: MyFeedDetailViewReactor) {
        let SetWeatherHappinessViewController = SetWeatherHappinessViewController(
            reactor: reactor,
            coordinator: self
        )
        
        navigationController.present(SetWeatherHappinessViewController, animated: true, completion: nil)
    }
    
    func showAdd2Modal(reactor: MyFeedDetailViewReactor) {
        let SetCategoryViewController = SetCategoryViewController(
            reactor: reactor,
            coordinator: self
        )
        
        navigationController.present(SetCategoryViewController, animated: true, completion: nil)
    }
    
}
