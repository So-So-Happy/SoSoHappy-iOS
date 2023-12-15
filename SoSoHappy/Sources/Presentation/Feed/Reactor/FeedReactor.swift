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
    
    enum Action {
        case fetchFeed
        case toggleLike
    }
    
    enum Mutation {
        case setUserFeed(UserFeed?)
        case setLike(Bool)
    }
    
    struct State {
        var userFeed: UserFeed?
        var isLike: Bool?
    }
    
    let initialState: State
    
    init(userFeed: UserFeed, feedRepository: FeedRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        initialState = State(userFeed: userFeed)
        self.feedRepository = feedRepository
        self.userRepository = userRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        guard let userFeed = initialState.userFeed else { return .empty() }
        let dstNickname: String = userFeed.nickName // 피드 주인 닉네임
        let provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
        let srcNickname = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName") ?? "" // 내 닉네임
        let date: Int64 = userFeed.dateFormattedInt64 // 피드의 date
        
        switch action {
        case .fetchFeed:
            print("FeedReactor - fetchFeed")
            
            return feedRepository.findDetailFeed(request: FindDetailFeedRequest(date: date, dstNickname: dstNickname, srcNickname: srcNickname))
                .flatMap { userFeed in // 이벤트 순서 유지,
                    print("FeedReactor - userFeed : \(userFeed)")
                    guard let userFeed = userFeed else {
                        print("FeedReactor - nil : \(userFeed)")
                        return Observable.just(userFeed)
                    }
                    
                    if let cachedImage = ImageCache.shared.cache[userFeed.nickName] {
                        print("FeedReactor - ⭕️ 캐시에 있음 - feed REACTOR nickname : \(userFeed.nickName)")
                        var userFeedWithCachedProfileImage = userFeed
                        userFeedWithCachedProfileImage.profileImage = cachedImage
                        return Observable.just(userFeedWithCachedProfileImage)
                    }
                    
                    print("FeedReactor - feed REACTOR if let 밖")
                    return self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: userFeed.nickName))
                        .map { profileImage in
                            var userFeedWithProfileImage = userFeed
                            userFeedWithProfileImage.profileImage = profileImage
                            ImageCache.shared.cache[userFeed.nickName] = profileImage
                            return userFeedWithProfileImage
                        }
                        .catch { error in
                            print("FeedReactor - 🚫 Feed reactor findProfileImg error : \(error.localizedDescription), error nickname : \(userFeed.nickName)")
                            return Observable.just(userFeed)
                        }
                }
                .map { Mutation.setUserFeed($0) }

            
        case .toggleLike:
            print("toggleLike muate")
            return feedRepository.updateLike(request: UpdateLikeRequest(srcNickname: srcNickname, nickname: dstNickname, date: date))
                .map { Mutation.setLike($0) }
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        print("FeedReactor - reduce - ")
        var state = state
        switch mutation {
        case .setUserFeed(let userFeed):
            print("FeedReactor - reduce - FeedReactor- setUserFeed")
            state.userFeed = userFeed
        case let .setLike(isLike):
            print("FeedReactor - reduce - FeedReactor- setLike")
            state.isLike = isLike
        }
        return state
    }
}
