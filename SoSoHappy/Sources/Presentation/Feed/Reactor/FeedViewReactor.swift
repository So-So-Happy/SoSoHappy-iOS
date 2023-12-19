//
//  FeedViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 12/2/23.
//

import ReactorKit
import UIKit

enum SortOption {
    case today
    case total
    case currentSort
}

enum DataRenewal {
    case load
    case refresh
}

final class FeedViewReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var ongoingProfileImageRequests: [String: Observable<UIImage>] = [:]
    
    private let cancelPreviousFetchSubject = PublishSubject<Void>()
    
    var isLastPage: Bool = false
    var pages: Int = 0
    let initialState: State
    var currentAction: DataRenewal?
 
    enum Action {
        case refresh
        case fetchFeeds(SortOption)
        case pagination
    }
    
    enum Mutation {
        case sortOption(SortOption)
        case setRefreshing(Bool)
        case isLoading(Bool)
        case isPaging(Bool)
        case updateDataSource([UserFeedSection.Item])
        case showNetworkErrorView(Bool) // 네트워크 에러
        case showServerErrorAlert(Bool) // 500에러
    }
    
    struct State {
        var sortOption: SortOption?
        var isRefreshing: Bool?
        var isLoading: Bool?
        var isPaging: Bool?
        var sections = UserFeedSection.Model(
          model: 0,
          items: []
        )
        var showNetworkErrorView: Bool? // 네트워크 에러
        var showServerErrorAlert: Bool? // 500
    }
    
    init(
        feedRepository: FeedRepositoryProtocol,
        userRepository: UserRepositoryProtocol
    )
    {
        initialState = State()
        self.feedRepository = feedRepository
        self.userRepository = userRepository
    }

    // MARK: mutate()
    func mutate(action: Action) -> Observable<Mutation> {
        cancelPreviousFetchSubject.onNext(())
        if !Connectivity.isConnectedToInternet() {
            currentAction = nil
            return .just(.showNetworkErrorView(true))
        }
    
        switch action {
        case .refresh: // 새로고침
            currentAction = .refresh
            
            return .concat([
                .just(.showNetworkErrorView(false)),
                .just(.setRefreshing(true)),
                fetchAndProcessFeeds(setSortOption: currentState.sortOption ?? .total, page: 0)
                    .take(until: cancelPreviousFetchSubject),
                .just(.setRefreshing(false))
            ])
            
        case let .fetchFeeds(sortOption): // 정렬에 따른 fetch
            let sort: SortOption = {
                switch sortOption {
                case .currentSort:
                    return currentState.sortOption ?? .total
                default: return sortOption
                }
            }()
            currentAction = .load
            
            return .concat([
                .just(.showNetworkErrorView(false)),
                .just(.sortOption(sort)),
                .just(.isLoading(true)),
                fetchAndProcessFeeds(setSortOption: sort, page: 0)
                    .take(until: cancelPreviousFetchSubject),
                .just(.isLoading(false))
            ])
            
        case .pagination: // paging
            currentAction = nil
        
            return .concat([
                .just(.showNetworkErrorView(false)),
                .just(.isPaging(true)),
                fetchAndProcessFeeds(setSortOption: currentState.sortOption!, page: nil)
                    .take(until: cancelPreviousFetchSubject),
                .just(.isPaging(false))
            ])
        }
    }
    
    // MARK: reduce()
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .sortOption(sortOption):
            state.sortOption = sortOption
            
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            
        case let .isPaging(isPaging):
            state.isPaging = isPaging
            
        case .updateDataSource(let sectionItem):
            if state.isPaging == true {
                state.sections.items.append(contentsOf: sectionItem)
            } else {
                state.sections.items = sectionItem
            }

        case .showNetworkErrorView(let showNetworkErrorView):
            if showNetworkErrorView {
                state.sections.items = []
                state.isRefreshing = false
            }
            state.showNetworkErrorView = showNetworkErrorView
            
        case .showServerErrorAlert(let showServerErrorAlert):
            state.showServerErrorAlert = showServerErrorAlert
        }
        
        return state
    }
}

extension FeedViewReactor {
    // MARK: request 날짜 설정
    private func setRequestDateBy(_ sortOption: SortOption) -> Int64? {
        switch sortOption {
        case .today:
            return Date().getFormattedYMDH()
        default: return nil
        }
    }
    
    // MARK: page 관련 프로퍼티 초기화
    private func resetPagination() {
        isLastPage = false
        pages = 0
    }
    
    // MARK: fetchAndProcessFeeds()
    private func fetchAndProcessFeeds(setSortOption: SortOption, page: Int?) -> Observable<Mutation> {
        if page != nil {
            resetPagination()
        } else if isLastPage {
            return .empty()
        } else {
            pages += 1
        }
        
        let requestDate: Int64? = setRequestDateBy(setSortOption)
        let nickname: String = KeychainService.getNickName()
        
        return feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: nickname, date: requestDate, page: pages, size: 21))
            .flatMap { [weak self] (userFeeds, isLast) -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                
                isLastPage = isLast

                if userFeeds.isEmpty { return Observable.just(.updateDataSource([])) }
                
                let observables: [Observable<UserFeedSection.Item>] = userFeeds.map {[weak self] feed in
                    guard let self = self else { return Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository()))) }
                    return processFeedWithProfileImage(feed)
                    
                }
                
                return Observable.zip(observables)
                    .map { items in
                        return Mutation.updateDataSource(items)
                    }
            }
            .catch { _ in
                return .concat([
                    .just(.showServerErrorAlert(true)),
                    .just(.showServerErrorAlert(false)) // 비워주기
                ])
            }
    }
    
    // MARK: processFeedWithProfileImage
    private func processFeedWithProfileImage(_ feed: UserFeed) -> Observable<UserFeedSection.Item> {
        if let cachedImage = ImageCache.shared.cache[feed.nickName] {
            return Observable.just(handleProfileImageRequestResult(cachedImage, feed))
        }
    
        if let ongoingRequest = self.ongoingProfileImageRequests[feed.nickName] {
            return ongoingRequest
                .map { [weak self] profileImg in
                    guard let self = self else { return .feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())) }
                    
                    return handleProfileImageRequestResult(profileImg, feed)
                }
                .catch { _ in Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository()))) }
        }
        
        let request = self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: feed.nickName))

        let sharedRequest = request.share()
        
        self.ongoingProfileImageRequests[feed.nickName] = sharedRequest
        
        return sharedRequest
            .map { profileImgFromServer in
                return self.handleProfileImageRequestResult(profileImgFromServer, feed, cacheImage: true)
            }
            .catch { error in
                return Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())))
            }
            .do(onDispose: {
                self.ongoingProfileImageRequests[feed.nickName] = nil
            })
        
    }
    
    // MARK: handleProfileImageRequestResult
    private func handleProfileImageRequestResult(_ profileImg: UIImage, _ feed: UserFeed, cacheImage: Bool = false) -> UserFeedSection.Item {
        if cacheImage {
            ImageCache.shared.cache[feed.nickName] = profileImg
        }
        let feed = feed.with(profileImage: profileImg)
        let reactor = FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())
        return .feed(reactor)
    }
}
