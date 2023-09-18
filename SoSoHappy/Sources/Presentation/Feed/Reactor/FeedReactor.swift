//
//  FeedCellReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/05.
//

/*
 1. isLike 를 프로퍼티로 하나 빼는게 좋을지 아니면 feed에서 빼서 쓰는게 좋을지 고민
 */

import ReactorKit

class FeedReactor: Reactor {
    enum Action {
        case toggleLike
    }
    
    enum Mutation {
        case setFeed(Feed)
    }
    
    struct State {
        var feed: Feed?
    }
    
    let initialState: State
    
    // MARK: 방법 1
//    init(state: State) {
//        self.initialState = state
//    }
    
    // MARK: 방법 2
    init(feed: Feed) {
        initialState = State(feed: feed)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .toggleLike:
            // Toggle the like state and emit a Mutation to update the UI
            guard var updatedFeed = currentState.feed else { fatalError() }
            updatedFeed.isLike = !updatedFeed.isLike
            // update된 피드 서버에도 알려주기
            return Observable.just(.setFeed(updatedFeed))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
//        case let .setLike(like):
//            newState.isLike = like
        case .setFeed(let feed):
            newState.feed = feed
        }
        
        return newState
    }
}

