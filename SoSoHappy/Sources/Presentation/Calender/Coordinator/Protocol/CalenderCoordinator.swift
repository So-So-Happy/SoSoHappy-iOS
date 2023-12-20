//
//  CalenderCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

protocol CalendarCoordinatorInterface: AnyObject {
    func pushDetailView(feed: MyFeed)
    func pushAlarmView()
    func pushListView(date: Date)
    func dismiss()
    func finished()
    func goToRoot()
}

final class CalendarCoordinator: Coordinator {
    
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = makeCalendarViewController()
        navigationController.pushViewController(viewController, animated: true)
        
    }
    
}

extension CalendarCoordinator: CalendarCoordinatorInterface {
    func pushAlarmView() {
        let viewController = makeAlarmViewController()
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func pushListView(date: Date) {
        let coordinator = HappyListCoordinator(navigationController: self.navigationController, date: date)
        coordinator.parentCoordinator = self
        coordinator.finishDelegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    // MARK: Preview -> DetailView
    func pushDetailView(feed: MyFeed) {
        let coordinator = MyFeedDetailCoordinator(navigationController: self.navigationController)
        coordinator.parentCoordinator = self
        coordinator.finishDelegate = self
        self.childCoordinators.append(coordinator)
        coordinator.showDetailView(feed: feed)
    }
    
    func dismiss() {
        self.navigationController.dismiss(animated: false)
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
    
    func finished() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension CalendarCoordinator {
    
    func makeCalendarViewController() -> UIViewController {
        let viewController = CalendarViewController(
            reactor: CalendarViewReactor(
                feedRepository: FeedRepository(),
                userRepository: UserRepository()
            )
            , coordinator: self
        )
    
        return viewController
    }
    
    func makeAlarmViewController() -> UIViewController {
        let viewController = AlertViewController()
        return viewController
    }
    
    // TODO: 만약에 detailViewController에서 뭐 하고 있었으면 거기 childcoordinator, viewcontroller 정리해줘야 누적안될듯(확인해보기)
    func goToRoot() {
        // Remove all child coordinators
        childCoordinators.removeAll()
        // Pop to the root view controller
        navigationController.popToRootViewController(animated: false)
    }

//    func makeDetailViewController(feed: MyFeed) -> UIViewController {
//        let reactor = MyFeedDetailViewReactor(feedRepository: FeedRepository())
//        let viewController = MyFeedDetailViewController(reactor: reactor, coordinator: self, feed: feed)
//
//        return viewController
//    }
}

extension CalendarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childDidFinish(childCoordinator, parent: self)
    }
}
