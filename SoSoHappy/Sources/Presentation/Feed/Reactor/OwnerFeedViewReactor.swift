//
//  OwnFeedViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/11.
//

import ReactorKit

final class OwnerFeedViewReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    private let cancelPreviousFetchSubject = PublishSubject<Void>()
    
    var isLastPage: Bool = false
    var pages: Int = 0
    var ownerNickName: String
    var profileImage: UIImage?
    let initialState: State
    var currentAction: DataRenewal?
    
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
        case isBlockSucceeded(Bool)
        case showNetworkErrorView(Bool) // 네트워크 에러
        case showServerErrorAlert(Bool) // 500에러
    }
    
    struct State {
        var isRefreshing: Bool?
        var isLoading: Bool? // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        var isPaging: Bool?
        var profile: Profile?
        var sections = UserFeedSection.Model(
          model: 0,
          items: []
        )
        var isBlockSucceeded: Bool?
        var showNetworkErrorView: Bool? // 네트워크 에러
        var showServerErrorAlert: Bool? // 500
    }
    
    init(ownerNickName: String, feedRepository: FeedRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        initialState = State()
        self.ownerNickName = ownerNickName
        self.feedRepository = feedRepository
        self.userRepository = userRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        cancelPreviousFetchSubject.onNext(())
        if !Connectivity.isConnectedToInternet() {
            currentAction = nil
            return .just(.showNetworkErrorView(true))
        }
    
        switch action {
        case .refresh:
            currentAction = .refresh
            
            return .concat([
                .just(.showNetworkErrorView(false)),
                .just(.setRefreshing(true)),
                fetchUserInformationWithFeeds(page: 0)
                    .take(until: cancelPreviousFetchSubject),
                .just(.setRefreshing(false))
            ])
            
        case .fetchFeeds:
            currentAction = .load
        
            return .concat([
                .just(.showNetworkErrorView(false)),
                .just(.isLoading(true)),
                fetchUserInformationWithFeeds(page: 0)
                    .take(until: cancelPreviousFetchSubject),
                .just(.isLoading(false))
            ])
            
        case .pagination:
            currentAction = nil

            return .concat([
                .just(.showNetworkErrorView(false)),
                .just(.isPaging(true)),
                findUserFeeds(dstNickname: self.ownerNickName, page: nil)
                    .take(until: cancelPreviousFetchSubject),
                .just(.isPaging(false))
            ])
            
        case .block:
            return .just(.isBlockSucceeded(true))
            
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            
        case let .isPaging(isPaging):
            state.isPaging = isPaging
            
        case let .setProfile(selfIntroduction):
            state.profile = Profile(email: "", nickName: self.ownerNickName, profileImg: self.profileImage ?? UIImage(named: "profile")!, introduction: selfIntroduction)
            
        case let .updateDataSource(sectionItem):
            if state.isPaging == true {
                state.sections.items.append(contentsOf: sectionItem)
            } else {
                state.sections.items = sectionItem
            }

        case let .isBlockSucceeded(isBlockSucceeded):
            state.isBlockSucceeded = isBlockSucceeded
            
        case .showNetworkErrorView(let showNetworkErrorView):
            if showNetworkErrorView {
                state.profile = Profile(email: "", nickName: "", profileImg: UIImage(named: "profile")!, introduction: "")
                state.sections.items = []
                state.isRefreshing = false 
            }
            state.showNetworkErrorView = showNetworkErrorView
            
        case .showServerErrorAlert(let showServerErrorAlert):
            state.profile = Profile(email: "", nickName: "", profileImg: UIImage(named: "profile")!, introduction: "")
            state.showServerErrorAlert = showServerErrorAlert
        }
        
        return state
    }
}

extension OwnerFeedViewReactor {
    private func resetPagination() {
        isLastPage = false
        pages = 0
    }
    
    func fetchUserInformationWithFeeds(page: Int?) -> Observable<Mutation> {
        let dstNickname: String = self.ownerNickName // 조회 대상 nickname
        return .concat([
            fetchProfileImage(owner: dstNickname),
            fetchSelfIntroduction(owner: dstNickname),
            findUserFeeds(dstNickname: dstNickname, page: page)
        ])
    }
    
    func findUserFeeds(dstNickname: String, page: Int?) -> Observable<Mutation> {
        let srcNickname = KeychainService.getNickName()
        
        if page != nil {
            resetPagination()
        } else if isLastPage {
            return .empty()
        } else {
            pages += 1
        }
        
        return feedRepository.findUserFeed(request: FindUserFeedRequest(srcNickname: srcNickname, dstNickname: dstNickname, page: pages, size: 21))
                .map { [weak self] (userFeeds, isLast: Bool) in
                    self?.isLastPage = isLast

                    let feedReactors = userFeeds.map { UserFeedSection.Item.feed(FeedReactor(userFeed: $0, feedRepository: FeedRepository(), userRepository: UserRepository())) }
                    return Mutation.updateDataSource(feedReactors)
                }
                .catch { _ in
                    return .concat([
                        .just(.showServerErrorAlert(true)),
                        .just(.showServerErrorAlert(false))
                    ])
                }
    }
    
    private func fetchProfileImage(owner dstNickname: String) -> Observable<Mutation> {
        if let cachedImage = ProfileImageCache.shared.cache[dstNickname] {
            self.profileImage = cachedImage
            return .empty()
        }
        
        self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: dstNickname))
            .map { profileImage in
                ProfileImageCache.shared.cache[dstNickname] = profileImage
                self.profileImage = profileImage
            }
            .catch { _ in
                self.profileImage = UIImage(named: "profile")
                return .empty()
            }
        return .empty()
    }
    
    private func fetchSelfIntroduction(owner dstNickname: String) -> Observable<Mutation> {
        if let cachedSelfIntro = SelfIntroductionCache.shared.cache[dstNickname] {
            return .just(.setProfile(cachedSelfIntro))
        }
        
        return userRepository.findIntroduction(request: FindIntroductionRequest(nickname: dstNickname))
            .map {
                SelfIntroductionCache.shared.cache[dstNickname] = $0
                return Mutation.setProfile($0)
            }
            .catch { _ in
                return .just(.setProfile(""))
            }
    }
}
