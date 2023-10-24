//
//  Coordinator .swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/08/28.
//

import UIKit


protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    var type: CoordinatorType { get }
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    func findCoordinator(type: CoordinatorType) -> Coordinator?
    func start()
    func finish()
    
}

extension Coordinator {
    func childDidFinish(_ child: Coordinator?, parent: Coordinator?) {
        guard let parent = parent, parent.childCoordinators.isEmpty == false else {
            return
        }
        
        for (index, coordinator) in parent.childCoordinators.enumerated() where coordinator === child {
            parent.childCoordinators.remove(at: index)
            break
        }
    }
    
    func finish() {
        childCoordinators.removeAll()
        finishDelegate?.coordinatorDidFinish(childCoordinator: self)
    }
    
    func findCoordinator(type: CoordinatorType) -> Coordinator? {
           var stack: [Coordinator] = [self]
           
           while !stack.isEmpty {
               let currentCoordinator = stack.removeLast()
               if currentCoordinator.type == type {
                   return currentCoordinator
               }
               currentCoordinator.childCoordinators.forEach({ child in
                   stack.append(child)
               })
           }
           return nil
       }
}


protocol CoordinatorFinishDelegate: AnyObject {
    func coordinatorDidFinish(childCoordinator: Coordinator)
    
}

enum CoordinatorType{
    case app
    case launchScreen
    case login
    case signup
    case tabBar
    case main
    case feed
    case add
    case chart
    case profile
}
