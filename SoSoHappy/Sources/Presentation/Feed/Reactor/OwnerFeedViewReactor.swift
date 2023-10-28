//
//  OwnFeedViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/11.
//

import ReactorKit

/*
 1. refresh control dealy 이런거 직접 통신해보면서 조정
 */

final class OwnerFeedViewReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    enum Action {
        case refresh
        case fetchFeeds
        case selectedCell(index: Int)
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case isLoading(Bool) // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        case setProfile(Profile)
        case setFeeds([UserFeed])
        case selectedCell(index: Int)
    }
    
    struct State {
        var isRefreshing: Bool = false
        var isLoading: Bool? // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        var profile: Profile?
        var userFeeds: [UserFeed]?
        var selectedFeed: UserFeed?
        var ownerNickName: String
    }
    
    let initialState: State
    
    init(ownerNickName: String, feedRepository: FeedRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        initialState = State(ownerNickName: ownerNickName)
        self.feedRepository = feedRepository
        self.userRepository = userRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            let srcNickname: String = "디저트러버" // 조회하는 유저 nickname
            let dstNickname: String = currentState.ownerNickName // 조회 대상 nickname
            
            return .concat([
                .just(.setRefreshing(true)).delay(.seconds(3), scheduler: MainScheduler.instance),
                // HEADER - 프로필 이미지, 닉네임, 한 줄 소개
                userRepository.findIntroduction(request: FindIntroductionRequest(nickname: dstNickname))
                    .flatMap { introduction in
                        return self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: dstNickname))
                            .map { profileImg in
                                return Profile(email: "", nickName: dstNickname, profileImg: profileImg, introduction: introduction)
                            }
                    }
                    .map { Mutation.setProfile($0)},
                
                feedRepository.findUserFeed(request: FindUserFeedRequest(srcNickname: srcNickname, dstNickname: dstNickname, page: 0, size: 7))
                    .map { Mutation.setFeeds($0) },
                
                .just(.setRefreshing(false))
            ])
            
        case .fetchFeeds:
            print("fetchFeeds")
            let srcNickname: String = "디저트러버" // 조회하는 유저 nickname
            let dstNickname: String = currentState.ownerNickName // 조회 대상 nickname
            
            return .concat([
                .just(.isLoading(true)),
                userRepository.findIntroduction(request: FindIntroductionRequest(nickname: dstNickname))
                    .flatMap { introduction in
                        return self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: dstNickname))
                            .map { profileImg in
                                return Profile(email: "", nickName: dstNickname, profileImg: profileImg, introduction: introduction)
                            }
                    }
                    .map { Mutation.setProfile($0)},
                
                feedRepository.findUserFeed(request: FindUserFeedRequest(srcNickname: srcNickname, dstNickname: dstNickname, page: 0, size: 7))
                    .map { Mutation.setFeeds($0) }
                    .delay(.seconds(1), scheduler: MainScheduler.instance),
                
                .just(.isLoading(false))
                
            ])
            
        case let .selectedCell(index):
            return Observable.just(.selectedCell(index: index))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
        case let .setProfile(profile):
            print("reduce - setProfile  : \(profile)")
            state.profile = profile
            state.selectedFeed = nil
            
        case let .setFeeds(feeds):
            print("reduce - setFeeds  : \(feeds)")
            state.userFeeds = feeds
//            state.selectedFeed = nil
            
        case let .selectedCell(index):
            print("선택했음")
            if let userFeeds = state.userFeeds {
                state.selectedFeed = userFeeds[index]
            }
        }
        
        return state
    }
}


/*
 case .fetchFeeds:
     // MARK: 일단은 Loading 없이 이렇게 처리함 (실제로 서버 연결해보면서 확인해보기)
     let fetchedFeeds: [FeedTemp] = []
     let profile = testProfile
     
     return Observable.concat([
         Observable.just(Mutation.profile(profile)),
         Observable.just(Mutation.setFeeds(fetchedFeeds))
     ])
     
 case .refresh:
     let fetchedFeeds: [FeedTemp] = []
     let profile = testProfile
     print("refreshed")
     return Observable.concat([
         Observable.just(.setRefreshing(true)).delay(.seconds(3), scheduler: MainScheduler.instance),
         //              UserService.users().map(Mutation.setUsers),
         // user 프로필도 불러와야 함
         Observable.just(Mutation.profile(profile)),
         Observable.just(Mutation.setFeeds(fetchedFeeds)), // 통신해서 받아온 feed들을 Mutation.setFeeds로 map
         Observable.just(.setRefreshing(false))
     ])
 */
