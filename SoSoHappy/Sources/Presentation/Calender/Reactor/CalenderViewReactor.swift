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
    
    private var nickName: String = ""
    
    // MARK: - Init
    init(
        feedRepository: FeedRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        state: State = State(
            year: "",
            month: "",
            monthHappinessData: [],
            currentPage: Date(),
            dayFeed: MyFeed(),
            selectedDate: Date())
    ) {
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.initialState = state
        
        self.nickName = KeychainService.getNickName()
    }
    
    // MARK: - Action
    enum Action {
        case viewWillAppear
        case tapAlarmButton
        case tapListButton
        case tapPreviousButton
        case tapNextButton
        case selectDate(Date)
        case changeCurrentPage(Date)
        case tapPreview
    }
    
    // MARK: - Mutaion
    enum Mutation {
        case setCalendarCell([MyFeed])
        case presentAlertView
        case presentListView
        case setPreview(MyFeed)
        case setSelectedDate(Date)
        case setMonth
        case setYear
        case changeCurrentPage(Date)
        case moveToNextMonth(Date)
        case moveToPreviousMonth(Date)
        case testOtherFeed(UpdateLikeResponse)
        case presentDetailView
    }
    
    // MARK: - State
    struct State {
        var year: String
        var month: String
        var monthHappinessData: [MyFeed]
        var currentPage: Date
        var dayFeed: MyFeed
        var selectedDate: Date
        @Pulse var showEmptyPreview: Void?
        @Pulse var presentAlertView: Void?
        @Pulse var presentListView: Void?
        @Pulse var presentDetailView: Void?
    }
    
    // MARK: - mutate func
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return .concat([
                .just(.setYear),
                .just(.setMonth),
                feedRepository.findMonthFeed(request: FindFeedRequest(date: self.currentPage.getFormattedYMDH(), nickName: nickName))
                    .map {
                        return Mutation.setCalendarCell($0)
                    },
                feedRepository.findDayFeed(request: FindFeedRequest(date: Date().getFormattedYMDH(), nickName: nickName))
                .map { .setPreview($0) }
            ])
        case .tapAlarmButton:
            return .just(.presentAlertView)
        case .tapListButton:
            return .just(.presentListView)
        case .changeCurrentPage(let date):
            return .concat([
                feedRepository.findMonthFeed(request: FindFeedRequest(date: date.getFormattedYMDH(), nickName: nickName))
                    .map({ Mutation.setCalendarCell($0) }),
                .just(.changeCurrentPage(date)),
                .just(.setMonth),
                .just(.setYear),
                feedRepository.findDayFeed(request: FindFeedRequest(date: date.getFormattedYMDH(), nickName: nickName))
                .map { .setPreview($0) }
            ])
        case .tapNextButton:
            let nextPage = currentPage.moveToNextMonth()
            return .just(.changeCurrentPage(nextPage))
        case .tapPreviousButton:
            let previousPage = currentPage.moveToPreviousMonth()
            return .just(.changeCurrentPage(previousPage))
        case .selectDate(let date):
            return .concat([
                feedRepository.findDayFeed(request: FindFeedRequest(date: date.getFormattedYMDH(), nickName: nickName))
                .map { .setPreview($0) },
                .just(.setSelectedDate(date))
            ])
        case .tapPreview:
            return .just(.presentDetailView)
        }
    }

    //MARK: - reduce func
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setCalendarCell(let feeds):
            newState.monthHappinessData = feeds
        case .presentAlertView:
            newState.presentAlertView = ()
        case .presentListView:
            newState.presentListView = ()
        case .changeCurrentPage(let currentPage):
            self.currentPage = currentPage
            newState.currentPage = currentPage
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
//        case .showErrorAlert(_):
        case .setPreview(let feed):
            newState.dayFeed = feed
        case .setSelectedDate(let date):
            newState.selectedDate = date
        case .presentDetailView:
            newState.presentDetailView = ()
        }
        
        return newState
    }
    
}


