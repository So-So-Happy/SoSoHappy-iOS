//
//  FeedCellReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/05.
//

/*
 1. isLike 를 프로퍼티로 하나 빼는게 좋을지 아니면 feed에서 빼서 쓰는게 좋을지 고민
 */

/*
 특정 유저 피드 조회
 - date: Int
 - dstNickName: String // 피드 주인 닉네임
 - srcNickName: String // 조회하는 유저 닉네임
 */


/*
 좋아요 post
 srcNickName: String    // 변경하는 유저 닉네임
 date: Int              // 2023090509083231
 nickName: String       // 피드 주인 닉네임
 */

/*
 response
 isLike: Bool // true
 */

import ReactorKit

class FeedReactor: Reactor {
//    let dataUpdated = PublishSubject<Void>()
    
    enum Action {
        case fetchFeed
        case toggleLike
    }
    
    enum Mutation {
        case setFeed(FeedTemp)
    }
    
    struct State {
        var feed: FeedTemp?
    }
    
    let initialState: State
    
    let forTest: FeedTemp = FeedTemp(profileImage: UIImage(named: "profile")!,
                              profileNickName: "구름이", time: "10분 전",
                              isLike: true, weather: "sunny",
                              feedDate: "2023.09.18 월요일",
                              categories: ["sohappy", "coffe", "donut"],
                              content: "오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다.오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다",
                              images: [UIImage(named: "bagel")!]
                              ) // FeedTemp?
    
    // MARK: 방법 1
//    init(state: State) {
//        self.initialState = state
//    }
    
    // MARK: 방법 2
    init(feed: FeedTemp) {
        initialState = State(feed: feed)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchFeed:
            guard var feed = currentState.feed else { fatalError() }
            print("FeedReactor - feed : \(feed)")
            // 서버에 feed.profileNickName, feed.feedDate (Int로 변환해서) request
            let responsedFeed = feed // 임의로 넣어줌
            return Observable.just(.setFeed(responsedFeed))
        case .toggleLike:
            print("muate: toggleLike")
            // 서버에 requset
            // response로 isLike를 받음
            guard var updatedFeed = currentState.feed else { fatalError() }
            updatedFeed.isLike = !updatedFeed.isLike // repsonse 받은 like 값 넣어주기
            // update된 피드 서버에도 알려주기
            return Observable.just(.setFeed(updatedFeed))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        print("reduce - ")
        var newState = state
        // MARK: FeedViewController에서 FeedReactor를 만들어서 넣어주기보다는 FeedReactor를 state의 property로 만들어서 반환해주는 것도 좋을 것 같음
        switch mutation {
        case .setFeed(let feed):
            print("reduce - setFeed")
            newState.feed = feed
        }
        return newState
    }
}
