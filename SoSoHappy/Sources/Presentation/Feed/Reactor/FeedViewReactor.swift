//
//  FeedViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/05.
//

import ReactorKit

enum SortOption {
    case today
    case total
}

class FeedViewReactor: Reactor {
    enum Action {
        case refresh
        case fetchTodayFeeds
        case fetchTotalFeeds
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case setFeeds([FeedTemp])
        case sortOption(SortOption)
    }
    
    struct State {
        var isRefreshing: Bool = false
        var feeds: [FeedTemp] = []
        var sortOption: SortOption = .today
    }
    
    let initialState: State
    
    init() {
        initialState = State()
    }
    
    var forTest: [FeedTemp] = [
        FeedTemp(profileImage: UIImage(named: "profile")!,
                                profileNickName: "Reactor", time: "10분 전",
                                isLike: true, weather: "sunny",
                                date: "2023.09.08 금요일",
                                categories: ["sohappy", "coffe", "donut"],
                                content: "엥 이거 왜 안나타나지?",
                                images: [UIImage(named: "bagel")!]
                                ),
        FeedTemp(profileImage: UIImage(named: "cafe")!,
                                profileNickName: "Reactor22", time: "15분 전",
                                isLike: false, weather: "rainy",
                                date: "2023.09.07 목요일",
                                categories: ["sohappy", "coffe", "coffe"],
                                content: "오호라 잘 나타나는구만",
                                images: [UIImage(named: "cafe")!, UIImage(named: "churros")!]
                                )
    ]
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            // currentState.sortOption에 따라 달라짐
            return Observable.concat([
                Observable.just(.setRefreshing(true)).delay(.seconds(3), scheduler: MainScheduler.instance),
                fetchFeedBySortOption(currentState.sortOption),
//              UserService.users().map(Mutation.setUsers),
              Observable.just(.setRefreshing(false))
            ])
            
        case .fetchTodayFeeds: // 오늘
            return fetchFeedBySortOption(.today)

        case .fetchTotalFeeds: // 전체
            return fetchFeedBySortOption(.total)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case let .setFeeds(feeds):
            newState.feeds = forTest
            
        case let .sortOption(sort):
            newState.sortOption = sort
            
        }
        return newState
    }
    
    private func fetchFeedBySortOption(_ sortOption: SortOption) -> Observable<Mutation> {
        let fetchedFeeds: [FeedTemp] = []
        // sortOption에 따라서 feed를 fetch - today, total
        
        // API 통신 부분 코드 작성할 때 AlertReactor 코드 참고해보기
        // UserService.users().map(Mutation.setUsers),
        // 통신해서 받아온 feed들을 Mutation.setFeeds로 map
        return  Observable.concat([
            Observable.just(Mutation.sortOption(sortOption)),
            Observable.just(Mutation.setFeeds(fetchedFeeds))
        ])

    }
}

