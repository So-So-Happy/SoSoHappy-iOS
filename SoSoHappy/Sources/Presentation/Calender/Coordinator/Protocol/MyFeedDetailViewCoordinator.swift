//
//  DetailViewCoordinator.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/12/06.
//

import UIKit



protocol MyFeedDetailCoordinatorInterface: Coordinator {
    func showDetailView(feed: MyFeed)
    func showAdd1Modal(reactor: MyFeedDetailViewReactor)
    func showAdd2Modal(reactor: MyFeedDetailViewReactor)
    func showLikeListView()
    func dismiss()
    func finished()
}

final class MyFeedDetailCoordinator: MyFeedDetailCoordinatorInterface {

    var type: CoordinatorType { .feed }
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
}

extension MyFeedDetailCoordinator {
    func start() {
    }
    
    func showDetailView(feed: MyFeed) {
        let reactor = MyFeedDetailViewReactor(feedRepository: FeedRepository())
        let detailViewController = MyFeedDetailViewController(reactor: reactor, coordinator: self, feed: feed)
        navigationController.pushViewController(detailViewController, animated: true)
    }
    
    func showAdd1Modal(reactor: MyFeedDetailViewReactor) {
        let setWeatherHappinessViewController = SetWeatherHappinessViewController(
            reactor: reactor,
            coordinator: self
        )
        
        navigationController.present(setWeatherHappinessViewController, animated: true, completion: nil)
    }
    
    func showAdd2Modal(reactor: MyFeedDetailViewReactor) {
        let setCategoryViewController = SetCategoryViewController(
            reactor: reactor,
            coordinator: self
        )
        
        navigationController.present(setCategoryViewController, animated: true, completion: nil)
    }
    
    // TODO: 좋아요 누른 사람 리스트 뷰
    func showLikeListView() {
        
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


