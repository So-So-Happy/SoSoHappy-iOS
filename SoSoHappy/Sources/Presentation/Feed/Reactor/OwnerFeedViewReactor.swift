//
//  OwnFeedViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/11.
//

import ReactorKit

/*
 1. refresh control dealy 이런거 직접 통신해보면서 조정
 2. 서버 결과 userFeeds가 비어있을 때( [ ] ) 넘길 Observable 처리
 3. 올라온 게시물이 없습니다 처리
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
//        case setNickName(String)
        case setProfileImage(UIImage)
        case setSelfIntroduction(String)
//        case setProfile(Profile)
        case setFeeds([UserFeed])
        case selectedCell(index: Int)
    }
    
    struct State {
        var isRefreshing: Bool?
        var isLoading: Bool? // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        var profile: Profile?
        var profileImage: UIImage?
        var selfIntroduction: String?
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
                fetchUserInformation(),
                .just(.setRefreshing(false))
            ])
            
        case .fetchFeeds:
            print("fetchFeeds")
            let srcNickname: String = "디저트러버" // 조회하는 유저 nickname
            let dstNickname: String = currentState.ownerNickName // 조회 대상 nickname
            
            return .concat([
                .just(.isLoading(true)),
                fetchUserInformation(),
                .just(.isLoading(false))
                
            ])
            
        case let .selectedCell(index):
            return Observable.just(.selectedCell(index: index))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case let .isLoading(isLoading):
            newState.isLoading = isLoading
            newState.selectedFeed = nil
            
        case let .setProfileImage(profileImage):
            newState.profileImage = profileImage
            newState.ownerNickName = state.ownerNickName
            
        case let .setSelfIntroduction(selfIntro):
            newState.selfIntroduction = selfIntro
            newState.profile = Profile(email: "", nickName: currentState.ownerNickName, profileImg: currentState.profileImage ?? UIImage(named: "profile")!, introduction: selfIntro)
            
        case let .setFeeds(feeds):
            print("reduce - setFeeds  : \(feeds)")
            newState.userFeeds = feeds
//            state.selectedFeed = nil
            
        case let .selectedCell(index):
            print("선택했음")
            if let userFeeds = state.userFeeds {
                newState.selectedFeed = userFeeds[index]
                /*
                 FeedDetail에서 OwnerFeedVC로 돌아올 때 남아있는 currentState.userFeeds가 있기 때문에
                 isLoading animating될 때 이미 기존에 받아와서 display된 cell들 위에 돌아가게 됨.
                 사용자 보기에 안 좋음
                 그렇다고 nil을 설정하는건 안됨 -> compactMap으로 처리해서 nil은 아예 통과 자체가 안됨
                 */
                
                newState.userFeeds = []
            }
        }
        
        return newState
    }
}

extension OwnerFeedViewReactor {
    func fetchUserInformation() -> Observable<Mutation> {
        
        let srcNickname: String = "디저트러버" // 조회하는 유저 nickname
        let dstNickname: String = currentState.ownerNickName // 조회 대상 nickname
        
        return .concat([
            fetchProfileImage(owner: currentState.ownerNickName),
            fetchSelfIntroduction(owner: currentState.ownerNickName),
            feedRepository.findUserFeed(request: FindUserFeedRequest(srcNickname: srcNickname, dstNickname: dstNickname, page: 0, size: 7))
                .map { Mutation.setFeeds($0) }
                .delay(.seconds(1), scheduler: MainScheduler.instance)
        ])
    }
    
    
    
    
    private func fetchProfileImage(owner dstNickname: String) -> Observable<Mutation> {
        if let cachedImage = ImageCache.shared.cache[dstNickname] {
            print("⭕️ 사진 캐시에 있음 - Owner Feed View REACTOR nickname : \(dstNickname)")
            
            return .just(.setProfileImage(cachedImage))
        }
        
        return self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: dstNickname))
            .map {
                ImageCache.shared.cache[dstNickname] = $0
                return Mutation.setProfileImage($0)
            }
            .catch { error in
                print("🚫 Owner feed view reactor findProfileImg error : \(error.localizedDescription), error nickname : \(dstNickname)")
                
                return .just(.setProfileImage(UIImage(named: "profile")!))
            }
    }
    
    private func fetchSelfIntroduction(owner dstNickname: String) -> Observable<Mutation> {
        
        if let cachedSelfIntro = SelfIntroductionCache.shared.cache[dstNickname] {
            print("⭕️ 자기소개 캐시에 있음 - Owner Feed View REACTOR nickname : \(dstNickname), \(cachedSelfIntro)")
            
            return .just(.setSelfIntroduction(cachedSelfIntro))
        }
        
        return userRepository.findIntroduction(request: FindIntroductionRequest(nickname: dstNickname))
            .map {
                SelfIntroductionCache.shared.cache[dstNickname] = $0
                return Mutation.setSelfIntroduction($0)
            }
            .catch { error in
                print("🚫 Owner feed view reactor findIntroduction error : \(error.localizedDescription), error nickname : \(dstNickname)")
                
                return .just(.setSelfIntroduction(""))
            }
    }
}
