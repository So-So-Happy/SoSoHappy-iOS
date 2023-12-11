//
//  FeedViewReactor2.swift
//  SoSoHappy
//
//  Created by Sue on 12/2/23.
//

import ReactorKit
import UIKit
/*
문제
 1. paging 완전 끝까지 다 하고 나서 정렬 버튼을 누르면 뒤에 계속 누적이 되는 문제
 */

enum SortOption {
    case today
    case total
    case currentSort // 미리 설정되어 있던 sortOption 설정해주기 위한 case
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
        var isRefreshing: Bool = false
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
    { //userRepository: UserRepositoryProtocol 추가
        initialState = State()
        self.feedRepository = feedRepository
        self.userRepository = userRepository
    }

    
    // MARK: mutate()
    // 새로운 action이 들어오면 그 전에 진행하고 있던 api 요청은 바로 끝내야 해.
    func mutate(action: Action) -> Observable<Mutation> {
        cancelPreviousFetchSubject.onNext(())

        switch action {
        case .refresh:
            print("mutate - refresh")
            return .concat([
                .just(.setRefreshing(true)),
                fetchAndProcessFeedsFinal(setSortOption: currentState.sortOption!, page: 0)
                    .take(until: cancelPreviousFetchSubject),
                .just(.setRefreshing(false))
            ])
            
        case let .fetchFeeds(sortOption):
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
                
                fetchAndProcessFeedsFinal(setSortOption: sort, page: 0)
                    .take(until: cancelPreviousFetchSubject),
                
                .just(.isLoading(false))
            ])

            
        case .pagination:
            print("mutate - pagination - date - \(Date())")
            return .concat([
                .just(.isPaging(true)),
                
                fetchAndProcessFeedsFinal(setSortOption: currentState.sortOption!, page: nil)
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
            print("reduce (157) sortOption - \(sortOption), isLoading : \(state.isLoading), setRefreshing : \(state.isRefreshing), isPaging: \(state.isPaging), ongoingProfileImageRequests : \(ongoingProfileImageRequests) ")
            state.sortOption = sortOption
            tempData = Date()
            
        case let .isLoading(isLoading):
            print("reduce (162) sortOption - \(state.sortOption), isLoading : \(isLoading), setRefreshing : \(state.isRefreshing), isPaging: \(state.isPaging), pages: \(pages), isLastPage : \(isLastPage), ongoingProfileImageRequests : \(ongoingProfileImageRequests) ")
//            print("check4 - isLoading: \(isLoading), sortOption :\(state.sortOption)")
            state.isLoading = isLoading
            
            if !isLoading {
                let interval = Date().timeIntervalSince(tempData)
                print("Time interval!!!!! : \(interval)")
            }
            
        case let .setRefreshing(isRefreshing):
            print("reduce (172) sortOption - \(state.sortOption), isLoading : \(state.isLoading), setRefreshing : \(isRefreshing), isPaging: \(state.isPaging), pages: \(pages), isLastPage : \(isLastPage), ongoingProfileImageRequests : \(ongoingProfileImageRequests) ")
            state.isRefreshing = isRefreshing
            
        case let .isPaging(isPaging):
            print("reduce (176) sortOption - \(state.sortOption), isLoading : \(state.isLoading), setRefreshing : \(state.isRefreshing), isPaging: \(isPaging), pages: \(pages), isLastPage : \(isLastPage), ongoingProfileImageRequests : \(ongoingProfileImageRequests) ")
            print("🤍 isPaging: \(isPaging), time : \(Date())")
            if isPaging {
                tempData = Date()
            } else {
                let interval = Date().timeIntervalSince(tempData)
                print("Time interval : \(interval)")
            }
            
            state.isPaging = isPaging
            
        case .updateDataSource(let sectionItem):
//            state.sections.items.append(contentsOf: sectionItem)
            
            if state.isPaging == true {
                // If it's pagination, append the new items
                state.sections.items.append(contentsOf: sectionItem)
                print("2 -- isPaging  - 1, count : \(state.sections.items.count)")
            } else {
                // If it's fetchFeed, replace the existing items
                state.sections.items = sectionItem
                print("2 -- isPaging  - 2, count : \(state.sections.items.count)")
            }
            
            print("reduce (199) - \(sectionItem.count)")
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

    private func fetchAndProcessFeedsFinal(setSortOption: SortOption, page: Int?) -> Observable<Mutation> {
        
        if page != nil { // / refresh 또는 viewWillAppear fetchFeed할 때
            resetPagination()
            print("fetchAndProcessFeedsFinal - resetPagination")
        } else if isLastPage {
            print("fetchAndProcessFeedsFinal - 마지막 페이지 - \(isLastPage)")
            return .empty()
        } else {
            pages += 1 // paging 하는 부분
            print("fetchAndProcessFeedsFinal - paging - \(pages)")
        }
        
        // sortOption에 따라서 requestDate 설정
        let requestDate: Int64? = setRequestDateBy(setSortOption)
        let provider = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo", forKey: "provider") ?? ""
        let nickname = KeychainService.loadData(serviceIdentifier: "sosohappy.userInfo\(provider)", forKey: "userNickName") ?? ""
    
        return feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: nickname, date: requestDate, page: pages, size: 7)) // 원래 size 7
            // MARK: - flatMap
            // 각 UserFeed에 대해 프로필 이미지를 비동기적으로 조회하고(병렬처리), 그 결과를 기반으로 새로운 Observable 생성
            .flatMap { [weak self] (userFeeds, isLast) -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                
                print("😄 isLast : \(isLast), currentPage: \(pages), sortOption: \(setSortOption), userFeeds.count : \(userFeeds.count)")
                isLastPage = isLast
                
                if userFeeds.isEmpty { return Observable.just(.updateDataSource([])) }
                
                // MARK: - 1. 각각의 Feed에 프로필 이미지 조회
                let observables: [Observable<UserFeedSection.Item>] = userFeeds.map {[weak self] feed in
                    guard let self = self else { return Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository()))) }
//                    print(" 🛑 feed.nickname : \(feed.nickName)")
                    return processFeedWithProfileImage(feed)

                } // observables map
                // MARK: zip - 여러 개의 Observable의 결과를 하나로 결합
                // 여러 피드에 대해 각각 비동기적으로 프로필 이밎 조회를 수행했고, 이 결과들을 하나의 배열로 조합하여 반환해야 하기 때문에
                return Observable.zip(observables)
                    .map { items in
                        return Mutation.updateDataSource(items)
                    }
            }
    }
    
    private func processFeedWithProfileImage(_ feed: UserFeed) -> Observable<UserFeedSection.Item> {
        // MARK: 캐시에 있는지 확인
        if let cachedImage = ImageCache.shared.cache[feed.nickName] {
            print("(캐시) ⭕️ 캐시에 있음(FeedView) -  nickname : \(feed.nickName)")
            return Observable.just(handleProfileImageRequestResult(cachedImage, feed))
        }
        
        print("(캐시) ❌ 캐시에 없음(FeedView) -  nickname : \(feed.nickName)")
        // MARK: 2. 해당 닉네임에 대한 진행중인 (프로필 이미지 조회)요청이 있는지 확인
        // 진행중인 요청을 ongoingRequest에 할당
        if let ongoingRequest = self.ongoingProfileImageRequests[feed.nickName] {
            print("🚜 ongoing REQUEST")
            return ongoingRequest
                .map { [weak self] profileImg in
                    guard let self = self else { return .feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())) }
//                    print("🚜🚜 profileImg = \(profileImg)")
                    // MARK: Cache에
                    // MARK: 캐시된 이미지를 넣은 UserFeed 반환
                    return handleProfileImageRequestResult(profileImg, feed)
//                                return reactor
                    
                }
                .catch { _ in Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository()))) }
        }
        

        
        // MARK: 3. 요청
        let request = self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: feed.nickName))
        // .share - 공유 ㅁ
        let sharedRequest = request.share()
        
