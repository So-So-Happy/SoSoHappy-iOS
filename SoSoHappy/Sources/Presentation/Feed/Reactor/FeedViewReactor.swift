//
//  FeedViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/05.
//

import ReactorKit

/*
 피드 조회 (오늘 - date 입력, 전체 - date 입력 x)
 nickName: String
 date: Int
 page: Int
 size: Int
 
 */

/*
 response
 nickName: String   // "admin1"
 weather: String    // "sunny"
 date: Int          // 2023090913248392
 happiness: Int     // 3
 text: String       // "hi~"
 categoryList: [String] // ["coffee"]
 imageList: [바이트]   // []
 isLiked: Bool      // false
 */


enum SortOption {
    case today
    case total
}

class FeedViewReactor: Reactor {
    enum Action {
        case refresh
        case fetchFeeds(SortOption)
        case selectedCell(index: Int)
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case setFeeds([FeedTemp])
        case sortOption(SortOption)
        case selectedCell(index: Int)
    }
    
    struct State {
        var isRefreshing: Bool = false
        var feeds: [FeedTemp] = []
        var sortOption: SortOption = .today
        var selectedFeed: FeedTemp?
    }
    
    let initialState: State
    
    init() {
        initialState = State()
    }
    
    var forTest: [FeedTemp] = [
        FeedTemp(profileImage: UIImage(named: "profile")!,
                                profileNickName: "구름이", time: "10분 전",
                                isLike: true, weather: "sunny",
                                feedDate: "2023.09.18 월요일",
                                categories: ["sohappy", "coffe", "donut"],
                                content: "오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다.오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다",
                                images: [UIImage(named: "bagel")!]
                                ),
        FeedTemp(profileImage: UIImage(named: "cafe")!,
                                profileNickName: "날씨조아", time: "15분 전",
                                isLike: false, weather: "rainy",
                                feedDate: "2023.09.07 목요일",
                                categories: ["sohappy", "coffe", "coffe"],
                                content: "오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다.오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다",
                                images: []
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

        case let .fetchFeeds(sortOption):
            return fetchFeedBySortOption(sortOption)
            
        case let .selectedCell(index):
            return Observable.just(.selectedCell(index: index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            
        case let .setFeeds(feeds):
            state.feeds = forTest
            
        case let .sortOption(sort):
            state.sortOption = sort
            
        case let .selectedCell(index):
            print("선택했음")
            state.selectedFeed = state.feeds[index]
            
        }
        
        return state
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

