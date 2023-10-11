//
//  CalenderCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/07.
//

import UIKit

public protocol CalendarCoordinatorInterface: AnyObject {
    func pushAlertView()
    func pushListView()
    func dismiss()
    func finished()
}

final class CalendarCoordinator: Coordinator {
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewController = makeCalendarViewController()
        navigationController.pushViewController(viewController, animated: true)
    }
    
}

extension CalendarCoordinator: CalendarCoordinatorInterface {
    func pushAlertView() {
        print("pushed Alert View button")
        let viewController = makeAlertViewController()
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func pushListView(){
        let viewController = makeFeedListViewController()
        navigationController.pushViewController(viewController, animated: false)
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
    
    func makeAlertViewController() -> UIViewController {
        let viewController = AlertViewController()
        return viewController
    }
    
    func makeFeedListViewController() -> UIViewController {
        let viewController = FeedListViewController()
        return viewController
    }
}

