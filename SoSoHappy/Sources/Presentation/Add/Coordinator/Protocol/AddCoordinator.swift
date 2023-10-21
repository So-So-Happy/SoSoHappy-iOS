//
//  AddCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/09.
//


import UIKit

protocol AddCoordinatorInterface: Coordinator {
    func showNextAdd(reactor: AddViewReactor)
}

final class AddCoordinator: AddCoordinatorInterface {
    var type: CoordinatorType { .add }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    var tabBarController: UITabBarController
    
    init(navigationController: UINavigationController = UINavigationController(), tabBarController: UITabBarController ) {
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    func start() {
        let addViewReactor = AddViewReactor()
        let addStep1VC = AddStep1ViewController(reactor: addViewReactor, coordinator: self)
        navigationController.pushViewController(addStep1VC, animated: true)
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension AddCoordinator {
    func showNextAdd(reactor: AddViewReactor) {
        print("[Coordinator] AddStep1 - shoNextAdd")
        print("reactor.initialState.selectedWeather: \(reactor.currentState.selectedWeather)")
        print("reactor.initialState.selectedHappiness : \(reactor.currentState.selectedHappiness)")
        let add2Coordinator = Add2Coordinator(navigationController: self.navigationController, reactor: reactor)
        self.childCoordinators.append(add2Coordinator)
        add2Coordinator.start()
    }
}


