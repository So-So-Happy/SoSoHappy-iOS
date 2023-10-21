//
//  Add2Coordinator.swift
//  SoSoHappy
//
//  Created by Sue on 10/11/23.
//

import UIKit

final class Add2Coordinator: AddCoordinatorInterface {
    var type: CoordinatorType { .add }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    var reactor: AddViewReactor
    
    init(navigationController: UINavigationController = UINavigationController(), reactor: AddViewReactor ) {
        self.navigationController = navigationController
        self.reactor = reactor
    }
    
    func start() {
        let addStep2VC = AddStep2ViewController(reactor: reactor, coordinator: self)
        navigationController.pushViewController(addStep2VC, animated: true)
    }
    
    func finish() {
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
}

extension Add2Coordinator {
    func showNextAdd(reactor: AddViewReactor) {
        print("AddStep2 - shoNextAdd")
        print("reactor.initialState.selectedCategories: \(reactor.currentState.selectedCategories)")
        
        let addStep3VC = AddStep3ViewController(reactor: reactor)
        navigationController.pushViewController(addStep3VC, animated: true)
    }
}
