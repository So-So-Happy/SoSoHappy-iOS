//
//  FeedCellReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/05.
//

import ReactorKit

class FeedReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    
    enum Action {
        case fetchFeed
        case toggleLike
    }
    
    enum Mutation {
        case setUserFeed(UserFeed)
        case setLike(Bool)
    }
    
    struct State {
        var userFeed: UserFeed
        var isLike: Bool?
    }
    
    let initialState: State
    
    init(userFeed: UserFeed, feedRepository: FeedRepositoryProtocol) {
        initialState = State(userFeed: userFeed)
        self.feedRepository = feedRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchFeed:
            let dstNickname: String = currentState.userFeed.nickName // 피드 주인 닉네임
            let srcNickname: String = "디저트 러버" // 조회하는 유저 닉네임
            let date: Int64 = currentState.userFeed.dateFormattedInt64 // 피드의 date
            return feedRepository.findDetailFeed(request: FindDetailFeedRequest(date: date, dstNickname: dstNickname, srcNickname: srcNickname))
                .map { Mutation.setUserFeed($0) }
            
            
        case .toggleLike:
            print("muate: toggleLike")
            // 서버에 requset
            // response로 isLike를 받음
            let srcNickname: String = "디저트러버" // 변경하는 유저 닉네임
            let nickName: String = currentState.userFeed.nickName // 피드 주인 닉네임
            let date = currentState.userFeed.dateFormattedInt64
            return feedRepository.updateLike(request: UpdateLikeRequest(srcNickname: srcNickname, nickname: nickName, date: date))
                .map { Mutation.setLike($0) }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        print("reduce - ")
        var newState = state
        // MARK: FeedViewController에서 FeedReactor를 만들어서 넣어주기보다는 FeedReactor를 state의 property로 만들어서 반환해주는 것도 좋을 것 같음
        switch mutation {
        case .setUserFeed(let userFeed):
            print("reduce - FeedReactor- setUserFeed")
            newState.userFeed = userFeed
        case let .setLike(isLike):
            newState.isLike = isLike
        }
        return newState
    }
}

