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


class OwnFeedViewReactor: Reactor {
    enum Action {
        case refresh
    }
    
    enum Mutation {
        case setRefreshing(Bool)
        case profile(Profile)
        case setFeeds([Feed])
    }
    
    struct State {
        var isRefreshing: Bool = false
        var profile: Profile?
        var feeds: [Feed] = []
    }
    
    let initialState: State
    
    init() {
        initialState = State()
    }
    
    var forTest: [Feed] = [
        Feed(profileImage: UIImage(named: "profile")!,
                                profileNickName: "Reactor", time: "10분 전",
                                isLike: true, weather: "sunny",
                                date: "2023.09.08 금요일",
                                categories: ["sohappy", "coffe", "donut"],
                                content: "엥 이거 왜 안나타나지?",
                                images: [UIImage(named: "bagel")!]
                                ),
        Feed(profileImage: UIImage(named: "profile")!,
                                profileNickName: "Reactor22", time: "15분 전",
                                isLike: false, weather: "rainy",
                                date: "2023.09.07 목요일",
                                categories: ["sohappy", "coffe", "donut"],
                                content: "오호라 잘 나타나는구만",
                                images: [UIImage(named: "cafe")!, UIImage(named: "churros")!]
                                )
    ]
    
    var testProfile = Profile(profileImage: UIImage(named: "pic2")!, profileNickName: "아메리카노러버", selfIntroduction: "나는야 소해피. 디저트 러버. 크로플, 도넛, 와플이 내 최애 디저트다. 음료는 아이스아메리카노 좋아함 !")
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .refresh:
            let fetchedFeeds: [Feed] = []
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
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case let .setRefreshing(isRefreshing):
            state.isRefreshing = isRefreshing
            
        case let .setFeeds(feeds):
            state.feeds = forTest
            
        case let .profile(profile):
            state.profile = testProfile
            
        }
        return state
    }
}
