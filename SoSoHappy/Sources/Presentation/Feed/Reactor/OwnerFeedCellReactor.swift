//
//  OwnerFeedCellReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/11.
//

import ReactorKit

//class OwnerFeedCellReactor: Reactor {
//    enum Action {
//        case toggleLike
//    }
//    
//    enum Mutation {
//        case setFeed(FeedTemp)
//    }
//    
//    struct State {
//        var feed: FeedTemp?
//    }
//    
//    let initialState: State
//    
//    init(state: State) {
//        self.initialState = state
//    }
//    
//    func mutate(action: Action) -> Observable<Mutation> {
//        switch action {
//        case .toggleLike:
//            // Toggle the like state and emit a Mutation to update the UI
//            guard var updatedFeed = currentState.feed else { fatalError() }
//            updatedFeed.isLike = !updatedFeed.isLike
//            // update된 피드 서버에도 알려주기
//            return Observable.just(.setFeed(updatedFeed))
//        }
//    }
//    
//    func reduce(state: State, mutation: Mutation) -> State {
//        var newState = state
//        switch mutation {
////        case let .setLike(like):
////            newState.isLike = like
//        case .setFeed(let feed):
//            newState.feed = feed
//        }
//        
//        return newState
//    }
//}
//
//
