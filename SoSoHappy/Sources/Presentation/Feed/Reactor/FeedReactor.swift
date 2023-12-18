//
//  FeedCellReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/05.
//

import ReactorKit

enum FeedError {
    case showNetworkErrorView
    case showServerErrorAlert
    case none
}

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
        case handleFeedError(FeedError)
//        case showNetworkErrorView(Bool)
//        case showServerErrorAlert(Bool) // 500에러
    }
    
    struct State {
        var userFeed: UserFeed?
        var isLike: Bool?
        var handleFeedError: FeedError?
//        var showNetworkErrorView: Bool? // 네트워크 처리
//        var showServerErrorAlert: Bool? // 500
    }
    
    let initialState: State
    
    init(userFeed: UserFeed, feedRepository: FeedRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        initialState = State(userFeed: userFeed)
        self.feedRepository = feedRepository
        self.userRepository = userRepository
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        if !Connectivity.isConnectedToInternet() {
            print("FeedReactor 인터넷 ❌")
            return .concat([
                .just(.handleFeedError(.showNetworkErrorView)), // 네트워크 연결안될 때
                .just(.handleFeedError(.none))
            ])
        }
        print("FeedReactor 인터넷 ⭕️")
        
        guard let userFeed = initialState.userFeed else { return .empty() }
        let dstNickname: String = userFeed.nickName // 피드 주인 닉네임
        let provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
        let srcNickname = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName") ?? "" // 내 닉네임
        let date: Int64 = userFeed.dateFormattedInt64 // 피드의 date
        
        switch action {
        case .fetchFeed:
            print("FeedReactor - fetchFeed (1)")
            
            print("FeedReactor - fetchFeed (2)")
            return feedRepository.findDetailFeed(request: FindDetailFeedRequest(date: date, dstNickname: dstNickname, srcNickname: srcNickname))
                .flatMap { userFeed in // 이벤트 순서 유지,
                    print("FeedReactor - userFeed : \(userFeed)")
                    
                    // MARK: 원본 코드
                    guard let userFeed = userFeed else {
                        print("FeedReactor - nil (inside guard let) : \(userFeed)")
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
                .map {
                    print("FeedReactor - 85번째 줄 - return Mutation.setUserFeed : \($0)")
                    return Mutation.setUserFeed($0)
                }
                .catch { _ in
                    return .concat([
                        .just(.handleFeedError(.showServerErrorAlert)),
                        .just(.handleFeedError(.none))
                    ])
                
                }

        case .toggleLike:

            print("toggleLike muate")
            return feedRepository.updateLike(request: UpdateLikeRequest(srcNickname: srcNickname, nickname: dstNickname, date: date))
                .map { Mutation.setLike($0) }
                .catch { _ in
                    return .concat([
                        .just(.handleFeedError(.showServerErrorAlert)),
                        .just(.handleFeedError(.none))
                    ])
                }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        print("FeedReactor - reduce - ")
        var state = state
        switch mutation {
        case .setUserFeed(let userFeed):
            print("FeedReactor - reduce - setUserFeed : \(userFeed)")
            state.userFeed = userFeed
        case .setLike(let isLike):
            print("FeedReactor - reduce - setLike : \(isLike)")
            if let feed = state.userFeed {
                var updatedFeed = feed
                updatedFeed.isLiked = isLike
                state.userFeed = updatedFeed
                state.isLike = isLike
            }
            
        case .handleFeedError(let handleFeedError):
            print("FeedReactor - reduce - handleFeedError : \(handleFeedError)")
            state.handleFeedError = handleFeedError
        
        }
        return state
    }
}
