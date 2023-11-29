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
    private var monthDays: [String] = []
    private let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    private var segementBarState: ChartState = .month
    
    private let provider = KeychainService.loadData(
            serviceIdentifier: "sosohappy.userInfo",
            forKey: "provider"
        ) ?? ""
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
        
        self.nickName = KeychainService.loadData(
            serviceIdentifier: "sosohappy.userInfo\(provider)",
            forKey: "userNickName"
        ) ?? ""
        
//        self.monthDays = setGraphXaxis()
    }
    
    enum Action {
        case viewDidLoad // 이번달 데이터 모두 불러오기(ranking, recommend, chart data)
        case tapAwardsDetailButton
        case tapRecommendRefreshButton
        case tapMonthChartButton // x deprecated
        case tapYearChratButton // x deprecated
        case tapNextButton // 다음달 날짜 (2023.3월) + viewDidLoad 에서 fetch 하는 모든 데이터 가져오기
        case tapPreviousButton // 이전달 날짜 (2023.3월) + 위랑동일
        case changeChartMode(index: Int) // 월 -> 년도 , 년도 -> 월
    }
    
    enum Mutation {
        case fetchAnalysisHappiness(AnalysisHappinessResponse) // awards + recommend
        case fetchHappiness([FindHappinessResponse]) // month or year happiness
        case showNextRecommend
        case setChartText(Date) // deprecated
        case setMonthYearText(String)
        case setSegementBarState(ChartState)
    }

    struct State {
        var happinessTopThree: [String]
        var bestCategoryList: [String]
        var recommendCategoryList: [String]
        var nowRecommendText: String
        var monthYearText: String
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
                .just(.setMonthYearText(date.getFormattedYM())),
                .just(.setChartText(date)),
                feedRepository.analysisHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                    .map { Mutation.fetchAnalysisHappiness($0) },
                feedRepository.findMonthHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                    .map { Mutation.fetchHappiness($0) }
            ])
        case .tapRecommendRefreshButton:
            return .just(.showNextRecommend)
        case .tapAwardsDetailButton:
            return .empty()
        case .tapMonthChartButton:
            return .concat([
                .just(.setSegementBarState(.month)),
                .just(.setChartText(date)),
                feedRepository.findMonthHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                    .map { Mutation.fetchHappiness($0) }
            ])
        case .tapYearChratButton:
            return .concat([
                .just(.setSegementBarState(.year)),
                .just(.setChartText(date)),
                feedRepository.findYearHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                    .map { Mutation.fetchHappiness($0) }
            ])
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
                    .just(.setMonthYearText(date.getFormattedYM())),
                    .just(.setChartText(date)),
                    feedRepository.findYearHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            case .month:
                return .concat([
                    .just(.setMonthYearText(date.getFormattedYM())),
                    .just(.setChartText(date)),
                    feedRepository.findMonthHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            }
        case .tapPreviousButton:
            date = date.moveToPreviousMonth()
            switch segementBarState {
            case .year:
                return .concat([
                    .just(.setMonthYearText(date.getFormattedYM())),
                    .just(.setChartText(date)),
                    feedRepository.findYearHappiness(request: HappinessRequest(nickname: nickName, date: date.getFormattedYMDH()))
                        .map { Mutation.fetchHappiness($0) }
                ])
            case .month:
                return .concat([
                    .just(.setMonthYearText(date.getFormattedYM())),
                    .just(.setChartText(date)),
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
        case .fetchHappiness(let data):
            newState.happinessChartData = data
            // x, y 데이터 세팅
//            newState.xAxisData = setGraphXaxis()
//            newState.yAxisData =
        case .showNextRecommend:
            let nextIdx = (nowRecommendListIdx + 1) % recommendList.count
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
    func moveToNextRecommend(recommends: [String], currentIdx: Int) -> String {
        let nextIdx = (currentIdx + 1) % recommends.count
        let recommend = recommends[nextIdx]
        return recommend
    }
}

extension ChartViewReactor {
    // 월간 연간 선택을 파라미터로 받아 그때그때 xaxis 처리 (월간일 경우 한달동안 날짜 , 연간일 경우는 매달 )
   
    
    
    // 누락된 날짜에 대해 더미 데이터를 생성하는 함수
    func fillMissingMonthData(dates: [String], data: [Double]) -> ([String], [Double]) {
        var filledDates: [String] = []
        var filledData: [Double] = []
        
        for day in 1...30 {
            if let dateIndex = dates.firstIndex(of: "\(day)일") {
                filledDates.append("\(day)일")
                filledData.append(data[dateIndex])
            } else {
                // 누락된 날짜에 대해 더미 데이터를 생성 (예: 0으로 설정)
                filledDates.append("\(day)일")
                filledData.append(0.0)
            }
        }
        
        return (filledDates, filledData)
    }
    
    
    func fillMissingYearData(dates: [String], data: [Double]) -> ([String], [Double]) {
        var filledDates: [String] = []
        var filledData: [Double] = []
        
        for day in 1...30 {
            if let dateIndex = dates.firstIndex(of: "\(day)일") {
                filledDates.append("\(day)일")
                filledData.append(data[dateIndex])
            } else {
                // 누락된 날짜에 대해 더미 데이터를 생성 (예: 0으로 설정)
                filledDates.append("\(day)일")
                filledData.append(0.0)
            }
        }
        
        return (filledDates, filledData)
    }
    
    
}


enum ChartState {
    case year
    case month
}
