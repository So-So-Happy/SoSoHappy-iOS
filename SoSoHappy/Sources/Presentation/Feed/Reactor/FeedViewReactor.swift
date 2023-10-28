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

enum SortOption {
    case today
    case total
    case currentSort // 미리 설정되어 있던 sortOption 설정해주기 위한 case
}

final class FeedViewReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let imageCacheManager: ImageCacheManager
    
    enum Action {
        case refresh
        case fetchFeeds(SortOption)
        case selectedCell(index: Int)
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case isLoading(Bool) // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        case setFeeds([UserFeed])
        case sortOption(SortOption)
        case selectedCell(index: Int)
    }
    
    struct State {
        var isRefreshing: Bool = false
        var isLoading: Bool? // 로딩 띄울 때 쓰려고 일단 만들어 놓음
        var userFeeds: [UserFeed]?
        var sortOption: SortOption?
        var selectedFeed: UserFeed?
    }
    
    let initialState: State
    
    init(
        feedRepository: FeedRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        imageCacheManager: ImageCacheManager)
    { //userRepository: UserRepositoryProtocol 추가
        initialState = State()
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.imageCacheManager = imageCacheManager
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            // currentState.sortOption에 따라 달라짐
            return .concat([
                .just(.setRefreshing(true)).delay(.seconds(3), scheduler: MainScheduler.instance),
                fetchAndProcessFeeds(setSortOption: currentState.sortOption!),
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
                .just(.setFeeds([])),
                .just(.isLoading(true)),
                // .isLoading ->  1초 delay 후 -> fetchAndProcessFeed 실행
                fetchAndProcessFeeds(setSortOption: setSortOption).delay(.milliseconds(400), scheduler: MainScheduler.instance),
                .just(.isLoading(false))
            ])
            
        case let .selectedCell(index):
            return .just(.selectedCell(index: index))
        }
    }
    // MARK: state.selectedFeed = nil를 한 곳에만 써도 될 것 같은데 한번 더 확인해보기
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            print("reduce - .setFreshing ")
            state.isRefreshing = isRefreshing
            
        case let .setFeeds(feeds):
            print("reduce -  .setFeeds : \(feeds)")
            state.userFeeds = feeds
            
        case let .sortOption(sort):
            print("reduce -  .sortOption : \(sort)")
            state.sortOption = sort
            state.selectedFeed = nil
            
        case let .selectedCell(index):
            print("reduce - .selectedCell")
            if let userFeeds = state.userFeeds {
                state.selectedFeed = userFeeds[index]
            }
            
        case let .isLoading(isLoading):
            state.isLoading = isLoading
            
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
        case .total:
            return nil
        default:
            return nil
        }
    }
    
    private func fetchAndProcessFeeds(setSortOption: SortOption) -> Observable<Mutation> {
        let requestDate: Int64? = setRequestDateBy(setSortOption)
        print("requestDate: \(requestDate)")
        
        return feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: "디저트러버", date: requestDate, page: 0, size: 7))
            .flatMap { userFeeds -> Observable<[UserFeed]> in
//                if userFeeds.isEmpty {
//                    print("비어있다")
//                    return Observable.just([])
//                }
                
                print("😀 type : \(type(of: userFeeds)), userFeeds: \(userFeeds)")
                let profileImageObservables: [Observable<UserFeed>] = userFeeds.map { feed in
                    return self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: feed.nickName))
                        .map { profileImage in
                            var updatedFeed = feed
                            print("HERE")
                            updatedFeed.profileImage = profileImage
                            return updatedFeed
                        }// map
                        .catch { error in
                            print("Feed view reactor findProfileImg error : \(error.localizedDescription)")
                            return Observable.just(feed)
                        }
                } // map
                // Observable.zip - profileImageObservables의 모든 작업이 끝날 때까지 기다림
                // 모든 작업의 결과를 하나의 Observable로 반환할 수 있음.
                // 결과의 순서를 원본 목록과 일치시켜서 하나의 Observable로 반환
                print("😀 profileImageObservables type : \(type(of: profileImageObservables)), profileImageObservables: \(profileImageObservables)")
                print("😀 Observable.zip(profileImageObservables) : \(Observable.zip(profileImageObservables))")
                return Observable.zip(profileImageObservables)
                
            } // flatMap
            .map { Mutation.setFeeds($0) }
    }
    
    
    
    //    private func fetchAndProcessFeeds(setSortOption: SortOption) -> Observable<Mutation> {
    //        let requestDate: Int64? = setRequestDateBy(setSortOption)
    //
    //        return feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: "디저트러버", date: requestDate, page: 0, size: 7))
    //            .flatMap { [weak self] userFeeds -> Observable<[UserFeed]> in
    //                print("😀 type : \(type(of: userFeeds))")
    //                let profileImageObservables: [Observable<UserFeed>] = userFeeds.map { feed in
    //                    if let cachedImage = self?.imageCacheManager.get(key: feed.nickName) {
    //                        print("❤️ Cache에 이미지가 있었어 ")
    //                        return Observable.just(feed.with(profileImage: cachedImage))
    //                    } else {
    //                        print("🖤  Cache에 이미지가 없어 ")
    //                        return self?.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: feed.nickName))
    //                            .map { profileImage in
    //                                self?.imageCacheManager.add(key: feed.nickName, value: profileImage)
    //                                return feed.with(profileImage: profileImage)
    //                            }
    //                    }
    ////                    } else if let fetchImageObservable = self?.fetchProfileImage(feed: feed) {
    ////                        print("🖤  Cache에 이미지가 없어 ")
    ////                        return fetchImageObservable
    ////                    } else {
    ////                        return Observable.just(feed)
    ////                    }
    //                } // map
    //                // Observable.zip - profileImageObservables의 모든 작업이 끝날 때까지 기다림
    //                // 모든 작업의 결과를 하나의 Observable로 반환할 수 있음.
    //                // 결과의 순서를 원본 목록과 일치시켜서 하나의 Observable로 반환
    //                return Observable.zip(profileImageObservables)
    //
    //            } // flatMap
    //            .map {
    //                print("@@feeds : \($0)")
    //                return Mutation.setFeeds($0)
    //            }
    ////            .catch { error in
    ////                print("🚩Error fetchAndProcessFeeds")
    ////                return Observable.just(.setFeeds([]))
    ////            }
    //    }
    
    private func fetchProfileImage(feed: UserFeed) -> Observable<UserFeed> {
        return self.userRepository.findProfileImg(request: FindProfileImgRequest(nickname: feed.nickName))
            .map { profileImage in
                self.imageCacheManager.add(key: feed.nickName, value: profileImage)
                return feed.with(profileImage: profileImage)
            }
    }
}

/*
 1. 피드 닉네임에 대한 이미지가 메모리 캐시에 있는지 검색
 2. 있으면, 바로 사용
 3. 없으면, 네트워크 다운로드 -> 캐시에 저장
 */
