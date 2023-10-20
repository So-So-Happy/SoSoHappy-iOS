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
    var currentPage: Date = Date()
    
    // MARK: - Init
    init(
        feedRepository: FeedRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        state: State = State(
            year: "",
            month: "",
            monthHappinessData: [],
        currentPage: Date())
    ) {
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.initialState = state
    }
    
    // MARK: - Action
    enum Action {
        case viewDidLoad
        case tapAlarmButton
        case tapListButton
        case tapPreviousButton
        case tapNextButton
//        case selectDate
    }
    
    // MARK: - Mutaion
    enum Mutation {
        case setCalendarCell([MyFeed])
        case presentAlertView
        case presentListView
//        case setPreview(Feed)
        case setMonth
        case setYear
        case moveToNextMonth(Date)
        case moveToPreviousMonth(Date)
        case testOtherFeed(UpdateLikeResponse)
//        case showErrorAlert(Error)
    }
    
    // MARK: - State
    struct State {
        var year: String
        var month: String
        var monthHappinessData: [MyFeed]
        var currentPage: Date
        @Pulse var presentAlertView: Void?
        @Pulse var presentListView: Void?
//        var happinessPreviewData: Feed
    }
    
    
    // MARK: - mutate func
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.setYear),
                .just(.setMonth),
                feedRepository.findMonthFeed(request: FindFeedRequest(date: self.currentPage.getFormattedYMDH(), nickName: "wonder"))
                    .map {
                        print("\($0)")
                        return Mutation.setCalendarCell($0)
                    }
            ])
        case .tapAlarmButton:
            return .just(.presentAlertView)
        case .tapListButton:
            return .just(.presentListView)
        case .tapNextButton:
            let nextPage = moveToNextMonth(currentPage)
            return .concat([
                feedRepository.findMonthFeed(request: FindFeedRequest(date: nextPage.getFormattedYMDH(), nickName: "wonder"))
                    .map({ Mutation.setCalendarCell($0) }),
                .just(.moveToNextMonth(nextPage)),
                .just(.setMonth),
                .just(.setYear)
            ])
        case .tapPreviousButton:
            let previousPage = moveToPreviousMonth(currentPage)
            return .concat([
                feedRepository.findMonthFeed(request: FindFeedRequest(date: previousPage.getFormattedYMDH(), nickName: "wonder"))
                    .map({ .setCalendarCell($0) }),
                .just(.moveToPreviousMonth(previousPage)),
                .just(.setMonth),
                .just(.setYear)
            ])
        }
    }

    //MARK: - reduce func
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setCalendarCell(let feeds):
            newState.monthHappinessData = feeds
        case .presentAlertView:
            newState.presentListView = ()
        case .presentListView:
            newState.presentListView = ()
        case .moveToNextMonth(let currentPage):
            self.currentPage = currentPage
            newState.currentPage = currentPage
        case .moveToPreviousMonth(let currentPage):
            self.currentPage = currentPage
            newState.currentPage = currentPage
        case .setYear:
            newState.year = self.currentPage.getFormattedDate(format: "yyyy")
        case .setMonth:
            newState.month = self.currentPage.getFormattedDate(format: "M월")
        case .testOtherFeed:
            newState.year = state.currentPage.getFormattedDate(format: "yyyy")
//            /        case .setPreview(_):
//            //            <#code#>
//        case .showErrorAlert(_):
            
//            <#code#>
            
        }
        
        return newState
    }
    
}


extension CalendarViewReactor {
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



