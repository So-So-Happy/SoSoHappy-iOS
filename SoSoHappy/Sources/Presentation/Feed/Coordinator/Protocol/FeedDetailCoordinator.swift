//
//  DetailFeedCoordinator.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/27.
//

import UIKit

enum FeedNavigationSource {
    case feedViewController
    case ownerFeedViewController
}


final class FeedDetailCoordinator: Coordinator {
    var type: CoordinatorType { .main }
    var navigationSource: FeedNavigationSource = .feedViewController
    
    var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    var finishDelegate: CoordinatorFinishDelegate?
    
    init(navigationController: UINavigationController = UINavigationController() ) {
        self.navigationController = navigationController
    }
    
    func start() {
        print("FeedDetailCoordinator START")
        let test = FeedTemp(profileImage: UIImage(named: "profile")!,
                            profileNickName: "구름이", time: "10분 전",
                            isLike: true, weather: "sunny",
                            date: "2023.09.18 월요일",
                            categories: ["sohappy", "coffe", "donut"],
                            content: "오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다.오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다",
                            images: [UIImage(named: "bagel")!]
                            )
        let feedReactor = FeedReactor(feed: test)
        let feedDetailVC = FeedDetailViewController(reactor: feedReactor)
        feedDetailVC.delegate = self
        navigationController.pushViewController(feedDetailVC, animated: true)
    }
}

extension FeedDetailCoordinator: FeedDetailViewControllerDelegate {
    func didSelectProfileImage() {
        print("FeedDetailViewController에서 프로필 이미지 선택함")
        switch navigationSource {
        case .feedViewController:
//            let ownerFeedCoordinator = OwnerFeedCoordinator(navigationController: self.navigationController)
            let ownerFeedCoordinator = FeedCoordinatorFactory.makeOwnerFeedCoordinator(navigationController: self.navigationController)
            
            ownerFeedCoordinator.start()
            self.childCoordinators.append(ownerFeedCoordinator)
        default: break
        }
    }
}