//        print("request : \(request)")
        self.ongoingProfileImageRequests[feed.nickName] = sharedRequest
        
        return request
            .map { profileImgFromServer in
//                print("🎉 요청 시작 , nickname : \(feed.nickName), content: \(feed.text)")
                // MARK: Cache에 저장
                return self.handleProfileImageRequestResult(profileImgFromServer, feed, cacheImage: true)
//                            return reactor
            }
            .catch { error in
//                print("🚫 프로필 이미지 조회 error : \(error.localizedDescription), nickname : \(feed.nickName)")
                
                return Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())))
            }
            .do(onDispose: {
                // 메모리에서 해제되면 ongoingRequest에서 제거해줌
//                print("🎀 do DISPOSE - nickname : \(feed.nickName), content : \(feed.text), date : \(feed.dateFormattedString)")
                self.ongoingProfileImageRequests[feed.nickName] = nil
            })
        
    }
    
    private func handleProfileImageRequestResult(_ profileImg: UIImage, _ feed: UserFeed, cacheImage: Bool = false) -> UserFeedSection.Item {
        if cacheImage {
            ImageCache.shared.cache[feed.nickName] = profileImg
        }
        let feed = feed.with(profileImage: profileImg)
        let reactor = FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())
        return .feed(reactor)
    }
}
