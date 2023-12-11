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
    var ownerNickName: String
    var profileImage: UIImage?
    var isLastPage: Bool = false
    var pages: Int = 0
    let initialState: State
    
    enum Action {
        case refresh
        case fetchFeeds
        case pagination
        case block
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case isLoading(Bool) // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        case isPaging(Bool)
        case setProfile(String)
        case updateDataSource([UserFeedSection.Item])
    }
    
    struct State {
        var isRefreshing: Bool = false
        var isLoading: Bool? // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        var isPaging: Bool?
        var profile: Profile?
        var sections = UserFeedSection.Model(
          model: 0,
          items: []
        )
    }
    
    init(ownerNickName: String, feedRepository: FeedRepositoryProtocol, userRepository: UserRepositoryProtocol) {
//        initialState = State(ownerNickName: ownerNickName)
        initialState = State()
        self.ownerNickName = ownerNickName
        self.feedRepository = feedRepository
        self.userRepository = userRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            print("OwnerFeedReactor - refresh")
            // 프로필 사진 조회
            // 프로필 소개글 조회
            // 특정 유저 피드 리스트 조회 (page: 0)
            return .concat([
                .just(.setRefreshing(true)),
                fetchUserInformation(page: 0),
                .just(.setRefreshing(false))
            ])
            
        case .fetchFeeds: // page: 0
            print("OwnerFeedReactor - fetchFeeds")
            return .concat([
                .just(.isLoading(true)),
//                fetchUserInformation(page: 0).delay(.seconds(3), scheduler: MainScheduler.instance),
                fetchUserInformation(page: 0),
                .just(.isLoading(false))
            ])
            
        case .pagination:
            print("OwnerFeedReactor - pagination")
            return .concat([
                .just(.isPaging(true)),
                findUserFeeds(dstNickname: self.ownerNickName, page: nil),
                .just(.isPaging(false))
            ])
            
        case .block:
            print("blocked")
            return .empty()
            
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
        case let .setProfile(selfIntroduction):
            state.profile = Profile(email: "", nickName: self.ownerNickName, profileImg: self.profileImage ?? UIImage(named: "profile")!, introduction: selfIntroduction)
            
        case let .updateDataSource(sectionItem):
           
            if state.isPaging == true {
                state.sections.items.append(contentsOf: sectionItem)
            } else {
                state.sections.items = sectionItem
            }
            
            print("updateSource for owner : \(state.sections.items.count)")

        case let .isPaging(isPaging):
            state.isPaging = isPaging
        }
        
        return state
    }
}

extension OwnerFeedViewReactor {
    private func resetPagination() {
        isLastPage = false
        pages = 0
    }
    
    func fetchUserInformation(page: Int?) -> Observable<Mutation> {
        let dstNickname: String = self.ownerNickName // 조회 대상 nickname
        return .concat([
            fetchProfileImage(owner: dstNickname),
            fetchSelfIntroduction(owner: dstNickname),
            findUserFeeds(dstNickname: dstNickname, page: page)
        ])
    }
    
    func findUserFeeds(dstNickname: String, page: Int?) ->  Observable<Mutation> {
        let srcNickname: String = "bread" // 조회하는 유저 nickname
        
//        return .empty()
        
        if let page = page {
            resetPagination()
        } else if isLastPage {
            return .empty()
        } else {
            pages += 1
        }

        return feedRepository.findUserFeed(request: FindUserFeedRequest(srcNickname: srcNickname, dstNickname: dstNickname, page: pages, size: 7))
                .map { [weak self] (userFeeds, isLast: Bool) in
                    self?.isLastPage = isLast
                    print("isLast owner - \(isLast)")
                    let feedReactors = userFeeds.map { UserFeedSection.Item.feed(FeedReactor(userFeed: $0, feedRepository: FeedRepository(), userRepository: UserRepository())) }
                    return Mutation.updateDataSource(feedReactors)
                }
                .catch { error in
                    print("error: \(error)")
                    return .empty()
                }
        
    }
    
    
    private func fetchProfileImage(owner dstNickname: String) -> Observable<Mutation> {
        if let cachedImage = ImageCache.shared.cache[dstNickname] {
            print("⭕️ 사진 캐시에 있음 - Owner Feed View REACTOR nickname : \(dstNickname)")
            self.profileImage = cachedImage
            return .empty()
        }
        
        self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: dstNickname))
            .map { profileImage in
                ImageCache.shared.cache[dstNickname] = profileImage
                self.profileImage = profileImage
            }
            .catch { error in
                print("🚫 Owner feed view reactor findProfileImg error : \(error.localizedDescription), error nickname : \(dstNickname)")
                self.profileImage = UIImage(named: "profile")
                return .empty()
            }
        
        return .empty()
    }
    
    private func fetchSelfIntroduction(owner dstNickname: String) -> Observable<Mutation> {
        
        if let cachedSelfIntro = SelfIntroductionCache.shared.cache[dstNickname] {
            print("⭕️ 자기소개 캐시에 있음 - Owner Feed View REACTOR nickname : \(dstNickname), \(cachedSelfIntro)")
            return .just(.setProfile(cachedSelfIntro))
        }
        
        return userRepository.findIntroduction(request: FindIntroductionRequest(nickname: dstNickname))
            .map {
                SelfIntroductionCache.shared.cache[dstNickname] = $0
                return Mutation.setProfile($0)
            }
            .catch { error in
                print("🚫 Owner feed view reactor findIntroduction error : \(error.localizedDescription), error nickname : \(dstNickname)")
                return .just(.setProfile(""))
            }
    }
}
