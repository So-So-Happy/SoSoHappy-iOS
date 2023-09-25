//
//  HappyListViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/21.
//

import ReactorKit

class HappyListViewReactor: Reactor {
    enum Action {
        case fetchRecentSortedFeeds(String) // year + month.
    }
    
    enum Mutation {
        case setFeeds([FeedTemp])
    }
    
    struct State {
        var feeds: [FeedTemp] = []
    }
    
    let initialState: State
    
    init() {
        initialState = State()
    }
    
    var forTest: [FeedTemp] = [
        FeedTemp(profileImage: UIImage(named: "profile")!,
                                profileNickName: "구름이", time: "10분 전",
                                isLike: true, weather: "sunny",
                                date: "2023.09.18 월요일",
                                categories: ["sohappy", "coffe", "donut"],
                                content: "오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다.오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다",
                                images: [UIImage(named: "bagel")!]
                                ),
        FeedTemp(profileImage: UIImage(named: "cafe")!,
                                profileNickName: "날씨조아", time: "15분 전",
                                isLike: false, weather: "rainy",
                                date: "2023.09.07 목요일",
                                categories: ["sohappy", "coffe", "coffe"],
                                content: "오호라 잘 나타나는구만",
                                images: []
                                )
    ]
    //[UIImage(named: "cafe")!, UIImage(named: "churros")!]
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchRecentSortedFeeds(yearAndMonth):
            // 서버로부터 해당 년도(year) 월(month)의 최신순 feed 받아오기
            let fetchedFeeds = forTest
            return Observable.just(.setFeeds(fetchedFeeds))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setFeeds(feeds):
            newState.feeds = feeds
        }
        
        return newState
    }
}
