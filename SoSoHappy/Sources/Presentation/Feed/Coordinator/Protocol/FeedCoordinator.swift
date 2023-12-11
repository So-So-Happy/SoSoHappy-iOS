//
//  FeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit

/*
 궁금한 점
 1. FeedCoordinator type을 .feed로 해야하는게 맞지?
 */

/*
 1. 중복되는 코드 리팩토링 - didSelectCell 자체가 많이 중복됨
 2. 데이터 넘겨주는 거 작성하기 (Reactor에 API request 해야할 때 보내야하는것들이 잘 챙겨져 있는지 확인하고 작성하기)
 */

// MARK: - FeedCoordinatorInterface
protocol FeedCoordinatorInterface: Coordinator {
    func showdDetails(feedReactor: FeedReactor) // feed 넘겨주기만 하면 됨 (따로 서버 통신 필요 없음)
    func showOwner(ownerNickName: String) // 조회대상 닉네임이 필요 ('특정 유저 피드 조회'는 서버통신 필요)
}

// MARK: - FeedCoordinator
final class FeedCoordinator: FeedCoordinatorInterface {
    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    // 실행했을 때 나오는 화면
    // MARK: Tab Coordinator에서 한번 딱 실행됨
    func start() {
        let feedViewReactor = FeedViewReactor(
            feedRepository: FeedRepository(),
            userRepository: UserRepository())
        
        let feedVC = FeedViewController(reactor: feedViewReactor, coordinator: self)
        navigationController.pushViewController(feedVC, animated: true)
    }
}

extension FeedCoordinator {
    // MARK: childCoordinators 계속 누적되는 문제
    func showdDetails(feedReactor: FeedReactor) {
        print("---- cell 선택함")
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController, feedReactor: feedReactor, navigatingFrom: .feedViewController)
        feedDetailCoordinator.parentCoordinator = self
//        feedDetailCoordinator.finishDelegate = self
        self.childCoordinators.append(feedDetailCoordinator)
        
//        print("🗂️ (detail) Feed coordinator childCoordinator count : \(childCoordinators.count), controller count : \(navigationController.viewControllers.count)")
        feedDetailCoordinator.start()
    }
    
    func showOwner(ownerNickName: String) {
//        print("2. 프로필 이미지 선택")
//        print("ownerNickName : \(ownerNickName)")
        let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController, ownerNickName: ownerNickName)
        ownerFeedCoordinator.parentCoordinator = self
        self.childCoordinators.append(ownerFeedCoordinator)
        
//        print("🗂️ (owner) Feed coordinator childCoordinator count : \(childCoordinators.count), controller count : \(navigationController.viewControllers.count)")
        ownerFeedCoordinator.start()
    }
}

//extension FeedCoordinator: CoordinatorFinishDelegate {
//    func coordinatorDidFinish(childCoordinator: Coordinator) {
//        if let index = childCoordinators.firstIndex(where: { $0 === childCoordinator }) {
//            childCoordinators.remove(at: index)
//            print("🗂️ Feed coordinator childCoordinator removed, count: \(childCoordinators.count)")
//        }
//    }
//}
