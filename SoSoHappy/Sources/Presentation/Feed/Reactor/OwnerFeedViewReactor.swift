//
//  OwnFeedViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/11.
//

import ReactorKit

/*
 1. refresh control dealy 이런거 직접 통신해보면서 조정
 */

/*
 requset
 srcNickName: String    // 조회하는 유저 닉네임
 dstNickName: String    // 조회 대상 닉네임
 page: Int
 size: Int
 */

/*
 response
 nickName: String   // "admin1"
 weather: String    // "sunny"
 date: Int          // 2023090913248392
 happiness: Int     // 3
 text: String       // "hi~"
 categoryList: [String] // ["coffee"]
 imageList: [바이트]   // []
 isLiked: Bool      // false
 */

class OwnerFeedViewReactor: Reactor {
    enum Action {
        case fetchFeeds
        case refresh
        case selectedCell(index: Int)
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case profile(ProfileTemp)
        case setFeeds([FeedTemp])
        case selectedCell(index: Int)
    }
    
    struct State {
        var ownerNickName: String
        var isRefreshing: Bool = false
        var profile: ProfileTemp?
        var feeds: [FeedTemp] = []
        var selectedFeed: FeedTemp?
    }
    
    let initialState: State
    
    init(ownerNickName: String) {
        initialState = State(ownerNickName: ownerNickName)
    }
    
    var forTest: [FeedTemp] = [
        FeedTemp(profileImage: UIImage(named: "profile")!,
                                profileNickName: "Reactor", time: "10분 전",
                                isLike: true, weather: "sunny",
                                feedDate: "2023.09.08 금요일",
                                categories: ["sohappy", "coffe", "donut"],
                                content: "츄로스 맛집 발견. 너무 행복해~",
                                images: [UIImage(named: "churros")!]
                                ),
        FeedTemp(profileImage: UIImage(named: "profile")!,
                                profileNickName: "Reactor22", time: "15분 전",
                                isLike: false, weather: "rainy",
                                feedDate: "2023.09.07 목요일",
                                categories: ["sohappy", "coffe", "donut"],
                                content: "오호라 잘 나타나는구만",
                                images: [UIImage(named: "cafe")!, UIImage(named: "churros")!]
                                )
    ]
    
    var testProfile = ProfileTemp(profileImage: UIImage(named: "pic2")!, profileNickName: "날씨조아", selfIntroduction: "나는야 날씨조아. 디저트 러버. 크로플, 도넛, 와플이 내 최애 디저트다. 음료는 아이스아메리카노 좋아함 !")
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchFeeds:
            // MARK: 일단은 Loading 없이 이렇게 처리함 (실제로 서버 연결해보면서 확인해보기)
            let fetchedFeeds: [FeedTemp] = []
            let profile = testProfile
            
            return Observable.concat([
                Observable.just(Mutation.profile(profile)),
                Observable.just(Mutation.setFeeds(fetchedFeeds))
            ])
            
        case .refresh:
            let fetchedFeeds: [FeedTemp] = []
            let profile = testProfile
            print("refreshed")
            return Observable.concat([
                Observable.just(.setRefreshing(true)).delay(.seconds(3), scheduler: MainScheduler.instance),
                //              UserService.users().map(Mutation.setUsers),
                // user 프로필도 불러와야 함
                Observable.just(Mutation.profile(profile)),
                Observable.just(Mutation.setFeeds(fetchedFeeds)), // 통신해서 받아온 feed들을 Mutation.setFeeds로 map
                Observable.just(.setRefreshing(false))
            ])
            
        case let .selectedCell(index):
            return Observable.just(.selectedCell(index: index))
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            
        case let .setFeeds(feeds):
            state.feeds = forTest
//            state.selectedFeed = nil
            
        case let .profile(profile):
            state.profile = testProfile
            state.selectedFeed = nil
            
        case let .selectedCell(index):
            print("선택했음")
            state.selectedFeed = state.feeds[index]
        }
        
        return state
    }
}
