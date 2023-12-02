//
//  FeedViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/05.
//

import ReactorKit
import UIKit

// 궁금한 점
// 1. 오늘 조회할 때 Int로 20231018만 넘겨주면 되는거죠? yes

// 아무래도 state의 값이 변경이 되면 다른 reactor.state에도 영향을 미치는 것 같음

//


enum SortOption {
    case today
    case total
    case currentSort // 미리 설정되어 있던 sortOption 설정해주기 위한 case
}

final class FeedViewReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var ongoingProfileImageRequests: [String: Observable<UIImage>] = [:]
    var currentPageTotal: Int = 0
    var currentPageToday: Int = 0
    let initialState: State
    
    enum Action {
        case refresh
        case fetchFeeds(SortOption)
        case selectedCell(index: Int)
        case pagination(
            contentHeight: CGFloat,
            contentOffsetY: CGFloat,
            scrollViewHeight: CGFloat
        )
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case isLoading(Bool) // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        case setFeeds([UserFeed])
        case sortOption(SortOption)
        case selectedCell(index: Int)
        case showNoFeedLabel(Bool?)
    }
    
    struct State {
        var isRefreshing: Bool = false
        var isLoading: Bool? // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        var userFeeds: [UserFeed]?
        var sortOption: SortOption?
        var selectedFeed: UserFeed?
        var showNoFeedLabel: Bool? = false
        var userFeedSection = UserFeedSection.Model(
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
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            // currentState.sortOption에 따라 달라짐
            return .concat([
                .just(.setRefreshing(true)).delay(.seconds(3), scheduler: MainScheduler.instance),
                fetchAndProcessFeedsFinal(setSortOption: currentState.sortOption!, page: 0),
                .just(.setRefreshing(false))
            ])
            
        case let .fetchFeeds(sortOption):
            let setSortOption: SortOption
            
            switch sortOption {
            case .today:
                setSortOption = .today
            case .total:
                setSortOption = .total
            case .currentSort:
                if let current = currentState.sortOption { // 미리 설정해뒀던 sortOption이 있다면 그걸로 설정
                    setSortOption = current
                } else { // 없었다면 기본설정
                    setSortOption = .total
                }
            }
            
            return .concat([
                .just(.sortOption(setSortOption)),
                /*
                 예를 들어, 전체에서 여러 개의 피드를 보여주고 '오늘' 피드들을 보여줄 때 indicator가 '전체'에 해당하는 피드 위에서 빙글빙글 돌아감
                 */

                .just(.setFeeds([])),
                .just(.isLoading(true)),
                // .isLoading ->  1초 delay 후 -> fetchAndProcessFeed 실행
                fetchAndProcessFeedsFinal(setSortOption: setSortOption, page: 0).delay(.milliseconds(1), scheduler: MainScheduler.instance),
                .just(.isLoading(false))
//                .just(.showNoFeedLabel(currentState.userFeeds?.isEmpty))
            ])
            
        case let .selectedCell(index):
            return .just(.selectedCell(index: index))
            
        case let .pagination(contentHeight, contentOffsetY, scrollViewHeight):
            let paddingSpace = contentHeight - contentOffsetY
            if paddingSpace < scrollViewHeight {
//                return getPhotos()
                print("get more datas")
               
                return fetchAndProcessFeedsFinal(setSortOption: currentState.sortOption!, page: <#T##Int#>)
            } else {
                return .empty()
            }
            
        }
    }
    
    
    // MARK: state.selectedFeed = nil를 한 곳에만 써도 될 것 같은데 한번 더 확인해보기
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
//            print("reduce - .setFreshing ")
            state.isRefreshing = isRefreshing
            
        case let .setFeeds(feeds):
//            print("reduce -  .setFeeds : \(feeds)")
            state.userFeeds = feeds
            
        case let .sortOption(sort):
//            print("reduce -  .sortOption : \(sort)")
            state.sortOption = sort
            state.selectedFeed = nil
            
        case let .selectedCell(index):
//            print("reduce - .selectedCell")
            if let userFeeds = state.userFeeds {
                state.selectedFeed = userFeeds[index]
            }
            
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
        case let .showNoFeedLabel(show):
            state.showNoFeedLabel = show
            
        }
        
        return state
    }
}

extension FeedViewReactor {
    private func setRequestDateBy(_ sortOption: SortOption) -> Int64? {
        switch sortOption {
        case .today:
            print("오늘 날짜 : \(Date().getFormattedYMDH())")
            return Date().getFormattedYMDH()
        default: return nil
        }
    }
    
