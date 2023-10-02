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
        case toggleLike
    }
    
    enum Mutation {
        case setFeed(FeedTemp)
    }
    
    struct State {
        var feed: FeedTemp?
    }
    
    let initialState: State
    
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
        switch mutation {
        case .setFeed(let feed):
            print("reduce - setFeed")
            newState.feed = feed
        }
        return newState
    }
}
