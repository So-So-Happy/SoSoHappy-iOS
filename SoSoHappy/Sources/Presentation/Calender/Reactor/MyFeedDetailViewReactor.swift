//
//  MyFeedDetailViewReactor.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/11/05.
//


import ReactorKit
import Moya
import RxSwift


class MyFeedDetailViewReactor: Reactor {
    
    let disposeBag = DisposeBag()
    
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    var currentPage: Int64
    
    let initialState: State
    
    init(
        feedRepository: FeedRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        currentPage: Int64,
        state: State = State(feed: nil)
    ) {
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.currentPage = currentPage
        self.initialState = state
    }
    
    
    enum Action {
        case viewWillAppear
    }
    
    enum Mutation {
        case setDetailView(MyFeed)
    }
    
    struct State {
        var feed: MyFeed?
    }
    
    
    func mutation(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return feedRepository.findDayFeed(request: FindFeedRequest(date: currentPage, nickName: "happykyung"))
                .map { .setDetailView($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setDetailView(let feed):
            newState.feed = feed
        }
        return newState
    }
}

