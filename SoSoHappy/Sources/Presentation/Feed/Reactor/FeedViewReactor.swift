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

final class FeedViewReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var ongoingProfileImageRequests: [String: Observable<UIImage>] = [:]
    var totalIsLast: Bool = false
    var todayIsLast: Bool = false
    var currentPageTotal: Int = -1
    var currentPageToday: Int = 0
    let initialState: State
    
    enum Action {
        case refresh
        case fetchFeeds(SortOption)
        case pagination(
            contentHeight: CGFloat,
            contentOffsetY: CGFloat,
            scrollViewHeight: CGFloat
        )
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case isLoading(Bool) // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        case updateDataSource([UserFeedSection.Item])
    }
    
    struct State {
        var isRefreshing: Bool = false
        var isLoading: Bool? // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        var sortOption: SortOption?
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
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            print("refresh")
            return .empty()
            
        case let .fetchFeeds(sortOption):
            print("sort : \(sortOption)")
            let sort: SortOption = {
                switch sortOption {
                case .currentSort:
                    return currentState.sortOption ?? .total
                default: return sortOption
                }
            }()
            
            // MARK: default 0 page
            return fetchAndProcessFeedsFinal(setSortOption: sort, page: 0)
            
        case let .pagination(contentHeight, contentOffsetY, scrollViewHeight):
            let paddingSpace = contentHeight - contentOffsetY
            if paddingSpace < scrollViewHeight {
                
                return fetchAndProcessFeedsFinal(setSortOption: .total, page: nil)
            } else {
              return .empty()
            }
            
        }
    }
    
    // MARK: reduce()
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            
        case .updateDataSource(let sectionItem):
            state.sections.items.append(contentsOf: sectionItem)
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
    
    private func resetPagination() {
        totalIsLast = false
        todayIsLast = false
        currentPageToday = 0
        currentPageTotal = 0
    }
    
    private func handleLastPage(for setSortOption: SortOption, isLast: Bool) {
        switch setSortOption {
        case.today:
            todayIsLast = isLast
        case .total:
            totalIsLast = isLast
        default: break
        }
     }

    
    private func fetchAndProcessFeedsFinal(setSortOption: SortOption, page: Int?) -> Observable<Mutation> {
        
        switch setSortOption {
        case .today where todayIsLast:
            print("today - todayIsLast: \(todayIsLast)")
            return .empty()
        case .total where totalIsLast:
            print("total - totalIsLast: \(totalIsLast)")
            return .empty()
        case .total, .today where page != nil:
            resetPagination()
        case .today:
            currentPageTotal += 1
        case .total:
            currentPageTotal += 1
        default: break
        }
        
        // sortOption에 따라서 requestDate 설정
        let requestDate: Int64? = setRequestDateBy(setSortOption)
        
        let page = setSortOption == .today ? currentPageToday : currentPageTotal
        
        return feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: "디저트러버", date: requestDate, page: page, size: 7))
            // MARK: - flatMap
            // 각 UserFeed에 대해 프로필 이미지를 비동기적으로 조회하고(병렬처리), 그 결과를 기반으로 새로운 Observable 생성
            .flatMap { [weak self] (userFeeds, isLast) -> Observable<Mutation> in
                guard let self = self else { return .empty() }
                print("😄 isLast : \(isLast), currentPage: \(self.currentPageTotal)")
                handleLastPage(for: setSortOption, isLast: isLast)
        
                
                // MARK: - 1. 각각의 Feed에 프로필 이미지 조회
                let observables: [Observable<UserFeedSection.Item>] = userFeeds.map { feed in
                    print(" 🛑 feed.nickname : \(feed.nickName)")
                    // MARK: 캐시에 있는지 확인
                    if let cachedImage = ImageCache.shared.cache[feed.nickName] {
                        print("⭕️ 캐시에 있음(FeedView) -  nickname : \(feed.nickName)")
                        
                        let feed = feed.with(profileImage: cachedImage)
                        let reactor = FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())
                        // MARK: 캐시된 이미지를 넣은 UserFeed 반환
                        return Observable.just(.feed(reactor))
//                        return Observable.just(reactor)
                    }
                    
                    print(" ❌ 캐시에 없음(FeedView) -  nickname : \(feed.nickName)")
                    // MARK: 2. 해당 닉네임에 대한 진행중인 (프로필 이미지 조회)요청이 있는지 확인
                    
                    // 진행중인 요청을 ongoingRequest에 할당
                    if let ongoingRequest = self.ongoingProfileImageRequests[feed.nickName] {
                        print("🚜 ongoing REQUEST")
                        return ongoingRequest
                            .map { profileImg in
                                print("🚜🚜 profileImg = \(profileImg)")
                                // MARK: Cache에 저장
//                                ImageCache.shared.cache[feed.nickName] = profileImg
                                let feed = feed.with(profileImage: profileImg)
                                let reactor = FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())
                                // MARK: 캐시된 이미지를 넣은 UserFeed 반환
                                return .feed(reactor)
//                                return reactor
                                
                            }
                            .catch { _ in Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository()))) }
                    }
                    

                    
                    // MARK: 3. 요청
                    let request = self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: feed.nickName))
                    // .share - 공유 ㅁ
                    let sharedRequest = request.share()
                    
                    print("request : \(request)")
                    self.ongoingProfileImageRequests[feed.nickName] = sharedRequest
                    
                    return request
                        .map { profileImgFromServer in
                            print("🎉 요청 시작 , nickname : \(feed.nickName), content: \(feed.text)")
                            // MARK: Cache에 저장
                            ImageCache.shared.cache[feed.nickName] = profileImgFromServer
                            
                            let feed = feed.with(profileImage: profileImgFromServer)
                            let reactor = FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())
                            return .feed(reactor)
//                            return reactor
                        }
                        .catch { error in
                            print("🚫 프로필 이미지 조회 error : \(error.localizedDescription), nickname : \(feed.nickName)")
                            
                            return Observable.just(.feed(FeedReactor(userFeed: feed, feedRepository: FeedRepository(), userRepository: UserRepository())))
                        }
                        .do(onDispose: {
                            // 메모리에서 해제되면 ongoingRequest에서 제거해줌
                            print("🎀 do DISPOSE - nickname : \(feed.nickName), content : \(feed.text), date : \(feed.dateFormattedString)")
                            self.ongoingProfileImageRequests[feed.nickName] = nil
                        })
                } // observables map
                // MARK: zip - 여러 개의 Observable의 결과를 하나로 결합
                // 여러 피드에 대해 각각 비동기적으로 프로필 이밎 조회를 수행했고, 이 결과들을 하나의 배열로 조합하여 반환해야 하기 때문에
                return Observable.zip(observables)
                    .map { items in
                        // items is an array of UserFeedSection.Item
                        return Mutation.updateDataSource(items)
                    }
            }
    }
}
