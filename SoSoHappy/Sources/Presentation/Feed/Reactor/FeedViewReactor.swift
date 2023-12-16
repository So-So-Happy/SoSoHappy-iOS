//
//  FeedViewReactor2.swift
//  SoSoHappy
//
//  Created by Sue on 12/2/23.
//

import ReactorKit
import UIKit

enum SortOption {
    case today
    case total
    case currentSort // 미리 설정되어 있던 sortOption 설정해주기 위한 case
}

enum DataRenewal {
    case load
    case refresh
}

final class FeedViewReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var ongoingProfileImageRequests: [String: Observable<UIImage>] = [:]
    
    var dataTestArr: [Date] = []
    var tempData = Date()
    
    private let cancelPreviousFetchSubject = PublishSubject<Void>()
    
    var isLastPage: Bool = false
    var pages: Int = 0
    let initialState: State
    
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

        switch action {
        case .refresh: // 새로고침
            print("mutate - refresh")
            return .concat([
                .just(.setRefreshing(true)),
                fetchAndProcessFeeds(setSortOption: currentState.sortOption!, page: 0)
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
            
            print("mutate - fetchFeeds sortOption - \(sortOption) - date - \(Date())")
            return .concat([
                .just(.sortOption(sort)),
                .just(.isLoading(true)),
                
                fetchAndProcessFeeds(setSortOption: sort, page: 0)
                    .take(until: cancelPreviousFetchSubject),
                
                .just(.isLoading(false))
            ])
            
        case .pagination: // paging
            print("~~~ mutate - pagination - date - \(Date())")
            return .concat([
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
//            print("reduce (157) sortOption - \(sortOption), isLoading : \(state.isLoading), setRefreshing : \(state.isRefreshing), isPaging: \(state.isPaging), ongoingProfileImageRequests : \(ongoingProfileImageRequests) ")
            state.sortOption = sortOption
//            tempData = Date()
            
        case let .isLoading(isLoading):
//            print("reduce (162) sortOption - \(state.sortOption), isLoading : \(isLoading), setRefreshing : \(state.isRefreshing), isPaging: \(state.isPaging), pages: \(pages), isLastPage : \(isLastPage), ongoingProfileImageRequests : \(ongoingProfileImageRequests) ")
//            
//            // MARK: 시간 확인용 test 코드
//            if !isLoading {
//                let interval = Date().timeIntervalSince(tempData)
//                print("Time interval!!!!! : \(interval)")
//            }

            state.isLoading = isLoading
            
        case let .setRefreshing(isRefreshing):
//            print("reduce (172) sortOption - \(state.sortOption), isLoading : \(state.isLoading), setRefreshing : \(isRefreshing), isPaging: \(state.isPaging), pages: \(pages), isLastPage : \(isLastPage), ongoingProfileImageRequests : \(ongoingProfileImageRequests) ")
            
            state.isRefreshing = isRefreshing
            
        case let .isPaging(isPaging):
//            print("reduce (176) sortOption - \(state.sortOption), isLoading : \(state.isLoading), setRefreshing : \(state.isRefreshing), isPaging: \(isPaging), pages: \(pages), isLastPage : \(isLastPage), ongoingProfileImageRequests : \(ongoingProfileImageRequests) ")
            
            // MARK: 시간 확인용 test 코드
//            print("🤍 isPaging: \(isPaging), time : \(Date())")
            if isPaging {
                tempData = Date()
            } else {
                let interval = Date().timeIntervalSince(tempData)
                print("~~~ Time interval : \(interval)")
            }
            
            state.isPaging = isPaging
            
        case .updateDataSource(let sectionItem):
            if state.isPaging == true {
                state.sections.items.append(contentsOf: sectionItem)
//                print("reduce (paging)  : \(state.sections.items.count)")
            } else {
                state.sections.items = sectionItem
//                print("reduce (fetching)  : \(state.sections.items.count)")
            }
            
            print("~~~reduce (updateDataSource) - \(state.sections.items.count)")
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
    
    // MARK: - fetchAndProcessFeedsFinal
    private func fetchAndProcessFeeds(setSortOption: SortOption, page: Int?) -> Observable<Mutation> {
    
        if page != nil {
            resetPagination()
        } else if isLastPage {
            return .empty()
        } else {
            pages += 1
        }
        
        let requestDate: Int64? = setRequestDateBy(setSortOption)
        let provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
        let nickname = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName") ?? ""
    
        return feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: nickname, date: requestDate, page: pages, size: 24)) // 원래 size 7
            .flatMap { [weak self] (userFeeds, isLast) -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                isLastPage = isLast
                print("🐨isLast: \(isLast), userFeeds: \(userFeeds)")
                print("🐨🐨 count : \(userFeeds.count)")

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
    }
    
    private func processFeedWithProfileImage(_ feed: UserFeed) -> Observable<UserFeedSection.Item> {
        if let cachedImage = ImageCache.shared.cache[feed.nickName] {
            return Observable.just(handleProfileImageRequestResult(cachedImage, feed))
        }
    
        if let ongoingRequest = self.ongoingProfileImageRequests[feed.nickName] {
            return ongoingRequest
                .map { [weak self] profileImg in
                    guard let self = self else { return .feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())) }
//                    print("🚜🚜 name : \(feed.nickName), 날짜 : \(feed.dateFormattedString)")
                    return handleProfileImageRequestResult(profileImg, feed)
                }
                .catch { _ in Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository()))) }
        }
        

        let request = self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: feed.nickName))
//        print("request에 넣음 ")
        let sharedRequest = request.share()
        
        self.ongoingProfileImageRequests[feed.nickName] = sharedRequest //  sharedRequest
        
        return sharedRequest
            .map { profileImgFromServer in
                print("🎉 요청 시작 , nickname : \(feed.nickName), 날짜 : \(feed.dateFormattedString)")
                return self.handleProfileImageRequestResult(profileImgFromServer, feed, cacheImage: true)
//                            return reactor
            }
            .catch { error in
                print("🚫 프로필 이지 조회 error : \(error.localizedDescription), nickname : \(feed.nickName)")
                return Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())))
            }
            .do(onDispose: {
//                print("🎀 do DISPOSE - nickname : \(feed.nickName), 날짜 : \(feed.dateFormattedString)")
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
