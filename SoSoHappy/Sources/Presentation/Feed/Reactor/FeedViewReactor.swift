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

class FeedViewReactor: Reactor {
    private let feedRepository: FeedRepositoryProtocol
    
    enum Action {
        case refresh
        case fetchFeeds(SortOption)
        case selectedCell(index: Int)
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case setFeeds([UserFeed])
        case sortOption(SortOption)
        case selectedCell(index: Int)
    }
    
    struct State {
        var isRefreshing: Bool = false
        var userFeeds: [UserFeed] = []
        var sortOption: SortOption?
        var selectedFeed: UserFeed?
    }
    
    let initialState: State
    
    init(feedRepository: FeedRepositoryProtocol) {
        initialState = State()
        self.feedRepository = feedRepository
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            // currentState.sortOption에 따라 달라짐
            let requestDate: Int64? = setRequestDateBy(currentState.sortOption!)
            
            return .concat([
                .just(.setRefreshing(true)).delay(.seconds(3), scheduler: MainScheduler.instance),
//                fetchFeedBySortOption(currentState.sortOption),
                feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: "디저트러버", date: requestDate, page: 0, size: 7))
                    .map { Mutation.setFeeds($0) },
                
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
            
            let requestDate: Int64? = setRequestDateBy(setSortOption)
            
            return .concat([
                .just(.sortOption(setSortOption)),
                feedRepository.findOtherFeed(request: FindOtherFeedRequest(nickname: "디저트러버", date: requestDate, page: 0, size: 7))
                    .map { Mutation.setFeeds($0) }
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
            state.selectedFeed = state.userFeeds[index]
            
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
}
