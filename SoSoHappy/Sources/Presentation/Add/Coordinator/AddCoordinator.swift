//
//  AddCoordinator.swift
//  SoSoHappy
//
//  Created by 박민주 on 2023/08/09.
//


import UIKit

enum AddNavigationSource {
    case addstep2
    case addstep3
}


protocol AddCoordinatorInterface: Coordinator {
    func dismiss()
    func showNextAdd(reactor: AddViewReactor, navigateTo: AddNavigationSource)
    func navigateBack()
}

final class AddCoordinator: AddCoordinatorInterface {
    var type: CoordinatorType { .add }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        let addViewReactor = AddViewReactor(feedRepository: FeedRepository())
        let addStep1VC = AddStep1ViewController(reactor: addViewReactor, coordinator: self)
        navigationController.pushViewController(addStep1VC, animated: true)
        print("🗂️ 쌓여 있는 AddCoordinator -  VC: \(navigationController.viewControllers.count)개")
        print("ADD coordinator count - start: \(parentCoordinator?.childCoordinators.count)")
    }
}

extension AddCoordinator {
    // MARK: 모달 내리기
    func dismiss() {
        print("dismissed")
        navigationController.dismiss(animated: true)
        print("🗂️ Dismiss 후 쌓여 있는 AddCoordinator -  VC: \(navigationController.viewControllers.count)개")
        // 이걸 해줘야 하나? 이걸 안해주면 Add 볼 때마다 addCoordinator가 추가가 됨
        
        parentCoordinator?.childDidFinish(self, parent: parentCoordinator)
        print("ADD coordinator count - dismiss : \(parentCoordinator?.childCoordinators.count)")
    }
    
    // MARK: 다음 VC로 이동
    func showNextAdd(reactor: AddViewReactor, navigateTo: AddNavigationSource) {
        switch navigateTo {
        case .addstep2:
            let addStep2VC = AddStep2ViewController(reactor: reactor, coordinator: self)
            navigationController.pushViewController(addStep2VC, animated: true)
            print("🗂️ 쌓여 있는 AddCoordinator  addstep2-  VC: \(navigationController.viewControllers.count)개")
        case .addstep3:
            let addStep3VC = AddStep3ViewController(reactor: reactor, coordinator: self)
            navigationController.pushViewController(addStep3VC, animated: true)
            print("🗂️ 쌓여 있는 AddCoordinator  addStep3-  VC: \(navigationController.viewControllers.count)개")
        }
    }
    
    // MARK: 이전 VC로 돌아가기
    func navigateBack() {
        navigationController.popViewController(animated: true)
    }
}
