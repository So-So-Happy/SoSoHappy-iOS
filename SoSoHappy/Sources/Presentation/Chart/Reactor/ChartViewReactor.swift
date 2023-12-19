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
    
    private var nickName: String = ""
    
    // MARK: - Init
    init(
        feedRepository: FeedRepositoryProtocol,
        userRepository: UserRepositoryProtocol,
        state: State = State(
            happinessTopThree: [],
            bestCategoryList: [],
            recommendCategoryList: [], 
            nowRecommendText: "",
            monthYearText: "",
            chartText: "" ,
            segementBarState: .month,
            happinessChartData: [], 
            xAxisData: [],
            yAxisData: [])
    ) {
        
        self.feedRepository = feedRepository
        self.userRepository = userRepository
        self.initialState = state
        
        self.nickName = KeychainService.getNickName()
        
    }
    
    enum Action {
        case viewDidLoad
        case tapAwardsDetailButton
        case tapRecommendRefreshButton
        case tapNextButton
        case tapPreviousButton
        case changeChartMode(index: Int)
    }
    
    enum Mutation {
        case fetchAnalysisHappiness(AnalysisHappinessResponse)
        case fetchHappiness([ChartEntry])
        case setRecommendIdx
        case showNextRecommend
        case setMonthYearText(String)
        case setSegementBarState(ChartState)
    }

    struct State {
        var happinessTopThree: [String]
        var bestCategoryList: [String]
        var recommendCategoryList: [String]
        var nowRecommendText: String
        var monthYearText: String
        var chartText: String
        var segementBarState: ChartState
        var happinessChartData: [ChartEntry]
        var xAxisData: [String]
        var yAxisData: [String]
    }
    
    // MARK: - mutate func
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.setMonthYearText(date.getFormattedYM2())),
                feedRepository.analysisHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                    .map { Mutation.fetchAnalysisHappiness($0) },
                .just(.showNextRecommend),
                feedRepository.findMonthHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                    .map { Mutation.fetchHappiness($0) }
            ])
        case .tapRecommendRefreshButton:
            return .concat([
                .just(.setRecommendIdx),
                .just(.showNextRecommend)
            ])
        case .tapAwardsDetailButton:
            return .empty()
        case .changeChartMode(let idx):
            if idx == 1 {
                return .concat([
                    .just(.setSegementBarState(.year)),
                    feedRepository.findYearHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            } else {
                return .concat([
                    .just(.setSegementBarState(.month)),
                    feedRepository.findMonthHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            }
        case .tapNextButton:
            date = date.moveToNextMonth()
            switch segementBarState {
            case .year:
                return .concat([
                    .just(.setMonthYearText(date.getFormattedYM2())),
                    feedRepository.analysisHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchAnalysisHappiness($0) },
                    feedRepository.findYearHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            case .month:
                return .concat([
                    .just(.setMonthYearText(date.getFormattedYM2())),
                    feedRepository.analysisHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchAnalysisHappiness($0) },
                    feedRepository.findMonthHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            }
        case .tapPreviousButton:
            date = date.moveToPreviousMonth()
            switch segementBarState {
            case .year:
                return .concat([
                    .just(.setMonthYearText(date.getFormattedYM2())),
                    feedRepository.analysisHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchAnalysisHappiness($0) },
                    feedRepository.findYearHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            case .month:
                return .concat([
                    .just(.setMonthYearText(date.getFormattedYM2())),
                    feedRepository.analysisHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchAnalysisHappiness($0) },
                    feedRepository.findMonthHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setMonthYearText(let date):
            newState.monthYearText = date
        case .fetchAnalysisHappiness(let data):
            newState.bestCategoryList = data.bestCategoryList
            newState.happinessTopThree = Array(data.bestCategoryList.prefix(3))
            newState.recommendCategoryList = data.recommendCategoryList
            self.recommendList = data.recommendCategoryList
            nowRecommendListIdx = 0
            newState.nowRecommendText = data.recommendCategoryList[nowRecommendListIdx]
        case .fetchHappiness(let data):
            newState.happinessChartData = data
        case .setRecommendIdx:
            nowRecommendListIdx = (nowRecommendListIdx + 1) % recommendList.count
        case .showNextRecommend:
            newState.nowRecommendText = recommendList[nowRecommendListIdx]
        case .setSegementBarState(let state):
            newState.segementBarState = state
            self.segementBarState = state
        }
        
        return newState
    }
}


enum ChartState {
    case year
    case month
}