    private func fetchAndProcessFeedsFinal(setSortOption: SortOption, page: Int) -> Observable<Mutation> {
        // sortOption에 따라서 requestDate 설정
        let requestDate: Int64? = setRequestDateBy(setSortOption)
        
        return feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: "디저트러버", date: requestDate, page: 0, size: 7))
            // MARK: - flatMap
            // 각 UserFeed에 대해 프로필 이미지를 비동기적으로 조회하고(병렬처리), 그 결과를 기반으로 새로운 Observable 생성
            .flatMap { (userFeeds, isLast) -> Observable<[UserFeed]> in
                print("😄 isLast : \(isLast)")
                // MARK: - 1. 각각의 Feed에 프로필 이미지 조회
                let observables: [Observable<UserFeed>] = userFeeds.map { feed in
                    print(" 🛑 feed.nickname : \(feed.nickName)")
                    // MARK: 캐시에 있는지 확인
                    if let cachedImage = ImageCache.shared.cache[feed.nickName] {
                        print("⭕️ 캐시에 있음(FeedView) -  nickname : \(feed.nickName)")
                        
                        // MARK: 캐시된 이미지를 넣은 UserFeed 반환
                        return Observable.just(feed.with(profileImage: cachedImage))
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
                                
                                return feed.with(profileImage: profileImg)
                            }
                            .catch { _ in Observable.just(feed) }
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
                            // MARK: 받아온 이미지를 넣은 UserFeed 반환
                            return feed.with(profileImage: profileImgFromServer) // 이거 자체로 이미 Observable
                        }
                        .catch { error in
                            print("🚫 프로필 이미지 조회 error : \(error.localizedDescription), nickname : \(feed.nickName)")
                            
                            return Observable.just(feed)
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
            }
            .map { Mutation.setFeeds($0) }
    }
    
    
    
    
    

    
    private func fetchAndProcessFeeds1(setSortOption: SortOption) -> Observable<Mutation> {
        let requestDate: Int64? = setRequestDateBy(setSortOption)
        print("requestDate: \(requestDate)")
        
        // MARK: page를 7로 해놓아서 처음부터 7
        return feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: "bread", date: requestDate, page: 1, size: 7))
            .flatMap { (userFeeds, isLast) -> Observable<[UserFeed]> in
//                print("fetchAndProcessFeeds 1 : \(userFeeds.count) , userFeeds : \(userFeeds)")
                // TODO: 처음으로 fech할 때 동일 nickname 있더라도 fetch를 해오는 문제가 있음
                let profileImageObservables: [Observable<UserFeed>] = userFeeds.map { feed in
                    print(" 🛑 feed.nickname : \(feed.nickName) ")
                    if let cachedImage = ImageCache.shared.cache[feed.nickName] {
                        print("⭕️ 캐시에 있음 - feedviewreactor nickname : \(feed.nickName)")
                        
                        var updateFeed = feed
                        updateFeed.profileImage = cachedImage
                        return Observable.just(updateFeed)
                    }
//                    print("✴️ else")
                    return self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: feed.nickName))
                        .map { profileImage in
                            print(" ❌ 캐시에 없음 - feedviewreactor nickname : \(feed.nickName)")
                            var updatedFeed = feed
                            updatedFeed.profileImage = profileImage
//                            print("ImageCache.shared 에 저장하기")
                            ImageCache.shared.cache[feed.nickName] = profileImage
                            return updatedFeed
                        }// map
                        .catch { error in
                            print("🚫 Feed view reactor findProfileImg error : \(error.localizedDescription), error nickname : \(feed.nickName)")
                            
                            return Observable.just(feed)
                        }
                    
                } // map
                // Observable.zip - profileImageObservables의 모든 작업이 끝날 때까지 기다림
                // 모든 작업의 결과를 하나의 Observable로 반환할 수 있음.
                // 결과의 순서를 원본 목록과 일치시켜서 하나의 Observable로 반환
                //                print("😀 profileImageObservables type : \(type(of: profileImageObservables)), profileImageObservables: \(profileImageObservables)")
                //                print("😀 Observable.zip(profileImageObservables) : \(Observable.zip(profileImageObservables))")
                return Observable.zip(profileImageObservables)
                
            } // flatMap
            .map {
                print("😀 feeds: \($0)")
                return Mutation.setFeeds($0)
            }
    }
    
    private func fetchAndProcessFeeds(setSortOption: SortOption) -> Observable<Mutation> {
            let requestDate: Int64? = setRequestDateBy(setSortOption)
            print("requestDate: \(requestDate)")

            return feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: "디저트러버", date: requestDate, page: 0, size: 7))
                .flatMap { (userFeeds, isLast) -> Observable<[UserFeed]> in
//                    if userFeeds.isEmpty {
//                        return Observable.just([])
//                    }
//                    
                    
                    let profileImageObservables: [Observable<UserFeed>] = userFeeds.map { feed in
                        // Check if the profile image is already cached
                        
                        print(" 🛑 feed.nickname : \(feed.nickName) ")
                        // MARK: 1차적으로 ImageCache에 저장이 되어있는지 확인
                        if let cachedImage = ImageCache.shared.cache[feed.nickName] {
                            print("⭕️ 캐시에 있음 - feedviewreactor nickname : \(feed.nickName)")
                            
                            var updateFeed = feed
                            updateFeed.profileImage = cachedImage
                            return Observable.just(updateFeed)
                        }

                        // Check if there is an ongoing request for the same nickname
                        if let ongoingRequest = self.ongoingProfileImageRequests[feed.nickName] {
                            print("✴️ ongoing Request: \(feed.nickName)")
                            return ongoingRequest
                                .map { profileImage in
                                    print("✴️ ongoing Request")
                                    var updatedFeed = feed
                                    updatedFeed.profileImage = profileImage
                                    return updatedFeed
                                }
                                .catch { error in
                                    return Observable.just(feed)
                                }
                        }

                        // Create a new request and add it to the ongoing requests dictionary
                        let request = self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: feed.nickName))
                        self.ongoingProfileImageRequests[feed.nickName] = request

                        return request
                            .map { profileImage in
                                print(" ❌ 캐시에 없음 - feedviewreactor nickname : \(feed.nickName)")
                                var updatedFeed = feed
                                updatedFeed.profileImage = profileImage
                                ImageCache.shared.cache[feed.nickName] = profileImage
                                return updatedFeed
                            }
                            .catch { error in
                                print("🚫 Feed view reactor findProfileImg error : \(error.localizedDescription), error nickname : \(feed.nickName)")
                                return Observable.just(feed)
                            }
                            .do(onDispose: {
                                // Remove the ongoing request when it's disposed (completed or errored)
                                self.ongoingProfileImageRequests[feed.nickName] = nil
                            }
                        )
                    }

                    return Observable.zip(profileImageObservables)
                }
                .map {
                    return Mutation.setFeeds($0)
                }
        }
}
