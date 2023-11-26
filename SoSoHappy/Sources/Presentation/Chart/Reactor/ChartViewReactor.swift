//
//  ChartViewReactor.swift
//  SoSoHappy
//
//  Created by 박희경 on 2023/10/21.
//

import Foundation
import ReactorKit
import RxSwift
import Moya


final class ChartViewReactor: Reactor {
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    let initialState: State
    
    private let feedRepository: FeedRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    private var nowRecommendListIdx: Int = 0
    private var recommendList: [String] = []
    private var date = Date()
    private var segementBarState: ChartState = .month
    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    
    // MARK: - Init
    init(
        feedRepository: FeedRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        state: State = State(
            happinessTopThree: [],
            bestCategoryList: [],
            recommendCategoryList: [], 
            nowRecommendText: "",
            chartText: "" ,
            segementBarState: .month,
            happinessChartData: [], 
            xAxisData: [],
            yAxisData: [])
    ) {
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.initialState = state
    }
    
    enum Action {
        case viewDidLoad
        case tapAwardsDetailButton
        case tapRecommendRefreshButton
        case tapMonthChartButton // x
        case tapYearChratButton // x
        case tapNextButton // 날짜
        case tapPreviousButton // 날짜
        case changeChartMode
    }
    
    enum Mutation {
        case fetchAnalysisHappiness(AnalysisHappinessResponse) // awards + recommend
        case fetchHappiness([FindHappinessResponse])
        case showNextRecommend
        case setChartText(Date)
        case setSegementBarState(ChartState)
    }

    struct State {
        var happinessTopThree: [String]
        var bestCategoryList: [String]
        var recommendCategoryList: [String]
        var nowRecommendText: String
        var chartText: String // ex) 1월, 2023년
        var segementBarState: ChartState // ex) .month, .year
        var happinessChartData: [FindHappinessResponse]
        var xAxisData: [String] // x축
        var yAxisData: [String] // y축
    }
    
    
    // MARK: - mutate func
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.setChartText(self.date)),
                feedRepository.analysisHappiness(request: HappinessRequest(nickname: "wonder", date: self.date.getFormattedYMDH()))
                    .map { Mutation.fetchAnalysisHappiness($0) },
                feedRepository.findMonthHappiness(request: HappinessRequest(nickname: "wonder", date: self.date.getFormattedYMDH()))
                    .map { Mutation.fetchHappiness($0) }
            ])
        case .tapAwardsDetailButton:
            return .empty()
        case .tapMonthChartButton:
            return .concat([
                .just(.setSegementBarState(.month)),
                .just(.setChartText(self.date)),
                feedRepository.findMonthHappiness(request: HappinessRequest(nickname: "wonder", date: self.date.getFormattedYMDH()))
                    .map { Mutation.fetchHappiness($0) }
            ])
        case .changeChartMode:
            if segementBarState == .month {
                return .concat([
                    .just(.setSegementBarState(.year)),
                    feedRepository.findYearHappiness(request: HappinessRequest(nickname: "wonder", date: self.date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            } else {
                return .concat([
                    .just(.setSegementBarState(.month)),
                    feedRepository.findMonthHappiness(request: HappinessRequest(nickname: "wonder", date: self.date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            }
        case .tapYearChratButton:
            return .concat([
                .just(.setSegementBarState(.year)),
                .just(.setChartText(self.date)),
                feedRepository.findYearHappiness(request: HappinessRequest(nickname: "wonder", date: self.date.getFormattedYMDH()))
                    .map { Mutation.fetchHappiness($0) }
            ])
        case .tapRecommendRefreshButton:
            return .just(.showNextRecommend)
        case .tapNextButton:
            switch segementBarState {
            case .year:
                let nextYear = moveToNextYear(self.date)
                return .concat([
                    .just(.setChartText(nextYear)),
                    feedRepository.findYearHappiness(request: HappinessRequest(nickname: "wonder", date: nextYear.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            case .month:
                let nextMonth = moveToNextMonth(self.date)
                return .concat([
                    .just(.setChartText(self.date)),
                    feedRepository.findMonthHappiness(request: HappinessRequest(nickname: "wonder", date: nextMonth.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            }
        case .tapPreviousButton:
            switch segementBarState {
            case .year:
                let previousYear = moveToPreviousYear(self.date)
                return .concat([
                    .just(.setChartText(previousYear)),
                    feedRepository.findYearHappiness(request: HappinessRequest(nickname: "wonder", date: previousYear.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            case .month:
                let previousMonth = moveToPreviousMonth(self.date)
                return .concat([
                    .just(.setChartText(previousMonth)),
                    feedRepository.findMonthHappiness(request: HappinessRequest(nickname: "wonder", date: previousMonth.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .fetchAnalysisHappiness(let data):
            newState.bestCategoryList = data.bestCategoryList
            newState.happinessTopThree = Array(data.bestCategoryList.prefix(3))
            newState.recommendCategoryList = data.recommendCategoryList
        case .fetchHappiness(let data):
            newState.happinessChartData = data
        case .showNextRecommend:
            let nextIdx = ( nowRecommendListIdx + 1) % recommendList.count
            newState.nowRecommendText = recommendList[nextIdx]
            self.nowRecommendListIdx = nextIdx
        case .setChartText(let date):
            switch segementBarState {
            case .month:
                newState.chartText = date.getFormattedDate(format: "M월")
            case .year:
                newState.chartText = date.getFormattedDate(format: "yyyy년")
            }
        case .setSegementBarState(let state):
            newState.segementBarState = state
            self.segementBarState = state
        }
        
        return newState
    }
}

extension ChartViewReactor {
    
    // FIXME: - moveToNextMonth 중복 코드 refector
    func moveToNextMonth(_ currentPage: Date) -> Date {
        let calendar = Calendar.current
        var nextPage = calendar.date(byAdding: .month, value: 1, to: currentPage) ?? Date()
        
        if calendar.component(.year, from: nextPage) != calendar.component(.year, from: currentPage)
        {
            nextPage = calendar.date(bySetting: .year, value: calendar.component(.year, from: currentPage), of: nextPage) ?? Date()
        }
        
        return nextPage
    }
    
    func moveToPreviousMonth(_ currentPage: Date) -> Date {
        let calendar = Calendar.current
        var previousPage = calendar.date(byAdding: .month, value: -1, to: currentPage) ?? Date()
        
        if calendar.component(.year, from: previousPage) != calendar.component(.year, from: currentPage)
        {
            previousPage = calendar.date(bySetting: .year, value: calendar.component(.year, from: currentPage), of: previousPage) ?? Date()
        }
        
        return previousPage
    }
    
    func moveToNextYear(_ currentPage: Date) -> Date {
        let calendar = Calendar.current
        let nextPage = calendar.date(byAdding: .year, value: 1, to: currentPage) ?? Date()
        return nextPage
    }
    
    func moveToPreviousYear(_ currentPage: Date) -> Date {
        let calendar = Calendar.current
        let previousPage = calendar.date(byAdding: .year, value: -1, to: currentPage) ?? Date()
        return previousPage
    }
    
    func moveToNextRecommend(recommends: [String], currentIdx: Int) -> String {
        let nextIdx = (currentIdx + 1) % recommends.count
        let recommend = recommends[nextIdx]
        return recommend
    }
}


enum ChartState {
    case year
    case month
}
