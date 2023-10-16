//
//  CalendarViewReactor.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/02.
//

import Foundation
import RxSwift
import ReactorKit
import Moya


final class CalendarViewReactor: Reactor {
    
    // MARK: - property
    let disposeBag = DisposeBag()
    
    let initialState: State
    
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    private var monthFeed: [MyFeed] = []
//    private var dayFeed: FindDayFeedResponse
    
    
    // MARK: - Init
    init(
        feedRepository: FeedRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        state: State = State(
            year: "",
            month: "",
            monthHappinessData: [])
    ) {
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.initialState = state
    }
    
    // MARK: - Action
    enum Action {
        case viewDidLoad
        case tapAlertButton
        case tapListButton
//        case tapPreviousButton
//        case tapNextButton
//        case selectDate
    }
    
    // MARK: - Mutaion
    enum Mutation {
        case setCalendarCell([MyFeed])
        case presentAlertView
        case presentListView
//        case setPreview(Feed)
//        case setMonth(String)
//        case setYear(String)
//        case showErrorAlert(Error)
    }
    
    // MARK: - State
    struct State {
        var year: String
        var month: String
        var monthHappinessData: [MyFeed]
        var currentPage: Date?
        @Pulse var presentAlertView: Void?
        @Pulse var presentListView: Void?
//        var happinessPreviewData: Feed
    }
    
    
    // MARK: - mutate func
    func mutate(action: Action) -> Observable<Mutation> {
        print("mutate func start: action: \(action)")
        switch action {
        case .viewDidLoad:
            return feedRepository.findMonthFeed(request: FindFeedRequest(date: Int64(2023091519321353), nickName: "wonder"))
                .map { Mutation.setCalendarCell($0) }
        case .tapAlertButton:
            print("mutate tapAlertButton action")
            let obser = Observable.just(Mutation.presentAlertView)
            return .just(.presentAlertView)
        case .tapListButton:
            print("mutate tabListButton action")
            return .just(.presentListView)
        }
    }

    //MARK: - reduce func
    func reduce(state: State, mutation: Mutation) -> State {
        print("reduce func start, state: \(state), mutation: \(mutation)")
        var newState = state
        switch mutation {
        case .setCalendarCell(let feeds):
            print("reduce setCalendarCell ")
            newState.monthHappinessData = feeds
        case .presentAlertView:
            print("reduce presentAlertView ")
            newState.presentListView = ()
        case .presentListView:
            print("reduce presentAlertView ")
            newState.presentListView = ()
//        case .setPreview(_):
//            <#code#>
//        case .setMonth(_):
//            <#code#>
//        case .setYear(_):
//            <#code#>
//        case .showErrorAlert(_):
//            <#code#>
        }
        
        return newState
    }
    
}


extension CalendarViewReactor {
    
   
}



