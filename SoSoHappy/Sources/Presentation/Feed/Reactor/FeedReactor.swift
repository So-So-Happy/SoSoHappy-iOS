//
//  FeedCellReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/05.
//

import ReactorKit

final class FeedReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    let initialState: State
    
    enum Action {
        case fetchFeed
        case toggleLike
        case reportProblem(ServerReport)
    }
    
    enum Mutation {
        case setUserFeed(UserFeed?)
        case setLike(Bool)
        case showNetworkErrorView(Bool) // 네트워크 에러
        case showServerErrorAlert(Bool) // 500에러
        case isReportProcessSucceded(Bool?)
    }
    
    struct State {
        var userFeed: UserFeed?
        var isLike: Bool?
        var showNetworkErrorView: Bool? // 네트워크 처리
        var showServerErrorAlert: Bool? // 500
        var isReportProcessSucceded: Bool?
    }
    
    init(userFeed: UserFeed, feedRepository: FeedRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        initialState = State(userFeed: userFeed)
        self.feedRepository = feedRepository
        self.userRepository = userRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        if !Connectivity.isConnectedToInternet() {
            return .just(.showNetworkErrorView(true))
        }
    
        guard let userFeed = initialState.userFeed else { return .empty() }
        let dstNickname: String = userFeed.nickName // 피드 주인 닉네임
        let srcNickname = KeychainService.getNickName()
        let date: Int64 = userFeed.dateFormattedInt64 // 피드의 date
       
        switch action {
        case .fetchFeed:
            return .concat([
                .just(.showNetworkErrorView(false)),
                findDetailUserFeed(dstNickname: dstNickname, srcNickname: srcNickname, date: date)
            ])
            
        case .toggleLike:
            return feedRepository.updateLike(request: UpdateLikeRequest(srcNickname: srcNickname, nickname: dstNickname, date: date))
                .map { Mutation.setLike($0) }
                .catch { _ in
                    return .concat([
                        .just(.showServerErrorAlert(true)),
                        .just(.showServerErrorAlert(false))
                    ])
                }
            
        case .reportProblem(_):
            return .concat([
                userRepository.block(request: BlockRequest(srcNickname: srcNickname, dstNickname: dstNickname))
                    .map { Mutation.isReportProcessSucceded($0) }
                    .catch({ _ in
                        return .concat([
                            .just(.showServerErrorAlert(true)),
                            .just(.showServerErrorAlert(false))
                        ])
                    }),
                
                .just(.isReportProcessSucceded(nil))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setUserFeed(let userFeed):
            state.userFeed = userFeed
        case .setLike(let isLike):
            if let feed = state.userFeed {
                var updatedFeed = feed
                updatedFeed.isLiked = isLike
                state.userFeed = updatedFeed
                state.isLike = isLike
            }
            
        case .showNetworkErrorView(let showNetworkErrorView):
            state.showNetworkErrorView = showNetworkErrorView
            
        case .showServerErrorAlert(let showServerErrorAlert):
            state.showServerErrorAlert = showServerErrorAlert
            
        case let .isReportProcessSucceded(isReportProcessSucceded):
            state.isReportProcessSucceded = isReportProcessSucceded
        
        }
        return state
    }
}

extension FeedReactor {
    func findDetailUserFeed(dstNickname: String, srcNickname: String, date: Int64) -> Observable<Mutation> {
        
        return feedRepository.findDetailFeed(request: FindDetailFeedRequest(date: date, dstNickname: dstNickname, srcNickname: srcNickname))
           .flatMap { userFeed in
               guard let userFeed = userFeed else {
                   return Observable.just(userFeed)
               }
               
               if let cachedImage = ProfileImageCache.shared.cache[userFeed.nickName] {
                   var userFeedWithCachedProfileImage = userFeed
                   userFeedWithCachedProfileImage.profileImage = cachedImage
                   return Observable.just(userFeedWithCachedProfileImage)
               }
               
               return self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: userFeed.nickName))
                   .map { profileImage in
                       var userFeedWithProfileImage = userFeed
                       userFeedWithProfileImage.profileImage = profileImage
                       ProfileImageCache.shared.cache[userFeed.nickName] = profileImage
                       return userFeedWithProfileImage
                   }
                   .catch { _ in
                       return Observable.just(userFeed)
                   }
           }
           .map { Mutation.setUserFeed($0) }
           .catch { _ in
               return .concat([
                .just(.showServerErrorAlert(true)),
                .just(.showServerErrorAlert(false))
               ])
           }
        
    }
}
