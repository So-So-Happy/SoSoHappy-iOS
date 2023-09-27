//
//  FeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/08/25.
//

import UIKit

/*
 궁금한 점
 1. FeedCoordinatorInterface 용도
 2. FeedCoordinator type을 .feed로 해야하는지 .main으로 둬도 되는지
 */

/*
 1. 중복되는 코드 리팩토링
 2. 데이터 넘겨주는 거 작성하기
 */

public protocol FeedCoordinatorInterface {
    func dismiss()
    func finished()
}

// MARK: - Coordinator 만들어주는 중복된 코드가 많아서 FeedCoordinatorFactory 만들어줌 (이게 가장 좋은 방법일지는 잘 모르겠음)
class FeedCoordinatorFactory {
    static func makeFeedDetailCoordinator(navigationController: UINavigationController, navigationSource: FeedNavigationSource) -> FeedDetailCoordinator {
        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: navigationController)
        feedDetailCoordinator.navigationSource = navigationSource
        return feedDetailCoordinator
    }
    
    static func makeOwnerFeedCoordinator(navigationController: UINavigationController) -> OwnerFeedCoordinator {
        let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: navigationController)
        return ownerFeedCoordinator
    }
}


final class FeedCoordinator: Coordinator {
    var type: CoordinatorType { .main }
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    // 실행했을 때 나오는 화면
    func start() {
        let feedReactor = FeedViewReactor()
        let feedVC = FeedViewController(reactor: feedReactor)
        feedVC.delegate = self
        navigationController.pushViewController(feedVC, animated: true)
    }
}

extension FeedCoordinator: FeedViewControllerDelegate {
    func didSelectCell() {
        print("cell 선택함")
//        let feedDetailCoordinator = FeedDetailCoordinator(navigationController: self.navigationController)
//        feedDetailCoordinator.navigationSource = .feedViewController
        let feedDetailCoordinator = FeedCoordinatorFactory.makeFeedDetailCoordinator(navigationController: self.navigationController, navigationSource: .feedViewController)
        feedDetailCoordinator.start()
        self.childCoordinators.append(feedDetailCoordinator)
    }
    
    func didSelectProfileImage() {
        print("프로필 이미지 선택")
//        let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController)
        let ownerFeedCoordinator = FeedCoordinatorFactory.makeOwnerFeedCoordinator(navigationController: self.navigationController)
        ownerFeedCoordinator.start()
        self.childCoordinators.append(ownerFeedCoordinator)
    }
}





