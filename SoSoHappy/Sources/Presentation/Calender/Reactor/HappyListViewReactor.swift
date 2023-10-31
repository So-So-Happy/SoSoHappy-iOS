//
//  HappyListViewReactor.swift
//  SoSoHappy
//
//  Created by Sue on 2023/09/21.
//

import ReactorKit

class HappyListViewReactor: Reactor {
    
    
    //MARK: - Properties
    let initialState: State
    
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private var currentPage: Date
    
    
    // MARK: - Init
    init (feedRepository: FeedRepositoryProtocol,
          userRepository: UserRepositoryProtocol,
          currentPage: Date,
          state: State = State(
            monthHappinessData: [],
            currentPage: Date(),
            date: ""
         )
    ) {
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.currentPage = currentPage
        self.initialState = state
    }
    
    // MARK: - Action
    enum Action {
        case viewDidLoad
        case tapNextButton
        case tapPreviousButton
        case tapHappyListCell
    }
    
    // MARK: - Mutation
    enum Mutation {
        case setFeedList([MyFeed])
        case setDate(String) // ex) 2023.10
        case presentDetailView
    }
    
    // MARK: - State
    struct State {
        var monthHappinessData: [MyFeed]
        var currentPage: Date
        var date: String
        @Pulse var presentDetailView: Void?
    }
    
    var forTest: [FeedTemp] = [
        FeedTemp(profileImage: UIImage(named: "profile")!,
                                profileNickName: "구름이", time: "10분 전",
                                isLike: true, weather: "sunny",
                                feedDate: "2023.09.18 월요일",
                                categories: ["sohappy", "coffe", "donut"],
                                content: "오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다.오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다오늘은 카페에 가서 맛있는 커피랑 배아굴울 먹었다. 잠깐이지만 마음 편하게 쉰 것 같아서 행복했다",
                                images: [UIImage(named: "bagel")!]
                                ),
        FeedTemp(profileImage: UIImage(named: "cafe")!,
                                profileNickName: "날씨조아", time: "15분 전",
                                isLike: false, weather: "rainy",
                                feedDate: "2023.09.07 목요일",
                                categories: ["sohappy", "coffe", "coffe"],
                                content: "오호라 잘 나타나는구만",
                                images: []
                                )
    ]
    
    
    //[UIImage(named: "cafe")!, UIImage(named: "churros")!]
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.setDate(currentPage.getFormattedYM())),
                feedRepository.findMonthFeed(request: FindFeedRequest(date: currentPage.getFormattedYMDH(), nickName: "wonder"))
                    .map { Mutation.setFeedList($0) }
            ])
        case .tapNextButton:
            let nextPage = moveToNextMonth(currentPage)
            return .concat([
                .just(.setDate(nextPage.getFormattedYM())),
                feedRepository.findMonthFeed(request: FindFeedRequest(date: nextPage.getFormattedYMDH(), nickName: "wonder"))
                    .map { Mutation.setFeedList($0) }
            ])
        case .tapPreviousButton:
            let previousPage = moveToPreviousMonth(currentPage)
            return .concat([
                .just(.setDate(previousPage.getFormattedYM())),
                feedRepository.findMonthFeed(request: FindFeedRequest(date: previousPage.getFormattedYMDH(), nickName: "wonder"))
                    .map { Mutation.setFeedList($0) }
            ])
        case .tapHappyListCell:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setFeedList(let feeds):
            newState.monthHappinessData = feeds
        case .setDate(let date):
            newState.date = date
        case .presentDetailView:
            newState.presentDetailView = ()
        }
        
        return newState
    }
}


extension HappyListViewReactor {
    func moveToNextMonth(_ currentPage: Date) -> Date {
        let calendar = Calendar.current
        let currentPage = calendar.date(byAdding: .month, value: 1, to: currentPage) ?? Date()
        return currentPage
    }
    
    func moveToPreviousMonth(_ currentPage: Date) -> Date {
        let calendar = Calendar.current
        let currentPage = calendar.date(byAdding: .month, value: -1, to: currentPage) ?? Date()
        return currentPage
    }
    
}



