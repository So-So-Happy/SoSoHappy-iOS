//
//  CalenderCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

public protocol CalendarCoordinatorInterface: AnyObject {
    func pushAlarmView()
    func pushListView(date: Date)
    func dismiss()
    func finished()
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
    
    func dismiss() {
        self.navigationController.dismiss(animated: false)
        self.finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
    
    func finished() {
        navigationController.popViewController(animated: true)
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
}

extension CalendarCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinish(childCoordinator: Coordinator) {
        childDidFinish(childCoordinator, parent: self)
    }
}
