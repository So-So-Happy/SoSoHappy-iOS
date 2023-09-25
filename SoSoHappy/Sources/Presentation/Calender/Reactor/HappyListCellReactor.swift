//
//  HappyListCellReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/21.
//

import ReactorKit

class HappyListCellReactor: Reactor {
    typealias Action = NoAction
    
    let initialState: State
    
    struct State {
        var feed: FeedTemp?
    }
    
    init(feed: FeedTemp) {
        initialState = State(feed: feed)
    }
}
